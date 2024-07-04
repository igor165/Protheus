#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA200.CH"
#Include "FWEDITPANEL.ch"

//Constantes para uso no array saCargos
#DEFINE IND_ACARGO_PAI        1
#DEFINE IND_ACARGO_COMP       2
#DEFINE IND_ACARGO_TRT        3
#DEFINE IND_ACARGO_CARGO_COMP 4
#DEFINE IND_ACARGO_CARGO_PAI  5
#DEFINE IND_ACARGO_PROMPT     6
#DEFINE IND_ACARGO_IMGVALIDO  7
#DEFINE IND_ACARGO_IND        8

//Constantes para uso no CARGO da tree
#DEFINE IND_ESTR "ESTR"
#DEFINE IND_TEMP "TEMP"

//Para reinicializar os valores das variáveis Static, utilizar a função P200IniStc
Static snSeqTree    := 0
Static scRevisao    := NIL
Static scRevTree    := ""
Static soDbTree     := NIL
Static soModelAux 	:= NIL
Static slConfList 	:= .F.
Static soMenu	    := NIL
Static saTreeLoad   := {}
Static saCargos     := {}
Static soCargosPai
Static soCargosCmp
Static slAltRev     := NIL
Static slAltPai     := NIL
Static slExecChL    := NIL
Static slTmpTree    := .T.
Static slChanging   := .F.
Static slMontando	:= .F.
Static scPicQuant   := GetSx3Cache("G1_QUANT","X3_PICTURE")
Static snDecQuant   := GetSx3Cache("G1_QUANT","X3_DECIMAL")
Static snTamCodPr   := GetSx3Cache("G1_COMP" ,"X3_TAMANHO")
Static slValQtde    := .F.
Static slReabre		:= .F.
Static slDIf	    := .F.
Static slExpCopia 	:= .F.
Static slOpcAltRv 	:= .T.
Static slSelecOPC
Static snPadMaxCmp  := 999999	//Quantidade maxima padrao para exibicao de componentes na Tree - Otimizacao de desempenho
Static scPergunte   := ""

Static soRevPE      := NIL
Static slA200RVPI   := ExistBlock("A200RVPI")
Static slM200CPTX   := ExistBlock("M200CPTX")
Static slM200NIV    := ExistBlock("M200NIV")
Static slP200ADBUT  := ExistBlock("P200ADBUT")
Static slP200BLQOP  := ExistBlock("P200BLQOP")
Static slP200PRD    := ExistBlock("PA200PRD")
Static slP200EXTR   := ExistBlock("P200EXTR")
Static slPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

Static slForcaPes   := .F.

Static slGIEstoq    := Nil

/*/{Protheus.doc} PCPA200
Programa de manutenção de estruturas (SG1)

@author Lucas Konrad França
@since 05/11/2018
@version 1.0
@param xAutoCab  , array   , Array com as informações do produto pai, utilizado para rotina automática.
@param xAutoItens, array   , Array com as informações dos componentes, utilizado para rotina automática.
@param nOpcAuto  , numeric , Opção a ser executada na rotina automática (3-Inclusão, 4-Alteração, 5-Exclusão).
@param cFuncao   , caracter, Nome da função chamadora (opcional).
@return Nil
/*/
Function PCPA200(xAutoCab, xAutoItens, nOpcAuto, cFuncao)
	Local aArea      := GetArea()
	Local oBrowse
	Local lCalcNivel := NIL
	Local l200Auto   := .F.
	Local cFiltro := ""

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		If GetRpoRelease() < "12.1.017"
			HELP(' ',1,"Help" ,,STR0140,2,0,,,,,,) //"Rotina não disponível nesta release."
			Return
		EndIf
	EndIf

	If xAutoCab <> Nil
		l200Auto := .T.
		nPos :=	aScan(xAutoCab,{|x| x[1] == "NIVALT"})
		If ( nPos > 0 .and. xAutoCab[nPos,2] == "S" )
			lCalcNivel	:= .T.
		Else
			lCalcNivel	:= .F.
		EndIf

		ExecutAuto(xAutoCab, xAutoItens, nOpcAuto, cFuncao)
	Else
		oBrowse := BrowseDef()

		If ExistBlock("PCP200FIL")
			cFiltro := ExecBlock("PCP200FIL", .F., .F.)

			If ValType(cFiltro) == "C"
				oBrowse:SetFilterDefault(cFiltro)
			EndIf
		EndIf

		oBrowse:Activate()
	EndIf

	// Recalcula os Niveis
	If GetMv('MV_NIVALT') == 'S' .And. If(ExistBlock("MA200CNI"),ExecBlock("MA200CNI",.F.,.F.),.T.)

		MA320Nivel(Nil,lCalcNivel,!l200Auto)

		// PE no final da rotina de Recalculo dos Niveis
		If ExistBlock("MA200FNI")
			ExecBlock("MA200FNI",.F.,.F.)
		EndIf
	Endif

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} BrowseDef
Função para definição do browse padrão

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@return oBrowse - Objeto do tipo FWMBrowse.
/*/
Static Function BrowseDef()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SG1")
	oBrowse:SetDescription(STR0001) //"Manutenção de estruturas"
	oBrowse:SetAttach( .T. )
	oBrowse:SetOpenChart( .F. ) //Define se o gráfico virá aberto ou oculto no carregamento do browse
	oBrowse:SetTotalDefault('G1_FILIAL','COUNT',STR0200) //'Total de Registros'
	oBrowse:SetParam({ || P200Pergun() })

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu do cadastro de estruturas (SG1)

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@return aRotina (vetor com botoes da EnchoiceBar)
/*/
Static Function MenuDef()
	Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "PCPA200MNU(2)" OPERATION OP_VISUALIZAR ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "PCPA200MNU(3)" OPERATION OP_INCLUIR    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "PCPA200MNU(4)" OPERATION OP_VISUALIZAR ACCESS 13 //"Alterar" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0005 ACTION "PCPA200MNU(5)" OPERATION OP_VISUALIZAR ACCESS 14 //"Excluir" - OP_EXCLUIR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0079 ACTION 'A200CEstN()'   OPERATION OP_VISUALIZAR ACCESS 0 //"Comparar"
	ADD OPTION aRotina TITLE STR0131 ACTION 'A200Subst()'   OPERATION OP_VISUALIZAR ACCESS 0 //"Substituir" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0164 ACTION 'A200Copia()' 	OPERATION OP_VISUALIZAR ACCESS 0 //"Estrutura Similar" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0181 ACTION 'P200Oper()'    OPERATION OP_VISUALIZAR ACCESS 0 //"Operações x Componente" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0243 ACTION 'P200MapDiv()'  OPERATION OP_VISUALIZAR ACCESS 0 //"Mapa de Divergências" - OP_VISUALIZAR (Nao realiza lock da FwMBrowse)

	//Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("PCP200MNU")
		ExecBlock("PCP200MNU",.F.,.F.)
	EndIf

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo do cadastro de estruturas (SG1)

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@return oModel - Modelo de dados da tabela SG1
/*/
Static Function ModelDef()
	Local oModel
	Local oStruPai 	:= FWFormStruct(1,"SG1",{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|G1_COD|"})
	Local oStruCmp 	:= FWFormStruct(1,"SG1",{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|G1_COD|"})
	Local oStruDet 	:= FWFormStruct(1,"SG1",{|cCampo| ! "|"+AllTrim(cCampo)+"|" $ "|G1_USERLGA|G1_USERLGI|"})
	Local oStruSMW	:= FWFormStruct(1,"SMW",{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|MW_CODIGO|MW_DESCRI|"})
	Local oStruSVG 	:= FWFormStruct(1,"SVG")
	Local oEvent    := PCPA200EVDEF():New()
	Local oEventPes := PCPA200EVPES():New()

	/*
		Os modelos são definidos como SetOnlyQuery, e o commit dos dados é feito através do modelo do fonte PCPA200Grv.
	*/

	AltFldMdl(@oStruPai,@oStruCmp,@oStruDet,@oStruSMW)

	oModel := MPFormModel():New("PCPA200")
	oModel:SetDescription(STR0006) //"Estrutura de produtos"
	oModel:InstallEvent("PCPA200EVDEF", /*cOwner*/, oEvent)
	oModel:InstallEvent("PCPA200EVPES"  , /*cOwner*/, oEventPes)

	//Modelo MESTRE, para exibir as informações do produto PAI
	oModel:AddFields("SG1_MASTER", /*cOwner*/, oStruPai)
	oModel:GetModel("SG1_MASTER"):SetDescription(STR0007) //"Estrutura - Informações do produto PAI"
	oModel:GetModel("SG1_MASTER"):SetOnlyQuery()

	//Modelo para exibir as informações do componente selecionado
	oModel:AddFields("SG1_COMPON", "SG1_MASTER", oStruCmp)
	oModel:GetModel("SG1_COMPON"):SetDescription(STR0008) //"Estrutura - Informações do componente selecionado"
	oModel:GetModel("SG1_COMPON"):SetOnlyQuery()
	oModel:GetModel("SG1_COMPON"):SetOptional(.T.)

	//Modelo DETALHE, para exibir os dados dos componentes na grid
	oModel:AddGrid("SG1_DETAIL", "SG1_COMPON", oStruDet)
	oModel:GetModel("SG1_DETAIL"):SetDescription(STR0009) //"Estrutura - Informações dos componentes"
	oModel:GetModel("SG1_DETAIL"):SetOnlyQuery()
	oModel:GetModel("SG1_DETAIL"):SetOptional(.T.)
	oModel:GetModel("SG1_DETAIL"):SetUniqueLine({"G1_COMP","G1_TRT","G1_REVINI","G1_REVFIM"})
	oModel:GetModel("SG1_DETAIL"):SetMaxLine(999999)
	oModel:GetModel("SG1_DETAIL"):SetUseOldGrid(.T.)

	//Verifica se existe a tabela de LISTA DE COMPONENTES
	If oStruSMW:HasField("MW_CODIGO")
		//FLD_LISTA - Modelo Mestre da tela de importação de Lista de Componentes
		oModel:AddFields("FLD_LISTA", "SG1_COMPON", oStruSMW, , ,{|| LoadSMW()})
		oModel:GetModel("FLD_LISTA"):SetDescription(STR0123) //"Lista de Componentes (SMW)"
		oModel:GetModel("FLD_LISTA"):SetOptional(.T.)
		oModel:GetModel("FLD_LISTA"):SetOnlyQuery()

		//GRID_LISTA - Modelo Mestre da tela de importação de Lista de Componentes
		oModel:AddGrid("GRID_LISTA", "FLD_LISTA", oStruSVG)
		oModel:GetModel("GRID_LISTA"):SetDescription(STR0124) //"Lista de Componentes (SVG)"
		oModel:GetModel("GRID_LISTA"):SetOptional(.T.)
		oModel:GetModel("GRID_LISTA"):SetOnlyQuery()
	EndIf

	//Realiza carga do Modelo de Pesquisa
	P200PesMod(oModel)

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View do cadastro de estruturas (SG1)

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@return oView - Objeto de View da tabela SG1
/*/
Static Function ViewDef()
	Local aButtons := {}
	Local nIndex   := 0
	Local nTotal   := 0
	Local oModel   := FWLoadModel("PCPA200")
	Local oStruPai := FWFormStruct(2,"SG1",{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|G1_COD|"})
	Local oStruCmp := FWFormStruct(2,"SG1",{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|G1_COD|"})
	Local oStruDet := FWFormStruct(2,"SG1",{|cCampo| ! "|"+AllTrim(cCampo)+"|" $ "|G1_COD|G1_USAALT|G1_LOCCONS|"})
	Local oView    := FWFormView():New()

	AltFldView(@oStruPai,@oStruCmp,@oStruDet)

	oView:SetModel(oModel)

	//Adiciona o FIELDS para as informações do produto PAI.
	oView:AddField("VIEW_PAI", oStruPai, "SG1_MASTER")
	oView:EnableTitleView("VIEW_PAI",STR0011) //"Produto"

	//Adiciona o FIELDS para as informações do componente selecionado
	oView:AddField("VIEW_SELECIONADO", oStruCmp, "SG1_COMPON")
	oView:EnableTitleView("VIEW_SELECIONADO",STR0012) //"Componentes"

	//Adiciona a GRID para as informações dos componentes
	oView:AddGrid("VIEW_COMPONENTES",oStruDet,"SG1_DETAIL")

	//Adiciona a TreeView para visualização da estrutura
	oView:AddOtherObject("VIEW_TREE", {|oPanel| MontaTree(oPanel)})
	oView:EnableTitleView("VIEW_TREE",STR0013) //"Estrutura"

	//Cria o BOX para as informações do produto PAI.
	oView:CreateHorizontalBox("SUPERIOR",110,,.T.)

	//Cria o BOX para exibir a tree e os componentes.
	oView:CreateHorizontalBox("INFERIOR",100)

	//Cria o BOX da TREE
	oView:CreateVerticalBox("INFERIOR_TREE",20,"INFERIOR")

	//Cria o BOX para informações dos componentes
	oView:CreateVerticalBox("INFERIOR_COMPONENTES" , 80,"INFERIOR")

	//Cria o BOX para as informações do componente selecionado.
	oView:CreateHorizontalBox("INFERIOR_COMP_SELEC",110,"INFERIOR_COMPONENTES",.T.)

	//Cria o BOX para as informações dos componentes.
	oView:CreateHorizontalBox("INFERIOR_COMP_GRID" ,100,"INFERIOR_COMPONENTES")

	//Relaciona cada BOX com sua view.
	oView:SetOwnerView("VIEW_PAI","SUPERIOR")
	oView:SetOwnerView("VIEW_TREE","INFERIOR_TREE")
	oView:SetOwnerView("VIEW_SELECIONADO","INFERIOR_COMP_SELEC")
	oView:SetOwnerView("VIEW_COMPONENTES","INFERIOR_COMP_GRID")

	oView:SetViewProperty( "VIEW_SELECIONADO", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 4 } )
	oView:SetViewProperty( "VIEW_PAI"        , "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 5 } )

	//Eventos de ativação da View.
	oView:SetViewCanActivate({|oView| beforeView(oView)})
	oView:SetAfterViewActivate({|oView| afterView(oView)})

	oView:SetFieldAction('G1_REVINI', { |oView, cIDView, cField, xValue| P200Refr( oView, cIDView, cField, xValue ) } )
	oView:SetFieldAction('G1_REVFIM', { |oView, cIDView, cField, xValue| P200Refr( oView, cIDView, cField, xValue ) } )

	//Adiciona botões no menu "Outras Ações"
	If slOpcAltRv
		oView:AddUserButton(STR0014, "", {|oView| AltRevisao(oView)}, , , {MODEL_OPERATION_VIEW  , MODEL_OPERATION_UPDATE}, .T.) //"Alterar revisão"
	EndIf
	oView:AddUserButton(STR0114, "", {|oView| ListaComp(oView)} , , , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} ) //"Lista de Componentes"
	oView:AddUserButton(STR0161, "", {|oView| AtalhoTecl("F5")}, , , , .T.) //"Pesquisa [F5]"

	//Habilita barra de progresso para abertura da tela.
	oView:SetProgressBar(.T.)

	//Desabilita o "Salvar e criar novo"
	oView:SetCloseOnOk({||.T.})

	//Desabilita a ordenação da grid.
	oView:SetViewProperty( "*", "GRIDNOORDER")

	If slP200ADBUT
		aButtons := ExecBlock("P200ADBUT", .F., .F.)
		If ValType(aButtons) == "A"
			nTotal := Len(aButtons)
			For nIndex := 1 To nTotal
				oView:AddUserButton(aButtons[nIndex][1], "", aButtons[nIndex][2] , , , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})
			Next nIndex
			FwFreeArray(aButtons)
		EndIf
	EndIf

Return oView

/*/{Protheus.doc} AltFldMdl
Adiciona campos no STRUCT do Model.

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@param oStrMaster	- Estrutura de dados do modelo SG1_MASTER para alterar os campos do Model
@param oStrCmp		- Estrutura de dados do modelo SG1_COMPON para alterar os campos do Model
@param oStrDet		- Estrutura de dados do modelo SG1_DETAIL para alterar os campos do Model
@param oStruSMW     - Estrutura de dados do modelo FLD_LISTA para alterar os campos do Model.
@return Nil
/*/
Static Function AltFldMdl(oStrMaster,oStrCmp,oStrDet,oStruSMW)

	//Adiciona o CARGO para controle da TREE
	AddCargo(@oStrMaster,"CARGO")
	AddCargo(@oStrCmp   ,"CARGO")
	AddCargo(@oStrDet   ,"CARGO")

	/**Alterações do modelo SG1_MASTER */
	oStrMaster:AddField(STR0015									,;	// [01]  C   Titulo do campo //"Revisão"
	                    STR0015									,;	// [02]  C   ToolTip do campo "Revisão"
	                    "CREVPAI"								,;	// [03]  C   Id do Field
	                    "C"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_REVATU","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    FWBuildFeature(STRUCT_FEATURE_INIPAD,"P200IniRev()"),;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(STR0180									,;	// [01]  C   Titulo do campo  //"Revisão Aberta"
	                    STR0180									,;	// [02]  C   ToolTip do campo //"Revisão Aberta"
	                    "CREVABERTA"							,;	// [03]  C   Id do Field
	                    "C"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_REVATU","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL										,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(STR0016									,;	// [01]  C   Titulo do campo  //"Unidade"
	                    STR0016									,;	// [02]  C   ToolTip do campo //"Unidade"
	                    "CUMPAI"								,;	// [03]  C   Id do Field
	                    "C"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_UM","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||IniUm()}								,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(STR0017									,;	// [01]  C   Titulo do campo  //"Quantidade Base"
	                    STR0017									,;	// [02]  C   ToolTip do campo //"Quantidade Base"
	                    "NQTBASE"								,;	// [03]  C   Id do Field
	                    "N"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_QB","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                    GetSx3Cache("B1_QB","X3_DECIMAL")		,;	// [06]  N   Decimal do campo
	                    {||VldBase()}							,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||IniBase()}							,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(STR0018									,;	// [01]  C   Titulo do campo  //"Descrição"
	                    STR0018									,;	// [02]  C   ToolTip do campo //"Descrição"
	                    "CDESCPAI"								,;	// [03]  C   Id do Field
	                    "C"										,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_DESC","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||IniDenProd()}						,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	//Campo para controlar a execução automática.
	oStrMaster:AddField(STR0112									,;	// [01]  C   Titulo do campo  //"Execução"
	                    STR0112									,;	// [02]  C   ToolTip do campo //"Execução"
	                    "CEXECAUTO"								,;	// [03]  C   Id do Field
	                    "C"										,;	// [04]  C   Tipo do campo
	                    1										,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||"N"}									,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	//Parâmetro utilizado quando é execução automática. Identifica
	//se será gerada nova revisão quando utilizar revisão manual.
	oStrMaster:AddField(STR0113									,;	// [01]  C   Titulo do campo  //"Gera Revisão"
	                    STR0113									,;	// [02]  C   ToolTip do campo //"Gera Revisão"
	                    "ATUREVSB1"								,;	// [03]  C   Id do Field
	                    "C"										,;	// [04]  C   Tipo do campo
	                    1										,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||"N"}									,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	//Campo para controlar a execução automática.
	oStrMaster:AddField(STR0162									,;	// [01]  C   Titulo do campo  //"É Pesquisa?"
	                    STR0162									,;	// [02]  C   ToolTip do campo //"É Pesquisa?"
	                    "LPESQUISA"								,;	// [03]  C   Id do Field
	                    "L"										,;	// [04]  C   Tipo do campo
	                    1										,;	// [05]  N   Tamanho do campo
	                    0										,;	// [06]  N   Decimal do campo
	                    {||.T.}									,;	// [07]  B   Code-block de validação do campo
	                    NIL										,;	// [08]  B   Code-block de validação When do campo
	                    NIL										,;	// [09]  A   Lista de valores permitido do campo
	                    .F.										,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||.F.}									,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL										,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual

	//Adiciona gatilhos no modelo.
	oStrMaster:AddTrigger("CREVPAI", "CREVPAI", , {||afterRevis()})
	oStrMaster:AddTrigger("G1_COD" , "G1_COD" , {||VldG1Cod()},{||afterG1Cod()})

	//Altera propriedades dos campos
	oStrMaster:SetProperty("G1_COD", MODEL_FIELD_NOUPD, .T.)
	oStrMaster:SetProperty("G1_COD", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "P200VLDPAI()"))
	oStrMaster:SetProperty("G1_COD", MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN, "P200EDTPAI()"))

	/**Alteração dos campos do modelo SG1_COMPON */
	oStrCmp:AddField(STR0018								,;	// [01]  C   Titulo do campo  //"Descrição"
	                 STR0018								,;	// [02]  C   ToolTip do campo //"Descrição"
	                 "CDESCCMP"								,;	// [03]  C   Id do Field
	                 "C"									,;	// [04]  C   Tipo do campo
	                 GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                 0										,;	// [06]  N   Decimal do campo
	                 NIL									,;	// [07]  B   Code-block de validação do campo
	                 NIL									,;	// [08]  B   Code-block de validação When do campo
	                 NIL									,;	// [09]  A   Lista de valores permitido do campo
	                 .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                 {||IniDenProd()}						,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                 .T.									)	// [14]  L   Indica se o campo é virtual

	oStrCmp:AddField(STR0016								,;	// [01]  C   Titulo do campo  //"Unidade"
	                 STR0016								,;	// [02]  C   ToolTip do campo //"Unidade"
	                 "CUMCMP"								,;	// [03]  C   Id do Field
	                 "C"									,;	// [04]  C   Tipo do campo
	                 GetSx3Cache("B1_UM","X3_TAMANHO")		,;	// [05]  N   Tamanho do campo
	                 0										,;	// [06]  N   Decimal do campo
	                 NIL									,;	// [07]  B   Code-block de validação do campo
	                 NIL									,;	// [08]  B   Code-block de validação When do campo
	                 NIL									,;	// [09]  A   Lista de valores permitido do campo
	                 .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                 {||IniUm()}							,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                 .T.									)	// [14]  L   Indica se o campo é virtual

	oStrCmp:AddField(STR0015								,;	// [01]  C   Titulo do campo  //"Revisão"
	                 STR0015								,;	// [02]  C   ToolTip do campo //"Revisão"
	                 "CREVCOMP"								,;	// [03]  C   Id do Field
	                 "C"									,;	// [04]  C   Tipo do campo
	                 GetSx3Cache("B1_REVATU","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                 0										,;	// [06]  N   Decimal do campo
	                 NIL									,;	// [07]  B   Code-block de validação do campo
	                 NIL									,;	// [08]  B   Code-block de validação When do campo
	                 NIL									,;	// [09]  A   Lista de valores permitido do campo
	                 .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                 {||P200IniRev()}						,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                 .T.									)	// [14]  L   Indica se o campo é virtual

	oStrCmp:SetProperty("G1_COD", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".F."))

	/**Alteração dos campos do modelo SG1_DETAIL */
	//Campo para guardar o RECNO quando é realizado o LOAD da grid.
	oStrDet:AddField(STR0019	,;	// [01]  C   Titulo do campo  //"Registro"
	                 STR0019	,;	// [02]  C   ToolTip do campo //"Registro"
	                 "NREG"		,;	// [03]  C   Id do Field
	                 "N"		,;	// [04]  C   Tipo do campo
	                 10			,;	// [05]  N   Tamanho do campo
	                 0			,;	// [06]  N   Decimal do campo
	                 NIL		,;	// [07]  B   Code-block de validação do campo
	                 NIL		,;	// [08]  B   Code-block de validação When do campo
	                 NIL		,;	// [09]  A   Lista de valores permitido do campo
	                 .F.		,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                 NIL		,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL		,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL		,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                 .T.		)	// [14]  L   Indica se o campo é virtual

	//Campo para guardar a sequência original do componente (G1_TRT). Utilizado em validações.
	oStrDet:AddField(STR0045							,;	// [01]  C   Titulo do campo  //"Seq. original"
	                 STR0045							,;	// [02]  C   ToolTip do campo //"Seq. original"
	                 "CSEQORIG"							,;	// [03]  C   Id do Field
	                 "C"								,;	// [04]  C   Tipo do campo
	                 GetSx3Cache("G1_TRT","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                 0									,;	// [06]  N   Decimal do campo
	                 NIL								,;	// [07]  B   Code-block de validação do campo
	                 NIL								,;	// [08]  B   Code-block de validação When do campo
	                 NIL								,;	// [09]  A   Lista de valores permitido do campo
	                 .F.								,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                 NIL								,;	// [11]  B   Code-block de inicializacao do campo
	                 NIL								,;	// [12]  L   Indica se trata-se de um campo chave
	                 NIL								,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                 .T.								)	// [14]  L   Indica se o campo é virtual

	If !oStrDet:HasField("G1_LISTA")
		oStrDet:AddField(STR0114   ,;	// [01]  C   Titulo do campo  //"Lista de Componentes"
						 STR0114   ,;	// [02]  C   ToolTip do campo //"Lista de Componentes"
						 "G1_LISTA",;	// [03]  C   Id do Field
						 "C"       ,;	// [04]  C   Tipo do campo
						 10        ,;	// [05]  N   Tamanho do campo
						 0         ,;	// [06]  N   Decimal do campo
						 NIL       ,;	// [07]  B   Code-block de validação do campo
						 NIL       ,;	// [08]  B   Code-block de validação When do campo
						 NIL       ,;	// [09]  A   Lista de valores permitido do campo
						 .F.       ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
						 NIL       ,;	// [11]  B   Code-block de inicializacao do campo
						 NIL       ,;	// [12]  L   Indica se trata-se de um campo chave
						 NIL       ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						 .T.       )	// [14]  L   Indica se o campo é virtual
	EndIf

	oStrDet:SetProperty("G1_COMP"   , MODEL_FIELD_NOUPD, .T.)

	oStrDet:SetProperty("G1_REVINI" , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN  , "P200EDTREV()"))
	oStrDet:SetProperty("G1_REVFIM" , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN  , "P200EDTREV()"))
	oStrDet:SetProperty("G1_LISTA"  , MODEL_FIELD_WHEN , FWBuildFeature(STRUCT_FEATURE_WHEN  , ".F."))

	oStrDet:SetProperty("G1_DESC"   , MODEL_FIELD_INIT,  FWBuildFeature(STRUCT_FEATURE_INIPAD, " "))

	oStrDet:SetProperty("G1_COMP"   , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "ExistCpo('SB1') .And. P200ValCpo('G1_COMP')"))
	oStrDet:SetProperty("G1_TRT"    , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_TRT')"))
	oStrDet:SetProperty("G1_QUANT"  , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "NaoVazio() .And. P200ValCpo('G1_QUANT')"))
	oStrDet:SetProperty("G1_FIM"    , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "NaoVazio() .And. P200ValCpo('G1_FIM')"))
	oStrDet:SetProperty("G1_INI"    , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "NaoVazio() .And. P200ValCpo('G1_INI')"))
	oStrDet:SetProperty("G1_GROPC"  , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_GROPC')"))
	oStrDet:SetProperty("G1_OPC"    , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_OPC')"))
	oStrDet:SetProperty("G1_REVINI",  MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_REVINI')"))
	oStrDet:SetProperty("G1_REVFIM",  MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_REVFIM')"))
	oStrDet:SetProperty("G1_POTENCI", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_POTENCI')"))
	oStrDet:SetProperty("G1_TIPVEC" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_TIPVEC')"))
	oStrDet:SetProperty("G1_VECTOR" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , "P200ValCpo('G1_VECTOR')"))

	If oStruSMW:HasField("MW_CODIGO")
		oStruSMW:SetProperty("MW_CODIGO" , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P200VldLis()"))
		oStruSMW:SetProperty("MW_CODIGO" , MODEL_FIELD_OBRIGAT, .F.)
		oStruSMW:SetProperty("MW_DESCRI" , MODEL_FIELD_OBRIGAT, .F.)
	EndIf

	If ExistBlock("PCA200MD")
		ExecBlock("PCA200MD",.F.,.F.,{"MODEL",@oStrMaster,@oStrCmp,@oStrDet})
	EndIf

Return Nil

/*/{Protheus.doc} AltFldView
Adiciona campos no STRUCT da view.

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@param oStrMaster	- Estrutura de dados do modelo SG1_MASTER para alterar os campos da View
@param oStrCmp		- Estrutura de dados do modelo SG1_COMPON para alterar os campos da View
@param oStrDet		- Estrutura de dados do modelo SG1_DETAIL para alterar os campos da View
@return Nil
/*/
Static Function AltFldView(oStrMaster,oStrCmp,oStrDet)
	Local cOrdem := ""
	Local aResolucao

	/**Altera os fields do modelo SG1_MASTER */
	cOrdem := oStrMaster:GetProperty("G1_COD",MVC_VIEW_ORDEM)
	cOrdem := Soma1(cOrdem)
	oStrMaster:AddField("CDESCPAI"						,;	// [01]  C   Nome do Campo
	                    cOrdem							,;	// [02]  C   Ordem
	                    STR0018							,;	// [03]  C   Titulo do campo    //"Descrição"
	                    STR0018							,;	// [04]  C   Descricao do campo //"Descrição"
	                    NIL								,;	// [05]  A   Array com Help
	                    "C"								,;	// [06]  C   Tipo do campo
	                    "@S30"							,;	// [07]  C   Picture
	                    NIL								,;	// [08]  B   Bloco de Picture Var
	                    NIL								,;	// [09]  C   Consulta F3
	                    .F.								,;	// [10]  L   Indica se o campo é alteravel
	                    NIL								,;	// [11]  C   Pasta do campo
	                    NIL								,;	// [12]  C   Agrupamento do campo
	                    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL								,;	// [15]  C   Inicializador de Browse
	                    .T.								,;	// [16]  L   Indica se o campo é virtual
	                    NIL								,;	// [17]  C   Picture Variavel
	                    NIL								)	// [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1(cOrdem)
	oStrMaster:AddField("CUMPAI"						,;	// [01]  C   Nome do Campo
	                    cOrdem							,;	// [02]  C   Ordem
	                    STR0016							,;	// [03]  C   Titulo do campo    //"Unidade"
	                    STR0016							,;	// [04]  C   Descricao do campo //"Unidade"
	                    NIL								,;	// [05]  A   Array com Help
	                    "C"								,;	// [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_UM'	)		,;	// [07]  C   Picture
	                    NIL								,;	// [08]  B   Bloco de Picture Var
	                    NIL								,;	// [09]  C   Consulta F3
	                    .F.								,;	// [10]  L   Indica se o campo é alteravel
	                    NIL								,;	// [11]  C   Pasta do campo
	                    NIL								,;	// [12]  C   Agrupamento do campo
	                    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL								,;	// [15]  C   Inicializador de Browse
	                    .T.								,;	// [16]  L   Indica se o campo é virtual
	                    NIL								,;	// [17]  C   Picture Variavel
	                    NIL								)	// [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1(cOrdem)

	oStrMaster:AddField("NQTBASE"						,;	// [01]  C   Nome do Campo
	                    cOrdem							,;	// [02]  C   Ordem
	                    STR0017							,;	// [03]  C   Titulo do campo    //"Quantidade base"
	                    STR0017							,;	// [04]  C   Descricao do campo //"Quantidade base"
	                    NIL								,;	// [05]  A   Array com Help
	                    "N"								,;	// [06]  C   Tipo do campo
	                    AllTrim(GetSX3Cache("B1_QB", "X3_PICTURE")),;	// [07]  C   Picture
	                    NIL								,;	// [08]  B   Bloco de Picture Var
	                    NIL								,;	// [09]  C   Consulta F3
	                    .T.								,;	// [10]  L   Indica se o campo é alteravel
	                    NIL								,;	// [11]  C   Pasta do campo
	                    NIL								,;	// [12]  C   Agrupamento do campo
	                    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL								,;	// [15]  C   Inicializador de Browse
	                    .T.								,;	// [16]  L   Indica se o campo é virtual
	                    NIL								,;	// [17]  C   Picture Variavel
	                    NIL								)	// [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1(cOrdem)
	oStrMaster:AddField("CREVPAI"						,;	// [01]  C   Nome do Campo
	                    cOrdem							,;	// [02]  C   Ordem
	                    STR0015							,;	// [03]  C   Titulo do campo    //"Revisão"
	                    STR0015							,;	// [04]  C   Descricao do campo //"Revisão"
	                    NIL								,;	// [05]  A   Array com Help
	                    "C"								,;	// [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_REVATU')		,;	// [07]  C   Picture
	                    NIL								,;	// [08]  B   Bloco de Picture Var
	                    NIL								,;	// [09]  C   Consulta F3
	                    .F.								,;	// [10]  L   Indica se o campo é alteravel
	                    NIL								,;	// [11]  C   Pasta do campo
	                    NIL								,;	// [12]  C   Agrupamento do campo
	                    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL								,;	// [15]  C   Inicializador de Browse
	                    .T.								,;	// [16]  L   Indica se o campo é virtual
	                    NIL								,;	// [17]  C   Picture Variavel
	                    NIL								)	// [18]  L   Indica pulo de linha após o campo

	/**Altera os fields do modelo SG1_COMPON */
	cOrdem := oStrCmp:GetProperty("G1_COD",MVC_VIEW_ORDEM)
	cOrdem := Soma1(cOrdem)
	oStrCmp:AddField("CDESCCMP"							,;	// [01]  C   Nome do Campo
	                  cOrdem							,;	// [02]  C   Ordem
	                  STR0018							,;	// [03]  C   Titulo do campo    //"Descrição"
	                  STR0018							,;	// [04]  C   Descricao do campo //"Descrição"
	                  NIL								,;	// [05]  A   Array com Help
	                  "C"								,;	// [06]  C   Tipo do campo
	                  "@S15"							,;	// [07]  C   Picture
	                  NIL								,;	// [08]  B   Bloco de Picture Var
	                  NIL								,;	// [09]  C   Consulta F3
	                  .F.								,;	// [10]  L   Indica se o campo é alteravel
	                  NIL								,;	// [11]  C   Pasta do campo
	                  NIL								,;	// [12]  C   Agrupamento do campo
	                  NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                  NIL								,;	// [15]  C   Inicializador de Browse
	                  .T.								,;	// [16]  L   Indica se o campo é virtual
	                  NIL								,;	// [17]  C   Picture Variavel
	                  NIL								)	// [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1(cOrdem)
	oStrCmp:AddField("CUMCMP"							,;	// [01]  C   Nome do Campo
	                  cOrdem							,;	// [02]  C   Ordem
	                  STR0016							,;	// [03]  C   Titulo do campo    //"Unidade"
	                  STR0016							,;	// [04]  C   Descricao do campo //"Unidade"
	                  NIL								,;	// [05]  A   Array com Help
	                  "C"								,;	// [06]  C   Tipo do campo
	                  PesqPict('SB1','B1_UM')			,;	// [07]  C   Picture
	                  NIL								,;	// [08]  B   Bloco de Picture Var
	                  NIL								,;	// [09]  C   Consulta F3
	                  .F.								,;	// [10]  L   Indica se o campo é alteravel
	                  NIL								,;	// [11]  C   Pasta do campo
	                  NIL								,;	// [12]  C   Agrupamento do campo
	                  NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                  NIL								,;	// [15]  C   Inicializador de Browse
	                  .T.								,;	// [16]  L   Indica se o campo é virtual
	                  NIL								,;	// [17]  C   Picture Variavel
	                  NIL								)	// [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1(cOrdem)
	oStrCmp:AddField("CREVCOMP"							,;	// [01]  C   Nome do Campo
	                  cOrdem							,;	// [02]  C   Ordem
	                  STR0015							,;	// [03]  C   Titulo do campo    //"Revisão"
	                  STR0015							,;	// [04]  C   Descricao do campo //"Revisão"
	                  NIL								,;	// [05]  A   Array com Help
	                  "C"								,;	// [06]  C   Tipo do campo
	                  PesqPict('SB1','B1_REVATU')		,;	// [07]  C   Picture
	                  NIL								,;	// [08]  B   Bloco de Picture Var
	                  NIL								,;	// [09]  C   Consulta F3
	                  .F.								,;	// [10]  L   Indica se o campo é alteravel
	                  NIL								,;	// [11]  C   Pasta do campo
	                  NIL								,;	// [12]  C   Agrupamento do campo
	                  NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                  NIL								,;	// [15]  C   Inicializador de Browse
	                  .T.								,;	// [16]  L   Indica se o campo é virtual
	                  NIL								,;	// [17]  C   Picture Variavel
	                  NIL								)	// [18]  L   Indica pulo de linha após o campo

	/**Altera os fields do modelo SG1_DETAIL */
	If oStrDet:HasField("G1_FILIAL")
		oStrDet:RemoveField("G1_FILIAL")
	EndIf
	If oStrDet:HasField("G1_COD")
		oStrDet:RemoveField("G1_COD")
	EndIf
	If oStrDet:HasField("G1_NIV")
		oStrDet:RemoveField("G1_NIV")
	EndIf
	If oStrDet:HasField("G1_NIVINV")
		oStrDet:RemoveField("G1_NIVINV")
	EndIf
	If oStrDet:HasField("G1_OK")
		oStrDet:RemoveField("G1_OK")
	EndIf

	/**Força a largura dos campos quando está fora do padrão*/
	aResolucao := getScreenRes()
	If GetSx3Cache("G1_COD", "X3_TAMANHO") > 15
		If aResolucao[1] > 1200
			oStrMaster:SetProperty("G1_COD", MVC_VIEW_PICT, "@!S15")
			oStrCmp:SetProperty("G1_COD",    MVC_VIEW_PICT, "@S15")
		ElseIf aResolucao[1] > 1010
			oStrMaster:SetProperty("G1_COD", MVC_VIEW_PICT, "@!S13")
			oStrCmp:SetProperty("G1_COD",    MVC_VIEW_PICT, "@S13")
		Else
			oStrMaster:SetProperty("G1_COD", MVC_VIEW_PICT, "@!S10")
			oStrCmp:SetProperty("G1_COD",    MVC_VIEW_PICT, "@S10")
		EndIf
	EndIf
	If GetSx3Cache("B1_DESC", "X3_TAMANHO") > 30
		If aResolucao[1] > 1200
			oStrMaster:SetProperty("CDESCPAI", MVC_VIEW_PICT, "@S40")
			oStrCmp:SetProperty("CDESCCMP",    MVC_VIEW_PICT, "@S35")
		ElseIf aResolucao[1] > 1010
			oStrMaster:SetProperty("CDESCPAI", MVC_VIEW_PICT, "@S25")
			oStrCmp:SetProperty("CDESCCMP",    MVC_VIEW_PICT, "@S20")
		Else
			oStrMaster:SetProperty("CDESCPAI", MVC_VIEW_PICT, "@S14")
			oStrCmp:SetProperty("CDESCCMP",    MVC_VIEW_PICT, "@S12")
		EndIf
	EndIf
	If GetSx3Cache("G1_COMP", "X3_TAMANHO") > 15
		oStrDet:SetProperty("G1_COMP", MVC_VIEW_WIDTH, 200)
	EndIf
	If GetSx3Cache("G1_DESC", "X3_TAMANHO") > 30
		oStrDet:SetProperty("G1_DESC", MVC_VIEW_WIDTH, 250)
	EndIf

	If ExistBlock("PCA200MD")
		ExecBlock("PCA200MD",.F.,.F.,{"VIEW",@oStrMaster,@oStrCmp,@oStrDet,cOrdem})
	EndIf

Return Nil

/*/{Protheus.doc} AddCargo
Adiciona o campo CARGO na estrutura do modelo

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param oStru	- Estrutura a ser adicionada o campo CARGO
@param cID  	- Identificador para o campo cargo
@return NIL
/*/
Static Function AddCargo(oStru, cID)
	oStru:AddField(STR0044		,; // [01]  C   Titulo do campo  - "CARGO"
	               STR0044		,; // [02]  C   ToolTip do campo - "CARGO"
	               cID			,; // [03]  C   Id do Field
	               "C"			,; // [04]  C   Tipo do campo
	               getTmCargo()	,; // [05]  N   Tamanho do campo
	               0			,; // [06]  N   Decimal do campo
	               NIL			,; // [07]  B   Code-block de validação do campo
	               NIL			,; // [08]  B   Code-block de validação When do campo
	               NIL			,; // [09]  A   Lista de valores permitido do campo
	               .F.			,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	               NIL			,; // [11]  B   Code-block de inicializacao do campo
	               NIL			,; // [12]  L   Indica se trata-se de um campo chave
	               .T.			,; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	               .T.			)  // [14]  L   Indica se o campo é virtual
	oStru:SetProperty(cID, MODEL_FIELD_NOUPD, .F.)
Return

/*/{Protheus.doc} MontaTree
Função responsável por fazer a criação do objeto da TREE.

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@param oPanel   - Objeto do tipo PANEL onde a tree será criada.
@return Nil
/*/
Static Function MontaTree(oPanel)

	//Inicializa as variáveis do tipo Static deste fonte.
	P200IniStc()

	//Cria ou Reseta a Tree
	If soDbTree == Nil
		soDbTree := DbTree():New(0, 0, 100, 100, oPanel, {|| P200TreeCh(.T.)}, /*bRClick*/, .T.)
		soDbTree:Align := CONTROL_ALIGN_ALLCLIENT

		P200MenDir()		//Cria opções de menu com botão direito
	Else
		soDbTree:Reset()
	EndIf

Return Nil

/*/{Protheus.doc} P200MenDir
Cria de menu de contexto (botão direito) e atribuição de ações

@author brunno.costa
@since 27/11/2018
@version 1.0

@return Nil
/*/
Static Function P200MenDir()

	//Criacao do Menu PopUp com as opcoes para a criacao da arvore
	//de perguntas e respostas.
	MENU soMenu POPUP OF oMainWnd

	MENUITEM STR0049 ACTION Expandir(soDbTree:GetCargo())	//"Expandir"
	MENUITEM STR0050 ACTION Recolher(soDbTree:GetCargo())	//"Recolher"

	ENDMENU

	//Criacao da arvore de perguntas e respostas.
	//Ao clicar com o botao direito sera exibido o menu popup.
	soDbTree:bRClicked := {|o,x,y| soDbTree:Refresh(), (MostraMenu(soMenu, x, y, @soDbTree)) } // Posicao x,y em relacao a Dialog
	soDbTree:cToolTip  := STR0048	//STR0048 "Utilize o botão direito do mouse para expandir ou recolher todos os sub-níveis."

Return

/*/{Protheus.doc} MostraMenu
Exibe menu contexto da Tree (botão direito)

@author brunno.costa
@since 27/11/2018
@version P12

@return Nil
@param oMenu, object, objeto oMenu
@param nCoorX, numeric, coordenada X
@param nCoorY, numeric, coordenada Y
@param oArea, object, objeto oDbTree passado por referência
@type Function
/*/

Static Function MostraMenu( oMenu, nCoorX, nCoorY, oArea)

	oMenu:Activate( nCoorX, nCoorY)

Return Nil

/*/{Protheus.doc} Expandir
Executa ação Expandir do menu de contexto

@author brunno.costa
@since 27/11/2018
@version 1.0

@param cCargoPai, caracter, código cCargoPai a ser expandido
@return Nil
/*/
Static Function Expandir(cCargoPai)

	Local oModel    := FWModelActive()
	Local oEvent    := gtMdlEvent(oModel, "PCPA200EVDEF")
	Local oProcess

	Default cCargoPai	:= soDbTree:GetCargo()

	//Forca carga do nivel por completo
	oEvent:lMostrandoTodos := .T.
	P200TreeCh(.T., , .T.)
	oEvent:lMostrandoTodos := .F.

	//Processa a expansao
	oEvent:lExpandindo := .T.
	oProcess := MSNewProcess():New( { | lEnd | oProcess:SetRegua2( 0 ), ExpandirL(cCargoPai, 1, @lEnd, @oProcess) }, STR0053, STR0054, .T. )	//"Aguarde..." - "Expandindo os registros"
	oProcess:Activate()
	oEvent:lExpandindo := .F.

	//Posiciona no produto pai da expansao
	slTmpTree := .T.
	soDbTree:TreeSeek(cCargoPai)
	P200TreeCh(.F.)

Return

/*/{Protheus.doc} ExpandirL
Trecho Loop da Ação Expandir do Menu de Contexto

@author brunno.costa
@since 27/11/2018
@version 1.0

@param cCargoPai	, caracter	, código cCargoPai a ser expandido
@param nRecursiva	, numerico	, contator de chamadas recursivas
@param lEnd			, lógico	, variável recebida por referência utilizada no cancelamentoda expansão
@param oProcess		, objeto	, objeto barra de processamento
@param nRegistros	, numérico	, contador de registros avaliados
@param nEstruturas	, numérico	, contador de estruturas avaliadas
@return Nil
/*/
Static Function ExpandirL(cCargoPai, nRecursiva, lEnd, oProcess, nRegistros, nEstruturas)

	Local aCargosCmp := Iif(soCargosPai[cCargoPai] == Nil, {}, soCargosPai[cCargoPai]:GetNames())
	Local cCargo     := ""
	Local oModel     := FwModelActive()
	Local oMdlDet    := oModel:GetModel("SG1_DETAIL")
	Local nPos       := 1
	Local nTotal     := Len(aCargosCmp)

	Default cCargoPai	:= soDbTree:GetCargo()
	Default nRecursiva	:= 1
	Default nRegistros	:= 0
	Default nEstruturas	:= 0

	If nTotal > 0
		nEstruturas++
		oProcess:SetRegua1( oMdlDet:Length() )
		For nPos := 1 to nTotal
			nRegistros++
			cCargo	 := aCargosCmp[nPos]
			oProcess:IncRegua1(STR0055 + AllTrim(P200RetInf(cCargo,"PAI")) + " (" + cValToChar(nEstruturas) + STR0057 + ")" )	//"Estrutura: " - " estruturas"
			oProcess:IncRegua2(STR0056 + AllTrim(P200RetInf(cCargo,"COMP")) + " (" + cValToChar(nRegistros) + STR0058 + ")" ) //"Checando: " - " registros"
			If ExistEstru(P200RetInf(cCargo,"COMP"),.F.)
				If soDbTree:TreeSeek(cCargo)
					slTmpTree := .F.
					P200TreeCh(.F.)
					If Mod(nEstruturas, 10) == 0//A Cada 10 estruturas, aguarda 0,5 segundos para funcionar botão cancelar
						Sleep(500)
					EndIf
					ExpandirL(cCargo, nRecursiva + 1, @lEnd, @oProcess, @nRegistros, @nEstruturas)
				EndIf
			EndIf

			If Mod(nRegistros, 500) == 0	//A Cada 500 registros, aguarda 0,5 segundos para funcionar botão cancelar
				Sleep(500)
			EndIf
		Next
	EndIf

Return

/*/{Protheus.doc} Recolher
Executa ação Recolher do menu de contexto

@author brunno.costa
@since 27/11/2018
@version 1.0

@param cCargoPai, caracter, código cCargoPai a ser expandido
@return Nil
/*/
Static Function Recolher(cCargoPai)

	Local oProcess

	Default cCargoPai	:= soDbTree:GetCargo()

	//Processa recolhimento
	oProcess := MSNewProcess():New( { | lEnd | oProcess:SetRegua2( 0 ), RecolherP(cCargoPai, @lEnd, @oProcess) }, STR0053, STR0059, .T. )	//"Aguarde..." - "Recolhendo os registros"
	oProcess:Activate()

	//Posiciona no produto pai do recolhimento
	slTmpTree := .T.
	soDbTree:TreeSeek(cCargoPai)
	P200TreeCh(.F.)

Return

/*/{Protheus.doc} RecolherP
Processamento da Ação Recolher do Menu de Contexto

@author brunno.costa
@since 27/11/2018
@version 1.0

@param cCargoPai	, caracter	, código cCargoPai a ser expandido
@param lEnd			, lógico	, variável recebida por referência utilizada no cancelamentoda expansão
@param oProcess		, objeto	, objeto barra de processamento
@return Nil
/*/
Static Function RecolherP(cCargoPai, lEnd, oProcess)

	Local aCargosCmp
	Local cCargo      := ""
	Local oModel      := FwModelActive()
	Local oMdlDet     := oModel:GetModel("SG1_DETAIL")
	Local nEstruturas := 0
	Local nIndAux     := 0
	Local nPos        := 1
	Local nRegistros  := 0
	Local nTotal

	Default cCargoPai	:= soDbTree:GetCargo()

	aCargosCmp  := Iif(soCargosPai[cCargoPai] == Nil, {}, soCargosPai[cCargoPai]:GetNames())
	nTotal      := Len(aCargosCmp)

	If nTotal > 0
		nEstruturas++
		oProcess:SetRegua1( oMdlDet:Length() )
		For nPos := 1 to nTotal
			nRegistros++
			cCargo	:= aCargosCmp[nPos]
			nIndAux := soCargosPai[cCargoPai][cCargo]
			If nIndAux > 0
				oProcess:IncRegua1(STR0055 + AllTrim(P200RetInf(cCargo,"PAI")) + " (" + cValToChar(nEstruturas) + STR0057 + ")" )	//"Estrutura: " - " estruturas"
				oProcess:IncRegua2(STR0060 + AllTrim(P200RetInf(cCargo,"COMP")) + " (" + cValToChar(nRegistros) + STR0058 + ")" )	//"Recolhendo: " - " registros"
				If soDbTree:TreeSeek(cCargo)
					soDbTree:PTCollapse()
				EndIf
			EndIf
		Next
	EndIf

Return

/*/{Protheus.doc} beforeView
Função executada antes ativar a view. Utilizado para atualizar a Revisão

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param oView	- Objeto da View.
@return lRet	- Identifica se a View será aberta.
/*/
Static Function beforeView(oView)

	Local oModel := oView:GetModel():GetModel("SG1_MASTER")
	Local lRet   := .T.

	If !slForcaPes .And. IsInCallStack("ButtonOkAction")
		Return lRet
	EndIf

	P200IniStc()

	//Se o modelo já estiver carregado (ExecView), não questiona a revisão
	If oModel:IsEmpty() .OR. !oModel:IsActive()
		If oView:GetOperation() == MODEL_OPERATION_UPDATE .Or. oView:GetOperation() == MODEL_OPERATION_VIEW
			lRet := getRevisao(.T., , oView:GetModel() )
		EndIf
	Else
		scRevisao := oModel:GetValue("CREVABERTA")
	EndIf

Return lRet

/*/{Protheus.doc} getRevisao
Solicita ao usuário a revisão de estrutura.

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param lInit	- Identifica se a tela deverá ser aberta com a revisão atual do produto.
@param cProduto	- Código do produto para exibir em tela.
@return lRet	- Identifica se o usuário confirmou.
/*/
Static Function getRevisao(lInit, cProduto, oModel)
	Local lRet     := .T.
	Local cDenPai  := ""
	Local aBackVar := Array(2)
	Local oEvent   := gtMdlEvent(oModel,"PCPA200EVDEF")

	Default cProduto := SG1->G1_COD

	cDenPai := IniDenProd(cProduto)

	If lInit
		//Busca a revisão atual do produto posicionado na SG1.
		scRevisao := P200IniRev(cProduto)
	EndIf

	DEFINE MSDIALOG oDlg FROM 000,000 TO 200,615 TITLE STR0022 PIXEL  //"Informe a revisão"

	//Get para exibir o código do produto.
	TGet():New(35,05,{|u|if(PCount()>0,cProduto:=u,cProduto)},oDlg,;
	           100,15,"@!",/*08*/,/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,{||.F.},.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"cProduto",/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0023,1) //"Produto Pai"

	//Get para exibir a descrição do produto.
	TGet():New(35,105,{|u|if(PCount()>0,cDenPai:=u,cDenPai)},oDlg,;
	           150,15,"@!",/*08*/,/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,{||.F.},.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"cDenPai",/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0018,1) //"Descrição"

	//Get para informar a revisão do produto desejada.
	TGet():New(70,05,{|u|if(PCount()>0,scRevisao:=u,scRevisao)},oDlg,;
	           30,15,PesqPict('SB1','B1_REVATU'),{|| lRet:=.T., oDlg:End() }/*08*/,/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"scRevisao",/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0015,1) //"Revisão"

	/*
		Variáveis INCLUI e ALTERA definidas como .F. neste ponto, para que a função EnchoiceBar crie os botões com as descrições
		corretas (Confirmar/Cancelar) em todos os pontos.
	*/
	aBackVar[1] := Iif(Type("INCLUI")=="L",INCLUI,Nil)
	aBackVar[2] := Iif(Type("ALTERA")=="L",ALTERA,Nil)
	INCLUI := .F.
	ALTERA := .F.

	ACTIVATE MSDIALOG oDlg CENTER ;
		ON INIT (EnchoiceBar(oDlg,{||(lRet:=.T.,oDlg:End())},{||(lRet:=.F.,oDlg:End())},/*lMsgDel*/,/*aButtons*/,/*nRecno*/,/*cAlias*/,.F.,.F.,.F.,.T.,.F.),;
				SetKey( K_CTRL_O, {|| (lRet:=.T., oDlg:End())} ))

	INCLUI := aBackVar[1]
	ALTERA := aBackVar[2]

	If !lRet .And. oEvent <> Nil
		//Remove lock's manuais
		oEvent:UnLock(cProduto)
	EndIf

Return lRet

/*/{Protheus.doc} afterView
Função executada após ativar a view. Utilizado para atualizar a Revisão

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param oView	- Objeto da View.
@return Nil
/*/
Static Function afterView(oView)
	Local oModel    := oView:GetModel()
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")
	Local cCargo    := ""
	Local lDelete   := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Local oEvent    := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local nInd      := 0

	If !slForcaPes
		If IsInCallStack("ButtonOkAction")
			Return Nil
		EndIf
	Else
		slForcaPes := .F.
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !oEvent:lCopia
		//Se for inclusão, apenas inicializa a variável Static com o valor em branco.
		scRevisao := CriaVar("B1_REVATU")

		oModel:GetModel("SG1_MASTER"):ClearField("CDESCPAI")
		oModel:GetModel("SG1_MASTER"):ClearField("CUMPAI")
		oModel:GetModel("SG1_MASTER"):ClearField("CREVPAI")
		oModel:GetModel("SG1_MASTER"):ClearField("CREVABERTA")
		oModel:GetModel("SG1_MASTER"):ClearField("NQTBASE")
		oModel:GetModel("SG1_COMPON"):ClearField("G1_COD")
		oModel:GetModel("SG1_COMPON"):ClearField("CDESCCMP")
		oModel:GetModel("SG1_COMPON"):ClearField("CUMCMP")
		oModel:GetModel("SG1_COMPON"):ClearField("CREVCOMP")

		//Carrega as informações da grid de componentes
		oMdlDet:ClearData(.T.,.T.)

		oView:Refresh()
	Else
		If oEvent:lCopia
			oModel:GetModel("SG1_MASTER"):SetValue("G1_COD", Padr(oEvent:mvcProdutoDestino, GetSX3Cache("G1_COD","X3_TAMANHO")))
		EndIf
		//Chama a função para criar a TREE
		cCargo := P200AddPai(oModel:GetModel("SG1_MASTER"):GetValue("G1_COD"))

		//Inicializa com a revisão atual do produto.
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			scRevisao := P200IniRev(oModel:GetModel("SG1_MASTER"):GetValue("G1_COD"))
		EndIf

		If lDelete
			oModel:GetModel("SG1_MASTER"):DeActivate()
			oModel:GetModel("SG1_MASTER"):oFormModel:nOperation := MODEL_OPERATION_VIEW
			oModel:GetModel("SG1_MASTER"):Activate()
		EndIf

		//Atualiza a revisão no modelo
		If oEvent:lCopia
			scRevisao := oEvent:mvcRevProdDestino
		EndIf
		oModel:GetModel("SG1_MASTER"):LoadValue("CREVPAI", scRevisao)

		//Seta a revisão carregada na Tree
		scRevTree := scRevisao

		If lDelete
			oModel:GetModel("SG1_MASTER"):DeActivate()
			oModel:GetModel("SG1_MASTER"):oFormModel:nOperation := MODEL_OPERATION_DELETE
			oModel:GetModel("SG1_MASTER"):Activate()
		EndIf

		//Carrega as informações do componente selecionado
		cargaSelec(oModel:GetModel("SG1_MASTER"):GetValue("G1_COD"),oModel,cCargo)

		//Carrega as informações da grid de componentes
		oMdlDet:ClearData(.F.,.F.)
		oMdlDet:DeActivate()
		oMdlDet:lForceLoad := .T.
		If oEvent:lCopia
			DbSelectArea("SG1")
			SG1->(DbSetOrder(1))
			//Atribui bloco de carga para carga dos dados de cópia
			oMdlDet:bLoad := {|| LoadGridC(cCargo, oModel)}
			oMdlDet:Activate()

			//Seta todas as linhas como modificadas para que os dados sejam gravados no modelo de gravação
			For nInd := 1 to oMdlDet:Length(.F.)
				oMdlDet:SetLineModify(nInd)
			Next nInd

			//Carrega a TREE com base nos componentes que foram carregados no grid
			AddCmpTree(cCargo,oModel)

			P200GravAl(oModel)
			RecupAlter(cCargo)

			//Atribui bloco de carga padrão
			oMdlDet:bLoad := {|| LoadCompon(cCargo, oModel)}

			//Seta o modelo para alterado
			oModel:lModify := .T.
			slAltPai := .F.

		Else
			oMdlDet:bLoad := {|| LoadCompon(cCargo, oModel, scRevisao)}
			oMdlDet:Activate()

			If oModel:GetOperation() == MODEL_OPERATION_VIEW;
				.And. oEvent:oDadosCommit["oQLinAlt"]["*Total*"] != Nil;
				.AND. oEvent:oDadosCommit["oQLinAlt"]["*Total*"] > 0
				//Tratativa para visualizar as informações na tela de Divergências do PCPA120.
				RecupAlter(cCargo)
			EndIf

			//Carrega a TREE com base nos componentes que foram carregados no grid
			addCmpTree(cCargo,oModel)

			//Seta o modelo para não alterado
			oModel:lModify := .F.
		EndIf

		//Atualiza a view.
		oView:Refresh()

	EndIf

	// Função para ser chamada a cada troca de linha
	oView:GetViewObj("SG1_DETAIL")[3]:bChangeLine := {|| ChgLinGrid(oView) }

	//Adiciona teclas de atalho
	P200Atalho(.T.)

Return Nil

/*/{Protheus.doc} AltRevisao
Chama a tela para alterar a revisão, quando utilizada a operação de Visualização.

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param oView	- Objeto da View.
@return Nil
/*/
Static Function AltRevisao(oView)
	Local oModel   := oView:GetModel()
	Local cProduto := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local oEvent   := gtMdlEvent(oModel, "PCPA200EVDEF")

	//Desabilita as teclas de atalho
	P200Atalho(.F.)

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE;
	   .And. (oModel:lModify .Or. (oEvent:oDadosCommit["oQLinAlt"] != NIL;
	                              .AND. oEvent:oDadosCommit["oQLinAlt"]["*Total*"] != NIL;
	                              .AND. oEvent:oDadosCommit["oQLinAlt"]["*Total*"] > 0))

		HelpInDark(.F.)
		Help(,,'Help',,STR0024,1,0,,,,,,; //"Já foram realizadas alterações na estrutura. Não será possível alterar a revisão."
		              {STR0025})          //"Para alterar a revisão, confirme ou cancele a operação corrente e abra a tela novamente."
		HelpInDark(.T.)
	Else
		If getRevisao(.F.,cProduto, oModel)
			oModel:GetModel("SG1_MASTER"):LoadValue("CREVPAI",   scRevisao)
			oModel:GetModel("SG1_MASTER"):LoadValue("CREVABERTA",scRevisao)
			afterRevis()
			scRevisao := oModel:GetModel("SG1_MASTER"):GetValue("CREVPAI")
			PCPA200Pes(oView, "INICIALIZA")
			oView:Refresh()
		EndIf
	EndIf

	//Habilita as teclas de atalho
	P200Atalho(.T.)

Return Nil

/*/{Protheus.doc} P200IniRev
Inicializador padrão da revisão do produto pai

@author Lucas Konrad França
@since 05/11/2018
@version 1.0

@param cProduto	- Código do produto para fazer a busca na SB1. (Opcional)
@return cRevAtu	- Revisão atual do produto
/*/
Function P200IniRev(cProduto)
	Local cRevAtu := ""
	Local nScan   := 0
	Local oEvent  := gtMdlEvent(FwModelActive(),"PCPA200EVDEF")

	Default cProduto := SG1->G1_COD

	If oEvent != NIL
		nScan := aScan(oEvent:aRevisoes, {|x| x[4] == cProduto .AND. x[1] })
	EndIf
	If nScan > 0
		cRevAtu := oEvent:aRevisoes[nScan,2]
	Else
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cProduto))
			cRevAtu := IIF(slPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
		Else
			cRevAtu := CriaVar('B1_REVATU')
		EndIf
	EndIf
Return cRevAtu

/*/{Protheus.doc} IniUm
Inicializador padrão da unidade de medida do produto pai

@author Lucas Konrad França
@since 07/11/2018
@version 1.0

@param cProduto		- Código do produto para fazer a busca na SB1. (Opcional)
@return cUnidade	- Unidade de medida do produto.
/*/
Static Function IniUm(cProduto)
	Local cUnidade := ""
	Default cProduto := SG1->G1_COD

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		cUnidade := SB1->B1_UM
	Else
		cUnidade := CriaVar('B1_UM')
	EndIf
Return cUnidade

/*/{Protheus.doc} afterRevis
Função executada pela Trigger do campo Revisão.

@author Lucas Konrad França
@since 07/11/2018
@version 1.0

@param cRev	- Revisão informada em tela.
@return Nil
/*/
Static Function afterRevis(cRev)
	Local oModel    := FwModelActive()
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")
	Local cCargoRet := ""

	Default cRev    := oModel:GetModel("SG1_MASTER"):GetValue("CREVPAI")

	//Adiciona o produto pai na TREE
	cCargoRet := P200AddPai(oModel:GetModel("SG1_MASTER"):GetValue("G1_COD"))

	//Seta a revisão carregada na Tree
	scRevTree := cRev

	//Atualiza CARGO do pai
	oModel:GetModel("SG1_MASTER"):LoadValue("CARGO",cCargoRet)

	//Carrega as informações do componente selecionado
	cargaSelec(P200RetInf(cCargoRet,"COMP"),oModel,cCargoRet)

	//Carrega as informações da grid de componentes
	oMdlDet:ClearData(.F.,.F.)
	oMdlDet:DeActivate()
	oMdlDet:lForceLoad := .T.
	oMdlDet:bLoad := {|| LoadCompon(cCargoRet, oModel, cRev)}

	FWMsgRun(, {|| oMdlDet:Activate() }, STR0053, STR0201) //"Aguarde..." + "Carregando a estrutura..."
	FWMsgRun(, {|| addCmpTree(cCargoRet,oModel) }, STR0053, STR0202) //"Aguarde..." + "Atualizando interface") //"Aguarde..." + "Carregando a estrutura..."
Return Nil

/*/{Protheus.doc} VldBase
Função de validação da quantidade base.

@author Lucas Konrad França
@since 07/11/2018
@version 1.0

@return lRet	- Indica se a quantidade base do produto pai informado é válido.
/*/
Static Function VldBase()
	Local lRet   := .T.
	Local oModel := FwModelActive()
	Local oMdlPai := oModel:GetModel("SG1_MASTER")

	If QtdComp(oMdlPai:GetValue("NQTBASE")) < QtdComp(0) .And. !SuperGetMv('MV_NEGESTR', .F., .F.)
		Help(' ',1,'MA200QBNEG')
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} IniBase
Função para inicializador padrão da quantidade base do produto pai.

@author Lucas Konrad França
@since 07/11/2018
@version 1.0

@param cProduto	- Código do produto para fazer a busca na SB1. (Opcional)
@return nBase	- Quantidade base do produto pai.
/*/
Static Function IniBase(cProduto)
	Default cProduto := SG1->G1_COD

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
Return RetFldProd(cProduto,"B1_QB")

/*/{Protheus.doc} IniDenProd
Função para inicializador padrão da descrição do produto pai.

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param cProduto	- Código do produto para fazer a busca na SB1. (Opcional)
@return cDesc	- Descrição do produto.
/*/
Static Function IniDenProd(cProduto)
	Local cDesc := ""
	Default cProduto := SG1->G1_COD

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		cDesc := SB1->B1_DESC
	Else
		cDesc := CriaVar("B1_DESC")
	EndIf
Return cDesc

/*/{Protheus.doc} P200TreeCh (Antiga TreeChange)
Função executada no evento de Change da tree

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param lRefresh	- Indica se executa o refresh da tela.
@param cCargo   - CARGO atual da tree. Utilizado quando execução automática.
@param lForce   - Forca execucao do P200TreeCh mesmo quando o cCargo recebido e igual ao pre-selecionado (Ver P200Reload)
@return Nil
/*/
Function P200TreeCh(lRefresh, cCargo, lForce)
	Local oModel    := FwModelActive()
	Local oView     := FwViewActive()
	Local oMdlSelec := oModel:GetModel("SG1_COMPON")
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")
	Local lModify   := oModel:lModify
	Local lRunAuto  := P200IsAuto(oModel)
	Local oEvent    := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local cCodProd
	Local cCodPai

	Default lRefresh := .T.
	Default cCargo   := ""
	Default lForce   := .F.

	If soCargosCmp == Nil
		P200IniStc()
	EndIf

	//Variável de controle para executar o evento de mudança de nó da tree
	If slExecChL == NIL
		slExecChL := .T.
	EndIf
	If !slExecChL
		Return
	EndIf

	If !lRunAuto
		cCargo := soDbTree:GetCargo()
	EndIf

	cCodProd  := P200RetInf(cCargo,"COMP")
	cCodPai   := P200RetInf(cCargo, "PAI")

	//Se o nó da tree for o mesmo que está carregado
	// no modelo de componente selecionado, não executa o evento
	If oMdlSelec:GetValue("CARGO") == cCargo .AND. !lForce
		Return
	EndIf

	If 	cCodProd != cCodPai .and. ;
		( oModel:GetOperation() == MODEL_OPERATION_VIEW .or. ;
		oModel:GetOperation() == MODEL_OPERATION_UPDATE )
		//Ponto de entrada para inibir a expansão de niveis.
		If ExistBlock("MT200EXP")
			lRet 	  := .T.
			aAreaSG1  := GetArea("SG1")

			DbSelectArea("SG1")
			SG1->(DbSetOrder(1))
			SG1->(DbSeek(xFilial("SG1")+cCodPai+cCodProd))

			lMt200Exp := ExecBlock("MT200EXP",.F.,.F., {cCodProd, cCodPai})
			If ( Valtype(lMt200Exp) == "L" ) .AND. !lMt200Exp
				lRet := .F.
			EndIf

			RestArea(aAreaSG1)

			If !lRet
				Return
			EndIf
		EndIf

	EndIf

	//Clicou na opcao para exibir todos os componentes do produto pai + nivel atual
	If AllTrim(P200RetInf(cCargo,"COMP")) == AllTrim(". . .")
		nPos      := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_COMP]  == cCargo })
		cCargoPai := saCargos[nPos][IND_ACARGO_CARGO_PAI]
		oEvent:lExecutaPreValid := .F.
		P200DelIt(cCargoPai, cCargo)
		oEvent:lMostrandoTodos := .T.
		P200TreeCh(.T., cCargo, .T.)
		oEvent:lMostrandoTodos := .F.
		oEvent:lExecutaPreValid := .T.
		Return
	EndIf

	oEvent:lExecutaPreValid := .F.

	If oModel:GetOperation() != MODEL_OPERATION_VIEW

		If Empty(oModel:GetModel("SG1_DETAIL"):GetValue("G1_COMP"))
			If oView != Nil;
			   .And. oView:IsActive();
			   .AND. FunName() == "PCPA200"
				oView:GetSubView("VIEW_COMPONENTES"):lNewLine := .F.
			EndIf
		EndIf

		//Verifica se a linha digitada é válida.
		If !oModel:GetModel("SG1_DETAIL"):VldLineData()
			If oView != Nil .And. oView:IsActive()
				oView:ShowLastError()
			EndIf
			slExecChL := .F.
			//Reposiciona a TREE no item anterior
			If !lRunAuto
				soDbTree:TreeSeek(oMdlSelec:GetValue("CARGO"))
			EndIf
			slExecChL := .T.
			Return Nil
		ElseIf !oEvent:lExpandindo .AND. !IsInCallStack("PosicTree")
			If oView != Nil .AND. Len(oMdlDet:GetLinesChanged()) > 150
				FWMsgRun(, {|| P200GravAl(oModel) }, STR0053, STR0203) //"Aguarde..." + "Guardando alterações para efetivação posterior..."
			Else
				P200GravAl(oModel)
			EndIf

		EndIf
	EndIf

	//Carrega as informações do componente selecionado
	cargaSelec(cCodProd,oModel,cCargo)

	oMdlDet:ClearData(.F.,.F.)
	oMdlDet:DeActivate()
	oMdlDet:lForceLoad := .T.
	oMdlDet:bLoad := {|| LoadCompon(cCargo,oModel)}

	If oView != Nil;
	   .AND. !IsInCallStack("PosicTree");
	   .AND. !oEvent:lExpandindo;
       .AND. QtdCompon(cCargo, oModel) > 150

		FWMsgRun(, {|| oMdlDet:Activate() }, STR0053, STR0201) //"Aguarde..." + "Carregando a estrutura..."
		RecupAlter(cCargo)
		FWMsgRun(, {|| addCmpTree(cCargo,oModel) }, STR0053, STR0202) //"Aguarde..." + "Atualizando interface") //"Aguarde..." + "Carregando a estrutura..."

	Else
		oMdlDet:Activate()
		RecupAlter(cCargo)
		addCmpTree(cCargo,oModel)

	EndIf

	//Realiza lock da estrutura
	If !oEvent:lExpandindo .AND.;
		 oModel:GetOperation() != MODEL_OPERATION_VIEW .AND.;
		 (oModel:GetOperation() != MODEL_OPERATION_DELETE .OR.;
		 cCargo == saCargos[1][IND_ACARGO_CARGO_COMP])

		oEvent:Lock(fAjustaStr(cCodProd), oView, .F.)
	EndIf

	If lRefresh .And. !lRunAuto
		If oView != Nil .And. oView:IsActive()
			oView:Refresh("VIEW_COMPONENTES")
			oView:Refresh("VIEW_SELECIONADO")
		EndIf

		soDbTree:SetFocus()
	EndIf

	oEvent:lExecutaPreValid := .T.

	//Seta o modelo com o status de modificado que estava antes de atualizar os dados da grid.
	oModel:lModify := lModify
Return Nil

/*/{Protheus.doc} P200IniStc
Inicializa as variáveis do tipo Static deste fonte.

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@return Nil
/*/
Function P200IniStc()

	snSeqTree  := 0
	//scRevisao  := NIL
	If soDbTree != NIL
		soDbTree:Reset()
	EndIf
	saTreeLoad := NIL
	If saCargos == NIL
		saCargos := {}
	Else
		aSize(saCargos,0)
	EndIf

	soCargosPai := JsonObject():New()
	soCargosCmp := JsonObject():New()

	soModelAux := NIL
	slConfList := .F.
	slAltRev   := NIL
	slAltPai   := NIL
	slExecChL  := NIL
	slSelecOPC := GetMV("MV_SELEOPC") == "S"

	If soRevPE != NIL
		FreeObj(soRevPE)
		soRevPE := Nil
	EndIf

Return Nil

/*/{Protheus.doc} MontaCargo
Monta o campo CARGO do registro

@author Lucas Konrad França
@since 08/11/2018
@version 1.0

@param cInd		- Indicador de tipo de registro:
                     ESTR - Componente da estrutura
                     TEMP - Nó temporário da tree, utilizado apenas para exibir a opção de expandir o nível (+)
@param cPai		- Código do pai do registro
@param cComp	- Código do componente
@param nRecno	- RECNO do registro (componente)
@return cCargo	- Campo CARGO formatado com o padrão do programa
/*/
Static Function MontaCargo(cInd,cPai,cComp,nRecno)
	Local cCargo := ""
	Default nRecno := 0

	snSeqTree++

	cCargo := PadR(cPai, GetSx3Cache("G1_COD" ,"X3_TAMANHO")) + ;
	          PadR(cComp,GetSx3Cache("G1_COMP","X3_TAMANHO")) + ;
	          StrZero(nRecno, 9) + ;
	          StrZero(snSeqTree, 9) + ;
	          cInd
Return PadR(cCargo,getTmCargo())

/*/{Protheus.doc} getTmCargo
Retorna o tamanho total do CARGO utilizado para TREE

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@return nTam	- Tamanho utilizado para o CARGO
/*/
Static Function getTmCargo()
	Local nTam := GetSx3Cache("G1_COD" ,"X3_TAMANHO") + ;
	              GetSx3Cache("G1_COMP","X3_TAMANHO") + ;
	              9 + 9 + 4
Return nTam

/*/{Protheus.doc} PromptTree
Gera o texto Prompt de exibição do item na Tree

@author Lucas Konrad França
@since 08/11/2018
@version 1.0

@param cCargo   	- Campo CARGO do item
@param cGrupoOpc	- Grupo de opcionais (G1_GROPC)
@param cItemOpc 	- Item do grupo de opcionais (G1_OPC)
@return cPrompt		- Texto Prompt do item na Tree formatado com o tamanho máximo
/*/
Static Function PromptTree(cCargo, cGrupoOpc, cItemOpc)
	Local cPrompt    := ""
	Local cGrupoDesc := ""
	Local cGrupoItem := ""
	Local nTamPromp  := 0

	Local lM200TEXT  := ExistBlock("M200TEXT")
	Local cTrtComp   := ""
	Local nQtdComp   := 0
	Local aAreaSG1   := {}

	Default cGrupoOpc := ""
	Default cItemOpc  := ""

	slSelecOPC := Iif(slSelecOPC == Nil, GetMV("MV_SELEOPC") == "S", slSelecOPC)

	nTamPromp := Len(STR0026) + 60 + ; //"Opcional"
	             GetSx3Cache("G1_COD" ,"X3_TAMANHO") + ;
	             GetSx3Cache("G1_GROPC" ,"X3_TAMANHO") + ;
	             GetSx3Cache("G1_OPC" ,"X3_TAMANHO")

	cPrompt := AllTrim(P200RetInf(cCargo, "COMP"))

	/* Ponto de entrada para manipular o texto a ser apresentado na estrutura */
 	If lM200TEXT
		//Busca os dados para PE
		aAreaSG1 := SG1->(GetArea())
		DbGoTo(P200RetInf(cCargo, "RECNO"))
		cTrtComp := SG1->G1_TRT
		nQtdComp := SG1->G1_QUANT
		RestArea(aAreaSG1)

		cM200TEXT := ExecBlock("M200TEXT", .F., .F., {cPrompt,;	                    // Texto original
													  P200RetInf(cCargo, "PAI"),;   // Codigo do item PAI
													  cTrtComp,;                    // TRT
													  P200RetInf(cCargo, "COMP"),;  // Codigo do componente/item inserido na estrutura
													  nQtdComp})                    // Qtde. do item na estrutura
		If ValType(cM200TEXT) == "C"
			cPrompt := cM200TEXT
		EndIf
	EndIf

	If (!Empty(cGrupoOpc) .Or. !Empty(cItemOpc)) .and. slSelecOPC
		If Empty(MV_PAR05) .Or. MV_PAR05 != 2
			cPrompt += " - " + STR0026 + ": " + AllTrim(cGrupoOpc) + "/" + AllTrim(cItemOpc) //"Opcional"
		Else
			SGA->(DbSetOrder(1))
			If SGA->(DbSeek(xFilial("SGA")+cGrupoOpc+cItemOpc)) //GA_FILIAL+GA_GROPC+GA_OPC
				cGrupoDesc := SGA->GA_DESCGRP
				cGrupoItem := SGA->GA_DESCOPC
			EndIf
			cPrompt += " / " + "Grupo: " + AllTrim(cGrupoOpc) + " - " + AllTrim(cGrupoDesc) + " / " + "Item: " + AllTrim(cItemOpc) + " - " + AllTrim(cGrupoItem)
		Endif
	EndIf

	If LEN(AllTrim(cPrompt)) > nTamPromp
		nTamPromp := LEN(AllTrim(cPrompt))
	EndIf

Return PadR(cPrompt,nTamPromp)

/*/{Protheus.doc} P200RetInf
Extrai informações do campo CARGO da Tree

@author Lucas Konrad França
@since 08/11/2018
@version 1.0

@param cCargo	- CARGO o qual as informações serão extraídas
@param cInfo 	- Indica a informação a ser extraída:
                    "IND"   - Indicador (NOVO, COMP, CODI)
                    "PAI"   - Pai
                    "COMP"  - Componente
                    "RECNO" - Recno
                    "INDEX" - Index
					"POS"   - Posição no array de controle (saCargos)
@return xRet	- Informação solicitada extraída do CARGO
/*/
Function P200RetInf(cCargo, cInfo)
	Local xRet
	Local nStart   := 0
	Local nTamanho := 0

	Default cInfo := "PAI"

	If cInfo == "IND"
		//Indicador
		xRet := Right(cCargo, 4)
	ElseIf cInfo == "PAI"
		//Pai
		xRet := Left(cCargo, GetSx3Cache("G1_COD","X3_TAMANHO"))
	ElseIf cInfo == "COMP"
		//Componente
		nStart   := GetSx3Cache("G1_COD","X3_TAMANHO") + 1
		nTamanho := GetSx3Cache("G1_COMP","X3_TAMANHO")
		xRet := Substr(cCargo, nStart, nTamanho)
	ElseIf cInfo == "RECNO"
		//Recno
		nStart   := GetSx3Cache("G1_COD","X3_TAMANHO") + GetSx3Cache("G1_COMP","X3_TAMANHO") + 1
		nTamanho := 9
		xRet := Val(Substr(cCargo, nStart, nTamanho))
	ElseIf cInfo == "INDEX"
		//Index
		nStart   := GetSx3Cache("G1_COD","X3_TAMANHO") + GetSx3Cache("G1_COMP","X3_TAMANHO") + 10
		nTamanho := 9
		xRet := Val(Substr( cCargo, nStart, nTamanho))
	ElseIf cInfo == "POS"
		//Posição do CARGO no array saCargos
		xRet := Iif(soCargosCmp == Nil .OR. soCargosCmp[cCargo] == Nil, 0, soCargosCmp[cCargo])
	EndIf
Return xRet

/*/{Protheus.doc} P200AddPai (Antiga AddTreePai)
Adiciona o código do produto pai na TREE. Se a tree não estiver vazia, ela será
reinicializada para incluir somente o produto pai.

@author Lucas Konrad França
@since 08/11/2018
@version 1.0

@return cCargo	- Código do CARGO criado.
/*/
Function P200AddPai(cProduto)
	Local cCargo := ""
	Local nSeq   := 0
	Local oEvent  := gtMdlEvent(FwModelActive(),"PCPA200EVDEF")

	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1")+cProduto))
		If oEvent:lCopia
			cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, 0)
		Else
			cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, SG1->(Recno()))
		EndIf
	Else
		cCargo := MontaCargo(IND_ESTR,cProduto,cProduto,0)
	EndIf

	If soDbTree <> NIL
		soDbTree:Reset()
		//Faz bkp da variável snSeqTree
		nSeq := snSeqTree
		P200IniStc()
		//Restaura o conteúdo da variável snSeqTree
		snSeqTree := nSeq

		soDbTree:BeginUpdate()
		soDbTree:AddTree(PromptTree(cCargo),.T.,'FOLDER5','FOLDER6',,,cCargo)
		soDbTree:EndTree()
		soDbTree:EndUpdate()
		soDbTree:Refresh()
	EndIf

Return cCargo


/*/{Protheus.doc} P200EDTPAI
Identifica quando será possível alterar o código do produto Pai.

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@return lRet	- Identifica se o código do produto pai poderá ser alterado.
/*/
Function P200EDTPAI()
	Local oModel := FwModelActive()
	Local lRet   := .T.

	If oModel:GetOperation() != MODEL_OPERATION_INSERT
		lRet := .F.
	Else
		If slAltPai != NIL
			lRet := slAltPai
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} P200VLDPAI
Faz as validações do código do produto PAI. (G1_COD)

@author Lucas Konrad França
@since 08/11/2018
@version 1.0

@return lRet	- Identifica se o código do produto informado é válido.
/*/
Function P200VLDPAI()
	Local lRet    := .T.
	Local cQuery  := ""
	Local aArea   := GetArea()
	Local aAreaG1 := SG1->(GetArea())
	Local aAreaB1 := SB1->(GetArea())
	Local oModel  := FwModelActive()
	Local oMdlPai := oModel:GetModel("SG1_MASTER")

	If !Empty(oMdlPai:GetValue("G1_COD"))
		//Valida se o produto existe.
		SB1->(dbSetOrder(1))
		If !SB1->(dbSeek(xFilial("SB1")+oMdlPai:GetValue("G1_COD")))
			Help(' ',1, 'NOFOUNDSB1')
			lRet := .F.
		EndIf

		//Valida se o produto já está cadastrado como produto pai.
		If lRet
			SG1->(dbSetOrder(1))
			If SG1->(dbSeek(xFilial('SG1')+oMdlPai:GetValue("G1_COD")))
				Help(' ',1, 'CODEXIST')
				lRet := .F.
			EndIf
		EndIf

		//Valida sub-produto.
		If lRet .And. !SuperGetMv( 'MV_NEGESTR' , .F. , .F. ,  )
			cQuery  := " SELECT COUNT(*) TOTREC FROM "+RetSqlName('SG1') + " SG1 "
			cQuery  += " WHERE SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
			cQuery  +=   " AND SG1.G1_COMP   = '"+oMdlPai:GetValue("G1_COD")+"' "
			cQuery  +=   " AND SG1.G1_QUANT  < 0 "
			cQuery  +=   " AND SG1.D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)
			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSG1",.F.,.T.)
			If QRYSG1->TOTREC > 0
				Help(' ',1,'A200NAOINC')
				lRet := .F.
			EndIf
			QRYSG1->(dbCloseArea())
		EndIf

		//Validação de produtos protótipos
		If lRet .And. IsProdProt(oMdlPai:GetValue("G1_COD")) .And. !IsInCallStack("DPRA340INT")
			Help(,,'Help',,STR0027,1,0) //"Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR)."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. slP200PRD
		lRet := ExecBlock("PA200PRD", .F., .F., {oMdlPai:GetValue("G1_COD"), ""})
	Endif

	//Restaura a área de trabalho.
	SG1->(RestArea(aAreaG1))
	SB1->(RestArea(aAreaB1))
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldG1Cod
Valida a execução do gatilho do Pai (usado para validar lock de registro)
@author Marcelo Neumann
@since 24/04/2019
@version 1.0
@return logic, indica se deve executar o gatilho ou não
/*/
Static Function VldG1Cod()

	Local oView    := FwViewActive()
	Local oModel   := FwModelActive()
	Local oEvent   := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local cProduto := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local lComTela := oView != Nil .And. oView:IsActive() .And. !(oModel:GetModel("SG1_MASTER"):GetValue("CEXECAUTO") == "S")

	If !oEvent:Lock(fAjustaStr(cProduto), , .T., .F., .F.)
		If lComTela
			oModel:GetModel("SG1_MASTER"):LoadValue("G1_COD"," ")
			oView:GetViewObj("SG1_MASTER")[3]:getFWEditCtrl("G1_COD"):oCtrl:SetFocus()
		EndIf
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} afterG1Cod
Trigger executado no campo G1_COD.
na operação de inclusão.

@author Lucas Konrad França
@since 08/11/2018
@version 1.0

@return Nil
/*/
Static Function afterG1Cod()

	Local oModel   := FwModelActive()
	Local oMdlPai  := oModel:GetModel("SG1_MASTER")
	Local cProduto := oMdlPai:GetValue("G1_COD")
	Local cCargo   := ""
	Local lRunAuto := P200IsAuto(oMdlPai)

	//Se operação de inclusão, carrega a tree com o código do produto.
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. (soDbTree != NIL .Or. lRunAuto)
		cCargo := P200AddPai(cProduto)
		If !lRunAuto
			soDbTree:TreeSeek(cCargo)
		EndIf
		P200TreeCh(.F.,cCargo)
	EndIf

	oMdlPai:LoadValue("CUMPAI"  ,IniUm(cProduto))
	oMdlPai:LoadValue("NQTBASE" ,IniBase(cProduto))
	oMdlPai:LoadValue("CREVPAI" ,P200IniRev(cProduto))
	oMdlPai:LoadValue("CDESCPAI",PadR(IniDenProd(cProduto),TamSx3('B1_DESC')[1]))

	//Seta a revisão carregada na Tree
	scRevTree := oMdlPai:GetValue("CREVPAI")
    	
Return Nil

/*/{Protheus.doc} P200EDTREV
Identifica se os campos de Revisão podem ser editados.

@author Lucas Konrad França
@since 12/11/2018
@version 1.0

@return lRet	- .T. se o campo de revisão puder ser modificado.
/*/
Function P200EDTREV()
	Local lRet := .T.

	If slAltRev == NIL
		slAltRev := .T.
		If AliasInDic("SOW")
			SOW->(DbSetOrder(1))
			If SOW->(dbSeek(xFilial('SOW'), .F.))
				If gtMdlEvent(FwModelActive(),"PCPA200EVDEF"):mvlRevisaoAutomatica
					slAltRev := .F.
				EndIf
			EndIf
		EndIf
		lRet := slAltRev
	Else
		lRet := slAltRev
	EndIf
Return lRet

/*/{Protheus.doc} P200ValCpo
Função para validar os campos informados na grid

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cCampo	- Indica qual campo está sendo validado.
@param lInsere	- Indica se deverá inserir o item na tree caso esteja válido
@return lRet	- Indica se o código digitado está válido.
/*/
Function P200ValCpo(cCampo, lInsere)
	Local lRet      := .T.
	Local lExiste   := .F.
	Local oModel    := FwModelActive()
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")
	Local oEvent    := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local cPai      := oModel:GetModel("SG1_COMPON"):GetValue("G1_COD")
	Local cComp     := oMdlDet:GetValue("G1_COMP")
	Local cTrt      := oMdlDet:GetValue("G1_TRT")
	Local cGrupoOpc := oMdlDet:GetValue("G1_GROPC")
	Local cItemOpc  := oMdlDet:GetValue("G1_OPC")
	Local cCargo    := ""
	Local cImg1     := "FOLDER5"
	Local cImg2     := "FOLDER6"
	Local cSeqInc   := Space(Len(cTrt))
	Local nQuant    := oMdlDet:GetValue("G1_QUANT")
	Local nPosAtual := 0
	Local nInd      := 0
	Local nX 		:= 0
	Local nLinha	:= 0
	Local lEditln	:= SuperGetMV("MV_PCPRLEP",.F., 2)

	Default lInsere := oMdlDet:IsInserted() .And. Empty(oMdlDet:GetValue("CARGO"))

	If cCampo == "G1_COMP" .And. Empty(cComp)
		lRet := NaoVazio()
	ElseIf cCampo == "G1_COMP" .And. !Empty(cComp)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cComp))

			If IsProdProt(cComp) .And. !IsInCallStack("DPRA340INT")
				Help(,,'Help',,STR0027,1,0) //"Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR)."
				lRet := .F.
			EndIf
			If lRet
				oView := FwViewActive()
				If !slConfList .OR. oEvent:lModeloAuxiliar
					If oView != Nil
						//FWMsgRun(, {|| lRet := CheckEstru(oModel) }, STR0053, STR0205) //"Aguarde..." + "Validando recursividade na estrutura."
						lRet := CheckEstru(oModel)
					Else
						lRet := CheckEstru(oModel)
					EndIf
				EndiF
			EndIf
		Else
			Help(' ', 1, 'NOFOUNDSB1')
			lRet := .F.
		EndIf

		If lRet .And. slP200PRD
			lRet := ExecBlock("PA200PRD", .F., .F., {cPai, cComp})
		Endif

		If lRet
			oMdlDet:LoadValue("G1_DESC",PadR(SB1->B1_DESC,GetSx3Cache("G1_DESC","X3_TAMANHO")))

			If Empty(oMdlDet:GetValue("G1_TRT"))
				oMdlDet:SetValue("G1_TRT", ProximoTrt(oMdlDet,cPai,cComp))
			EndIf

			//incrementa a sequência deste componente.
			If Empty(oMdlDet:GetValue("G1_TRT")) .And. !IsInCallStack("ListaComp")
				If Empty(oMdlDet:GetValue("G1_LISTA"))
					For nInd := 1 To oMdlDet:Length()
						If nInd == oMdlDet:GetLine() .Or. oMdlDet:IsDeleted(nInd) .Or. oMdlDet:GetValue("G1_COMP",nInd) != cComp
							Loop
						EndIf
						lExiste := .T.
						If !Empty(oMdlDet:GetValue("G1_TRT",nInd)) .And. oMdlDet:GetValue("G1_TRT",nInd) > cSeqInc
							cSeqInc := oMdlDet:GetValue("G1_TRT",nInd)
						EndIf
					Next nInd
					If lExiste
						If Empty(cSeqInc)
							cSeqInc := StrZero(1,Len(cSeqInc))
						Else
							cSeqInc := Soma1(cSeqInc)
						EndIf
						oMdlDet:LoadValue("G1_TRT",cSeqInc)
					EndIf
				EndIf
			EndIf
		EndIf

	ElseIf cCampo == "G1_TRT"
		If lRet
			cCargo := oMdlDet:GetValue("CARGO")
			If !Empty(cCargo)
				nPosAtual := P200RetInf(cCargo,"POS")
				If nPosAtual > 0
					saCargos[nPosAtual][IND_ACARGO_TRT] := cTrt
				EndIf
			EndIf
		EndIf
	ElseIf cCampo == "G1_QUANT"
		If IsProdMod(cComp) .And. SuperGetMV('MV_TPHR',.F.,"C") == 'N'
			nQuant := nQuant - Int(nQuant)
			If nQuant > .5999999999
				HELP(' ',1,'NAOMINUTO')
				lRet := .F.
			Else
				//Restaura o conteúdo do NQUANT
				nQuant := oMdlDet:GetValue("G1_QUANT")
			EndIf
		ElseIf QtdComp(nQuant) < QtdComp(0) .And. !SuperGetMv('MV_NEGESTR',.F.,.F.)
			Help(,,'Help',,STR0046,; //"Não é permitido informar quantidades negativas para os componentes."
			     1,0,,,,,,{STR0047}) //"Para que seja possível informar quantidades negativas na estrutura, configure o parâmetro MV_NEGESTR."
			lRet := .F.
		EndIf
	ElseIf cCampo == "G1_FIM"
		If oMdlDet:GetValue("G1_FIM") < oMdlDet:GetValue("G1_INI")
			Help(,,'Help',,STR0028,1,0,,,,,,; //"Data final não pode ser menor que a data inicial."
			              {STR0029})          //"Informe uma data final que seja maior ou igual a data inicial."
			lRet := .F.
		EndIf
	ElseIf cCampo == "G1_GROPC"
		If !Empty(cGrupoOpc)
			lRet := ExistCpo("SGA")
		EndIf
	ElseIf cCampo == "G1_OPC"
		If !Empty(cGrupoOpc)
			lRet := NaoVazio() .And. ExistCpo("SGA",cGrupoOpc+cItemOpc)
		Else
			lRet := Vazio()
		EndIf
	ElseIf cCampo == "G1_REVINI"
		If !oEvent:mvlRevisaoAutomatica .And. lEditln == 1 .And. !Empty(oMdlDet:GetValue("G1_LISTA"))
			cLista 	:= oMdlDet:GetValue("G1_LISTA")
			cRevIni := oMdlDet:GetValue("G1_REVINI")
			nLinha  := oMdlDet:GetLine()
			For nX := 1 to oMdlDet:Length()
				If oMdlDet:IsDeleted(nX)
					Loop
				EndIf
				If cLista == oMdlDet:GetValue("G1_LISTA",nX)
					oMdlDet:GoLine(nX)
					oMdlDet:LoadValue("G1_REVINI",cRevIni)
				EndIf
			Next nX
			oMdlDet:GoLine(nLinha)
		EndIf
	ElseIf cCampo == "G1_REVFIM"
		If !oEvent:mvlRevisaoAutomatica .And. lEditln == 1 .And. !Empty(oMdlDet:GetValue("G1_LISTA"))
			cLista 	:= oMdlDet:GetValue("G1_LISTA")
			cRevFim := oMdlDet:GetValue("G1_REVFIM")
			nLinha  := oMdlDet:GetLine()
			For nX := 1 to oMdlDet:Length()
			 	If oMdlDet:IsDeleted(nX)
			 		Loop
			 	EndIf
				If cLista == oMdlDet:GetValue("G1_LISTA",nX)
					oMdlDet:GoLine(nX)
					oMdlDet:LoadValue("G1_REVFIM",cRevFim)
				EndIf
			Next nX
			oMdlDet:GoLine(nLinha)
		EndIf
	ElseIf cCampo == "G1_POTENCI"
		If oMdlDet:GetValue("G1_POTENCI") <> 0
			If !Rastro(cComp)
				Help(" ",1,"NAORASTRO")
				lRet:=.F.
			ElseIf !PotencLote(cComp)
				Help(" ",1,"NAOCPOTENC")
				lRet:=.F.
			EndIf
		EndIf
	ElseIf cCampo == "G1_TIPVEC"
		lRet := Vazio() .Or. ExistCpo("SX5","VC"+oMdlDet:GetValue("G1_TIPVEC"))
	ElseIf cCampo == "G1_VECTOR"
		lRet := Vazio() .Or. ExistCpo("SHV",oMdlDet:GetValue("G1_TIPVEC")+oMdlDet:GetValue("G1_VECTOR"),1)
	EndIf

	If lRet .And. !Empty(cComp) .And. nQuant != 0 .And. !oEvent:lModeloAuxiliar
		If cCampo $ "G1_COMP/G1_QUANT/G1_TRT"
			//Insere o produto na tree se for necessário.
			oMdlDet:LoadValue("G1_COD", cPai)

			If lInsere
				JIncrementa(cPai, cComp + cTrt)

				//Verifica se o cargo da linha já não está carregado.
				//Esse cenário acontece quando uma linha da grid é recuperada da deleção.
				cCargo := oMdlDet:GetValue("CARGO")
				If Empty(cCargo)
					cCargo := MontaCargo(IND_ESTR,cPai,cComp,0)
					oMdlDet:LoadValue("CARGO",cCargo)
				EndIf
				//Verifica qual a imagem da TREE.
				If dDataBase < oMdlDet:GetValue("G1_INI") .Or. dDataBase > oMdlDet:GetValue("G1_FIM")
					cImg1 := 'FOLDER7'
					cImg2 := 'FOLDER8'
				EndIf
				AddTree(oModel:GetModel("SG1_COMPON"):GetValue("CARGO"),cCargo,cGrupoOpc,cItemOpc,cTrt,cImg1,cImg2)
			EndIf
		ElseIf cCampo $ "G1_GROPC/G1_OPC"
			//Atualiza o PROMPT da tree. (Opcionais)
			cCargo := oMdlDet:GetValue("CARGO")
			AttPrompt(cCargo, PromptTree(cCargo, cGrupoOpc, cItemOpc))
		ElseIf cCampo $ "G1_INI/G1_FIM"
			//Faz a alteração da imagem da tree
			cCargo := oMdlDet:GetValue("CARGO")
			//Verifica qual a imagem da TREE.
			If dDataBase < oMdlDet:GetValue("G1_INI") .Or. dDataBase > oMdlDet:GetValue("G1_FIM")
				cImg1 := 'FOLDER7'
				cImg2 := 'FOLDER8'
			EndIf
			AttImgTree(cCargo,cImg1,cImg2)
		EndIf
	EndIf

	If cCampo $ "G1_COMP"
		oView := FwViewActive()
		If oEvent:lRefresh
			oView:GetSubView("VIEW_COMPONENTES"):Refresh()
			oEvent:lRefresh := .F.
		EndIf

		FwViewActive(oView)
	EndIf

Return lRet

/*/{Protheus.doc} AddItemTr
Adiciona um item na Tree

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cCargoPai 	- Campo CARGO do pai (G1_COD)
@param cCargoComp	- Campo CARGO do componente (G1_COMP)
@param cPrompt   	- Valor a ser exibido no Prompt da tree
@param cGrupoOpc 	- Grupo opcional do componente (G1_GROPC)
@param cItemOpc  	- Item opcional do componente (G1_OPC)
@param cTrt      	- Sequência do componente (G1_TRT)
@param cImg1     	- Nome da imagem para a TREE, quando o nível estiver fechado
@param cImg2     	- Nome da imagem para a TREE, quando o nível estiver aberto
@param lTmp      	- Indica se será executada a função para adicionar nós temporários na tree
@return lAddTree    - Indica se o componente foi adicionado na tree
/*/
Static Function AddItemTr(cCargoPai, cCargoComp, cPrompt, cGrupoOpc, cItemOpc, cTrt, cImg1, cImg2, lTmp)
	Local cCargoAtu := ""
	Local lAddTree  := .T.
	Local nLen

	Default cPrompt := PromptTree(cCargoComp, cGrupoOpc, cItemOpc)
	Default cImg1   := 'FOLDER5'
	Default cImg2   := 'FOLDER6'
	Default lTmp    := .T.

	If !slTmpTree .And. lTmp
		lTmp := .F.
	EndIf

	aAdd(saCargos,{ P200RetInf(cCargoComp,"PAI") ,; //G1_COD
	                P200RetInf(cCargoComp,"COMP"),; //G1_COMP
	                cTrt                         ,; //G1_TRT
	                cCargoComp                   ,; //CARGO
	                cCargoPai                    ,; //CARGO_PAI
	                cPrompt                      ,; //PROMPT
	                cImg1=="FOLDER5"             ,; //Indicador de imagem de validade válida ou inválida
	                P200RetInf(cCargoComp,"IND")})  //Indicador da tree (IND_ESTR/IND_TEMP)

	nLen := Len(saCargos)
	soCargosCmp[cCargoComp] := nLen
	If soCargosPai[cCargoPai] == Nil
		soCargosPai[cCargoPai] := JsonObject():New()
	EndIf
	soCargosPai[cCargoPai][cCargoComp] := nLen

	If soDbTree <> Nil
		cCargoAtu := soDbTree:GetCargo()

		If cCargoAtu != cCargoPai
			soDbTree:TreeSeek(cCargoPai)
		EndIf

		If slP200EXTR
			lAddTree := ExecBlock("P200EXTR",.F.,.F.,{P200RetInf(cCargoComp, "PAI"), P200RetInf(cCargoComp,"COMP"), cTrt, cGrupoOpc, cItemOpc})
		EndIf

		If lAddTree
			soDbTree:AddItem(cPrompt, cCargoComp, cImg1, cImg2, , , 2)
		EndIf

		//Se este componente possui estrutura, adiciona um item temporário na TREE, para que seja exibido com a opção de navegar na tree (+)
		If lTmp
			AddTmpTree(P200RetInf(cCargoComp,"COMP"), cCargoComp)
		EndIf

		If soDbTree:GetCargo() != cCargoAtu
			soDbTree:TreeSeek(cCargoAtu)
		EndIf
	EndIf
Return lAddTree

/*/{Protheus.doc} addCmpTree
Adiciona componentes na tree de acordo com o que está carregado no modelo de componentes.

@author Lucas Konrad França
@since 12/11/2018
@version 1.0

@param cCargoPai- Cargo do nível pai de onde os componentes serão adicionados.
@param oModel	- Modelo de dados
@return Nil
/*/
Static Function addCmpTree(cCargoPai,oModel)
	Local cCargo    := ""
	Local cIdTree   := ""
	Local cFolderA  := 'FOLDER5'
	Local cFolderB  := 'FOLDER6'
	Local cPrdPai   := P200RetInf(cCargoPai,"COMP")
	Local cNewCargo := ""
	Local lTodosNvl := .T.
	Local nIndFor   := 0
	Local nPos      := 0
	Local nLineAnt  := 0
	Local oEvent    := gtMdlEvent(oModel, "PCPA200EVDEF")
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")

	If saTreeLoad == NIL
		saTreeLoad := {}
	EndIf

	//Verifica no array saTreeLoad se este pai já foi carregado.
	//Se já foi adicionado na TREE, somente sincroniza a Tree com a Grid
	If aScan(saTreeLoad,{|x| x==cCargoPai}) > 0
		SincTreeGr(oMdlDet, cCargoPai)
		Return
	EndIf

	If !P200IsAuto(oModel) .And. soDbTree != NIL
		//Verifica se é necessário posicionar na tree.
		If soDbTree:GetCargo() != cCargoPai
			soDbTree:TreeSeek(cCargoPai)
		EndIf

		//Guarda o ID do nó pai para posicionamento.
		cIdTree := soDbTree:CurrentNodeId

		//Inicializa atualização da tree
		soDbTree:BeginUpdate()

		//Verifica se existe o componente "TEMP" nesse nível da tree, e o apaga.
		cNewCargo := cCargoPai
		cNewCargo := StrTran(cNewCargo,P200RetInf(cNewCargo,"IND"),IND_TEMP)
		If soDbTree:TreeSeek(cNewCargo)
			nPos := soCargosCmp[cNewCargo]
			If nPos != Nil .and. nPos > 0
				InitACargo(nPos)

				soCargosCmp[cNewCargo] := Nil
				If soCargosPai[saCargos[nPos][IND_ACARGO_CARGO_PAI]] != Nil
					soCargosPai[saCargos[nPos][IND_ACARGO_CARGO_PAI]][cNewCargo] := Nil
				EndIf

			EndIf
			soDbTree:DelItem()
			soDbTree:PTGotoToNode(cIdTree)
		EndIf
	EndIf

	//Se o componente da tree não possuir estrutura, não faz a carga.
	If Empty(oMdlDet:GetValue("G1_COMP",1))
		Return
	EndIf

	For nIndFor := 1 To oMdlDet:Length()
		//Supre a exibicao de todos os componentes do mesmo nivel na Tree
		//Inicio - snPadMaxCmp = 999999. Mantido no fonte como tecnica "Carta na manga de melhoria de performance" a pedidos do PO, entretanto "em desuso". Para uso, reduzir snPadMaxCmp para X componentes.
		If nIndFor > snPadMaxCmp .AND. !oEvent:lExpandindo
			//Adiciona o componente EXPANDIR  (. . .) na TREE
			lTodosNvl := .F.
			cCargo    := MontaCargo(IND_ESTR, cPrdPai, ". . .", 0)
			AddItemTr(cCargoPai, cCargo, NIL, "", "", "", "PMSUPDOWN", "PMSUPDOWN",.T.)
			Exit
		EndIf
		//Fim

		//Inicializa a imagem padrão da tree.
		cFolderA := 'FOLDER5'
		cFolderB := 'FOLDER6'

		If oMdlDet:IsDeleted(nIndFor)
			Loop
		EndIf

		//Incrementa a sequência e cria o CARGO
		If Empty(oMdlDet:GetValue("CARGO",nIndFor))
			cCargo := MontaCargo(IND_ESTR, cPrdPai, oMdlDet:GetValue("G1_COMP",nIndFor), oMdlDet:GetValue("NREG",nIndFor))
			nLineAnt := oMdlDet:GetLine()
			oMdlDet:GoLine(nIndFor)
			oMdlDet:LoadValue("CARGO",cCargo)
			oMdlDet:GoLine(nLineAnt)
		Else
			cCargo := oMdlDet:GetValue("CARGO",nIndFor)
			//Verifica se é necessário gerar um novo cargo
			nPos := P200RetInf(cCargo,"POS")
			If (nPos > 0 .And. aScan(saTreeLoad,{|x| x == cCargo}) == 0) .Or. ;
			   (nPos > 0 .And. saCargos[nPos][IND_ACARGO_CARGO_PAI] != cCargoPai)
				If saCargos[nPos][IND_ACARGO_CARGO_PAI] != cCargoPai
					//Gera um cargo novo, pois o cargo que está no modelo é referente a outro PAI
					cCargo := MontaCargo(IND_ESTR,cPrdPai,oMdlDet:GetValue("G1_COMP",nIndFor),oMdlDet:GetValue("NREG",nIndFor))
					nLineAnt := oMdlDet:GetLine()
					oMdlDet:GoLine(nIndFor)
					oMdlDet:LoadValue("CARGO",cCargo)
					oMdlDet:GoLine(nLineAnt)
				EndIf
			EndIf
		EndIf

		If ( oModel:GetOperation() == MODEL_OPERATION_VIEW .or. ;
		oModel:GetOperation() == MODEL_OPERATION_UPDATE )
			If ExistBlock("MT200EXP")
				cCodProd  := P200RetInf(cCargo,"COMP")
				cCodPai   := P200RetInf(cCargo, "PAI")

				aAreaSG1  := GetArea("SG1")

				DbSelectArea("SG1")
				SG1->(DbSetOrder(1))
				SG1->(DbSeek(xFilial("SG1")+cCodPai+cCodProd))

				lMt200Exp := ExecBlock("MT200EXP",.F.,.F., {cCodProd, cCodPai})
				If ( Valtype(lMt200Exp) == "L" ) .AND. !lMt200Exp
					cFolderA := 'FOLDER12'
					cFolderB := 'FOLDER12'
				EndIf

				RestArea(aAreaSG1)
			EndIf
		EndIf

		//Verifica qual a imagem da TREE.
		If dDataBase < oMdlDet:GetValue("G1_INI",nIndFor) .Or. dDataBase > oMdlDet:GetValue("G1_FIM",nIndFor)
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		//Adiciona o componente na TREE
		AddItemTr(cCargoPai, cCargo, NIL, ;
		          oMdlDet:GetValue("G1_GROPC",nIndFor), ;
		          oMdlDet:GetValue("G1_OPC",nIndFor), ;
		          oMdlDet:GetValue("G1_TRT",nIndFor), ;
		          cFolderA, cFolderB,.T.)

	Next nIndFor

	If !P200IsAuto(oModel) .And. soDbTree != Nil
		soDbTree:EndUpdate()
		soDbTree:PTGotoToNode(cIdTree)
	EndIf

	aAdd(saTreeLoad,cCargoPai)
Return

/*/{Protheus.doc} AddTmpTree
Adiciona um nó temporário na tree, apenas para mostrar o botão + quando
o componente possuir estrutura

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cComp	- Código do componente que foi adicionado
@param cCargo	- Cargo do componente que foi adicionado
@return Nil
/*/
Static Function AddTmpTree(cComp, cCargo)
	Local cIdTreeAtu := ""
	Local cNewCargo  := cCargo
	Local oEvent     := gtMdlEvent(FwModelActive(),"PCPA200EVDEF")
	Local lVencido   := Iif(oEvent:nExibeInvalidos == 1, .F.,.T.)
	Local lChangeBkp := slExecChL

	If soDbTree == Nil
		Return
	EndIf

	//Gera o novo cargo para o nó temporário
	cNewCargo := StrTran(cNewCargo, P200RetInf(cNewCargo,"IND"), IND_TEMP)

	//Se esse nó temporário já foi adicionado, não adiciona novamente.
	If soCargosCmp[cNewCargo] != Nil .and. soCargosCmp[cNewCargo] > 0
		Return
	EndIf

	//Verifica se o componente possui estrutura.
	If ExistEstru(cComp, lVencido)
		//Pega o ID do nó posicionado da tree
		cIdTreeAtu := soDbTree:CurrentNodeId

		//Seta variável para não executar o ChangeLine
		slExecChL := .F.

		//Posiciona no componente que foi adicionado na tree
		soDbTree:TreeSeek(cCargo)

		//Adiciona o nó temporário na tree
		AddItemTr(cCargo, cNewCargo, "", "", "", "", "", "",.F.)

		//Retorna para o nó posicionado anteriormente.
		soDbTree:PTGotoToNode(cIdTreeAtu)

		//Retorna o valor da variável do ChangeLine
		slExecChL := lChangeBkp
	EndIf
Return

/*/{Protheus.doc} RmvTmpTree
Remove um nó temporário na tree quando for o caso

@author brunno.costa
@since 13/11/2018
@version 1.0

@param cComp	- Código do componente que foi adicionado
@param cCargo	- Cargo do componente que foi adicionado
@return Nil
/*/
Static Function RmvTmpTree(cComp, cCargo)
	Local cIdTreeAtu := ""
	Local oEvent     := gtMdlEvent(FwModelActive(),"PCPA200EVDEF")
	Local lVencido   := Iif(oEvent:nExibeInvalidos == 1, .F.,.T.)

	If soDbTree == Nil
		Return
	EndIf

	//Atualiza [+] para "" apos delecao de todos os componentes
	If !ExistEstru(cComp, lVencido)
		//Pega o ID do nó posicionado da tree
		cIdTreeAtu := soDbTree:CurrentNodeId

		//Posiciona no componente pai
		If soDbTree:TreeSeek(cCargo)
			soDbTree:DelItem()
			soCargosCmp[cCargo] := Nil
		Endif

		//Retorna para o nó posicionado anteriormente.
		soDbTree:PTGotoToNode(cIdTreeAtu)
	EndIf
Return

/*/{Protheus.doc} AttImgTree
Atualiza a imagem da tree do componente em todos os níveis abertos

@author Lucas Konrad França
@since 16/11/2018
@version 1.0

@param cCargoComp	- CARGO do item que será alterado o Prompt
@param cImg1     	- imagem da tree, para nó Fechado
@param cImg2     	- imagem da tree, para nó Aberto
@return NIL
/*/
Static Function AttImgTree(cCargoComp,cImg1,cImg2)
	Local nPosAtual := P200RetInf(cCargoComp,"POS")
	Local cPai      := saCargos[nPosAtual][IND_ACARGO_PAI]
	Local cComp     := saCargos[nPosAtual][IND_ACARGO_COMP]
	Local cTrt      := saCargos[nPosAtual][IND_ACARGO_TRT]
	Local lValido   := saCargos[nPosAtual][IND_ACARGO_IMGVALIDO]
	Local nPos      := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
	                                         x[IND_ACARGO_COMP] == cComp .And. ;
	                                         x[IND_ACARGO_TRT]  == cTrt })

	If (lValido .And. cImg1 != "FOLDER5") .Or. (!lValido .And. cImg1 == "FOLDER5")
		If soDbTree != NIL
			//Percorre e atualiza todos os itens da Tree
			While nPos > 0
				soDbTree:ChangeBmp(cImg1,cImg2,,,saCargos[nPos][IND_ACARGO_CARGO_COMP])
				saCargos[nPos][IND_ACARGO_IMGVALIDO] := cImg1=="FOLDER5"

				nPos := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
				                              x[IND_ACARGO_COMP] == cComp .And. ;
				                              x[IND_ACARGO_TRT]  == cTrt }, (nPos + 1))
			End
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} AttPrompt
Atualiza o Prompt do componente em todos os níveis abertos

@author Lucas Konrad França
@since 14/11/2018
@version 1.0

@param cCargoComp	- CARGO do item que será alterado o Prompt
@param cPrompt   	- Descrição do novo Prompt para o item
@return NIL
/*/
Static Function AttPrompt(cCargoComp, cPrompt)
	Local nPosAtual := P200RetInf(cCargoComp,"POS")
	Local cPai      := saCargos[nPosAtual][IND_ACARGO_PAI]
	Local cComp     := saCargos[nPosAtual][IND_ACARGO_COMP]
	Local cTrt      := saCargos[nPosAtual][IND_ACARGO_TRT]
	Local nPos      := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
	                                         x[IND_ACARGO_COMP] == cComp .And. ;
	                                         x[IND_ACARGO_TRT]  == cTrt })
	If soDbTree != NIL
		//Percorre e atualiza todos os itens da Tree
		While nPos > 0
			soDbTree:ChangePrompt(cPrompt, saCargos[nPos][IND_ACARGO_CARGO_COMP])
			saCargos[nPos][IND_ACARGO_PROMPT] := cPrompt

			nPos := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
			                              x[IND_ACARGO_COMP] == cComp .And. ;
			                              x[IND_ACARGO_TRT]  == cTrt }, (nPos + 1))
		End
	EndIf
Return

/*/{Protheus.doc} QtdCompon
Retorna a quantidade de componentes do produto

@author brunno.costa
@since 30/05/2019
@version 1.0

@param cCargo	- Cargo do produto selecionado na TREE
@param oModel	- Modelo de dados
@return nQtdComp - Quantidade de componentes do produto
/*/
Static Function QtdCompon(cCargo, oModel)
	Local cProdSelec := P200RetInf(cCargo,"COMP")
	Local cRevisao   := P200IniRev(cProdSelec)
	Local cAliasQry  := QueryLoad(oModel, {}, cRevisao, cProdSelec)
	Local nQtdComp   := 0

	//Loop registros encontrados no banco de dados
	If (cAliasQry)->(!Eof())
		nQtdComp := (cAliasQry)->TOTAL
	EndIf
	(cAliasQry)->(dbCloseArea())

Return nQtdComp

/*/{Protheus.doc} LoadCompon
Carrega os dados que serão exibidos na grid de componentes

@author Lucas Konrad França
@since 09/11/2018
@version 1.0

@param cCargo	- Cargo do produto selecionado na TREE
@param oModel	- Modelo de dados
@param cRevisao	- Revisão utilizada para explodir a estrutura do produto.
@return aLoad	- Array com os dados da SG1.
/*/
Static Function LoadCompon(cCargo, oModel, cRevisao)
	Local aAreaSG1     := SG1->(GetArea())
	Local aData        := oModel:GetModel("SG1_DETAIL"):GetOldData()
	Local aDefDados    := {}
	Local aFields      := oModel:GetModel("SG1_DETAIL"):oFormModelStruct:aFields
	Local aLoad        := {}
	Local cAliasQry    := ""
	Local cIniBrw      := ""
	Local cProdSelec   := P200RetInf(cCargo,"COMP")
	Local nIndCps      := 0
	Local nTamDesc     := GetSx3Cache("G1_DESC","X3_TAMANHO")
	Local nPos         := 0
	Local nLinha
	Local oAdicionados := JsonObject():New()
	Local oEvent       := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local oFields
	Local oLinDel
	Local oLines
	Local oProdutos

	If oEvent:oDadosCommit["oFields"] == Nil
		oEvent:oDadosCommit["oFields"]   := JsonObject():New()
		addaFields(aData[1], @oEvent:oDadosCommit["oFields"])
	EndIf

	oFields   := oEvent:oDadosCommit["oFields"]
	oLinDel   := oEvent:oDadosCommit["oLinDel"]
	oLines    := oEvent:oDadosCommit["oLines"]
	oProdutos := oEvent:oDadosCommit["oProdutos"]

	If oProdutos[cProdSelec] == Nil
		oProdutos[cProdSelec] := JsonObject():New()
	EndIf

	Default cRevisao := oModel:GetModel("SG1_COMPON"):GetValue("CREVCOMP")

	//Se é nova revisão, considera revisão alterior para buscar no banco
	If oEvent:mvlRevisaoAutomatica .AND. aScan(oEvent:aRevisoes, {|x| x[4] == cProdSelec .AND. x[1] }) > 0
		cRevisao := Tira1(cRevisao)
	EndIf

	For nIndCps := 1 to Len(aFields)
		aAdd(aDefDados,Nil)
	Next nIndCps

	If Empty(oModel:GetModel("SG1_COMPON"):GetValue("G1_COD"))
		aAdd(aLoad, {0, aClone(aDefDados)})
	Else
		//Define a query para a busca dos componentes
		cAliasQry := QueryLoad(oModel, aFields, cRevisao, cProdSelec, .F.)

		//Loop registros encontrados no banco de dados
		While (cAliasQry)->(!Eof())
			cChave   := (cAliasQry)->(G1_COMP + G1_TRT)

			//Recupera dados da memoria, quando for o caso
			If oLines[cProdSelec + cChave] != NIL

				//Se estiver parametrizado para não exibir os itens vencidos
				If oEvent:nExibeInvalidos == 2 .And. !CompValido(oLines[cProdSelec+cChave][oFields["G1_INI"]],;
				                                                 oLines[cProdSelec+cChave][oFields["G1_FIM"]])
					(cAliasQry)->(dbSkip())
					Loop
				EndIf

				oAdicionados[cProdSelec + cChave] := .T.
				For nIndCps := 1 To Len(aFields)
					If aFields[nIndCps][14] == .F. //Verifica se é campo virtual
						aDefDados[nIndCps] := oLines[cProdSelec+cChave][oFields[aFields[nIndCps][3]]]

					ElseIf AllTrim(aFields[nIndCps][3]) == "G1_DESC"
						aDefDados[nIndCps] := oLines[cProdSelec+cChave][oFields["G1_DESC"]]

					ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
						aDefDados[nIndCps] := oLines[cProdSelec+cChave][oFields["NREG"]]

					ElseIf AllTrim(aFields[nIndCps][3]) == "CARGO"
						nPos := aScan(saCargos, {|x| x[IND_ACARGO_PAI]       == cProdSelec             .And. ;
													 x[IND_ACARGO_COMP]      == oLines[cProdSelec+cChave][oFields["G1_COMP"]] .And. ;
													 x[IND_ACARGO_TRT]       == oLines[cProdSelec+cChave][oFields["G1_TRT"]]  .And. ;
													 x[IND_ACARGO_CARGO_PAI] == cCargo})
						If nPos > 0
							aDefDados[nIndCps] := saCargos[nPos][IND_ACARGO_CARGO_COMP] //CARGO
						Else
							aDefDados[nIndCps] := MontaCargo(IND_ESTR, ;
															oLines[cProdSelec+cChave][oFields["G1_COD"]], ;
															oLines[cProdSelec+cChave][oFields["G1_COMP"]],;
															oLines[cProdSelec+cChave][oFields["NREG"]])
						EndIf
					ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
						aDefDados[nIndCps] := oLines[cProdSelec+cChave][oFields["G1_TRT"]]

					ElseIf aFields[nIndCps][14] == .T. //Verifica se é campo virtual
						cIniBrw := getSx3Cache(aFields[nIndCps][3], "X3_INIBRW")
						If !Empty(cIniBrw)
							aAreaSG1 := SG1->(GetArea())
							SG1->(DBGOTO(oLines[cProdSelec+cChave][oFields["NREG"]]))
							aDefDados[nIndCps] := &(cIniBrw)
							RestArea(aAreaSG1)
						EndIf
					EndIf
				Next nIndCps


			//Recupera dados do banco, quando for o caso
			Else

				//Se estiver parametrizado para não exibir os itens vencidos
				If oEvent:nExibeInvalidos == 2 .And. !CompValido((cAliasQry)->(G1_INI), (cAliasQry)->(G1_FIM))
					(cAliasQry)->(dbSkip())
					Loop
				EndIf

				For nIndCps := 1 To Len(aFields)
					If aFields[nIndCps][14] == .F. //Verifica se é campo virtual
						aDefDados[nIndCps] := (cAliasQry)->(&(aFields[nIndCps][3]))
					ElseIf AllTrim(aFields[nIndCps][3]) == "G1_DESC"
						aDefDados[nIndCps] := PadR((cAliasQry)->(B1_DESC),nTamDesc)
					ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
						aDefDados[nIndCps] := (cAliasQry)->(RECSG1)
					ElseIf AllTrim(aFields[nIndCps][3]) == "CARGO"
						nPos := aScan(saCargos, {|x| x[IND_ACARGO_PAI]       == cProdSelec             .And. ;
													x[IND_ACARGO_COMP]      == (cAliasQry)->(G1_COMP) .And. ;
													x[IND_ACARGO_TRT]       == (cAliasQry)->(G1_TRT)  .And. ;
													x[IND_ACARGO_CARGO_PAI] == cCargo})
						If nPos > 0
							aDefDados[nIndCps] := saCargos[nPos][IND_ACARGO_CARGO_COMP] //CARGO
						Else
							aDefDados[nIndCps] := MontaCargo(IND_ESTR, ;
															(cAliasQry)->(G1_COD), ;
															(cAliasQry)->(G1_COMP), ;
															(cAliasQry)->(RECSG1))
						EndIf
					ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
						aDefDados[nIndCps] := (cAliasQry)->(G1_TRT)
					ElseIf aFields[nIndCps][14] == .T. //Verifica se é campo virtual
						cIniBrw := getSx3Cache(aFields[nIndCps][3], "X3_INIBRW")
						If !Empty(cIniBrw)
							aAreaSG1 := SG1->(GetArea())
							SG1->(DBGOTO((cAliasQry)->(RECSG1)))
							aDefDados[nIndCps] := &(cIniBrw)
							RestArea(aAreaSG1)
						EndIf
					EndIf
				Next nIndCps

			EndIf

			aAdd(aLoad, {0, aClone(aDefDados)})
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Recupera demais registros de memória, inexistentes no banco de dados
	aChaves := aSort(oProdutos[cProdSelec]:GetNames())

	For nLinha := 1 to Len(aChaves)
		cChave   := aChaves[nLinha]
		cProduto := cProdSelec
		If oAdicionados[cProduto + cChave] == Nil .AND. oLines[cProduto + cChave] != NIL .and. Len(oLines[cProduto+cChave]) > 0
			If oLinDel[cProduto + cChave] != Nil .and. oLinDel[cProduto + cChave]
				Loop
			EndIf

			//Se estiver parametrizado para não exibir os itens vencidos
			If oEvent:nExibeInvalidos == 2 .And. !CompValido(oLines[cProduto+cChave][oFields["G1_INI"]],;
															 oLines[cProduto+cChave][oFields["G1_FIM"]])
				Loop
			EndIf

			For nIndCps := 1 To Len(aFields)
				If aFields[nIndCps][14] == .F. //Verifica se é campo virtual
					aDefDados[nIndCps] := oLines[cProduto+cChave][oFields[aFields[nIndCps][3]]]

				ElseIf AllTrim(aFields[nIndCps][3]) == "G1_DESC"
					aDefDados[nIndCps] := oLines[cProduto+cChave][oFields["G1_DESC"]]

				ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
					aDefDados[nIndCps] := oLines[cProduto+cChave][oFields["NREG"]]

				ElseIf AllTrim(aFields[nIndCps][3]) == "CARGO"
					nPos := aScan(saCargos, {|x| x[IND_ACARGO_PAI]          == cProduto             .And. ;
													x[IND_ACARGO_COMP]      == oLines[cProduto+cChave][oFields["G1_COMP"]] .And. ;
													x[IND_ACARGO_TRT]       == oLines[cProduto+cChave][oFields["G1_TRT"]]  .And. ;
													x[IND_ACARGO_CARGO_PAI] == cCargo})
					If nPos > 0
						aDefDados[nIndCps] := saCargos[nPos][IND_ACARGO_CARGO_COMP] //CARGO
					Else
						aDefDados[nIndCps] := MontaCargo(IND_ESTR, ;
														oLines[cProduto+cChave][oFields["G1_COD"]], ;
														oLines[cProduto+cChave][oFields["G1_COMP"]],;
														oLines[cProduto+cChave][oFields["NREG"]])
					EndIf
				ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
					aDefDados[nIndCps] := oLines[cProduto+cChave][oFields["G1_TRT"]]
				ElseIf aFields[nIndCps][14] == .T. //Verifica se é campo virtual
					cIniBrw := getSx3Cache(aFields[nIndCps][3], "X3_INIBRW")
					If !Empty(cIniBrw)
						aAreaSG1 := SG1->(GetArea())
						SG1->(DBGOTO(oLines[cProdSelec+cChave][oFields["NREG"]]))
						aDefDados[nIndCps] := &(cIniBrw)
						RestArea(aAreaSG1)
					EndIf
				EndIf
			Next nIndCps
			aAdd(aLoad, {0, aClone(aDefDados)})
		EndIf
	Next

	RestArea(aAreaSG1)


	If ExistBlock("PC200ORD")
		bSort := ExecBlock("PC200ORD",.F.,.F.,aFields)
		If bSort <> Nil
			aSort(aLoad,,,bSort)
		EndIf
	EndIf

Return aLoad

/*/{Protheus.doc} ExistEstru
Verifica se um produto possui estrutura

@author Lucas Konrad França
@since 12/11/2018
@version 1.0

@param cProduto	- Código do produto a ser verificado.
@return lRet	- Identifica se o produto possui estrutura
/*/
Static Function ExistEstru(cProduto, lVencido)
	Local aNames     := {}
	Local cQuery     := ""
	Local cRevisao   := ""
	Local lRet       := .F.
	Local lPossuiEst := .F.
	Local nIndex     := 0
	Local nTotal     := 0
	Local oModel     := FwModelActive()
	Local oMdlSelec  := oModel:GetModel("SG1_COMPON")
	Local oMdlDet    := oModel:GetModel("SG1_DETAIL")
	Local oMdlMaster := oModel:GetModel("SG1_MASTER")
	Local oEvent     := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local oLines     := oEvent:oDadosCommit["oLines"]
	Local oLinDel    := oEvent:oDadosCommit["oLinDel"]
	Local oProdutos  := oEvent:oDadosCommit["oProdutos"]

	If cProduto == oMdlSelec:GetValue("G1_COD")
		cRevisao := oMdlSelec:GetValue("CREVCOMP")

	ElseIf cProduto == oMdlMaster:GetValue("G1_COD")
		cRevisao := scRevisao
	Else
		cRevisao := RevisaoPI(oMdlSelec:GetValue("G1_COD"), cProduto, oMdlSelec:GetValue("CREVCOMP"))
	EndIf

	cQuery := "SELECT COUNT(*) TOTREC"
	cQuery += "	FROM "+RetSqlName('SG1') + " SG1"
	cQuery += " WHERE SG1.G1_FILIAL   = '" + xFilial("SG1") + "'"
	cQuery +=   " AND SG1.G1_COD      = '" + cProduto + "'"
	cQuery +=   " AND SG1.G1_REVINI  <= '" + cRevisao + "'"
	cQuery +=   " AND SG1.G1_REVFIM  >= '" + cRevisao + "'"
	cQuery +=   " AND SG1.D_E_L_E_T_ <> '*'"

	If lVencido
		cQuery += " AND SG1.G1_INI <= '" + DToS(dDataBase) + "' AND SG1.G1_FIM >= '" + DToS(dDataBase) + "'"
	EndIf

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSG1E",.F.,.T.)
	If QRYSG1E->TOTREC > 0
		lRet := .T.
	EndIf
	QRYSG1E->(dbCloseArea())

	If !lRet
		If oMdlSelec:GetValue("G1_COD") == cProduto .And. oMdlDet:Length(.T.) .AND. !IsIncallStack("DELETELINE")
			lRet := .T.
		ElseIf oMdlSelec:GetValue("G1_COD") == cProduto .And. oMdlDet:Length(.T.) == 1 .AND. IsIncallStack("DELETELINE")
			lRet := .F.
		ElseIf oEvent:oDadosCommit["oQLinAlt"][cProduto] != Nil .AND. oEvent:oDadosCommit["oQLinAlt"][cProduto] > 0
			lRet := .T.
		EndIf
	Else
		If oMdlSelec:GetValue("G1_COD") == cProduto .And. oMdlDet:Length(.T.) == 1 .AND. IsIncallStack("DELETELINE")
			lRet := .F.
		EndIf
		If lRet .And. oProdutos[cProduto] != Nil
			aNames := oProdutos[cProduto]:GetNames()
			nTotal := Len(aNames)
			lPossuiEst := .F.
			For nIndex := 1 To nTotal
				If oLines[cProduto+aNames[nIndex]]   != Nil .And. ;
				   (oLinDel[cProduto+aNames[nIndex]] == Nil  .Or. ;
				    (oLinDel[cProduto+aNames[nIndex]] != Nil .And. !oLinDel[cProduto+aNames[nIndex]]))
					lPossuiEst := .T.
					Exit
				EndIf
			Next nIndex
			If nTotal > 0 .And. !lPossuiEst
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} cargaSelec
Carrega as informações do componente selecionado na tree para o modelo SG1_COMPON

@author Lucas Konrad França
@since 12/11/2018
@version 1.0

@param cProduto	- Código do produto selecionado.
@param oModel	- Modelo de dados
@param cCargo   - Cargo do item selecionado na TREE
@return Nil
/*/
Static Function cargaSelec(cProduto,oModel,cCargo)
	Local oMdlMaster := oModel:GetModel("SG1_MASTER")
	Local oMdlSelec  := oModel:GetModel("SG1_COMPON")
	Local oView      := FwViewActive()
	Local cRevComp   := ""
	Local lDelete    := oModel:GetOperation() == MODEL_OPERATION_DELETE

	If lDelete
		oMdlSelec:DeActivate()
		oMdlSelec:oFormModel:nOperation := MODEL_OPERATION_VIEW
		oMdlSelec:Activate()
	EndIf
	oMdlSelec:LoadValue("G1_COD",cProduto)
	oMdlSelec:LoadValue("CDESCCMP",PadR(IniDenProd(cProduto),TamSx3('B1_DESC')[1]))
	oMdlSelec:LoadValue("CUMCMP",IniUm(cProduto))

	If cProduto == oMdlMaster:GetValue("G1_COD")
		oMdlMaster:LoadValue("CARGO"  , cCargo)
		oMdlSelec:LoadValue("CREVCOMP", oMdlMaster:GetValue("CREVPAI"))
	Else
		cRevComp := RevisaoPI(P200RetInf(cCargo, "PAI"), cProduto)
		oMdlSelec:LoadValue("CREVCOMP", cRevComp)
	EndIf
	oMdlSelec:LoadValue("CARGO",cCargo)

	If lDelete
		oMdlSelec:DeActivate()
		oMdlSelec:oFormModel:nOperation := MODEL_OPERATION_DELETE
		oMdlSelec:Activate()
		If oView != Nil .And. oView:IsActive()
			oView:Refresh("VIEW_SELECIONADO")
			If soDbTree != Nil
				soDbTree:SetFocus()
			EndIf
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} P200GravAl
Grava as alterações realizadas no objeto com dados para commit, que posteriormente será utilizado
para efetivar as alterações no banco.

@author Lucas Konrad França
@since 12/11/2018
@version 1.0

@param oModel	- Modelo de dados
@param lDiverg  - Identifica se está gravando uma divergência do PCPA120
@param nLineErr - Linha do modelo de dados relacionada a divergência
@return Nil
/*/
Function P200GravAl(oModel, lDiverg, nLineErr)
	Local oMdlDet    := oModel:GetModel("SG1_DETAIL")
	Local aData      := oMdlDet:GetOldData()
	Local aLinAlt    := oMdlDet:GetLinesChanged()
	Local cProdPai
	Local cProdSelec := oModel:GetModel("SG1_COMPON"):GetValue("G1_COD")
	Local nIndLin    := 0
	Local nLinha
	Local oEvent     := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local oFields
	Local oLines
	Local oLinDel
	Local oProdutos
	Local oQLinAlt
	Local oRecnos
	Local oErros

	Default lDiverg  := .F.
	Default nLineErr := 0

	oEvent:lExecutaPreValid := .F.

	If oEvent:oDadosCommit["oFields"] == Nil
		oEvent:oDadosCommit["oFields"]   := JsonObject():New()
		addaFields(aData[1], @oEvent:oDadosCommit["oFields"])
	EndIf

	oFields   := oEvent:oDadosCommit["oFields"]
	oLinDel   := oEvent:oDadosCommit["oLinDel"]
	oLines    := oEvent:oDadosCommit["oLines"]
	oProdutos := oEvent:oDadosCommit["oProdutos"]
	oQLinAlt  := oEvent:oDadosCommit["oQLinAlt"]
	oRecnos   := oEvent:oDadosCommit["oRecnos"]
	oErros    := oEvent:oDadosCommit["oErros"]

	If oProdutos[cProdSelec] == Nil
		oProdutos[cProdSelec] := JsonObject():New()
	EndIf

	For nIndLin := 1 To Len(aLinAlt)
		nLinha := aLinAlt[nIndLin]
		If Empty(oMdlDet:GetValue("G1_COMP", nLinha))
			Loop
		EndIf

		oMdlDet:GoLine(nLinha)
		cChave := oMdlDet:GetValue("G1_COMP", nLinha)
		If oMdlDet:GetValue("NREG",nLinha) > 0
			cChave += oMdlDet:GetValue("CSEQORIG" , nLinha)
		Else
			cChave += oMdlDet:GetValue("G1_TRT" , nLinha)
		EndIf

		aAdd(aData[2][nLinha], oMdlDet:GetDataID()) //RECNO
		aAdd(aData[2][nLinha], .F.)                 //NovaRevisao

		oProdutos[cProdSelec][cChave]            := nLinha
		oLines[cProdSelec + cChave]              := aData[2][nLinha]
		oLinDel[cProdSelec + cChave]             := oMdlDet:IsDeleted()
		oRecnos[cValToChar(oMdlDet:GetDataID())] := cProdSelec + cChave

		If lDiverg .And. nLinha == nLineErr
			oErros[cProdSelec + cChave] := aClone(aData[2][nLinha])
		EndIf

	Next nIndLin

	//Remove lock's
	If Len(aLinAlt) == 0
		cProdPai   := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
		If cProdPai != cProdSelec
			oEvent:UnLock(cProdSelec)
		EndIf
	EndIf

	oEvent:lExecutaPreValid := .T.

Return Nil

/*/{Protheus.doc} addaFields
Popula objeto JSON com posicoes dos campos aFields

@author brunno.costa
@since 20/05/2019
@version 1.0

@param 01 - aFields, array , array aFields do objeto de Grid
@param 02 - oFields, objeto, objeto Json para popular
@return NIL
/*/
Static Function addaFields(aFields, oFields)
	Local nInd
	Local cCampo
	For nInd := 1 to Len(aFields)
		cCampo := aFields[nInd][2]
		oFields[cCampo] := nInd
	Next

	nInd++
	oFields["RECNO"] := nInd

	nInd++
	oFields["NovaRevisao"] := nInd
Return

/*/{Protheus.doc} RecupAlter
Recupera as alterações gravadas no modelo de gravação (utilizado quando volta para um item que foi modificado anteriormente)

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cCargo	- CARGO do item da tree a ser recuperado
@return NIL
/*/
Static Function RecupAlter(cCargo)
	Local bLoad     := NIL
	Local cProduto
	Local oModel    := FwModelActive()
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")
	Local aFields   := oMdlDet:oFormModelStruct:aFields
	Local oEvent    := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local lDiverg   := .F.
	Local nLinha    := 0
	Local nIndex    := 0
	Local nPosComp  := 0
	Local nPosTrt   := 0
	Local oProdutos := oEvent:oDadosCommit["oProdutos"]
	Local oFields   := oEvent:oDadosCommit["oFields"]
	Local oLinDel   := oEvent:oDadosCommit["oLinDel"]
	Local oLines    := oEvent:oDadosCommit["oLines"]
	Local oErros    := oEvent:oDadosCommit["oErros"]


	oEvent:lExecutaPreValid := .F.

	If oModel:GetOperation() == MODEL_OPERATION_VIEW .And. Len(oLines:GetNames()) > 0
		//Tratativa para visualizar as informações na tela de Divergências do PCPA120
		lDiverg := .T.

		//Retira o bloco de carga do modelo para não carregar novamente
		bLoad := oMdlDet:bLoad
		oMdlDet:bLoad := {|X,Y|FORMLOADGRID(X,Y)}

		oMdlDet:DeActivate()
		oMdlDet:oFormModel:nOperation := MODEL_OPERATION_UPDATE
		oMdlDet:Activate()
	EndIf

	//Enquanto encontra modificações no modelo de gravação
	cProduto := P200RetInf(cCargo, "COMP")
	If oProdutos[cProduto] != Nil
		aChaves := oProdutos[cProduto]:GetNames()
		For nIndex := 1 to Len(aChaves)
			cChave := aChaves[nIndex]
			If oProdutos[cProduto][cChave] == Nil
				Loop
			ENDIF
			nPosComp := aScan(aFields,{|X| AllTrim(X[3]) == "G1_COMP"})
			nPosTrt  := aScan(aFields,{|X| AllTrim(X[3]) == "G1_TRT"})
			nLinha   := aScan(oMdlDet:aCols, { |x| AllTrim(x[nPosComp]+x[nPosTrt])  == AllTrim(cChave) })

			If nLinha == 0
				If !Empty(oMdlDet:GetValue("G1_COD"))
					oMdlDet:AddLine()
				EndIf
			Else
				oMdlDet:GoLine(nLinha)
			EndIf

			If oLinDel[cProduto + cChave] != Nil .And. oLinDel[cProduto + cChave]
				oEvent:lExecutaPreValid := .F.
				oMdlDet:DeleteLine()
				oEvent:lExecutaPreValid := .T.
			EndiF

			loadValMdl(aFields, cCargo, @oLines, cProduto+cChave, @oFields, @oMdlDet)

			If lDiverg .And. oErros[cProduto+cChave] != Nil
				If oErros[cProduto+cChave][oFields["NREG"]] < 1
					oMdlDet:AddLine()
				EndIf

				oEvent:lExecutaPreValid := .F.
				oMdlDet:DeleteLine()

				loadValMdl(aFields, cCargo, @oErros, cProduto+cChave, @oFields, @oMdlDet)

				oEvent:lExecutaPreValid := .T.

			EndIf
		Next
	EndIf

	If lDiverg

		oMdlDet:DeActivate()
		oMdlDet:oFormModel:nOperation := MODEL_OPERATION_VIEW
		oMdlDet:Activate()

		//Restaura o bloco de Load
		oMdlDet:bLoad := bLoad
	EndIf

	oMdlDet:GoLine(1)
	oEvent:lExecutaPreValid := .T.
Return

/*/{Protheus.doc} loadValMdl
Carrega o valor dos campos no modelo de dados

@author Lucas Konrad França
@since 06/01/2020
@version 1.0

@param aFields, Array    , Array dos campos do modelo
@param cCargo , Character, CARGO do item da tree
@param oDados , Object   , Objeto JSON com os dados que serão adicionados no modelo
@param cChave , Character, Chave do objeto JSON
@param oFields, Object   , Objeto JSON com as posições dos campos em oDados.
@param oMdlDet, Object   , Objeto do modelo de dados onde os dados serão adicionados
@return Nil
/*/
Static Function loadValMdl(aFields, cCargo, oDados, cChave, oFields, oMdlDet)
	Local cCampo   := ""
	Local nIndCps  := 0
	Local nPos     := 0
	Local aAreaSG1 := {}
	Local cIniBrw  := ""

	If oDados[cChave] != Nil

		For nIndCps := 1 To Len(aFields)
			cCampo := AllTrim(aFields[nIndCps][3])
			If aFields[nIndCps][14] == .F. //Verifica se é campo virtual
				oMdlDet:LoadValue(cCampo, oDados[cChave][oFields[cCampo]])
			ElseIf cCampo == "G1_DESC"
				oMdlDet:LoadValue(cCampo, oDados[cChave][oFields["G1_DESC"]])
			ElseIf cCampo == "NREG"
				oMdlDet:LoadValue(cCampo, oDados[cChave][oFields["NREG"]])
			ElseIf cCampo == "CARGO"
				nPos := aScan(saCargos, {|x| x[IND_ACARGO_PAI]       == oDados[cChave][oFields["G1_COD"]]  .And. ;
											 x[IND_ACARGO_COMP]      == oDados[cChave][oFields["G1_COMP"]] .And. ;
											 x[IND_ACARGO_TRT]       == oDados[cChave][oFields["G1_TRT"]]  .And. ;
											 x[IND_ACARGO_CARGO_PAI] == cCargo})
				If nPos > 0
					oMdlDet:LoadValue(cCampo, saCargos[nPos][IND_ACARGO_CARGO_COMP])
				Else
					oMdlDet:LoadValue(cCampo, oDados[cChave][oFields[cCampo]])
				EndIf
			ElseIf cCampo == "CSEQORIG"
				oMdlDet:LoadValue(cCampo, oDados[cChave][oFields["CSEQORIG"]])
			ElseIf aFields[nIndCps][14] == .T. //Verifica se é campo virtual
				cIniBrw := getSx3Cache(aFields[nIndCps][3], "X3_INIBRW")
				If !Empty(cIniBrw)
					aAreaSG1 := SG1->(GetArea())
					DbSelectArea("SG1")
					SG1->(DbSetOrder(2))
					SG1->(dbSeek(xFilial("SG1")+oDados[cChave][oFields["G1_COMP"]]))
					oMdlDet:LoadValue(cCampo, &(cIniBrw))
					SG1->(dbCloseArea())
					RestArea(aAreaSG1)
				EndIf
			EndIf
		Next nIndCps
	EndIf
Return

/*/{Protheus.doc} CheckEstru
Verifica a recursividade da estrutura

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param oModel	- Objeto do modelo de dados
@return lRet	- Indica se o código digitado está válido.
/*/
Static Function CheckEstru(oModel)
	Local aAreaG1    := {}
	Local lRet       := .T.
	Local lErrAltern := .F.
	Local oMdlSelec  := oModel:GetModel("SG1_COMPON")
	Local oMdlDet    := oModel:GetModel("SG1_DETAIL")
	Local cPai       := oMdlSelec:GetValue("G1_COD")
	Local cCargoPai  := oMdlSelec:GetValue("CARGO")
	Local cComp      := oMdlDet:GetValue("G1_COMP")
	Local cMsgEstr   := ""
	Local cHelp      := ""
	Local oEvent     := gtMdlEvent(oModel, "PCPA200EVDEF")

	If ExistAcima(cComp, cCargoPai)
		Help(,,"Help",,STR0030,;  //"Esse componente já foi informado nessa estrutura."
		     1, 0,,,,,,{STR0032}) //"Verifique o componente digitado."
		lRet := .F.
	ElseIf ExistTree(cPai, cComp, @cMsgEstr, @lErrAltern)
		cHelp := STR0031 + AllTrim(cMsgEstr) + " > " + AllTrim(cPai)
		If lErrAltern
			cHelp += ")"
		EndIf
		Help(,,"Help",,cHelp,;   //"Operação não permitida. Incluir esse componente causará recursividade na estrutura: "
		     1,0,,,,,,{STR0032}) //"Verifique o componente digitado."
		lRet := .F.
	Else
		aAreaG1 := SG1->(GetArea())
		SG1->(dbSetOrder(2))
		If ExistTable(cPai, cComp, @cMsgEstr, oEvent:oDadosCommit, xFilial("SG1"), .F., .F., @lErrAltern, .F.)
			cHelp := STR0031 + AllTrim(cMsgEstr) + " > " + AllTrim(cPai)
			Help(,,"Help",,cHelp,;   //"Operação não permitida. Incluir esse componente causará recursividade na estrutura: "
			     1,0,,,,,,{STR0032}) //"Verifique o componente digitado."
			lRet := .F.
		Else
			//Verifica se esse componente possui estrutura, e se essa estrutura irá se tornar recursiva
			SG1->(dbSetOrder(1))
			If ExistTable(cComp, cPai, @cMsgEstr, oEvent:oDadosCommit, xFilial("SG1"), .T., .T., @lErrAltern, .F.)
				cHelp := STR0031 + AllTrim(cMsgEstr)
				If !lErrAltern
					cHelp += " > " + AllTrim(cPai)
				EndIf
				Help(,,"Help",,cHelp,;  //"Operação não permitida. Incluir esse componente causará recursividade na estrutura: "
					1,0,,,,,,{STR0032}) //"Verifique o componente digitado."
				lRet := .F.
			EndIf
		EndIf
		SG1->(RestArea(aAreaG1))
	EndIf
Return lRet

/*/{Protheus.doc} ExistAcima
Verifica se o componente já existe na mesma estrutura em que está digitando

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cComp		- Código do componente
@param cCargoPai	- CARGO do pai do componente
@return lExiste		- Indica se o componente já existe na estrutura
/*/
Static Function ExistAcima(cComp, cCargoPai)
	Local nPos    := 0
	Local lExiste := .F.

	//É igual ao Pai?
	If cComp == P200RetInf(cCargoPai, "COMP")
		lExiste := .T.
	Else
		//É igual ao Vô?
		If cComp == P200RetInf(cCargoPai, "PAI")
			lExiste := .T.
		Else
			//Percorre os níveis acima presentes na tela
			nPos := soCargosCmp[cCargoPai]
			While nPos != Nil .and. nPos > 0
				If cComp == P200RetInf(saCargos[nPos][IND_ACARGO_CARGO_COMP], "PAI")
					lExiste := .T.
					Exit
				Else
					If cComp == P200RetInf(saCargos[nPos][IND_ACARGO_CARGO_PAI], "PAI")
						lExiste := .T.
						Exit
					EndIf
				EndIf

				nPos := soCargosCmp[saCargos[nPos][IND_ACARGO_CARGO_PAI]]
			End
		EndIf
	EndIf
Return lExiste

/*/{Protheus.doc} ExistTree

Percorre todas as estruturas da tree onde o pai (cCodPesq) é usado validando se o componente digitado (cCodValid) já existe

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cCodPesq		- código do item para pesquisa
@param cCodValid	- código do componente a ser comparado
@param cMsgEstr		- (referência) caminho da estrutura que ficará inconsistente
@param lErrAltern	- Retorna por referência se ocorreu erro de recursividade em produtos alternativos.
@return lExiste		- Indica se o item é usado na estrutura
/*/
Static Function ExistTree(cCodPesq, cCodValid, cMsgEstr, lErrAltern)
	Local cAlterna := ""
	Local nPos     := aScan(saCargos, { |x| x[IND_ACARGO_COMP] == cCodPesq })
	Local lExiste  := .F.

	//Percorre os pais do item
	While nPos > 0
		//Se encontrou um item igual, causará erro na estrutura (infinita)
		If cCodValid == saCargos[nPos][IND_ACARGO_PAI]
			lExiste  := .T.
			cMsgEstr := AllTrim(saCargos[nPos][IND_ACARGO_PAI])
			Exit
		EndIf

		//Verifica os avós
		If ExistTree(saCargos[nPos][IND_ACARGO_PAI], cCodValid, @cMsgEstr, @lErrAltern)
			lExiste  := .T.

			cMsgEstr := AllTrim(cMsgEstr) + " > " + AllTrim(saCargos[nPos][IND_ACARGO_PAI])
			If lErrAltern
				cMsgEstr += ")"
				lErrAltern := .F.
			EndIf

			Exit
		EndIf

		nPos := aScan(saCargos, { |x| x[IND_ACARGO_COMP] == cCodPesq }, (nPos + 1))
	End

	If !lExiste .And. vldAlter()
		cAlterna := produzAlt(cCodValid)
		If !Empty(cAlterna)
			If cAlterna == cCodPesq
				lExiste    := .T.
				lErrAltern := .T.
				cMsgEstr := AllTrim(cCodValid) + " -> (" + STR0229 //"Produto alternativo"
			EndIf
		EndIf
	EndIf
Return lExiste

/*/{Protheus.doc} ExistTable
Percorre todas as estruturas onde o pai (cCodPesq) é usado validando se o componente digitado (cCodValid) já existe
Obs: Por ser uma função recursiva, antes de executar esta função deve ser feito o dbSetOrder()
     para o alias SG1. GetArea e RestArea para o alias SG1 deve ser feito também pela função chamadora.
	 Quando lPai := .T., o deverá usar o índice 1 da SG1 (SG1->(dbSetOrder(1)))
	 Quando lPai := .F., o deverá usar o índice 2 da SG1 (SG1->(dbSetOrder(2)))

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cCodPesq		- código do item para pesquisa
@param cCodValid	- código do componente a ser comparado
@param cMsgEstr		- (referência) caminho da estrutura que ficará inconsistente
@param oDadosCommit - Objeto Json com os dados para commit
@param cFilSG1		- Filial utilizada no seek da tabela SG1.
@param lPai			- Identifica se a validação é para o produto pai. Nesse caso, faz a busca no sentido PAI->COMPON
                      verificando se o G1_COMP é igual ao cCodValid.
					  Se não for o produto pai, faz a busca no sentido COMPON->PAI, verificando se o G1_COD é igual ao cCodValid.
@param lVerAlt      - Identifica se serão verificados os produtos alternativos.
@param lErrAltern   - Retorna por referência se ocorreu erro de recursividade em produtos alternativos.
@param lVldAlt      - Indica que está executando validação de produto alternativo.
@return lExiste		- Indica se o item é usado na estrutura
/*/
Static Function ExistTable(cCodPesq, cCodValid, cMsgEstr, oDadosCommit, cFilSG1, lPai, lVerAlt, lErrAltern, lVldAlt)
	Local lExiste  := .F.
	Local lEntrou  := .F.
	Local cCodG1   := ""
	Local cAlterna := ""
	Local nRecAtu  := 0

	If FindFunction("PCPA200REC")
		lExiste := PCPA200REC(cCodPesq, cCodValid, @cMsgEstr, oDadosCommit, cFilSG1, lPai)

	Else
		//Percorre os pais do item
		If SG1->(dbSeek(cFilSG1 + cCodPesq, .F.))
			lEntrou := .T.
			While !SG1->(Eof()) .And. ;
				SG1->G1_FILIAL == cFilSG1 .And. ;
				Iif(lPai,SG1->G1_COD,SG1->G1_COMP) == cCodPesq

				//Se o item foi deletado da tela deve ser desconsiderado
				If oDadosCommit["oLines"][SG1->(G1_COD + G1_COMP + G1_TRT)] != Nil
					//Se o item foi deletado da estrutura, desconsidera
					If oDadosCommit["oLinDel"][SG1->(G1_COD + G1_COMP + G1_TRT)]
						SG1->(dbSkip())
						Loop
					EndIf
				EndIf

				If lPai
					cCodG1 := SG1->G1_COMP
				Else
					cCodG1 := SG1->G1_COD
				EndIf

				//Se encontrou um item igual, causará erro na estrutura (infinita)
				If cCodValid == cCodG1
					lExiste  := .T.
					cMsgEstr := AllTrim(cCodG1)
					Exit
				EndIf

				//Verifica os avós do item
				nRecAtu := SG1->(Recno())
				If ExistTable(cCodG1, cCodValid, @cMsgEstr, oDadosCommit, cFilSG1, lPai, lVerAlt, @lErrAltern, lVldAlt)
					SG1->(dbGoTo(nRecAtu))
					lExiste  := .T.
					If lErrAltern
						If Left(cMsgEstr, Len(AllTrim(cCodG1))+2) == AllTrim(cCodG1) + " >"
							//Validação para não adicionar o código do componente 2x
							cMsgEstr := AllTrim(SG1->G1_COD) + " > " + AllTrim(cMsgEstr)
						Else
							cMsgEstr := AllTrim(SG1->G1_COD) + " > " + AllTrim(cCodG1) + " > " + AllTrim(cMsgEstr)
						EndIf
					Else
						If lVldAlt
							cMsgEstr := AllTrim(cCodG1) + " > " + AllTrim(cMsgEstr)
						Else
							cMsgEstr := AllTrim(cMsgEstr) + " > " + AllTrim(cCodG1)
						EndIf
					EndIf
					Exit
				EndIf
				SG1->(dbGoTo(nRecAtu))

				SG1->(dbSkip())
			End
		EndIf
	EndIf

	If !lExiste .And. lVerAlt .And. vldAlter()
		cAlterna := produzAlt(cCodPesq)
		If !Empty(cAlterna)
			If cAlterna == cCodValid
				lExiste    := .T.
				lErrAltern := .T.
				cMsgEstr := "(" + STR0229 + " " + AllTrim(cAlterna) + ")" //"Produto alternativo"
				If !lEntrou
					//Se é um produto sem estrutura, adiciona seu código na mensagem de erro.
					cMsgEstr := AllTrim(cCodPesq) + " > " + cMsgEstr
				EndIf
			Else
				If ExistTable(cAlterna, cCodValid, @cMsgEstr, oDadosCommit, cFilSG1, lPai, lVerAlt, @lErrAltern, .T.)
					lExiste    := .T.
					lErrAltern := .T.
					If Left(cMsgEstr, Len(AllTrim(cCodPesq))+2) == AllTrim(cCodPesq) + " >"
						cMsgEstr := "(" + STR0229 + " " + AllTrim(cAlterna) + ") > " + AllTrim(cMsgEstr) //"Produto alternativo"
					Else
						cMsgEstr := AllTrim(cCodPesq) + " > (" + STR0229 + " " + AllTrim(cAlterna) + ") > " + AllTrim(cMsgEstr) //"Produto alternativo"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lExiste

/*/{Protheus.doc} AddTree
Adiciona um novo componente na TREE

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param cCargoPai	- CARGO do produto Pai
@param cCargoComp	- Cargo utilizado para o novo componente
@param cGrupoOpc	- Grupo de opcionais
@param cItemOpc		- Item opcional
@param cTrt			- Sequência do componente
@param cImg1		- Nome da imagem para a TREE, quando o nível estiver fechado
@param cImg2		- Nome da imagem para a TREE, quando o nível estiver aberto

@return Nil
/*/
Static Function AddTree(cCargoPai,cCargoComp,cGrupoOpc,cItemOpc,cTrt,cImg1,cImg2)
	Local cCargoAtu := ""
	Local cPai      := P200RetInf(cCargoComp,"PAI")
	Local nPos      := 0

	If soDbTree != Nil
		cCargoAtu := soDbTree:GetCargo()
	EndIf

	If saTreeLoad == NIL
		saTreeLoad := {}
	EndIf

	nPos := aScan(saCargos, {|x| x[IND_ACARGO_COMP] == cPai})
	//Se o PAI não estiver na Tree, apenas adiciona o componente.
	If nPos == 0
		AddItemTr(cCargoPai,cCargoComp,NIL,cGrupoOpc,cItemOpc,cTrt,cImg1,cImg2,.T.)
		If aScan(saTreeLoad,{|x| x==cCargoPai}) == 0
			aAdd(saTreeLoad,cCargoPai)
		EndIf
	Else
		//Primeiro adiciona no nó que está selecionado na tree para manter o cargo recebido por parâmetro.
		AddItemTr(cCargoPai,cCargoComp,NIL,cGrupoOpc,cItemOpc,cTrt,cImg1,cImg2,.T.)
		If aScan(saTreeLoad,{|x| x==cCargoPai}) == 0
			aAdd(saTreeLoad,cCargoPai)
		EndIf

		//Percorre a TREE para adicionar o componente em todos os pais
		While nPos > 0
			//Somente carrega se for diferente do nó selecionado na tree, pois este nó já foi carregado antes do while.
			If saCargos[nPos][IND_ACARGO_CARGO_COMP] != cCargoPai
				//Verifica no array saTreeLoad se este pai já foi carregado.
				//Se já foi carregado adiciona o componente. Se não foi carregado ainda, adiciona o nó temporário
				If cCargoPai != saCargos[nPos][IND_ACARGO_CARGO_COMP] .And. aScan(saTreeLoad,{|x| x==saCargos[nPos][IND_ACARGO_CARGO_COMP]}) == 0
					AddTmpTree(P200RetInf(saCargos[nPos][IND_ACARGO_CARGO_COMP],"COMP"),saCargos[nPos][IND_ACARGO_CARGO_COMP])
				Else
					AddItemTr(saCargos[nPos][IND_ACARGO_CARGO_COMP],cCargoComp,NIL,cGrupoOpc,cItemOpc,cTrt,cImg1,cImg2,.T.)
					If aScan(saTreeLoad,{|x| x==saCargos[nPos][IND_ACARGO_CARGO_COMP]}) == 0
						aAdd(saTreeLoad,saCargos[nPos][IND_ACARGO_CARGO_COMP])
					EndIf
				EndIf
			EndIf

			cCargoComp := MontaCargo(P200RetInf(cCargoComp,"IND")     , ;
			                 P200RetInf(cCargoComp,"PAI")     , ;
			                 P200RetInf(cCargoComp,"COMP")     , ;
			                 P200RetInf(cCargoComp,"RECNO"))
			nPos := aScan(saCargos, { |x| x[IND_ACARGO_COMP] == cPai .And. x[IND_ACARGO_IND] != IND_TEMP}, (nPos + 1))
		End
	EndIf

	If !Empty(cCargoAtu)
		soDbTree:TreeSeek(cCargoAtu)
	EndIf
Return Nil

/*/{Protheus.doc} P200DelIt
Remove um item da Tree

@author Lucas Konrad França
@since 14/11/2018
@version 1.0

@param cCargoPai	- Campo CARGO do pai (G1_COD)
@param cCargoComp	- Campo CARGO do componente (G1_COMP)
@return NIL
/*/
Function P200DelIt(cCargoPai, cCargoComp)
	Local aCargosPai := {}
	Local cComp      := ""
	Local cPai       := ""
	Local cTrt       := ""
	Local lRemoveTmp := .T.
	Local nFilhos    := 0
	Local nPosAtual  := P200RetInf(cCargoComp, "POS")
	Local nPos       := 0
	Local nLenArr    := 0
	Local oModel     := FwModelActive()
	Local oEvent     := gtMdlEvent(oModel, "PCPA200EVDEF")
	Local oLinDel    := oEvent:oDadosCommit["oLinDel"]
	If nPosAtual > 0
		nLenArr := Len(saCargos)
		cPai    := saCargos[nPosAtual][IND_ACARGO_PAI]
		cComp   := saCargos[nPosAtual][IND_ACARGO_COMP]
		cTrt    := saCargos[nPosAtual][IND_ACARGO_TRT]

		If soDbTree != Nil
			nFilhos := 0
			For nPos := 1 To nLenArr
				If saCargos[nPos][IND_ACARGO_CARGO_PAI] == cCargoPai
					nFilhos++
					If nFilhos > 1
						lRemoveTmp := .F.
						Exit
					EndIf
				EndIf
			Next nPos
			If lRemoveTmp
				//Identifica os pais do componente para atualizar o [+] quando nao existir estrutura
				nPos := aScan(saCargos, { |x| x[IND_ACARGO_COMP]  == cPai })
				While nPos > 0 .AND. !Empty(cPai)
					If saCargos[nPos][IND_ACARGO_CARGO_COMP] != soDbTree:GetCargo();
					.AND. "TEMP" == P200RetInf(saCargos[nPos][IND_ACARGO_CARGO_COMP], "IND")
						aAdd(aCargosPai, saCargos[nPos][IND_ACARGO_CARGO_COMP])
					EndIf
					nPos := aScan(saCargos, { |x| x[IND_ACARGO_COMP]  == cPai }, nPos + 1)
				EndDo
			EndIf
		EndIf

		//Percorre a tree buscando o componente removido
		nPos := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
		                              x[IND_ACARGO_COMP] == cComp .And. ;
		                              x[IND_ACARGO_TRT]  == cTrt })
		If !Empty(cPai)
			While nPos > 0
				slExecChL := .F.
				If soDbTree != Nil .And. soDbTree:TreeSeek(saCargos[nPos][IND_ACARGO_CARGO_COMP])
					soDbTree:DelItem()
				EndIf
				slExecChL := .T.

				//Exclui as alterações realizadas no componente
				ExcluiAlt(saCargos[nPos][IND_ACARGO_CARGO_COMP], oModel)

				InitACargo(nPos)

				nPos := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
										      x[IND_ACARGO_COMP] == cComp .And. ;
										      x[IND_ACARGO_TRT]  == cTrt }, nPos+1)
			End
		EndIf

		JDecrementa(cPai, cComp + cTrt)
		oLinDel[cPai +cComp + cTrt] := .T.

		//Atualiza [+] dos pais do componente
		nLen := Len(aCargosPai)
		While nLen > 0
			slExecChL := .F.
			If soDbTree != Nil
				RmvTmpTree(cPai, aCargosPai[1])
				aDel(aCargosPai, 1)
				nLen := nLen - 1
				aSize(aCargosPai, nLen)
			EndIf
			slExecChL := .T.
		End

		If soDbTree != Nil
			soDbTree:TreeSeek(cCargoPai)
		EndIf
	EndIf
Return

/*/{Protheus.doc} P200Reload
Recarrega os itens da GRID de detalhes conforme banco

@author brunno.costa
@since 09/04/2019
@version 1.0

@param cOldCargo	- Campo CARGO a ser recarregado
@return NIL
/*/
Function P200Reload(cOldCargo)
	Local oModel    := FwModelActive()
	Local nPos      := 0
	Local nLen
	Local cCargoPai
	Local cCargoComp
	Local aCargosCmp
	Local nInd
	Local nTotal

	Default cOldCargo := Iif(soDbTree != Nil, soDbTree:GetCargo(), Nil)

	If cOldCargo != Nil
		If Empty(oModel:GetModel("SG1_DETAIL"):GetValue("CARGO"))
			oModel:GetModel("SG1_DETAIL"):GoLine(1)
		EndIf

		aCargosCmp := Iif(soCargosPai[cOldCargo] == Nil, {}, soCargosPai[cOldCargo]:GetNames())
		nTotal     := Len(aCargosCmp)

		//Loop Filhos
		For nInd := 1 to nTotal
			cCargoPai  := cOldCargo
			cCargoComp := aCargosCmp[nInd]
			P200DelIt(cCargoPai, cCargoComp)
		Next

		//Remove cargo do array de controle
		nPos := aScan(saTreeLoad,{|x| x == cOldCargo})
		If nPos > 0
			nLen := Len(saTreeLoad)
			aDel(saTreeLoad , nPos)
			aSize(saTreeLoad, nLen-1)
		Endif

		//Recarrega grid
		P200TreeCh(.T., cOldCargo, .T.)

		If soDbTree != Nil
			soDbTree:Refresh()
		EndIf
	EndIf

Return

/*/{Protheus.doc} ExcluiAlt
Exclui as alterações realizadas nos componentes excluídos

@author Lucas Konrad França
@since 14/11/2018
@version 1.0

@param cCargoExcl	- CARGO do componente removido
@param oModel		- Modelo de dados
@return NIL
/*/
Static Function ExcluiAlt(cCargoExcl, oModel)
	Local nPos
	Local nLen       := ""
	Local nPosTree   := 0
	Local aCargosCmp := Iif(soCargosPai[cCargoExcl] == Nil, {}, soCargosPai[cCargoExcl]:GetNames())
	Local nTotal     := Len(aCargosCmp)
	Local nInd

	//Percorre os níveis abaixo do componente para eliminar as alterações salvas
	For nInd := 1 to nTotal
		nPos := soCargosPai[cCargoExcl][aCargosCmp[nInd]]

		//Chamada recursiva para o componente do componente
		ExcluiAlt(aCargosCmp[nInd], oModel)

		//Se alguma alteração foi salva no modelo de gravação, remove a mesma
		nPosTree := aScan(saTreeLoad,{|x| x == cCargoExcl})

		If nPosTree > 0
			nLen := Len(saTreeLoad)
			aDel(saTreeLoad,nPosTree)
			aSize(saTreeLoad,nLen-1)
		EndIf

		InitACargo(nPos)
	Next
Return

/*/{Protheus.doc} InitACargo
Inicializa as informações de uma determinada posição do array saCargos

@author Lucas Konrad França
@since 23/11/2018
@version 1.0

@param nPos	- Posição do array saCargos que deverá ser inicializada.
@return NIL
/*/
Static Function InitACargo(nPos)
	saCargos[nPos][IND_ACARGO_PAI]        := ""
	saCargos[nPos][IND_ACARGO_COMP]       := ""
	saCargos[nPos][IND_ACARGO_TRT]        := ""
	saCargos[nPos][IND_ACARGO_CARGO_COMP] := ""
	saCargos[nPos][IND_ACARGO_CARGO_PAI]  := ""
	saCargos[nPos][IND_ACARGO_PROMPT]     := ""
	saCargos[nPos][IND_ACARGO_IMGVALIDO]  := .T.
	saCargos[nPos][IND_ACARGO_IND]        := ""
Return

/*/{Protheus.doc} A200CEstN()
Comparação de Estruturas - Antiga A200CEst
@author brunno.costa
@since 28/11/2018
@version 1.0
/*/
Function A200CEstN(cDescOrig, cDescDest, cOpcOrig, cOpcDest, cCodOrig, cCodDest, cRevOrig, cRevDest, dDtRefOrig, dDtRefDest)
	Local aArea      := GetArea()
	Local mOpcDest   := ""
	Local mOpcOrig   := ""
	Local oSay
	Local oSay2
	Local oChk1
	Local oChk2
	Local lOk        := .F.
	Local aPosObj    := {}
	Local oSizeW     := FwDefSize():New()
	Local oSizeI     := Nil


	Default cDescOrig	:= Criavar("B1_DESC",.F.)
	Default cDescDest	:= Criavar("B1_DESC",.F.)
	Default cOpcOrig	:= Criavar("C2_OPC"	,.F.)
	Default cOpcDest	:= Criavar("C2_OPC"	,.F.)
	Default cCodOrig	:= Criavar("G1_COMP",.F.)
	Default cCodDest	:= Criavar("G1_COMP",.F.)
	Default cRevOrig    := Criavar("C2_REVISAO",.F.)
	Default cRevDest    := Criavar("C2_REVISAO",.F.)
	Default dDtRefOrig  := dDataBase
	Default dDtRefDest  := dDataBase

	If Empty(cCodDest)
		cCodOrig	:= Criavar("G1_COMP",.F.)
		cCodDest	:= Criavar("G1_COMP",.F.)
		cDescOrig	:= Criavar("B1_DESC",.F.)
		cDescDest	:= Criavar("B1_DESC",.F.)
		cOpcOrig	:= Criavar("C2_OPC"	,.F.)
		cOpcDest	:= Criavar("C2_OPC"	,.F.)
		cRevOrig    := Criavar("C2_REVISAO",.F.)
		cRevDest    := Criavar("C2_REVISAO",.F.)
		dDtRefOrig  := dDataBase
		dDtRefDest  := dDataBase
	EndIf

	Private nseqori  := 0
	Private nseqdest := 0
	Private cEstrutura 	:= ''
	Private lestigual	:= .F.  // identifica se esta comparando o mesmo produto
	Private cOrdeRev	:= '1'  // Identifica a ordem da revisão, se revisao de origem e maior que revisao de destino, utilizado para montar ordem na tree de comparacao

	oSizeW:AddObject('WND', 600,310, .F.,.F.)
	oSizeW:Process()

	aPosObj 	:= {oSizeW:GetDimension('WND','LININI'),oSizeW:GetDimension('WND','COLINI'),oSizeW:GetDimension('WND','LINEND'),oSizeW:GetDimension('WND','COLEND')}

	DEFINE MSDIALOG oDlg FROM  aPosObj[1],aPosObj[2] TO aPosObj[3],aPosObj[4] TITLE OemToAnsi(STR0061) PIXEL //"Comparador de Estruturas"

	oSizeI		:= FwDefSize():New(.T.,,,oDlg)

	oSizeI:AddObject('TOP',100,45,.T.,.T.)
	oSizeI:AddObject('BOT',100,45,.T.,.T.)
	oSizeI:AddObject('CHK',100,20,.T.,.T.)

	osizeI:lProp 		:= .T.
	oSizeI:aMargins 	:= { 3, 3, 3, 3}
	oSizeI:Process()

	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg

	@ oSizeI:GetDimension('TOP','LININI'),oSizeI:GetDimension('TOP','COLINI') TO oSizeI:GetDimension('TOP','LINEND'),oSizeI:GetDimension('TOP','COLEND')-5 LABEL OemToAnsi(STR0062) OF oDlg PIXEL //"Dados Originais"
	@ oSizeI:GetDimension('BOT','LININI'),oSizeI:GetDimension('BOT','COLINI') TO oSizeI:GetDimension('BOT','LINEND'),oSizeI:GetDimension('BOT','COLEND')-5 LABEL OemToAnsi(STR0063) OF oDlg PIXEL //"Dados para Comparacao"
	@ oSizeI:GetDimension('CHK','LININI'),oSizeI:GetDimension('CHK','COLINI') TO oSizeI:GetDimension('CHK','LINEND'),oSizeI:GetDimension('CHK','COLEND')-5 LABEL OemToAnsi(STR0086) OF oDlg PIXEL //Parâmetros

	@ oSizeI:GetDimension('TOP','LININI')+12,035 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,9 OF oDlg PIXEL
	@ oSizeI:GetDimension('TOP','LININI')+12,200 MSGET cRevOrig   Picture PesqPict("SC2","C2_REVISAO") SIZE 15,09 OF oDlg PIXEL
	@ oSizeI:GetDimension('TOP','LININI')+27,200 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefOrig) SIZE 40,09 OF oDlg PIXEL
	@ oSizeI:GetDimension('TOP','LININI')+27,040 MSGET cOpcOrig   When .F. SIZE 93,09 OF oDlg PIXEL
	@ oSizeI:GetDimension('TOP','LININI')+27,133 BUTTON "?" SIZE 06,11 Action (cOpcOrig:=SeleOpc(4,"PCPA200",cCodOrig,,,,,,1,dDtRefOrig,cRevOrig,,@mOpcOrig)) OF oDlg FONT oDlg:oFont PIXEL

	@ oSizeI:GetDimension('BOT','LININI')+12,035 MSGET cCodDest   F3 "SB1" Picture PesqPict("SG1","G1_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL
	@ oSizeI:GetDimension('BOT','LININI')+12,200 MSGET cRevDest   Picture PesqPict("SC2","C2_REVISAO") SIZE 15,09 OF oDlg PIXEL
	@ oSizeI:GetDimension('BOT','LININI')+27,200 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefDest) SIZE 40,09 OF oDlg PIXEL
	@ oSizeI:GetDimension('BOT','LININI')+27,040 MSGET cOpcDest   When .F. SIZE 93,09 OF oDlg PIXEL
	@ oSizeI:GetDimension('BOT','LININI')+27,133 BUTTON "?" SIZE 06,11 Action (cOpcDest:=SeleOpc(4,"PCPA200",cCodDest,,,,,,1,dDtRefDest,cRevDest,,@mOpcDest)) OF oDlg FONT oDlg:oFont PIXEL

	@ aPosObj[1]+37,030 SAY oSay Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
	@ aPosObj[1]+73,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL

	@ oSizeI:GetDimension('TOP','LININI')+14,010 SAY OemtoAnsi(STR0011) SIZE 25,7  OF oDlg PIXEL //"Produto"
	@ oSizeI:GetDimension('TOP','LININI')+14,175 SAY OemToAnsi(STR0015) SIZE 35,13 OF oDlg PIXEL //"Revisao"
	@ oSizeI:GetDimension('TOP','LININI')+29,156 SAY OemToAnsi(STR0064) SIZE 85,13 OF oDlg PIXEL //"Data Referencia"
	@ oSizeI:GetDimension('TOP','LININI')+29,010 SAY OemtoAnsi(STR0065) SIZE 25,7  OF oDlg PIXEL //"Opc."

	@ oSizeI:GetDimension('BOT','LININI')+14,010 SAY OemToAnsi(STR0011) SIZE 25,7  OF oDlg PIXEL //"Produto"
	@ oSizeI:GetDimension('BOT','LININI')+14,175 SAY OemToAnsi(STR0015) SIZE 35,13 OF oDlg PIXEL //"Revisao"
	@ oSizeI:GetDimension('BOT','LININI')+29,156 SAY OemToAnsi(STR0064) SIZE 85,13 OF oDlg PIXEL //"Data Referencia"
	@ oSizeI:GetDimension('BOT','LININI')+29,010 SAY OemtoAnsi(STR0065) SIZE 25,7  OF oDlg PIXEL //"Opc."

	@ oSizeI:GetDimension('CHK','LININI')+10,oSizeI:GetDimension('CHK','COLINI')+10 CHECKBOX oChk1 VAR slDIf PROMPT OemtoAnsi(STR0066) SIZE 150,009 Of oDlg PIXEL //"Mostra somente componentes diferentes?"
	@ oSizeI:GetDimension('CHK','LININI')+10,oSizeI:GetDimension('CHK','COLINI')+150 CHECKBOX oChk2 VAR slValQtde PROMPT OemtoAnsi("Compara quantidades?") SIZE 150,009 Of oDlg PIXEL //"Mostra somente componentes diferentes?"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(A200COk(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest),(lOk:=.T.,oDlg:End()),lOk:=.F.) },{||(lOk:=.F.,oDlg:End())})

	// Processa comparacao das estruturas
	If lOk
		Processa({|| A200PrCom(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,cCodDest,cRevDest,dDtRefDest,cOpcDest,mOpcOrig,mOpcDest) })
	EndIf
	RestArea(aArea)

	If slReabre
		slReabre := .F.
		A200CEstN(cDescOrig, cDescDest, cOpcOrig, cOpcDest, cCodOrig, cCodDest, cRevOrig, cRevDest, dDtRefOrig, dDtRefDest)
	EndIf
RETURN

/*/{Protheus.doc} A200Cok()
Valida se pode efetuar a comparacao das Estruturas

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - cCodOrig	, caracter	, Codigo do produto origem
@param 02 - cRevOrig	, caracter	, Codigo da revisão origem
@param 03 - dDtRefOrig	, data		, Data de referencia origem
@param 04 - cOpcOrig 	, caracter	, Opcionais do produto origem
@param 05 - cCodDest 	, caracter	, Codigo do produto destino
@param 06 - cRevDest	, caracter	, Codigo da revisão destino
@param 07 - dDtRefDest 	, data		, Data de referencia destino
@param 08 - cOpcDest 	, caracter	, Opcionais do produto destino
@return     lRet        , lógico    , indica se pode efetuar a amarração
/*/
Static Function A200COk(cCodOrig, cRevOrig, dDtRefOrig, cOpcOrig, cCodDest, cRevDest, dDtRefDest, cOpcDest)
	Local lRet       := .T.
	Local lRetPE     := .T.
	Local lExibDIf   := .T.
	Local aEstruOrig := {}
	Local aEstruDest := {}

	Private nEstru := 0

	// Verifica se todas as informacoes estao iguais
	If cCodOrig+cRevOrig+DTOS(dDtRefOrig)+cOpcOrig == cCodDest+cRevDest+DTOS(dDtRefDest)+cOpcDest
		Help('  ',1,'A200COMPIG')
		lRet := .F.
	EndIf
	If lRet .And. cCodOrig <> cCodDest
		// Verifica se existe item dentro da outra estrutura - NAO PERMITE COMPARAR PARA EVITAR RECURSIVIDADE
		nEstru := 0; aEstruOrig := Estrut(cCodOrig,1)
		nEstru := 0; aEstruDest := Estrut(cCodDest,1)
		If (aScan(aEstruOrig,{|x| x[3] == cCodDest}) > 0) .Or. (aScan(aEstruDest,{|x| x[3] == cCodOrig}) > 0)
			Help('  ',1,'A200COMPES')
			lRet := .F.
		EndIf
		// Avisa ao usuario sobre produtos diferentes
		If lRet
			If ExistBlock("MT200DIF")
				lRetPE   := ExecBlock("MT200DIF",.F.,.F.,{cCodOrig,cCodDest})
				lExibDIf := IIF(ValType(lRetPE)=="L",lRetPE,lExibDif)
			EndIf
			If lExibDif
				Help('  ',1,'A200COMPDF')
			EndIf
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} A200PrCom()
Efetua a comparacao das Estruturas

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - cCodOrig	, caracter	, Codigo do produto origem
@param 02 - cRevOrig	, caracter	, Codigo da revisão origem
@param 02 - dDtRefOrig	, data		, Data de referencia origem
@param 03 - cOpcOrig 	, caracter	, Opcionais do produto origem
@param 04 - cCodDest 	, caracter	, Codigo do produto destino
@param 06 - cRevDest	, caracter	, Codigo da revisão destino
@param 05 - dDtRefDest 	, data		, Data de referencia destino
@param 06 - cOpcDest 	, caracter	, Opcionais do produto destino
@param 07 - mOpcOrig	, memo		, Opcionais Origem - Memo convertido de array
@param 08 - mOpcDest	, memo		, Opcionais Destino - Memo convertido de array
/*/
Static Function A200PrCom(cCodOrig, cRevOrig, dDtRefOrig, cOpcOrig, cCodDest, cRevDest, dDtRefDest, cOpcDest, mOpcOrig, mOpcDest)
	Local aEstruOri  := {}
	Local aEstruDest := {}
	Local aSize      := MsAdvSize(.T.)
	Local oDlg
	Local oTree
	Local oTree2
	Local aObjects  := {}
	Local aInfo     := {}
	Local aPosObj   := {}
	Local aButtons  := {}
	Local cDescOri	:= ""
	Local cDescDest := ""
	Local l800x600	:= .F.
	Local cColunas	 := STR0080+";"+STR0081+";"+STR0070+";"+STR0083+";"+STR0084	//Código;Descrição;Sequência;Rev.Inicial;Rev.Final

	If slValQtde
		cColunas	 += ";"+STR0082+";"+STR0085	//Quantidade;Consumo
	EndIf

	lestigual := cCodOrig = cCodDest

	If lestigual .and. cRevOrig > cRevDest
		cOrdeRev := '2'
	EndIf

	//Monta a  tela com o tree da versao base e com o tree da versao resultado da comparacao.
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
	aPosObj :=  MsObjSize( aInfo, aObjects, .T.,.T. )

	l800x600 := aSize[5] <= 800

	If ExistBlock( "MA200BUT" )
		If Valtype( aUsrBut := Execblock( "MA200BUT", .f., .f. ) ) == "A"
			AEval( aUsrBut, { |x| aAdd( aButtons, x ) } )
		EndIf
	EndIf

	slMontando := .T.

	SG1->(DbSetOrder(1))
	//Monta array com os conteudos dos tree
	SG1->(dbSeek(xFilial("SG1")+cCodOrig))
	M200Expl(cCodOrig,cRevOrig,dDtRefOrig,cOpcOrig,1,aEstruOri,0,mOpcOrig)
	SG1->(dbSeek(xFilial("SG1")+cCodDest))
	M200Expl(cCodDest,cRevDest,dDtRefDest,cOpcDest,1,aEstruDest,0,mOpcDest)

	//Iguala os arrays de origem e destino da comparacao
	Mt200CpAr(aEstruOri,aEstruDest,cCodOrig,cCodDest)

	slMontando := .F.

	//Descricao do Produto Origem e Destino
	If SB1->(MsSeek(xFilial("SB1")+cCodOrig))
		cDescOri := SB1->B1_DESC
	EndIf

	If SB1->(MsSeek(xFilial("SB1")+cCodDest))
		cDescDest := SB1->B1_DESC
	EndIf

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0061) FROM -20,-50 TO aSize[6]-50,aSize[5]-70 OF oMainWnd PIXEL	//Comparador de Estruturas
		@ aPosObj[1,1],aPosObj[1,2] TO If(l800x600,070,060)+15,aPosObj[1,4]-7 LABEL OemToAnsi(STR0062) OF oDlg PIXEL //"Dados Originais"

		@ aPosObj[1,1]+10,033 MSGET cCodOrig   When .F. SIZE 105,09 OF oDlg PIXEL
		@ aPosObj[1,1]+26,aPosObj[1,4]-098 MSGET cRevOrig   Picture PesqPict("SC2","C2_REVISAO") When .F. SIZE 15,09 OF oDlg PIXEL
		@ aPosObj[1,1]+10,aPosObj[1,4]-062 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") When .F. SIZE 44,09 OF oDlg PIXEL

		@ aPosObj[1,1]+12,011 SAY OemtoAnsi(STR0011)  SIZE 24,7  OF oDlg PIXEL //"Produto"
		@ aPosObj[1,1]+28,aPosObj[1,4]-121 SAY OemToAnsi(STR0015)  SIZE 32,13 OF oDlg PIXEL //"Revisao"
		@ aPosObj[1,1]+12,aPosObj[1,4]-104 SAY OemToAnsi(STR0064)  SIZE 50,09 OF oDlg PIXEL //"Data Referencia"

		@ aPosObj[1,1]+26,aPosObj[1,4]-062 MSGET cOpcOrig   When .F. SIZE 35,09 OF oDlg PIXEL
		@ aPosObj[1,1]+28,aPosObj[1,4]-074 SAY OemtoAnsi(STR0065)   SIZE 24,7  OF oDlg PIXEL //Opc.
		@ aPosObj[1,1]+28,011 SAY OemtoAnsi(cDescOri) SIZE 130,6 Color CLR_HRED OF oDlg PIXEL

		@ aPosObj[2,1], aPosObj[2,2]-8 TO If(l800x600,070,060)+15,aPosObj[2,4]-8 LABEL OemToAnsi(STR0063) OF oDlg PIXEL //"Dados para Comparacao"

		@ aPosObj[2,1]+10,aPosObj[2,2]+020 MSGET cCodDest   When .F. SIZE 105,09 OF oDlg PIXEL
		@ aPosObj[2,1]+26,aPosObj[2,4]-102 MSGET cRevDest   Picture PesqPict("SC2","C2_REVISAO") When .F.  SIZE 15,09 OF oDlg PIXEL
		@ aPosObj[2,1]+10,aPosObj[2,4]-064 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") When .F. SIZE 44,09 OF oDlg PIXEL

		@ aPosObj[2,1]+12,aPosObj[2,2]-001 SAY OemToAnsi(STR0011)   SIZE 24,7  OF oDlg PIXEL //"Produto"
		@ aPosObj[2,1]+28,aPosObj[2,4]-124 SAY OemToAnsi(STR0015)   SIZE 32,13 OF oDlg PIXEL //"Revisao"
		@ aPosObj[2,1]+12,aPosObj[2,4]-107 SAY OemToAnsi(STR0064)   SIZE 50,09 OF oDlg PIXEL //"Data Referencia"

		@ aPosObj[2,1]+26,aPosObj[2,4]-064 MSGET cOpcDest   When .F. SIZE 35,09 OF oDlg PIXEL
		@ aPosObj[2,1]+28,aPosObj[2,4]-076 SAY OemtoAnsi(STR0065)    SIZE 24,7  OF oDlg PIXEL //Opc.
		@ aPosObj[2,1]+28,aPosObj[2,2]-001 SAY OemtoAnsi(cDescDest) SIZE 130,6 Color CLR_HRED OF oDlg PIXEL

		oTree :=  dbTree():New(aPosObj[1,1]+If(l800x600,060,050), aPosObj[1,2],aPosObj[1,3]-10,aPosObj[1,4]-10, oDlg,,,.T.,,,cColunas)
		oTree:lShowHint := .F.

		ProcRegua(len(aEstruOri))
		cMsgProc := STR0076	//'Processando Dados Originais'
		cEstrutura := '1' 	// origem

		A200TreeCm(oTree,aEstruOri,NIL,NIL,cRevOrig,aEstruDest)

		oTree2 := dbTree():New(aPosObj[2,1]+If(l800x600,060,050), aPosObj[2,2]-10,aPosObj[2,3]-10,aPosObj[2,4]-10, oDlg,,,.T.,,,cColunas)
		oTree:lShowHint := .F.

		ProcRegua(len(aEstruDest))

		cMsgProc := STR0077	//'Processando Dados para comparação'
		cEstrutura := '2' // destino

		A200TreeCm(oTree2,aEstruDest,NIL,NIL,cRevDest,aEstruOri)

		aAdd( aButtons, { "PMSSETADOWN", { || Mt200Nav(1,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0067)} ) //"Desce"
		aAdd( aButtons, { "PMSSETAUP"  , { || Mt200Nav(2,@oTree,@oTree2,aEstruOri,aEstruDest) },OemToAnsi(STR0068)} ) //"Sobe"
		aAdd( aButtons, { "DBG09"      , { || Mt200Inf() }, STR0069 } ) //"Legenda"
		AAdd( aButtons, { ""           , { || oDlg:End(), slReabre := .T. }, STR0086 } )	//"Parâmetros"

		oTree:bChange  := {|| CompTreeCh(1, @oTree, @oTree2, @aEstruOri, @aEstruDest) }
		oTree2:bChange := {|| CompTreeCh(2, @oTree, @oTree2, @aEstruOri, @aEstruDest) }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)
Return Nil

/*/{Protheus.doc} CompTreeCh()
Comparação: Ações do Change Tree com Posicionamento Conjunto nas Trees

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - nOpc	, numérico	, Identificador de Origem:
		  - 1 - Tree 1
		  - 2 - Tree 2
@param 02 - oTree		, objeto	, Tree da origem da comparacao
@param 03 - oTree2		, objeto	, Tree do destino da comparacao
@param 04 - aEstruOri	, array		, Array com os dados da estrutura origem da comparacao
@param 05 - aEstruDest	, array		, Array com os dados da estrutura destino da comparacao
/*/
Static Function CompTreeCh(nOpc, oTree, oTree2, aEstruOri, aEstruDest)
	Local lOldChange  := slChanging
	If !slChanging .and. !slMontando
		slChanging := .T.
		If nOpc == 1
			Mt200Nav(3,@oTree,@oTree2,aEstruOri,aEstruDest)
		ElseIf nOpc == 2
			Mt200Nav(0,@oTree,@oTree2,aEstruOri,aEstruDest)
		EndIf
		slChanging := lOldChange
	EndIf
Return

/*/{Protheus.doc} M200Expl()
Comparação: Faz a explosao de uma estrutura para comparacao

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - cProduto	, caracter	, Código do produto
@param 02 - cRevisao	, caracter	, Revisão do produto a ser explodido
@param 03 - dDataRef	, data		, Data de referência para explosão do produto
@param 04 - cOpcionais 	, caracter	, Grupo de opcionais para explosao do produto
@param 05 - nQuantPai 	, numérico	, Quantidade base para explosão
@param 06 - aEstru 		, array		, Array com o retorno da pre-estrutura
@param 07 - nNivelEstr 	, numérico	, Nivel da pre-estrutura
@param 08 - mOpc		, memo		, Memo com os opcionais para conversão em array
@param 09 - cProdAnt	, caracter	, Código do produto anterior
@param 10 - cCargoPai   , caracter  , Código do Cargo Pai
@param 11 - nQuantPai2 	, numérico	, Quantidade base para explosão - desconsidera validade
/*/
Static Function M200Expl(cProduto,cRevisao,dDataRef,cOpcionais,nQuantPai,aEstru,nNivelEstr,mOpc,cProdAnt,cCargoPai,nQuantPai2)
	Local nReg        := 0
	Local nQuantItem  := 0
	Local nQuantIte2 := 0
	Local nHistorico  := 4 // Produto ok
	Local nNivelBase  := 999
	Local nRet
	Local cComp       := ""
	Local cTrt        := ""
	Local cOpcPar     := ""
	Local aOpc        := Str2Array(mOpc,.F.)
	Local nPos        := 0

	Default cProdAnt  := PadR(cProduto,TamSX3("G1_COD")[1])
	Default cCargoPai := ""
	Default nQuantPai2:= 1

	// Estrutura do array
	// [1] Produto PAI
	// [2] Componente
	// [3] TRT
	// [4] Quantidade
	// [5] Historico
	// [6] Nivel
	// [7] Cargo = [6]+[2]+[3]
	// [8] Revisao inicial
	// [9] Revisao final
	// [10] Quantidade Original
	// [11] Quantidade Consumo - Desconsidera validade
	// [12] Cargo Pai
	// [13] cProdAnt

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If  Empty(cRevisao)  // PEGA A ULTIMA REVISAO CASO O PARAMETRO DE REVISAO DE ESTRUTUTA ESTIVER ATIVADO
		If SB1->(dbSeek(xFilial("SB1") + cProduto, .F.))
			cRevisao := IIF(slPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
		EndIf
	EndIf

	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))
	While SG1->(!Eof()) .And. SG1->(G1_FILIAL+G1_COD) == xFilial("SG1")+cProduto

		//Nao Adiciona Componentes fora da Revisao
		If  (cRevisao # Nil) .And. ;
			!(SG1->G1_REVINI <= cRevisao .And. (SG1->G1_REVFIM >= cRevisao .Or. SG1->G1_REVFIM = ' '))
			SG1->(dbSkip())
			Loop
		EndIf

		nReg := Recno()

		//Calcula a qtd dos componentes
		nHistorico := 4
		cOpcPar    := cOpcionais
		If aOpc != Nil .And. Len(aOpc) > 0 .And. !Empty(SG1->G1_GROPC)
			nPos := aScan(aOpc,{|x| x[1] == cProdAnt+SG1->G1_COMP+SG1->G1_TRT})
			If nPos > 0
				cOpcPar := aOpc[nPos,2]
			Else
				cOpcPar := "*NAOENTRA*"
			EndIf
		EndIf
		nQuantItem := ExplEstr(nQuantPai,dDataRef,cOpcPar,cRevisao,@nHistorico)
		dbSelectArea("SG1")
		SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
		If QtdComp(nQuantItem) < QtdComp(0)
			nQuantItem := If(QtdComp(RetFldProd(SB1->B1_COD,"B1_QB"))>0,RetFldProd(SB1->B1_COD,"B1_QB"),1)
		EndIf
		nQuantIte2 := SG1->G1_QUANT*nQuantPai2
		If Empty(cRevisao) .And. !Empty(SG1->G1_REVINI)
			nHistorico := 3
		EndIf
		cCargo := StrZero(nNivelEstr,5,0)+SG1->G1_COMP+SG1->G1_TRT
		aAdd(aEstru,{SG1->G1_COD   ,;
					SG1->G1_COMP   ,;
					SG1->G1_TRT    ,;
					nQuantItem     ,;
					nHistorico     ,;
					nNivelEstr     ,;
					cCargo         ,;
					SG1->G1_REVINI ,;
					SG1->G1_REVFIM ,;
					SG1->G1_QUANT  ,;
					nQuantIte2     ,;
					cCargoPai      ,;
					cProdAnt       })
		cComp := SG1->G1_COMP
		cTrt  := SG1->G1_TRT

		//Verifica se existe sub-estrutura
		dbSelectArea("SG1")
		If dbSeek(xFilial("SG1")+SG1->G1_COMP)
			nNivelEstr++
			//Ponto de entrada para definir o nivel de comparacao
			If slM200NIV
				nRet := (ExecBlock("M200NIV",.F.,.F.))
				If ( Valtype(nRet) == "N" )
					nNivelBase := nRet
				EndIf
			EndIf

			If nNivelEstr <= nNivelBase
				M200Expl(SG1->G1_COD       ,;
						IIF(slPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU),;
						dDataRef           ,;
						cOpcionais         ,;
						nQuantItem         ,;
						aEstru             ,;
						nNivelEstr         ,;
						mOpc               ,;
						cProdAnt+cComp+cTrt,;
						cCargo             ,;
						nQuantIte2)
			EndIf
			nNivelEstr--
		EndIf
		SG1->(dbGoto(nReg))
		SG1->(dbSkip())
	EndDo
Return(.T.)

/*/{Protheus.doc} Mt200CpAr()
Compara e ajusta os arrays de origem e destino

@author brunno.costa
@since 27/11/2018
@version 1.0

@param 01 - aEstruOri	, array		, Array com os dados pre-estrutura origem da comparacao
@param 02 - aEstruDest	, array		, Array com os dados pre-estrutura destino da comparaca
@param 03 - cCodOrig	, caracter	, Codigo do produto origem
@param 04 - cCoddest	, caracter	, Codigo do produto destino
/*/
Static Function Mt200CpAr(aEstruOri, aEstruDest, cCodOrig, cCoddest)
	Local nz          := 0
	Local nw          := 0
	Local nAcho       := 0
	Local cProcura    := ""
	Local lFirstLevel := .F.
	Local nHist       := 5  // historio da comparacao, padrao sempre 5 - fora da estrutura
	Local nIndex      := 0
	Local nIndAux     := 0

	If lestigual  // se estrutura for igual, o historico vai ser componente fora da revisão.
		nHist := 3
	EndIf

	// Estrutura do array
	// [1] Produto PAI
	// [2] Componente
	// [3] TRT
	// [4] Quantidade
	// [5] Historico
	// [6] Nivel
	// [7] Cargo = [6]+[2]+[3]
	// [8] Revisao inicial
	// [9] Revisao final
	// [10] Quantidade Original
	// [11] Quantidade Consumo - Desconsidera validade
	// [12] Cargo Pai
	// [13] cProdAnt

	// Compara os elementos em comum do array
	// Adiciona no array origem os componentes do array destino diferentes
	For nz := 1 To Len(aEstruDest)
		// Verifica se esta no primeiro nivel
		If aEstruDest[nz,6]==0
			lFirstLevel := .T.
		Else
			lFirstLevel := .F.
		EndIf
		// Nao procura o produto pai junto
		If lFirstLevel
			cProcura := aEstruDest[nz,2]+aEstruDest[nz,3]
		// Procura o produto pai junto
		Else
			cProcura := aEstruDest[nz,1]+aEstruDest[nz,2]+aEstruDest[nz,3]+aEstruDest[nz,12]
		EndIf
		// Efetua procura no array origem
		nAcho := aScan(aEstruOri,{|x| x[6] == aEstruDest[nz,6];
				.And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]+x[12]) == cProcura;
				.and. ComProdAnt(5, aEstruDest[nz,13], x[13] ) )})
		// Caso nao achou soma componentes no array origem com a estrutura do item
		If nAcho == 0

			For nw := nz to Len(aEstruDest)
				nseqori++
				aAdd(aEstruOri,{If(lFirstLevel,If(Len(aEstruOri)> 0,aEstruOri[1,1],cCodOrig),aEstruDest[nw,1]),aEstruDest[nw,2],aEstruDest[nw,3],aEstruDest[nw,4],nHist,aEstruDest[nw,6],aEstruDest[nw,7],aEstruDest[nw,8],aEstruDest[nw,9],aEstruDest[nw,10],aEstruDest[nw,11],aEstruDest[nw,12],aEstruDest[nw,13]})
				// Desliga flag de primeiro nivel
				If lFirstLevel
					lFirstLevel := .F.
				EndIf
				If nw == Len(aEstruDest) .Or. (aEstruDest[nz,6] == aEstruDest[nw+1,6])
					nz := nw
					Exit
				EndIf

			Next nw
		EndIf
	Next nz

	// Adiciona no array destino os componentes do array origem diferentes
	For nz := 1 To Len(aEstruOri)
		// Verifica se esta no primeiro nivel
		If aEstruOri[nz,6]==0
			lFirstLevel := .T.
		Else
			lFirstLevel := .F.
		EndIf
		// Nao procura o produto pai junto
		If lFirstLevel
			cProcura := aEstruOri[nz,2]+aEstruOri[nz,3]
		// Procura o produto pai junto
		Else
			cProcura := aEstruOri[nz,1]+aEstruOri[nz,2]+aEstruOri[nz,3]+aEstruOri[nz,12]
		EndIf
		// Efetua procura no array origem
		nAcho := aScan(aEstruDest,{|x| x[6] == aEstruOri[nz,6];
				.And. (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]+x[12]) == cProcura;
				.and. ComProdAnt(5, aEstruOri[nz,13], x[13] ) )})
		// Caso nao achou soma componentes no array origem com a estrutura do item
		If nAcho == 0
			For nw := nz to Len(aEstruOri)
				nseqdest++
				aAdd(aEstruDest,{If(lFirstLevel,If(Len(aEstruDest)> 0,aEstruDest[1,1],cCodDest),aEstruOri[nw,1]),aEstruOri[nw,2],aEstruOri[nw,3],aEstruOri[nw,4],nHist,aEstruOri[nw,6],aEstruOri[nw,7],aEstruOri[nw,8],aEstruOri[nw,9],aEstruOri[nw,10],aEstruOri[nw,11],aEstruOri[nw,12],aEstruOri[nw,13]})
				// Desliga flag de primeiro nivel
				If lFirstLevel
					lFirstLevel := .F.
				EndIf
				If nw == Len(aEstruOri) .Or. (aEstruOri[nz,6] == aEstruOri[nw+1,6])
					nz := nw
					Exit
				EndIf
			Next nw
		EndIf
	Next nz

	// Ordena arrays por nivel
	aSort(aEstruOri,,,{|x,y| x[7]+x[12]  < y[7]+y[12] })
	aSort(aEstruDest,,,{|x,y| x[7]+x[12] < y[7]+y[12] })

	For nIndex := 1 to Len(aEstruOri)
		//Corrige Cargo Pai do array aEstruOri
		nIndAux := aScan(aEstruOri, {|x| x[12] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][13], x[13]) })
		While nIndAux > 0
			aEstruOri[nIndAux][12]  := aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
			nIndAux := aScan(aEstruOri, {|x| x[12] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][13], x[13]) })
		EndDo

		//Corrige Cargo Pai do array aEstruDest
		nIndAux := aScan(aEstruDest, {|x| x[12] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][13], x[13]) })
		While nIndAux > 0
			aEstruDest[nIndAux][12] := aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
			nIndAux := aScan(aEstruDest, {|x| x[12] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][13], x[13]) })
		EndDo

		//Corrige Cargo do array aEstruDest
		nIndAux := aScan(aEstruDest, {|x| x[7] == aEstruOri[nIndex][7] .AND. x[12] == aEstruOri[nIndex][12] .AND. ComProdAnt(2, x[13], aEstruOri[nIndex][13]) })
		While nIndAux > 0
			aEstruDest[nIndAux][7]	:= aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
			nIndAux := aScan(aEstruDest, {|x| x[7] == aEstruOri[nIndex][7] .AND. x[12] == aEstruOri[nIndex][12] .AND. ComProdAnt(2, x[13], aEstruOri[nIndex][13]) })
		EndDo

		//Corrige Cargo do array aEstruOri
		aEstruOri[nIndex][7]	    := aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
	Next nIndex

RETURN(.T.)

/*/{Protheus.doc} ComProdAnt()
Compara árvore cProdAnt do produto desconsiderando o produto PAI

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - nOpc	, numérico	, indicador do local de chamada
@param 02 - cAnt1	, caracter	, cProdAnt 1 para comparação
@param 03 - cAnt2	, caracter	, cProdAnt 2 para comparação
/*/

Static Function ComProdAnt(nOpc, cAnt1, cAnt2)
	Local lReturn := .F.
	cAnt1 := Substring(cAnt1, snTamCodPr+1, Len(cAnt1) - snTamCodPr)
	cAnt2 := Substring(cAnt2, snTamCodPr+1, Len(cAnt1))
	lReturn := cAnt1 == cAnt2
Return lReturn

/*/{Protheus.doc} A200TreeCm()
Comparação: Monta o objeto TREE - FUNCAO RECURSIVA

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - oObjTree	, objeto	, Objeto tree utilizado
@param 02 - aEstru		, array		, Array com os dados da pre-estrutura
@param 03 - cCargoPai	, caracter	, Código do cargo Pai
@param 04 - nz			, numérico	, Posicao do array de pre-estrutura utilizado
@param 05 - aEstru2		, array		, Array com os dados da OUTRA pre-estrutura
@param 06 - cProdAnt	, caracter	, Chave Produto + TRT Anteriores - Concatenados
/*/
Static Function A200TreeCm(oObjTree, aEstru, cCargoPai, nz, cRevisao, aEstru2, cProdAnt )
	Local nAcho        := 0
	Local aOcorrencia  := {}
	Local cTexto       := ""
	Local cprodX       := ""
	Local cDesc	       := ""
	Local cCargoVazio  := Space(5+Len(SG1->G1_COMP+SG1->G1_TRT))
	Local lMontouTree  := .F.
	Local nTipo		   := 2

	Default nz         := 1
	Default cCargoPai  := ""
	Default cProdAnt   := ""

	// Ordem de pesquisa por codigo
	SB1->(dbSetOrder(1))

	// Array com as ocorrencias cadastradas
	aAdd(aOcorrencia,"PMSTASK4") //"Componente fora das datas inicio / fim"
	aAdd(aOcorrencia,"PMSTASK5") //"Componente fora dos grupos de opcionais"
	aAdd(aOcorrencia,"PMSTASK2") //"Componente fora das revisoes"
	aAdd(aOcorrencia,"PMSTASK6") //"Componente ok"
	aAdd(aOcorrencia,"PMSTASK1") //"Componente nao existente"
	AADD(aOcorrencia,"PMSTASK3") 	//"Componente ok - Quantidade diferente"

	// Monta tree na primeira vez
	If !lMontouTree .AND. Empty(cCargoPai) .And. Len(aEstru) > 0
		cCargoPai := aEstru[1,12]
		cProdAnt  := aEstru[1,13]
		oObjTree:BeginUpdate()
		oObjTree:Reset()
		oObjTree:EndUpdate()

		// Coloca titulo no TREE
		SB1->(dbSeek(xFilial("SB1")+aEstru[1,1]))

		oObjTree:AddTree(AllTrim(aEstru[1,1])+;
						";"+Alltrim(Substr(SB1->B1_DESC,1,30))+ Space(60)+;
						";"+Space(40)+;
						";"+cRevisao+Space(5)+;
						";"+cRevisao+Space(5)+;
						Iif(slValQtde,";;"+Transform(1, scPicQuant),"");
						,.T.,,,aOcorrencia[4],aOcorrencia[4],cCargoVazio)

		lMontouTree := .T.
	EndIf

	While nz <=  Len(aEstru)

		//Avalia Quantidade
		If slValQtde .and. aEstru[nz,5] == 4
			If aEstru[nz,10]  != aEstru2[nz,10]
				aEstru[nz,5] := 6
			EndIf
		EndIf

		// Verifica se componente tem estrutura
		nAcho  := aScan(aEstru,{|x| x[12] == aEstru[nz,7]} )

		// Monta Texto
		cDesc  := Posicione("SB1",1,xFilial("SB1")+aEstru[nz,2], 'B1_DESC')

		cTexto := Alltrim(aEstru[nz,2])+;
				  ";"+cDesc+;
				  ";"+aEstru[nz,3]+;
				  ";"+aEstru[nz,8]+;
				  ";"+aEstru[nz,9]+;
				  Iif(slValQtde,";"+Transform(aEstru[nz,10], scPicQuant)+;
				  ";"+Transform2(aEstru[nz,11]),"")

		cprodX := cTexto

		If slM200CPTX
			cM200CPTX  := ExecBlock("M200CPTX",.F.,.F.,{cTexto,aEstru[nz][1],aEstru[nz][2],SB1->B1_DESC,aEstru[nz][3],aEstru[nz][4],aEstru[nz][8],aEstru[nz][9]})
			If ValType(cM200CPTX) == "C"
				cTexto := cM200CPTX
			EndIf
		EndIf

		If aEstru[nz,12] == cCargoPai .AND. ComProdAnt(4, aEstru[nz,13], cProdAnt)
			If (!slDIf .OR. aEstru[nz,5] <> 4)
				If nAcho > 0
					oObjTree:AddItem(cTexto, aEstru[nz,7], , , aOcorrencia[aEstru[nz,5]], aOcorrencia[aEstru[nz,5]], nTipo )
					oObjTree:TreeSeek(aEstru[nz,7])
					IncProc(cMsgProc)

					// Chama funcao recursiva
					A200TreeCm(oObjTree, aEstru, aEstru[nz,7], nAcho, cRevisao, aEstru2, aEstru[nz,13]+aEstru[nz,2]+aEstru[nz,3])
					oObjTree:TreeSeek(aEstru[nz,7])
					oObjTree:PTCollapse()

				Else
					// Adiciona item no tree
					oObjTree:AddItem(cTexto, aEstru[nz,7], , , aOcorrencia[aEstru[nz,5]], aOcorrencia[aEstru[nz,5]], nTipo )
					oObjTree:TreeSeek(aEstru[nz,7])
					IncProc(cMsgProc)

				EndIf
				If nTipo == 2
					nTipo := 1
				EndIf
			EndIf
		EndIf
		nz++
	End

	If lMontouTree
		oObjTree:EndTree()
		oObjTree:TreeSeek(cCargoVazio)
	EndIf

RETURN(.T.)

/*/{Protheus.doc} Transform2()
Transforma valor recebido no padrão de casas decimais do campo G1_QUANT
- Constroi picture variável de acordo com o valor recebido

@author brunno.costa
@since 03/12/2018
@version 1.0

@param 01 - nValor, numérico, valor a ser transformado;
/*/
Static Function Transform2(nValor)
Return Transform( nValor, ("@E "+ PadL( ("9." + PadL('9', snDecQuant,'9')), (Len(cValToChar(Int(nValor)))+snDecQuant+1), '9')) )

/*/{Protheus.doc} Mt200Nav()
Comparação: Mantem o posicionamento das duas pre-estruturas

@author brunno.costa
@since 28/11/2018
@version 1.0

@param 01 - nTipo		, numérico	, Codigo do Evento:
		  - 0 - Muda posicionamento da Tree com base na Tree 2
		  - 1 - Desce Linha
		  - 2 - Sobe linha
		  - 3 - Muda posicionamento da Tree 2 com base na Tree
@param 02 - oTree		, objeto	, Tree da origem da comparacao
@param 03 - oTree2		, objeto	, Tree do destino da comparacao
@param 04 - aEstruOri	, array		, Array com os dados da estrutura origem da comparacao
@param 05 - aEstruDest	, array		, Array com os dados da estrutura destino da comparacao
/*/
Static Function Mt200Nav(nTipo,oTree,oTree2,aEstruOri,aEstruDest)
	Local cCargoAtu   := oTree2:GetCargo()
	Local cCargoVazio := Space(5+Len(SG1->G1_COMP+SG1->G1_TRT))
	Local nPos        := aScan(aEstruDest,{|x| x[7] == cCargoAtu})
	Local lOldChange  := slChanging

	slChanging	:= .T.
	//Posiciona o tree na linha de baixo
	If nTipo == 1 .And. nPos < Len(aEstruDest)
		oTree:TreeSeek(aEstruOri[nPos+1,7])
		oTree2:TreeSeek(aEstruDest[nPos+1,7])

	//Posiciona o tree na linha de cima
	ElseIf nTipo == 2 .And. nPos >= 1
		oTree:TreeSeek( If(nPos-1<=0, cCargoVazio, aEstruOri[nPos-1,7]))
		oTree2:TreeSeek(If(nPos-1<=0, cCargoVazio, aEstruDest[nPos-1,7]))

	//Reposiciona a Tree 2 com base na Tree
	ElseIf nTipo == 3
		cCargoAtu   := oTree:GetCargo()
		nPos        := aScan(aEstruDest,{|x| x[7] == cCargoAtu})
		oTree2:TreeSeek(If(nPos>0, aEstruDest[nPos,7], cCargoVazio))
		oTree:TreeSeek(oTree:GetCargo())

	//Reposiciona a Tree com base na Tree 2
	Else
		nPos        := aScan(aEstruOri,{|x| x[7] == cCargoAtu})
		oTree:TreeSeek( If(nPos>0, aEstruOri[nPos,7] , cCargoVazio))
		oTree2:TreeSeek(oTree2:GetCargo())

	EndIf
	slChanging	:= lOldChange

	oTree:Refresh()
	oTree2:Refresh()

Return(.T.)

/*/{Protheus.doc} Mt200Inf()
Legenda do Comparador de estruturas
@author brunno.costa
@since 27/11/2018
@version 1.0
/*/
Static Function Mt200Inf()
	Local oDlg
	Local oBmp1
	Local oBmp2
	Local oBmp3
	Local oBmp4
	Local oBmp5
	Local oBut1

	DEFINE MSDIALOG oDlg TITLE STR0069 OF oMainWnd PIXEL FROM 0,0 TO 200,550 //"Legenda"
	@ 2,3 TO 080,273 LABEL STR0069 PIXEL //"Legenda"
	@ 18,010 BITMAP oBmp1 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
	@ 18,020 SAY OemToAnsi(STR0071) OF oDlg PIXEL	//"Componente Não Existente"
	@ 18,150 BITMAP oBmp2 RESNAME "PMSTASK6" SIZE 16,16 NOBORDER PIXEL
	@ 18,160 SAY OemToAnsi(STR0072) OF oDlg PIXEL	//"Componente Ok"
	@ 30,010 BITMAP oBmp3 RESNAME "PMSTASK2" SIZE 16,16 NOBORDER PIXEL
	@ 30,020 SAY OemToAnsi(STR0078) OF oDlg PIXEL	//"Componente Fora das Revisões"

	If slValQtde
		@ 30,150 BITMAP oBmp2 RESNAME "PMSTASK3" SIZE 16,16 NOBORDER PIXEL
		@ 30,160 SAY OemToAnsi(STR0075) OF oDlg PIXEL	//"Componente Ok - Quantidade diferente"
	EndIf

	@ 42,010 BITMAP oBmp4 RESNAME "PMSTASK5" SIZE 16,16 NOBORDER PIXEL
	@ 42,020 SAY OemToAnsi(STR0073) OF oDlg PIXEL	//"Componente Fora Dos Grupos De Opcionais"
	@ 54,010 BITMAP oBmp5 RESNAME "PMSTASK4" SIZE 16,16 NOBORDER PIXEL
	@ 54,020 SAY OemToAnsi(STR0074) OF oDlg PIXEL	//"Componente Fora Das Datas Início / Fim"

	DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)

/*/{Protheus.doc} PCPA200MNU()
Função que executa a view do programa.
Necessário desvio da abertura re-executando sempre a MenuDef e ViewDef

@author brunno.costa
@since 11/12/2018
@version 1.0

@param nOpcao	- Identifica a operação que está sendo executada (inclusão/exclusão/alteração/visualização)
@return nOK	- Identifica se o usuário confirmou (nOk==0) ou cancelou (nOk==1) a operação.
/*/
Function PCPA200MNU(nOpcao)
	Local nOpc      := 2
	Local nOk       := 0
	Local cTexto    := ""
	Local bCancela
	Local nRecno    := SG1->(Recno())
	Local oModelAux := FWLoadModel("PCPA200")

	If nOpcao != 3							  //Operacoes de Inclusao, Alteracao e Exclusao
		SG1->(DbSkip())                       //Forca desposicianamento de registro
		SG1->(dbGoTo(nRecno))                 //Forca reposicionamento do registro
		If SG1->(Deleted()) .OR. SG1->(Eof()) //Verifica se o registro esta excluido ou se esta em EOF - sem registros dentro da condicao de filtro
			SG1->(DbSkip())                   //Forca desposicianamento de registro
			SG1->(DbGoTop())                  //Posiciona no primeiro registro
			//Este registro foi excluído por outro usuário.
			//Selecione outro registro e tente novamente.
			Help( ,  , "Help", ,  STR0195, 1, 0, , , , , , {STR0196})
			nOk := -1
		EndiF
	EndiF

	If slP200BLQOP
		lRetPE := ExecBlock("P200BLQOP", .F., .F., {nOpcao})

		If ValType(lRetPE) <> "L" .Or. !lRetPE
			nOk := -1
		EndIf
	EndIf

	If nOk == 0
		Do Case
			Case nOpcao == 2
				nOpc   := MODEL_OPERATION_VIEW
				cTexto := STR0002 //Visualizar
			Case nOpcao == 3
				nOpc   := MODEL_OPERATION_INSERT
				cTexto := STR0003 //Incluir
			Case nOpcao == 4
				nOpc     := MODEL_OPERATION_UPDATE
				cTexto   := STR0004 //Alterar
				bCancela := {|| P200Cancel()}
			Case nOpcao == 5
				nOpc   := MODEL_OPERATION_DELETE
				cTexto := STR0005 //Excluir
		EndCase
		nOk := FWExecView(cTexto, "PCPA200", nOpc,,{|| .T. },{|| P200AvaRev() },,,bCancela,,,oModelAux)
		If nOpc == MODEL_OPERATION_VIEW
			If ExistBlock("P200GRAV")
				ExecBlock("P200GRAV", .F., .F., {nOpc, {}})
			EndIf
		EndIf
	EndIf

Return nOk

/*/{Protheus.doc} P200AvaRev
Avalia Geração de Revisão na Estrutura

@author brunno.costa
@since 06/12/2018
@version 1.0

@return lReturn, lógico, indica se prossegue com a confirmação da tela
/*/
Function P200AvaRev()

	Local cLinha1  := STR0093 + CHR(13) //"Cada alteração em uma estrutura pode gerar uma nova estrutura para"
	Local cLinha2  := STR0094 + CHR(13) //"o controle histórico de alterações em determinado produto."
	Local cLinha3  := STR0095 + CHR(13) //"A alteração deve gerar uma nova revisão para esta estrutura?"
	Local oView
	Local oModel   := FwModelActive()
	Local oEvent
	Local cProduto
	Local lRetPE   := .T.
	Local lReturn  := .T.

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. Empty(oModel:GetModel("SG1_MASTER"):GetValue("G1_COD"))
		lReturn := .F.
		Help(,,"Help",,STR0037,1,0)	//"Não existem alterações a serem salvas."
	EndIf

	If lReturn .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
		If oModel:GetModel("SG1_DETAIL"):VldLineData()
			oEvent := gtMdlEvent(oModel,"PCPA200EVDEF")
			oEvent:PerguntaPCPA200()

			If oEvent:mvlRevisaoAutomatica	//MV_REVAUT - Revisão Automática
				oEvent:lGeraRevisao := .T.
			Else
				//Chama pergunte PCPA200 e converte em propriedades - Sem tela
				oEvent:PerguntaPCPA200(.F.)

				If oEvent:mvlArquivoRevisao	//MV_PAR02  - Gera Arquivo de Revisão
					//P.E. para Gerar ou nao uma nova revisao para a estrutura sem a apresentacao do Aviso.
					If ExistBlock("MT200GRE")
						lRetPE := ExecBlock("MT200GRE",.F.,.F.)
						oEvent:lGeraRevisao := IIF(ValType(lRetPE)=="L", lRetPE, oEvent:lGeraRevisao)
					ElseIf avaliaRev(oEvent, oModel)

						If P200IsAuto(oModel)
							oEvent:lGeraRevisao := oModel:GetModel():GetModel("SG1_MASTER"):GetValue("ATUREVSB1") == "S"
						Else
							oEvent:lGeraRevisao := ApMsgYesNo(cLinha1+cLinha2+cLinha3,STR0096)	//"Gerar Revisão da Estrutura?"
						EndIf
					Else
						oEvent:lGeraRevisao := .F.
					EndIf
				Else
					oEvent:lGeraRevisao := .F.
				EndIf

				If oEvent:lGeraRevisao .AND. oModel:GetOperation() != MODEL_OPERATION_DELETE
					cProduto := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
					nInd := aScan(oEvent:aRevisoes, {|x| x[4] == cProduto .AND. x[1] })
					If nInd > 0 .OR. !oEvent:mvlRevisaoAutomatica
						//Gera SG5 e grava alteração na SB1 - Produto Master
						oEvent:cRevisaoMaster := oEvent:AtualizaRevisao( cProduto, !oEvent:mvlRevisaoAutomatica, .F.,,oModel)
					EndIf
				EndIf
			EndIf
		Else
			If !P200IsAuto(oModel)
				oView := FwViewActive()
				oView:ShowLastError()
			EndIf
			lReturn := .F.
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} A200UpDRev
Atualiza o campo B1_UREV do pais do componente

@author brunno.costa
@since 10/12/2018
@version 1.0

@param 01 - mvlDataRevisao, logico  , indica se deve atualizar a data de revisao
@param 02 - cProdAux      , caracter, codigo do produto
@param 03 - cCargoAux     , caracter, cargo do produto
@return Nil
/*/

Function A200UpDRev(mvlDataRevisao, cProdAux, cCargoAux)

	Local nIndAux   := 0

	If mvlDataRevisao
		While .T.
			//Atualiza a Última Revisão do Componente
			If SB1->(dBSeek(xFilial('SB1') + cProdAux, .F.))
				RecLock('SB1', .F.)
				Replace B1_UREV With dDataBase
				SB1->(MsUnlock())
			EndIf

			//Atualiza o Pai do Componente nesta Ramificação da Estrutura, tal qual MATA200
			nIndAux := soCargosCmp[cCargoAux]
			If nIndAux != Nil .and. nIndAux > 0
				cProdAux  := saCargos[nIndAux][IND_ACARGO_PAI]
				cCargoAux := saCargos[nIndAux][IND_ACARGO_CARGO_PAI]
			Else
				Exit
			EndIf
		EndDo
	EndIf
Return

/*/{Protheus.doc} ExecutAuto
Faz a execução automática do cadastro de estruturas, de acordo com os parâmetros recebidos.

@author lucas.franca
@since 21/12/2018
@version 12
@param aAutoCab  , array   , Array com as informações do cabeçalho do programa
                            e com parâmetros adicionais para identificar alguns comportamentos do programa.
@param aAutoItens, array   , Array com as informações dos componentes que serão modificados.
                            Para a operação de Exclusão, este array não é considerado.
@param nOpcAuto  , numeric , Opção que será utilizada na execução automática. 3-Inclusão, 4-Modificação, 5-Exclusão.
@param cFuncao   , caracter, Nome da função chamadora (opcional).
@return Nil
/*/
Static Function ExecutAuto(aAutoCab, aAutoItens, nOpcAuto, cFuncao)
	Local oModel    := FwLoadModel("PCPA200")
	Local oModelCab := oModel:GetModel("SG1_MASTER")
	Local oModelDet := oModel:GetModel("SG1_DETAIL")
	Local oEvent    := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local oStruCab  := oModelCab:GetStruct()
	Local oStruDet  := oModelDet:GetStruct()
	Local aSeekLine := {}
	Local aLinPos   := {}
	Local nIndField := 0
	Local nIndLine  := 0
	Local nPosCmp   := 0
	Local nPos      := 0
	Local nLinPos   := 0
	Local nIndSeek  := 0
	Local nTamCod   := GetSx3Cache("G1_COD","X3_TAMANHO")
	Local cPaiAnt   := ""
	Local cCargo    := ""
	Local lOk       := .T.
	Local xValue

	//Limpa as variáveis Static deste fonte.
	P200IniStc()

	//Se foi chamado pelo "Criar Estrutura" (PCPA135), deve permitir alterar o campo da Lista
	If cFuncao == "PCPA135CrE"
		oStruDet:SetProperty("G1_LISTA", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, ".T."))
	EndIf

	//Altera o inicializador padrão do campo virtual 'CEXECAUTO', para que a rotina consiga identificar que é uma execução automática.
	oStruCab:SetProperty("CEXECAUTO",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD, "'S'"))

	If nOpcAuto == 3
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()

		//Preenche as informações do cabeçalho.
		For nIndField := 1 To Len(aAutoCab)
			//Verifica se o campo existe no modelo
			If oStruCab:HasField(aAutoCab[nIndField][1])
				lOk := oEvent:SetaValor(oModelCab,aAutoCab[nIndField][1],aAutoCab[nIndField][2])
				If !lOk
					Exit
				EndIf
			EndIf
		Next nIndField

	ElseIf nOpcAuto == 4
		//Busca o código do produto PAI para modificação da estrutura
		nPos := aScan(aAutoCab, {|x| x[1] == "G1_COD"})
		If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
			lOk := .F.
			Help(' ',1,"HELP", , STR0100,;//"Código do produto PAI não informado."
			     2,0, , , , , , {STR0101})//"Informe o código do produto PAI para prosseguir com a operação."
		Else
			SG1->(dbSetOrder(1))
			If !SG1->(dbSeek(xFilial("SG1")+PadR(aAutoCab[nPos][2],nTamCod)))
				lOk := .F.
				Help(' ',1,"HELP", , STR0102,;//"Produto informado não possui estrutura."
				     2,0, , , , , , {STR0103})//"Alteração não permitida."
			EndIf
		EndIf
		If lOk
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()

			//Adiciona o produto PAI.
			cCargo := P200AddPai(oModelCab:GetValue("G1_COD"))

			//Carrega a revisão atual do produto pai
			nPos := aScan(aAutoCab,{|x| AllTrim(Upper(x[1])) == 'AUTREVPAI'})
			If nPos > 0
				scRevisao := PadR(aAutoCab[nPos][2],GetSx3Cache("B1_REVATU","X3_TAMANHO"))
			Else
				scRevisao := P200IniRev(oModelCab:GetValue("G1_COD"))
			EndIf
			oModelCab:LoadValue("CREVPAI",scRevisao)

			//Carrega os componentes
			P200TreeCh(.F.,cCargo)
		EndIf

	ElseIf nOpcAuto == 7
		A200Subst(aAutoCab, aAutoItens)

	EndIf

	If lOk .And. (nOpcAuto == 3 .Or. nOpcAuto == 4)
		//Verifica se recebeu a quantidade base, e altera o valor no modelo.
		nPos := aScan(aAutoCab,{|x| x[1] == 'G1_QUANT'})
		If nPos > 0
			lOk := oEvent:SetaValor(oModelCab,"NQTBASE",aAutoCab[nPos][2])
		EndIf

		If lOk
			//Parâmetro para criação de nova revisão quando for execução automática e revisão manual
			nPos := aScan(aAutoCab,{|x| AllTrim(Upper(x[1])) == 'ATUREVSB1'})
			If nPos > 0
				oModelCab:LoadValue("ATUREVSB1",aAutoCab[nPos][2])
			Else
				oModelCab:LoadValue("ATUREVSB1","N")
			EndIf

			//Se conseguiu atribuir as informações do produto pai, carrega os componentes
			For nIndLine := 1 To Len(aAutoItens)
				//Verifica se o código do produto PAI está informado.
				nPosCmp := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_COD"})
				If nPosCmp <= 0 .Or. (nPosCmp > 0 .And. Empty(aAutoItens[nIndLine][nPosCmp][2]))
					lOk := .F.
					Help(' ',1,"HELP", , STR0100,;//"Código do produto PAI não informado."
					     2,0, , , , , , {STR0101})//"Informe o código do produto PAI para prosseguir com a operação."
					Exit
				ElseIf nIndLine == 1
					//Se é o primeiro item do array a ser processado, inicializa a variável de controle cPaiAnt
					//com o código do primeiro PAI do array.
					cPaiAnt := PadR(aAutoItens[nIndLine][nPosCmp][2],nTamCod)
				EndIf

				//Verifica se mudou o código do produto PAI
				If PadR(cPaiAnt,nTamCod) != PadR(aAutoItens[nIndLine][nPosCmp][2],nTamCod) .Or. (nIndLine == 1 .And. cPaiAnt != oModelCab:GetValue("G1_COD"))
					cPaiAnt := PadR(aAutoItens[nIndLine][nPosCmp][2],nTamCod)
					//Se o produto pai já existir carregado, busca o CARGO para adicionar novo componente
					nPos := aScan(saCargos,{|x| x[IND_ACARGO_PAI] == cPaiAnt})
					If nPos > 0
						cCargo := saCargos[nPos][IND_ACARGO_CARGO_PAI]
					Else
						//Produto pai ainda não está carregado. Monta um novo cargo para ele.
						cCargo := P200AddPai(cPaiAnt)
					EndIf
					//Executa a função P200TreeCh para carregar como produto pai o código recebido por parâmetro.
					P200TreeCh(.F.,cCargo)
				EndIf

				nLinPos := aScan(aAutoItens[nIndLine],{|x| AllTrim(Upper(x[1])) == 'LINPOS'})
				If nLinPos > 0
					aSeekLine := {}
					//Verifica se é chave composta
					If "+" $ aAutoItens[nIndLine][nLinPos][2]
						aLinPos := StrTokArr(aAutoItens[nIndLine][nLinPos][2],"+")
					Else
						aLinPos := {aAutoItens[nIndLine][nLinPos][2]}
					EndIf
					For nIndSeek := 1 To Len(aLinPos)
						//Monta o array para fazer o seek na grid.
						If !oStruDet:HasField(aLinPos[nIndSeek])
							HELP(' ',1,"HELP", , STR0104 + AllTrim(aLinPos[nIndSeek]) + STR0105,; //"Parâmetros informados no LINPOS estão incorretos. Campo " XXX " não existe."
							     2,0, , , , , , {STR0106}) //"Ajuste os parâmetros utilizados no LINPOS."
							lOk := .F.
							Exit
						EndIf

						xValue := aAutoItens[nIndLine][nLinPos][nIndSeek+2]
						If ValType(xValue) == "C"
							//Se for uma string, ajusta o tamanho de acordo com o campo.
							xValue := PadR(xValue,GetSx3Cache(AllTrim(aLinPos[nIndSeek]),"X3_TAMANHO"))
						EndIf
						aAdd(aSeekLine,{AllTrim(aLinPos[nIndSeek]),xValue})
					Next nIndSeek
					//Caso tenha acontecido algum erro, sai da execução.
					If !lOk
						Exit
					EndIf
					//Busca a linha no grid com base no LINPOS recebido
					If !oModelDet:SeekLine(aSeekLine,.T.)
						HELP(' ',1,"HELP", , STR0107,;//"Parâmetros informados no LINPOS estão incorretos. Registro não encontrado."
						     2,0, , , , , , {STR0106})//"Ajuste os parâmetros utilizados no LINPOS."
						lOk := .F.
						Exit
					EndIf
				Else
					//Verifica se é necessário adicionar uma nova linha na grid.
					If (oModelDet:Length() == 1 .And. !Empty(oModelDet:GetValue("G1_COMP"))) .Or. oModelDet:Length() > 1
						oModelDet:AddLine()
					EndIf
				EndIf

				If !lOk
					Exit
				EndIf

				//Verifica se é edição ou exclusão de registro.
				nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "AUTDELETA"})
				If nPos > 0 .And. aAutoItens[nIndLine][nPos][2] == "S"
					//Se recebeu o parâmetro AUTDELETA com o valor 'S', faz a exclusão da linha.
					//A linha a ser excluída é posicionada com o parâmetro LINPOS.
					lOk := oModelDet:DeleteLine()
				Else
					//Primeiro faz o SETVALUE dos campos que devem ser preenchidos em ordem.
					//G1_COMP
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_COMP"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					Else
						lOk := .F.
						Help(' ',1,"HELP", , STR0108,;//"Código do componente não informado."
						     2,0, , , , , , {STR0109})//"Informe o código do componente para prosseguir com a operação."
						Exit
					EndIf

					//G1_TRT
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_TRT"})
					If nPos > 0 .And. aAutoItens[nIndLine][nPos][2] != NIL
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//G1_QUANT
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_QUANT"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//G1_INI
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_INI"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//G1_FIM
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_FIM"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//G1_GROPC
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_GROPC"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//G1_OPC
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "G1_OPC"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//Atribui as demais informações do componente no modelo
					For nIndField := 1 To Len(aAutoItens[nIndLine])
						If aAutoItens[nIndLine][nIndField][1] $ "|G1_COMP|G1_TRT|G1_QUANT|G1_INI|G1_FIM|G1_GROPC|G1_OPC|"
							Loop
						EndIf
						If oStruDet:HasField(aAutoItens[nIndLine][nIndField][1])
							lOk := oEvent:SetaValor(oModelDet,aAutoItens[nIndLine][nIndField][1],aAutoItens[nIndLine][nIndField][2])
						EndIf
						If !lOk
							Exit
						EndIf
					Next nIndField
				EndIf

				If !lOk
					Exit
				EndIf

				//Valida a linha digitada.
				lOk := oModelDet:VldLineData()
				If !lOk
					Exit
				EndIf
			Next nIndLine
		EndIf
	ElseIf nOpcAuto == 5 //Exclusão
		//Busca o código do produto PAI para exclusão da estrutura
		nPos := aScan(aAutoCab, {|x| x[1] == "G1_COD"})
		If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
			lOk := .F.
			Help(' ',1,"HELP", , STR0100,;//"Código do produto PAI não informado."
			     2,0, , , , , , {STR0101})//"Informe o código do produto PAI para prosseguir com a operação."
		Else
			SG1->(dbSetOrder(1))
			If SG1->(dbSeek(xFilial("SG1")+PadR(aAutoCab[nPos][2],nTamCod)))
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				oModel:Activate()
			Else
				lOk := .F.
				Help(' ',1,"HELP", , STR0110,;//"Produto informado não possui estrutura."
				     2,0, , , , , , {STR0111})//"Exclusão não permitida."
			EndIf
		EndIf
	EndIf
	If nOpcAuto <> 7
		//Efetiva os dados.
		If lOk
			If nOpcAuto == 3 .Or. nOpcAuto == 4
				//Se for inclusão ou modificação, carrega as variáveis de controle para geração de nova revisão.
				lOk := P200AvaRev()
			EndIf

			oModel:lModify := .T.
			If lOk .And. oModel:VldData(,.T.)
				lOk := oModel:CommitData()
			EndIF
		EndIf

		//Verifica se existe alguma mensagem de erro no modelo.
		If oModel:HasErrorMessage()
			oEvent:TratMsgErr(oModel)
			lOk := .F.
		EndIf

		//Desativa o modelo.
		If oModel:IsActive()
			oModel:DeActivate()
		EndIf
		oModel:Destroy()
	EndIf
	//Limpa as variáveis Static deste fonte.
	P200IniStc()
Return Nil

/*/{Protheus.doc} ListaComp
A opção "Lista de Componentes" irá carregar os componentes da lista para a tela de cadastro da estrutura
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@param 01 oViewPai, object, objeto da ViewPai
@return lRet, logical, identifica se a View será aberta
/*/
Static Function ListaComp(oViewPai)
	Local oStruSMW  := FWFormStruct(2, "SMW", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|MW_CODIGO|MW_DESCRI|"})
	Local oStruSVG  := FWFormStruct(2, "SVG", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|VG_COMP|VG_TRT|VG_QUANT|VG_INI|VG_FIM|"})
	Local oView     := Nil
	Local oViewExec := Nil
	Local oModel    := oViewPai:GetModel()
	Local cPai      := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local nOldInd   := oModel:GetModel("SG1_DETAIL"):GetLine()
	Local nUltItem  := oModel:GetModel("SG1_DETAIL"):Length(.F.)
	Local lCancelar := .F.
	Local lRet      := .T.
	Local oEvent    := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local cCodProd  := P200RetInf(soDbTree:GetCargo(), "COMP")

	If !oStruSMW:HasField("MW_CODIGO")
		Help( ,  , "Help", ,  STR0212 + " (" + GetRpoRelease() + ")",;  //"Opção não disponível nessa Release"
			 1, 0, , , , , , {STR0213})                                 //"Atualize o sistema."
		Return .F.
	EndIf

	If !Empty(cPai)

		If !oEvent:Lock(fAjustaStr(cCodProd), oViewPai, .T.)
			lRet := .F.

		Else
			//Grava a última linha da grid principal para posicionar no primeiro registro inserido
			If !Empty(oModel:GetModel("SG1_DETAIL"):GetValue("G1_COMP"))
				nUltItem++
			EndIf

			//Não abrir a tela se a linha posicionada está inválida
			If oModel:GetModel("SG1_DETAIL"):VldLineData()
				oModel:GetModel("SG1_DETAIL"):GoLine( oModel:GetModel("SG1_DETAIL"):Length(.F.) )

				//Monta a tela de Lista de Componentes
				oView := FWFormView():New(oViewPai)
				oView:SetModel(oModel)
				oView:SetOperation(oViewPai:GetOperation())

				oStruSMW:SetProperty("MW_DESCRI", MVC_VIEW_CANCHANGE, .F.  )
				oStruSMW:SetProperty('MW_CODIGO', MVC_VIEW_LOOKUP   , 'SMW')

				oView:AddField("HEADER_SMW", oStruSMW, "FLD_LISTA")
				oView:AddGrid ("GRID_SVG"  , oStruSVG, "GRID_LISTA" )

				oView:CreateHorizontalBox("BOX_GRID_CAB",  60, , .T.)
				oView:CreateHorizontalBox("BOX_GRID_SVG", 100)

				oView:SetOwnerView("HEADER_SMW", 'BOX_GRID_CAB')
				oView:SetOwnerView("GRID_SVG"  , 'BOX_GRID_SVG')

				oView:SetOnlyView("GRID_SVG")

				lCancelar := .F.

				oView:AddUserButton(STR0115,"",{|| slConfList := .F., lCancelar := .T., oView:CloseOwner() },STR0115,,,.T.) //"Cancelar"

				//Proteção para execução com View ativa
				If oModel != Nil .And. oModel:isActive()
					oViewExec := FWViewExec():New()
					oViewExec:SetModel(oModel)
					oViewExec:SetView(oView)
					oViewExec:SetTitle(STR0114) //"Lista de Componentes"
					oViewExec:SetOperation(oViewPai:GetOperation())
					oViewExec:SetReduction(70)
					oViewExec:SetButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0116},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Confirmar"
					oViewExec:SetCloseOnOk({|oViewPai| ConfirmLis(oViewPai)})
					oViewExec:SetModal(.T.)
					oViewExec:OpenView(.F.)

					If lCancelar .Or. !slConfList
						oModel:GetModel("SG1_DETAIL"):GoLine(nOldInd)
						CancelList(oView, oViewPai, oViewExec)
					Else
						oModel:GetModel("SG1_DETAIL"):GoLine(nUltItem)
						slConfList := .F.
						CancelList(oView, oViewPai, oViewExec)
					Endif
				EndIf
			Else
				oViewPai:ShowLastError()
			EndIf
		EndIf
	Else
		Help( ,  , "Help", ,  STR0117,;  //"Código do Produto não informado."
			 1, 0, , , , , , {STR0118})  //"Informe um código de produto válido."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ConfirmLis
Função para verificar se a tela da Lista de Componentes será fechada ou não após a mensagem
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@param 01 oViewPai, object, objeto da View Pai
@return lRet, logical, identifica se a View será fechada
/*/

Static Function ConfirmLis(oViewPai)
	Local lRet       := .T.
	FWMsgRun(, {|| lRet := ConfirmLiX(oViewPai)  }, STR0053, STR0206) //"Aguarde..." + "Validando a operação..."
Return lRet

Static Function ConfirmLiX(oViewPai)
	Local oModel     := oViewPai:GetModel()
	Local oModelGrid := oModel:GetModel("SG1_DETAIL")
	Local oModelList := oModel:GetModel("GRID_LISTA")
	Local oModelAtu  := FwModelActive()
	Local oModelAuxG
	Local oEvent
	Local nX         := 0
	Local aError     := {}
	Local cCompon    := ""
	Local cLoadXML   := ""
	Local nLinErro   := 0
	Local lRet       := .T.

	If soModelAux == Nil
		soModelAux := FWLoadModel("PCPA200") //Carrega um novo modelo para fazer as validações
	Else
		soModelAux:DeActivate()
		//soModelAux:Activate()
	EndIf
	oModelAuxG := soModelAux:GetModel("SG1_DETAIL")

	oEvent := gtMdlEvent(soModelAux,"PCPA200EVDEF")

	//Copia para o modelo auxiliar os dados do modelo atual
	cLoadXML := oModel:GetXMLData( .T. /*lDetail*/, ;
	                               oViewPai:GetOperation() /*nOperation*/, ;
	                               /*lXSL*/           , ;
	                               /*lVirtual*/       , ;
	                               /*lDeleted*/       , ;
	                               .F. /*lEmpty*/     , ;
	                               .F. /*lDefinition*/, ;
	                               /*cXMLFile*/ )
	If !soModelAux:LoadXMLData( cLoadXML, .T. )
		lRet := .F.
    	Help( , , "Help", , STR0119, 1, 0) //"Ocorreu um erro ao realizar o backup dos dados."
	Else
 		slConfList := .T.

 		//Percorre os componentes da lista buscando por componente já informado na grid principal
		nQtdGrid := oModelList:Length(.F.)
		For nX := 1 To nQtdGrid
		  	If oModelGrid:SeekLine({ {"G1_COMP",oModelList:GetValue("VG_COMP",nX)},{"G1_TRT",oModelList:GetValue("VG_TRT", nX)} }, .T., .F. )
		  		If !Empty(oModelList:GetValue("VG_COMP"))
		  		    slConfList := .F.
		  			If !Empty(cCompon)
		  				cCompon += ", "
		  			EndIf
		  			cCompon += AllTrim(oModelList:GetValue("VG_COMP", nX))
		  			lRet := .F.
		  		EndIf
		 	EndIf
		Next nX

		If lRet = .F.
			Help( , , "Help", , STR0120 + " (" + AllTrim(cCompon) + ")", 1, 0) //"Este componente já está cadastrado na estrutura."
		EndIf

	    If Empty(oModelList:GetValue("VG_COMP"))
	    	Help( , , "Help", , STR0121, 1, 0) //"A lista selecionada não existe."
			lRet := .F.
	    EndIf

		If lRet
			//Inicia a inserção dos componentes da lista no modelo Auxiliar
			oModelAuxG:SetNoUpdateLine(.F.)
			oModelAuxG:SetNoDeleteLine(.F.)

			nQtdGrid := oModelList:Length(.F.)

			//Seta variável para que a inserção de componentes no modelo auxiliar não crie o item na Tree
			oEvent:lModeloAuxiliar := .T.
			FwModelActive(oModelAuxG)
			For nX := 1 To nQtdGrid
				If !( nX == 1 .And. ;
				      oModelAuxG:Length() == 1 .And. ;
				      Empty(oModelAuxG:GetValue("G1_COMP")) .And. ;
				      Empty(oModelAuxG:GetValue("G1_QUANT")) .And. ;
				      !oModelAuxG:IsDeleted() )

					If oModelAuxG:AddLine()
						If oEvent:mvlRevisaoAutomatica
							oModelAuxG:LoadValue("G1_REVINI", oModel:GetModel("SG1_COMPON"):GetValue("CREVCOMP"))
						EndIf
					EndIf
				EndIf

				//Valida a atribuição dos valores dos campos principais
				If !oModelAuxG:SetValue("G1_COMP" , oModelList:GetValue("VG_COMP" , nX))
				    nLinErro := nX
					lRet     := .F.
					Exit
				EndIf
				If !oModelAuxG:LoadValue("G1_TRT"  , oModelList:GetValue("VG_TRT"  , nX))
				    nLinErro := nX
					lRet     := .F.
					Exit
				EndIf
				If !oModelAuxG:SetValue("G1_QUANT", oModelList:GetValue("VG_QUANT", nX))
				    nLinErro := nX
					lRet     := .F.
					Exit
				EndIf
				oModelAuxG:SetValue("G1_INI"    , oModelList:GetValue("VG_INI"    , nX))
				oModelAuxG:SetValue("G1_FIM"    , oModelList:GetValue("VG_FIM"    , nX))
				oModelAuxG:SetValue("G1_FIXVAR" , oModelList:GetValue("VG_FIXVAR" , nX))
				oModelAuxG:SetValue("G1_GROPC"  , oModelList:GetValue("VG_GROPC"  , nX))
				oModelAuxG:SetValue("G1_OPC"    , oModelList:GetValue("VG_OPC"    , nX))
				oModelAuxG:SetValue("G1_POTENCI", oModelList:GetValue("VG_POTENCI", nX))
				oModelAuxG:SetValue("G1_TIPVEC" , oModelList:GetValue("VG_TIPVEC" , nX))
				oModelAuxG:SetValue("G1_VECTOR" , oModelList:GetValue("VG_VECTOR" , nX))
				oModelAuxG:SetValue("G1_LOCCONS", oModelList:GetValue("VG_LOCCONS", nX))
				oModelAuxG:LoadValue("G1_LISTA" , oModelList:GetValue("VG_COD"    , nX))

				If !oModelAuxG:VldLineData(.F.)
				    nLinErro := nX
					lRet     := .F.
					Exit
				EndIf

				If !lRet
					aError 	 := soModelAux:GetErrorMessage()
					cCompon  := oModelList:GetValue("VG_COMP", nX)
					nLinErro := nX
					Exit
				ElseIf !oModelAuxG:VldLineData(.F.)
					nLinErro := nX
					lRet   	 := .F.
					Exit
				EndIf
			Next nX
			oEvent:lModeloAuxiliar := .F.
			FwModelActive(oModelAtu)

			//Se a lista está correta, carrega os dados do modelo Auxiliar no modelo Atual
			If nLinErro = 0
				oModelGrid:SetNoUpdateLine(.F.)
				oModelGrid:SetNoDeleteLine(.F.)

				//Se a linha posicionada está válida
				If !Empty(oModelGrid:GetValue("CARGO"))
					oModelGrid:AddLine()
				EndIf

				For nX := oModelGrid:Length(.F.) To oModelAuxG:Length(.F.)
					oModelGrid:SetNoUpdateLine(.F.)
					oModelGrid:SetNoDeleteLine(.F.)
					oModelGrid:LoadValue("G1_REVINI", oModelAuxG:GetValue("G1_REVINI" , nX))
					oModelGrid:SetValue("G1_COMP"   , oModelAuxG:GetValue("G1_COMP"   , nX))
					oModelGrid:LoadValue("G1_TRT"   , oModelAuxG:GetValue("G1_TRT"    , nX))
					oModelGrid:SetValue("G1_INI"    , oModelAuxG:GetValue("G1_INI"    , nX))
					oModelGrid:SetValue("G1_FIM"    , oModelAuxG:GetValue("G1_FIM"    , nX))
					oModelGrid:SetValue("G1_FIXVAR" , oModelAuxG:GetValue("G1_FIXVAR" , nX))
					oModelGrid:SetValue("G1_GROPC"  , oModelAuxG:GetValue("G1_GROPC"  , nX))
					oModelGrid:SetValue("G1_OPC"    , oModelAuxG:GetValue("G1_OPC"    , nX))
					oModelGrid:SetValue("G1_POTENCI", oModelAuxG:GetValue("G1_POTENCI", nX))
					oModelGrid:SetValue("G1_TIPVEC" , oModelAuxG:GetValue("G1_TIPVEC" , nX))
					oModelGrid:SetValue("G1_VECTOR" , oModelAuxG:GetValue("G1_VECTOR" , nX))
					oModelGrid:SetValue("G1_LOCCONS", oModelAuxG:GetValue("G1_LOCCONS", nX))
					oModelGrid:LoadValue("G1_LISTA" , oModelAuxG:GetValue("G1_LISTA"  , nX))
					oModelGrid:SetValue("G1_QUANT"  , oModelAuxG:GetValue("G1_QUANT"  , nX))

					If nX != oModelAuxG:Length(.F.)
						oModelGrid:AddLine()
					EndIf
				Next nX
			Else
				lRet    := .F.
				aError 	:= soModelAux:GetErrorMessage()
				cCompon := oModelList:GetValue("VG_COMP", nLinErro, nLinErro)
				If Empty(aError[MODEL_MSGERR_SOLUCTION])
				   aError[MODEL_MSGERR_SOLUCTION] := STR0122 //"Verifique o Cadastro da Lista de Componentes."
				EndIf
				Help( , , aError[MODEL_MSGERR_ID] + " (" + aError[MODEL_MSGERR_IDFORMERR] + ")", , ;
				     FormatErro(cCompon, aError), 1, 0, , , , , , { aError[MODEL_MSGERR_SOLUCTION] })
			EndIf

			EnableLine(oModelGrid)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} FormatErro
Formata a mensagem de erro
@author Marcelo Neumann
@since 28/11/2018
@version 1.0
@param 01 cCompon, characters, componente com o erro
@param 01 aError , array     , array com a mensagem GetErrorMessage()
@return cMsg, characters, mensagem de erro formatada
/*/
Static Function FormatErro(cCompon, aError)
	Local cMsg := ""

	cMsg := STR0125 + CHR(13) + CHR(10) + ; //"Existem erros que impedem a importação da lista: "
	        AllTrim(RetTitle("G1_COMP")) + " " + AllTrim(cCompon)

	If !Empty( AllTrim(aError[MODEL_MSGERR_IDFIELDERR])) .And. ;
	    Upper( AllTrim(RetTitle(aError[MODEL_MSGERR_IDFIELDERR])) ) <> Upper( AllTrim(RetTitle("G1_COMP")) )

		cMsg += " (" + AllTrim(RetTitle(aError[MODEL_MSGERR_IDFIELDERR])) + ")"
	EndIf

	cMsg += ": " + AllTrim(aError[MODEL_MSGERR_MESSAGE])

Return cMsg

/*/{Protheus.doc} LoadSMW
Função para carregar a lista de componentes
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@return aLoad, array, array com os dados da SMW
/*/
Static Function LoadSMW()
	Local aLoad := {CriaVar("MW_CODIGO",.F.), CriaVar("MW_DESCRI",.F.)}

Return aLoad

/*/{Protheus.doc} CancelList
Função para cancelar a opção da lista de componentes
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@param 01 oView	   , object, objeto da View
@param 02 oViewPai , object, objeto da ViewPai
@param 03 oViewExec, object, Objeto da ViewExec
@return lRet, logical, identifica se a View será cancelada
/*/
Static Function CancelList(oView, oViewPai, oViewExec)
	Local lRet := .F.

	oViewExec:DeActivate()
	oView:DeActivate()
	oView:Destroy()
	oViewPai:GetModel("GRID_LISTA"):ClearData(.F., .T.)
	oViewPai:GetModel("FLD_LISTA"):LoadValue("MW_CODIGO"," ")
	oViewPai:GetModel("FLD_LISTA"):LoadValue("MW_DESCRI"," ")

 Return lRet

/*/{Protheus.doc} P200VldLis
Valida se o código da lista já existe
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@return lRet, logical, identifica se o registro existe
/*/
Function P200VldLis()
	Local aArea 	:= GetArea()
	Local oModel    := FWModelActive()
	Local oModelSMW := oModel:GetModel("FLD_LISTA")
	Local oModelSVG := oModel:GetModel("GRID_LISTA")
	Local oView 	:= FwViewActive()
	Local cCodSMW  	:= oModelSMW:GetValue("MW_CODIGO")
	Local lRet      := .T.

	If Empty(oModelSMW:GetValue("MW_CODIGO"))
		oModelSMW:LoadValue("MW_DESCRI","")
		oModelSVG:ClearData(.F.,.T.)
	Else
		oModelSVG:ClearData(.F.,.F.)
		oModelSVG:DeActivate()
		oModelSVG:lForceLoad := .T.
		oModelSVG:Activate()
	EndIf

	oView:Refresh("GRID_SVG")

	dbSelectArea("SMW")
	SMW->(DbSetOrder(1))
	If !SMW->(DbSeek(xFilial("SMW") + cCodSMW))
		oModelSMW:LoadValue("MW_DESCRI","")
	Else
		oModelSMW:LoadValue("MW_DESCRI",SMW->MW_DESCRI)
	EndIf

	LoadLista(oModel)

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} LoadLista
Função para carregar o grid da tabela SVG
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@param 01 oModel, object, modelo principal da tela de lista
@return	NIL
/*/
Static Function LoadLista(oModel)
	Local oView  		:= FwViewActive()
	Local oModelSVG 	:= oModel:GetModel("GRID_LISTA")
	Local cCodigo 		:= ""
	Local oStructSVG	:= oModelSVG:oFormModelStruct
	Local aFields 		:= oStructSVG:aFields
	Local nIndFields	:= 0

	If oView != Nil .And. oModel != Nil .And. oView:IsActive()
		cCodigo	:= oModel:GetModel("FLD_LISTA"):GetValue("MW_CODIGO")

		dbSelectArea("SVG")
		SVG->(dbSetOrder(1))
		If SVG->(DbSeek(xFilial("SVG") + cCodigo))
			oModelSVG:SetNoUpdateLine(.F.)
			oModelSVG:SetNoDeleteLine(.F.)
			oModelSVG:SetNoInsertLine(.F.)
			oModelSVG:ClearData(.F.,.F.)

			While !SVG->(Eof()) .And. SVG->VG_FILIAL == xFilial("SVG") .And. SVG->VG_COD == cCodigo
				oModelSVG:AddLine()

				For nIndFields := 1 To Len(aFields)
					If !oStructSVG:GetProperty(aFields[nIndFields][3], MODEL_FIELD_VIRTUAL)
						oModelSVG:LoadValue(aFields[nIndFields][3], SVG->(&(aFields[nIndFields][3])))
					EndIf
				Next nIndFields

				SVG->(DbSkip())
			EndDo

			oModelSVG:GoLine(1)
			oModelSVG:SetNoUpdateLine(.T.)
			oModelSVG:SetNoDeleteLine(.T.)
			oModelSVG:SetNoInsertLine(.T.)
		Endif
	EndIf

Return

/*/{Protheus.doc} EnableLine
Função para verificar se habilita a linha para edição/exclusão
@author Carlos Alexandre da Silveira
@since 08/01/2019
@version 1.0
@param 01 oModelSG1, object, modelo da tabela SG1
@return NIL
/*/
Static Function EnableLine(oModelSG1)
	Local lEditln := SuperGetMV("MV_PCPRLEP",.F., 2)

	If Empty(oModelSG1:GetValue("G1_LISTA")) .And. lEditln == 2
		oModelSG1:SetNoUpdateLine(.F.)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} P200Refr
Função para forçar a atualização de todas as linhas do Grid
@author Carlos Alexandre da Silveira
@since 22/01/2019
@version 1.0
@return NIL
/*/
//---------------------------------------------------------------------
Static Function P200Refr(oView, cIDView, cField, xValue)
	Local oGridView

	If cIDView == "VIEW_COMPONENTES"
		oGridView := oView:GetSubView("VIEW_COMPONENTES")
		oGridView:DeActivate(.T.)
		oGridView:Activate()
	EndIf

Return

/*/{Protheus.doc} CompValido
Verifica se o componente está válido dentro da estrutura
@author Carlos Alexandre da Silveira
@since 01/02/2019
@version 1.0
@param 01 dValIni, data inicial
@param 02 dValFim, data final
@return lValido, se o componente está válido
/*/
Static Function CompValido(dValIni, dValFim)
	Local lValido := .T.

	If dDataBase < dValIni .Or. dDataBase > dValFim
		lValido := .F.
	EndIf

Return lValido

/*/{Protheus.doc} ProximoTrt
Busca a próxima sequência para gravar no campo TRT
@author Carlos Alexandre da Silveira
@since 01/02/2019
@version 1.0
@param 01 oMdlDet, object    , modelo da Grid com os componentes
@param 02 cPai   , characters, código do produto Pai
@param 03 cComp  , characters, código do componente
@return cProxTrt, characters, próxima sequência que pode ser utilizada
/*/
Static Function ProximoTrt(oMdlDet, cPai, cComp)
	Local aAreaG1   := SG1->(GetArea())
	Local nInd      := 0
	Local nTamTrt   := GetSx3Cache("G1_TRT","X3_TAMANHO")
	Local cMaxTrtBd := Space(nTamTrt)
	Local cProxTrt  := Space(nTamTrt)
	Local cQuery    := ""
	Local lExiste   := .F.
	Local oEvent    := gtMdlEvent(oMdlDet,"PCPA200EVDEF")

	//Se estiver ocultando os inválidos, valida a TRT com o Banco de Dados
	If oEvent:nExibeInvalidos == 2
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial("SG1")+cPai+cComp))
			cQuery := "SELECT MAX(G1_TRT) MAXTRT"
			cQuery +=  " FROM " + RetSqlName('SG1') + " SG1"
			cQuery += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
			cQuery +=   " AND SG1.G1_COD     = '" + cPai  + "'"
			cQuery +=   " AND SG1.G1_COMP    = '" + cComp + "'"
			cQuery +=   " AND ((SG1.G1_INI < '" + DToS(dDataBase) + "' AND SG1.G1_FIM < '" + DToS(dDataBase) + "' ) OR"
			cQuery +=        " (SG1.G1_INI > '" + DToS(dDataBase) + "' AND SG1.G1_FIM > '" + DToS(dDataBase) + "' ))"
			cQuery +=   " AND SG1.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)

			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSG1",.F.,.T.)
			If !QRYSG1->(Eof())
				cMaxTrtBd := QRYSG1->MAXTRT
				lExiste  := .T.
			EndIf
			QRYSG1->(dbCloseArea())
		EndIf
	EndIf

	//Percorre a grid buscando pelo componente e guardando a maior sequência informada em tela
	For nInd := 1 To oMdlDet:Length()
		If nInd == oMdlDet:GetLine() .Or. oMdlDet:IsDeleted(nInd) .Or. oMdlDet:GetValue("G1_COMP", nInd) != cComp
			Loop
		EndIf

		If !Empty(oMdlDet:GetValue("G1_TRT",nInd)) .And. oMdlDet:GetValue("G1_TRT",nInd) > cProxTrt
			cProxTrt := oMdlDet:GetValue("G1_TRT",nInd)
		EndIf

		lExiste := .T.
	Next nInd

	If lExiste
		If cMaxTrtBd > cProxTrt
			cProxTrt := cMaxTrtBd
		EndIf

		If Empty(cProxTrt)
			cProxTrt := StrZero(1, nTamTrt)
			While cProxTrt <= PadR("Z", nTamTrt, "Z")
				If oEvent:ValidaTrt(oMdlDet, cPai, cComp, cProxTrt)
					Exit
				Else
					cProxTrt := Soma1(cProxTrt)
				EndIf
			End
		Else
			If cProxTrt == PadR("Z", nTamTrt, "Z")
				cProxTrt := Space(nTamTrt)
			Else
				cProxTrt := Soma1(cProxTrt)
			EndIf
		EndIf
	EndIf
	SG1->(RestArea(aAreaG1))
Return cProxTrt

/*/{Protheus.doc} P200Cargo
Monta o novo campo CARGO
@author Carlos Alexandre da Silveira
@since 05/02/2019
@version 1.0
@param 01 cPai 			- Código do produto pai
@param 02 cComp 		- Código do componente
@param 03 cTrt 			- Sequência do componente
@param 04 cCargoComp	- Campo CARGO do componente
@param 05 cRecno 		- Número do registro corrente
@return cNewCargo		- Retorna o novo campo CARGO
/*/
Function P200Cargo(cPai, cComp, cTrt, cCargoComp, cRecNo)
	Local cCargoPai := ""
	Local cNewCargo := ""
	Local nPos      := 0

	nPos := aScan(saCargos, {|x| x[IND_ACARGO_CARGO_COMP] == cCargoComp})
	If nPos > 0
		cCargoPai := saCargos[nPos][IND_ACARGO_CARGO_PAI]
		nPos := aScan(saCargos, {|x| x[IND_ACARGO_PAI]       == cPai             .And. ;
		                             x[IND_ACARGO_COMP]      == cComp .And. ;
		                             x[IND_ACARGO_TRT]       == cTrt  .And. ;
		                             x[IND_ACARGO_CARGO_PAI] == cCargoPai})
		If nPos > 0
			cNewCargo:= saCargos[nPos][IND_ACARGO_CARGO_COMP] //CARGO
		Else
			cNewCargo := MontaCargo(IND_ESTR, cPai, cComp, cRecNo)
		EndIf
	Else
		cNewCargo := MontaCargo(IND_ESTR, cPai, cComp, cRecNo)
	EndIf

Return cNewCargo

/*/{Protheus.doc} gtMdlEvent
Recupera a referência do objeto dos Eventos do modelo.

@type  Static Function
@author lucas.franca
@since 04/02/2019
@version P12
@param oModel  , Object   , Modelo de dados
@param cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent , Object   , Referência do evento do modelo de dados.
/*/
Static Function gtMdlEvent(oModel, cIdEvent)
	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent

/*/{Protheus.doc} AtalhoTecl
Recupera a referência do objeto dos Eventos do modelo.

@type  Static Function
@author marcelo.neumann
@since 01/03/2019
@version P12
@param cTecla, Character, Tecla de atalho pressionada
@return Nil
/*/
Static Function AtalhoTecl(cTecla)

	Local oViewActiv := FwViewActive()
	Local oModelPai  := oViewActiv:GetModel():GetModel("SG1_MASTER")

	If !Empty(oModelPai:GetValue("G1_COD"))
		//Só permitirá acessar os atalhos quando estiver na view/modelo principal
		If oViewActiv != Nil .and. oViewActiv:IsActive() .and. aScan(oViewActiv:GetModelsIds(), "SG1_COMPON") > 0

			//Tecla F5 (Pesquisa)
			If cTecla == "F5"
				PCPA200Pes(oViewActiv, "PESQUISA")

			//Tecla F6 (Anterior)
			ElseIf cTecla == "F6"
				PCPA200Pes(oViewActiv, "ANTERIOR")

			//Tecla F7 (Próximo)
			ElseIf cTecla == "F7"
				PCPA200Pes(oViewActiv, "PROXIMO")

			EndIf

			//Adiciona teclas de atalho
			P200Atalho(.T.)
		EndIf
	EndIf

Return

/*/{Protheus.doc} P200Atalho
Habilita os atalhos das teclas de Pesquisa (F5, F6 e F7)
@author marcelo.neumann
@since 01/03/2019
@version P12
@param lHabilita, logic, indica se deve habilitar ou desabilitar os atalhos
@return Nil
/*/
Function P200Atalho(lHabilita)

	If lHabilita
		SetKey( VK_F5, { || AtalhoTecl("F5") } )
		SetKey( VK_F6, { || AtalhoTecl("F6") } )
		SetKey( VK_F7, { || AtalhoTecl("F7") } )
	Else
		SetKey( VK_F5,  Nil )
		SetKey( VK_F6,  Nil )
		SetKey( VK_F7,  Nil )
	EndIf

Return

/*/{Protheus.doc} P200GetTre
Retorna o objeto da Tree (variável estática soDbTree)
@author marcelo.neumann
@since 01/03/2019
@version P12
@return soDbTree, object, objeto DbTree
/*/
Function P200GetTre()
Return soDbTree

/*/{Protheus.doc} P200GtNoID
Retorna o ID do nó selecionado na tree
@author marcelo.neumann
@since 01/03/2019
@version P12
@return soDbTree:CurrentNodeId, characters, Id do nó selecionado
/*/
Function P200GtNoID()
Return soDbTree:CurrentNodeId

/*/{Protheus.doc} P200TrSeek
Seleciona um registro na Tree
@author marcelo.neumann
@since 01/03/2019
@version P12
@param 01 cCargo    , characters, Cargo do registro a ser posicionado (caso não passado o cNodeId)
@param 02 cNodeId   , characters, ID do nó do registro a ser posicionado (caso não passado o cCargo)
@param 03 lExeTreeCh, logic     , indica se deve executar a função TreeChange após posicionar
@return Nil
/*/
Function P200TrSeek(cCargo, cNodeId, lExeTreeCh)

	Local lPosicionou  := .F.
	Local cCargoPai
	Local cFolderA 	   := 'FOLDER5'
	Local cFolderB 	   := 'FOLDER6'
	Local oModel       := FwModelActive()
	Local oMdlDet      := oModel:GetModel("SG1_DETAIL")

	Default cCargo     := ""
	Default cNodeId    := ""
	Default lExeTreeCh := .F.

	If Empty(cNodeId)
		lPosicionou := soDbTree:TreeSeek(cCargo)
	Else
		lPosicionou := soDbTree:PTGotoToNode(cNodeID)
	EndIf

	IF lPosicionou
		If lExeTreeCh
			P200TreeCh(.T.)
		EndIf
	ElseIf oMdlDet:GetValue("CARGO") == cCargo

		//Verifica qual a imagem da TREE.
		If dDataBase < oMdlDet:GetValue("G1_INI") .Or. dDataBase > oMdlDet:GetValue("G1_FIM")
			cFolderA := 'FOLDER7'
			cFolderB := 'FOLDER8'
		EndIf

		nPos := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_COMP]  == cCargo })
		If nPos > 0
			cCargoPai := saCargos[nPos][IND_ACARGO_CARGO_PAI]
		Else
			cCargoPai := soDbTree:GetCargo()
		EndIf
		If AddItemTr(cCargoPai                   , ;
		             oMdlDet:GetValue("CARGO")   , ;
		             NIL                         , ;
		             oMdlDet:GetValue("G1_GROPC"), ;
		             oMdlDet:GetValue("G1_OPC")  , ;
		             oMdlDet:GetValue("G1_TRT")  , ;
		             cFolderA                    , ;
		             cFolderB                    , ;
		             .T.)

			P200TrSeek(cCargo, cNodeId, lExeTreeCh)
		EndIf
	EndiF

Return lPosicionou

/*/{Protheus.doc} P200GetF12
Retorna um parâmetro F12
@author marcelo.neumann
@since 01/03/2019
@version P12
@param 01 cParametro, characters, indica qual parâmetro deve ser retornado
@return xValue, valor do parâmetro (o tipo de dado depende do parâmetro)
/*/
Function P200GetF12(cParametro)

	Local oEvent := gtMdlEvent(FWModelActive(), "PCPA200EVDEF")
	Local xValue

	If cParametro == "EXIBE_VENCIDOS"
		xValue := oEvent:nExibeInvalidos
	EndIf

Return xValue

/*/{Protheus.doc} P200GetRvT
Retorna a revisão do produto usada para carregar a Tree
@author marcelo.neumann
@since 01/03/2019
@version P12
@return scRevTree, characters, revisão do produto utilizada na tree
/*/
Function P200GetRvT()
Return scRevTree

/*/{Protheus.doc} A200Copia
Copia de Estruturas
@author Douglas Heydt
@since 21/03/2018
@version 1.0
/*/
Function A200Copia()

	Local oModelAux   := FWLoadModel("PCPA200")
	Local oEvent      := gtMdlEvent(oModelAux,"PCPA200EVDEF")
	Local nOk := .T.

	Private cProdFiltro := "MV_PAR01"

	If ExistePerg('PCPA200C')
		//Chama Pergunte PCPA200C
		oEvent := Iif(oEvent == Nil, PCPA200EVDEF():New(), oEvent)
		If !oEvent:PergPCPA200C(.T.)
			Return
		EndIf

		oEvent:lCopia := .T.
		nOk := 	FWExecView(STR0164, "PCPA200", MODEL_OPERATION_INSERT,,,{|| P200AvaRev()},,,,,,oModelAux) //"Estrutura Similar"
		oEvent:lCopia := .F.
	Else
		Help( ,  , "Help", ,  STR0212 + " (" + GetRpoRelease() + ")",;  //"Opção não disponível nessa Release"
			 1, 0, , , , , , {STR0213})                                 //"Atualize o sistema."
	EndIf

Return nOk

/*/{Protheus.doc} LoadGridC
Retorna array com os dados a serem inseridos na Grid - Cópia de Estruturas/Pré-Estruturas
@author Douglas Heydt
@since 21/03/2018
@version 1.0
@param 01 cCargo, characters, cCargo referente ao item selecionado
@param 02 oModel, object    , modelo principal
@return aLoad, array, array de carga da grid
/*/
Static Function LoadGridC(cCargo, oModel)
	Local aAreaAlias := SG1->(GetArea())
	Local aDefDados  := {}
	Local aFields    := oModel:GetModel("SG1_DETAIL"):oFormModelStruct:aFields
	Local aLoad      := {}
	Local cEstrAlias := ""
	Local nIndCps    := 0
	Local nIndPai    := aScan(aFields, {|x| x[3] == "G1_COD" })
	Local nIndRevI   := aScan(aFields, {|x| x[3] == "G1_REVINI" })
	Local nIndRev    := aScan(aFields, {|x| x[3] == "G1_REVFIM" })
	Local cProdPai   := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local cRevisao   := ""
	Local oEvent     := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local cProdSelec := oEvent:mvcEstruturaOrigem

	For nIndCps := 1 to Len(aFields)
		aAdd(aDefDados,Nil)
	Next nIndCps

	/*Busca revisão correta e atualizada do pai*/
	nScan := aScan(oEvent:aRevisoes, {|x| x[4] == cProdPai .AND. x[1] })
	If nScan == 0
		//Avalia a próxima Revisão - Sem tela
		cRevisao := oEvent:AtualizaRevisao( cProdPai, .F., .F.,,oModel)

		//Atualiza Revisão do Produto Master e Selecionado
		oModel:GetModel("SG1_MASTER"):LoadValue("CREVPAI", cRevisao)
		oModel:GetModel("SG1_COMPON"):LoadValue("CREVCOMP", cRevisao)
	Else
		cRevisao := oEvent:aRevisoes[nScan,2]
	EndIf

	If Empty(oModel:GetModel("SG1_COMPON"):GetValue("G1_COD"))
		aAdd(aLoad, {0, aClone(aDefDados)})
	Else
		//Define a query para a busca dos componentes
		cEstrAlias := QueryLoad(oModel, aFields, cRevisao, cProdSelec, .T.)

		While !(cEstrAlias)->(Eof()) .And. (cEstrAlias)->&("G1_FILIAL") == xFilial("SG1") .And. ;
				(cEstrAlias)->&("G1_COD")    == cProdSelec

			For nIndCps := 1 to Len(aFields)
				If AllTrim(aFields[nIndCps][3]) == "CARGO"
					//Gera um novo CARGO
					aDefDados[nIndCps] := MontaCargo(IND_ESTR, oEvent:mvcProdutoDestino, (cEstrAlias)->&("G1_COMP"), 0)

				ElseIf AllTrim(aFields[nIndCps][3]) == "G1_DESC"
					aDefDados[nIndCps] := PadR(IniDenProd((cEstrAlias)->&("G1_COMP")), GetSx3Cache("G1_DESC","X3_TAMANHO"))

				ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
					aDefDados[nIndCps] := 0

				ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
					aDefDados[nIndCps] := (cEstrAlias)->&("G1_TRT")

				ElseIf aFields[nIndCps][14] == .F. .And. (aFields[nIndCps][3] != "G1_REVINI" .And. aFields[nIndCps][3] != "G1_REVFIM" )//Verifica se é campo virtual
					aDefDados[nIndCps] := (cEstrAlias)->(&(aFields[nIndCps][3]))
				EndIf
			Next nIndCps

			//Corrige o XX_COD para o produto destino
			aDefDados[nIndPai]  := oEvent:mvcProdutoDestino

			If oEvent:mvlRevisaoAutomatica
				aDefDados[nIndRevI] := cRevisao
				aDefDados[nIndRev]  := cRevisao
			Else
				aDefDados[nIndRevI] := "   "
				aDefDados[nIndRev]  := "ZZZ"
			EndIf

			aAdd(aLoad, {0, aClone(aDefDados)})
			(cEstrAlias)->(dbSkip())
		End
		(cEstrAlias)->(dbCloseArea())

	EndIf

	SG1->(RestArea(aAreaAlias))

Return aLoad

/*/{Protheus.doc} QueryLoad
Retorna query para efetuar a busca de componentes de um produto pai da estrutura
@author Douglas Heydt
@since 21/03/2018
@version 1.0
@param 01 oModel, 		object, 	modelo
@param 02 aFields, 		array, 		array com a estrutura dos registros
@param 03 cRevisao, 	characters 	revisao do produto, no caso da cópia usará a revisão do produto origem
@param 04 cProdSelec, 	characters, produto selecionado na tree
@param 05 lCopia, 		boolean, 	informa se a operação é uma cópia
@return cQuery
/*/
Static Function QueryLoad(oModel, aFields, cRevisao, cProdSelec, lCopia)
	Local cAliasQry  := GetNextAlias()
	Local cQrySelect := "%"
	Local cQryFrom   := "%"
	Local cQryMemos  := ""
	Local lCount     := Empty(aFields)
	Local oEvent     := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local nIndCps    := 0
	Local nTotal     := Len(aFields)

	If lCount
		cQrySelect += " COUNT(*) TOTAL%"
	Else
		cQrySelect += " SG1.R_E_C_N_O_ RECSG1"

		For nIndCps := 1 To nTotal
			If aFields[nIndCps][3] == "G1_DESC"
				cQrySelect += ", SB1.B1_DESC"

			ElseIf aFields[nIndCps][4] == "M" //Se for campo memo tem que ter tratamento especial
				cQryMemos += ", " + AllTrim(aFields[nIndCps][3])

			ElseIf aFields[nIndCps][14] == .F. //Se é um campo do tipo Virtual, não adiciona na Query
				cQrySelect += ", SG1." + AllTrim(aFields[nIndCps][3])
			EndIf
		Next nIndCps

		cQrySelect += cQryMemos + "%"
	EndIf

	cQryFrom +=   " " + RetSqlName("SG1") + " SG1,"
	cQryFrom +=         RetSqlName("SB1") + " SB1"
	cQryFrom += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
	cQryFrom +=   " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQryFrom +=   " AND SG1.G1_COD     = '" + cProdSelec + "'"
	cQryFrom +=   " AND SB1.B1_COD     = SG1.G1_COMP"
	cQryFrom +=   " AND SG1.D_E_L_E_T_ = ' '"
	cQryFrom +=   " AND SB1.D_E_L_E_T_ = ' '"

	If cRevisao # Nil
		If oModel:GetOperation() != MODEL_OPERATION_DELETE .Or. oModel:GetModel("SG1_MASTER"):GetValue("LPESQUISA")
			cQryFrom += " AND SG1.G1_REVINI <= '" + IIF(lCopia, oEvent:mvcRevisaoOrigem, cRevisao) + "'"
			cQryFrom += " AND (SG1.G1_REVFIM >= '" + IIF(lCopia, oEvent:mvcRevisaoOrigem, cRevisao) + "' OR SG1.G1_REVFIM = ' ')"
		EndIf
	EndIf

	If !lCount
		cQryFrom += " ORDER BY " + SqlOrder(SG1->(IndexKey(1)))
	EndIf
	cQryFrom += "%"

	BeginSql Alias cAliasQry
	  SELECT %Exp:cQrySelect%
	    FROM %Exp:cQryFrom%
	EndSql

	If !lCount
		//Faz a conversão dos campos Data, Lógico e Numérico.
		For nIndCps := 1 To nTotal
			If aFields[nIndCps][14] == .F. //Se é um campo do tipo Virtual, não adiciona na Query
				If aFields[nIndCps][4] $ "N|L|D"
					// aFields[nIndCps][3] - Nome do campo
					// aFields[nIndCps][4] - Tipo de dado do campo
					// aFields[nIndCps][5] - Tamanho do campo
					// aFields[nIndCps][6] - Precisão do campo
					TcSetField(cAliasQry, aFields[nIndCps][3], aFields[nIndCps][4], aFields[nIndCps][5], aFields[nIndCps][6])
				EndIf
			EndIf
		Next nIndCps
	EndIf

Return cAliasQry

/*/{Protheus.doc} P200OpcRev
Indica se deverá ser exibida a opção de Alterar Revisão no programa
@author Marcelo Neumann
@since 04/04/2019
@version 1.0
@param lPermite, boolean, indica se exibe ou não o botão de Aterar Revisão
@return Nil
/*/
Function P200OpcRev(lPermite)

	slOpcAltRv := lPermite

Return

/*/{Protheus.doc} P200Oper
Abre a tela de operações do produto selecionado
@author Carlos Alexandre da Silveira
@since 10/04/2019
@version 1.0
@return Nil
/*/
Function P200Oper()

	Local aBackVar  := Array(2)
	Local lRet      := .F.
	Local cProduto  := SG1->G1_COD
	Local cDenPai	:= IniDenProd(cProduto)
	Local cRoteiro  := CriaVar("GF_ROTEIRO")
	Local oModel637
	Local oTGet1

	dbSelectArea('SB1')
	SB1->(dbSetOrder(1))
	IF SB1->(dbSeek(xFilial('SB1')+SG1->G1_COD))
		cRoteiro := SB1->B1_OPERPAD
	EndIf

	DEFINE MSDIALOG oDlg FROM 000,000 TO 200,615 TITLE STR0182 PIXEL  //"Informe o roteiro"

	//Get para exibir o código do produto.
	TGet():New(35,05,{|u|if(PCount()>0,cProduto:=u,cProduto)},oDlg,;
	           100,15,"@!",/*08*/,/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,{||.F.},.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"cProduto",/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0023,1) //"Produto Pai"

	//Get para exibir a descrição do produto.
	TGet():New(35,105,{|u|if(PCount()>0,cDenPai:=u,cDenPai)},oDlg,;
	           150,15,"@!",/*08*/,/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,{||.F.},.F.,.F.,;
	           /*20*/,.F.,.F.,/*23*/,"cDenPai",/*25*/,/*26*/,/*27*/,.F.,.T.,/*30*/,STR0018,1) //"Descrição"

	//Get para informar o roteiro desejado
	oTGet1 := TGet():New(70,05,{|u|if(PCount()>0,cRoteiro:=u,cRoteiro)},oDlg,;
	     				30,15,PesqPict('SGF','GF_ROTEIRO'),{|| (lRet:=VldRotOper(cRoteiro),Iif(lRet, oDlg:End(),.F.)) }/*08*/,/*09*/,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,;
						/*20*/,.F.,.F.,/*23*/,"cRoteiro",/*25*/,/*26*/,/*27*/,.T.,.F.,/*30*/,STR0183,1) //"Roteiro"

	oTGet1:cF3 := "SG2001"

	//Variáveis INCLUI e ALTERA definidas como .F. para a função EnchoiceBar criar os botões com as descrições Confirmar/Cancelar
	aBackVar[1] := Iif(Type("INCLUI")=="L",INCLUI,Nil)
	aBackVar[2] := Iif(Type("ALTERA")=="L",ALTERA,Nil)
	INCLUI := .F.
	ALTERA := .F.
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {||lRet:=.T.}, {||(lRet:=.F.,oDlg:End())}, , , , , .F., .F., .F., .T., .F.)
	INCLUI := aBackVar[1]
	ALTERA := aBackVar[2]

	If lRet
		oModel637 := FWLoadModel("MATA637")
		dbSelectArea('SGF')
		SGF->(dbSetOrder(1))
		IF SGF->(dbSeek(xFilial('SGF')+SG1->G1_COD+cRoteiro))
			oModel637:SetOperation(MODEL_OPERATION_UPDATE)
			oModel637:Activate()
			oModel637:GetModel("SGFDETAIL"):SetNoInsertLine(.T.)
			oModel637:GetModel("SGFDETAIL"):SetNoUpdateLine(.T.)
			oModel637:GetModel("SGFDETAIL"):SetNoDeleteLine(.T.)
			FWExecView(STR0002, "MATA637", MODEL_OPERATION_UPDATE,,,,,,,,,oModel637) //"Alterar"
		Else
			oModel637:SetOperation(MODEL_OPERATION_INSERT)
			oModel637:Activate()
			oModel637:GetModel("SGFMASTER"):SetValue("GF_PRODUTO",cProduto)
			oModel637:GetModel("SGFMASTER"):SetValue("GF_ROTEIRO",cRoteiro)
			oModel637:GetModel("SGFMASTER"):SetOnlyView()
			FWExecView(STR0003, "MATA637", MODEL_OPERATION_INSERT,,,,,,,,,oModel637) //"Incluir"
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} VldRotOper
Valida se o roteiro informado existe na tabela SG2
@author Carlos Alexandre da Silveira
@since 12/04/2019
@version 1.0
@param cRoteiro, caracter, roteiro informado
@return lRet, indica se o roteiro existe ou não
/*/
Static Function VldRotOper(cRoteiro)
	Local lRet := .T.

	dbSelectArea('SG2')
	SG2->(dbSetOrder(1))
	IF !SG2->(dbSeek(xFilial('SG2')+SG1->G1_COD+cRoteiro)) .Or. Empty(cRoteiro)
		Help(' ',1,"Help" ,,STR0194,2,0,,,,,,) // "Informe um roteiro válido."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} P200Cancel
Bloco executado ao cancelar a alteração
@author Carlos Alexandre da Silveira
@since 16/04/2019
@version 1.0
@return lRet, indica se pode ser cancelado
/*/
Function P200Cancel()
	Local lRet	 := .T.
	Local oModel := FwModelActive()
	Local oEvent := gtMdlEvent(oModel, "PCPA200EVDEF")

	If oEvent:oDadosCommit["oQLinAlt"]["*Total*"] == 0;
		.AND. Len(oModel:GetModel("SG1_DETAIL"):GetLinesChanged()) == 0
		oModel:lModify := .F.
	EndIf

Return lRet


/*/{Protheus.doc} SincTreeGr
Sincroniza a Tree com a Grid
@author Marcelo Neumann
@since 24/04/2019
@version 1.0
@param 01 oMdlDet  , objeto   , modelo da Grid
@param 02 cCargoPai, caractere, cargo do pai selecionado
@return Nil
/*/
Static Function SincTreeGr(oMdlDet, cCargoPai)

	Local cCargo
	Local nPos     	 := 0
	Local nInd     	 := 1
	Local cFolderA 	 := 'FOLDER5'
	Local cFolderB 	 := 'FOLDER6'
	Local aCargosCmp := Iif(soCargosPai[cCargoPai] == Nil, {}, soCargosPai[cCargoPai]:GetNames())
	Local nTotal     := Len(aCargosCmp)
	Local lTodosNvl  := .T.
	Local oEvent     := gtMdlEvent(oMdlDet:GetModel(),"PCPA200EVDEF")

	If !oMdlDet:IsEmpty()
		For nInd := 1 To oMdlDet:Length()
			If oMdlDet:IsDeleted(nInd)
				Loop
			EndIf

			//Supre a exibicao de todos os componentes do mesmo nivel na Tree
			//Inicio - snPadMaxCmp = 999999. Mantido no fonte como tecnica "Carta na manga de melhoria de performance" a pedidos do PO, entretanto "em desuso". Para uso, reduzir snPadMaxCmp para X componentes.
			If nInd == (snPadMaxCmp+1) .AND. !oEvent:lMostrandoTodos
				lTodosNvl := .F.
				nPos      := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargoPai .and. AllTrim(x[IND_ACARGO_COMP])  == ". . ." })
				If nPos > 0
					P200DelIt(cCargoPai, saCargos[nPos][IND_ACARGO_CARGO_COMP])
				EndIf
				cCargo    := MontaCargo(IND_ESTR, P200RetInf(cCargoPai,"COMP"), ". . .", 0)
				AddItemTr(cCargoPai, cCargo, NIL, "", "", "", "PMSUPDOWN", "PMSUPDOWN",.T.)
				Exit
			EndIf
			//Fim

			cCargo := oMdlDet:GetValue("CARGO", nInd)

			If soCargosPai[cCargoPai] == Nil;
			   .OR. soCargosPai[cCargoPai][cCargo] == Nil;
			   .OR. soCargosPai[cCargoPai][cCargo] == 0

				//Verifica qual a imagem da TREE.
				If dDataBase < oMdlDet:GetValue("G1_INI",nInd) .Or. dDataBase > oMdlDet:GetValue("G1_FIM",nInd)
					cFolderA := 'FOLDER7'
					cFolderB := 'FOLDER8'
				EndIf

				AddItemTr(cCargoPai                        , ;
						  oMdlDet:GetValue("CARGO" ,nInd)  , ;
						  NIL, ;
						  oMdlDet:GetValue("G1_GROPC",nInd), ;
						  oMdlDet:GetValue("G1_OPC",nInd)  , ;
						  oMdlDet:GetValue("G1_TRT",nInd)  , ;
						  cFolderA                         , ;
						  cFolderB                         , ;
						  .T.)
			EndIf
		Next nInd
	EndIf

	//Verifica se os Nós ainda existem (se ainda estão na Grid)
	If lTodosNvl
		For nInd := 1 to nTotal
			nPos := aCargosCmp[nInd]
			If !oMdlDet:SeekLine({ {"CARGO", aCargosCmp[nInd]}  }, .F., .T.)
				P200DelIt(cCargoPai, aCargosCmp[nInd])
			EndIf
		Next
	EndIf

	oMdlDet:GoLine(1)

Return

/*/{Protheus.doc} ChgLinGrid
Função acionada ao mudar a linha da grid
@author Marcelo Neumann
@since 24/04/2019
@version 1.0
@param 01 oView, objeto, view principal
@return Nil
/*/
Static Function ChgLinGrid(oView)

	Local oModel  := oView:GetModel()
	Local oMdlDet := oModel:GetModel("SG1_DETAIL")
	Local oEvent  := gtMdlEvent(oModel,"PCPA200EVDEF")
	Local lRet    := .T.

	If oMdlDet:IsInserted() .And. Empty(oMdlDet:GetValue("CARGO"))
		If !oEvent:GridLinePreVld(oMdlDet, "SG1_DETAIL", oMdlDet:GetLine(), "ADDLINE")
			oMdlDet:ClearData(.F.,.F.)
			oMdlDet:DeActivate()
			oMdlDet:Activate()

			P200Refr(oView, "VIEW_COMPONENTES")

			lRet := .F.
		EndIf
	EndIf

	EnableLine(oMdlDet)

Return lRet

/*/{Protheus.doc} JIncrementa
Incrementa totalizador de componentes validos Total e do Produto Intermediario

@author brunno.costa
@since 20/05/2019
@version 1.0

@param 01 - cProduto    , caracter, codigo do produto intermediario
@param 02 - cChave      , caracter, cChave atual do componente
@return NIL
/*/
Static Function JIncrementa(cProduto, cChave)
	Local oModel    := FwModelActive()
	Local oEvent    := gtMdlEvent(oModel, "PCPA200EVDEF")
	Local oLinDel   := oEvent:oDadosCommit["oLinDel"]
	Local oProdutos := oEvent:oDadosCommit["oProdutos"]
	Local oQLinAlt  := oEvent:oDadosCommit["oQLinAlt"]

	If oProdutos[cProduto] == Nil;
		.OR. oProdutos[cProduto][cChave] == Nil;
		.OR. oLinDel[cProduto + cChave]

		If oQLinAlt[cProduto] == Nil
			oQLinAlt[cProduto] := 1
		Else
			oQLinAlt[cProduto] += 1
		EndIf
		If oQLinAlt["*Total*"] == Nil
			oQLinAlt["*Total*"] := 1
		Else
			oQLinAlt["*Total*"] += 1
		EndIf
	EndIf
Return

/*/{Protheus.doc} JDecrementa
Decrementa totalizador de componentes validos Total e do Produto Intermediario

@author brunno.costa
@since 20/05/2019
@version 1.0

@param 01 - cProduto    , caracter, codigo do produto intermediario
@param 02 - cChave      , caracter, cChave atual do componente
@return NIL
/*/
Static Function JDecrementa(cProduto, cChave)
	Local oModel    := FwModelActive()
	Local oEvent    := gtMdlEvent(oModel, "PCPA200EVDEF")
	Local oMdlDet   := oModel:GetModel("SG1_DETAIL")
	Local oLinDel   := oEvent:oDadosCommit["oLinDel"]
	Local oProdutos := oEvent:oDadosCommit["oProdutos"]
	Local oQLinAlt  := oEvent:oDadosCommit["oQLinAlt"]

	If (oProdutos[cProduto] != Nil;
	   .AND. oProdutos[cProduto][cChave] != Nil;
	   .AND. (oLinDel[cProduto + cChave] == Nil .OR. !oLinDel[cProduto + cChave]));
	   .OR. oMdlDet:IsInserted()

		If oQLinAlt[cProduto] == Nil
			oQLinAlt[cProduto] := 0
		Else
			oQLinAlt[cProduto] := oQLinAlt[cProduto] - 1
		EndIf
		If oQLinAlt["*Total*"] == Nil
			oQLinAlt["*Total*"] := 0
		Else
			oQLinAlt["*Total*"] := oQLinAlt["*Total*"] -1
		EndIf
	EndIf
Return

/*/{Protheus.doc} P200GPdMax
Retorna conteudo da variavel snPadMaxCmp

@author brunno.costa
@since 20/05/2019
@version 1.0

@return snPadMaxCmp, numero, numero maximo de componentes exibidos por padrao na Tree
/*/
Function P200GPdMax()
Return snPadMaxCmp

/*/{Protheus.doc} P200SPdMax
Seta conteudo padrao da variavel snPadMaxCmp

@author brunno.costa
@since 20/05/2019
@version 1.0

@param 01 - nMax, numero, valor a ser atribuido a variavel snPadMaxCmp
@return NIL
/*/
Function P200SPdMax(nMax)
	snPadMaxCmp := nMax
Return

/*/{Protheus.doc} P200Pergun
Trata a exibição do Pergunte para clientes que não possuem a do PCPA200
@author marcelo.neumann
@since 25/05/2019
@version 1.0
@param lExibe, lógico, indica se exibe o pergunte em tela
@return NIL
/*/
Function P200Pergun(lExibe)

	Default lExibe := .T.

	If Empty(scPergunte)
		If ExistePerg('PCPA200')
			scPergunte := 'PCPA200'
		Else
			scPergunte := 'MTA200'
		EndIf
	EndIf

	Pergunte(scPergunte, lExibe)

Return scPergunte

/*/{Protheus.doc} ExistePerg
Verifica se a Pergunte existe na SX1
@author marcelo.neumann
@since 25/06/2019
@version 1.0
@param cPergunte, caracter, código da Pergunte a ser pesquisada
@return lExiste, lógico, indica se a Pergunte enviada existe na SX1
/*/
Static Function ExistePerg(cPergunte)

	Local oPergunta := NIL
	Local aDadosPer := {}

	oPergunta := FWSX1Util():New()
	oPergunta:AddGroup(cPergunte)
	oPergunta:SearchGroup()
	aDadosPer := oPergunta:GetGroup(cPergunte)

Return !Empty(aDadosPer[2])

/*/{Protheus.doc} P200FcPesq
Seta flag de controle para forçar a execução da função beforeView e afterView.
Após a execução da função afterView, o indicador será executado automaticamente para .F.

@type  Function
@author lucas.franca
@since 03/01/2020
@version P12.1.29
@param lSetForc, Logical, Indicador para executar a função afterView
@return Nil
/*/
Function P200FcPesq(lSetForc)
	slForcaPes := lSetForc
Return Nil

/*/{Protheus.doc} avaliaRev
Verifica se deve ser questionado ao usuário
sobre a geração de nova revisão quando o parâmetro
MV_REVAUT estiver como F.

@type  Static Function
@author lucas.franca
@since 17/01/2020
@version P12.1.27
@param oEvent, Object, Referência do objeto do evento padrão do PCPA200
@param oModel, Object, Objeto de dados da tela.
@return lGerar, Logic, Identifica se deve ser gerada nova revisão
/*/
Static Function avaliaRev(oEvent, oModel)
	Local aNames  := {}
	Local lGerar  := .F.
	Local nTotal  := 0
	Local nIndex  := 0
	Local nPosRec := 0
	Local oLines  := oEvent:oDadosCommit["oLines"]
	Local oLinDel := oEvent:oDadosCommit["oLinDel"]
	Local oFields := oEvent:oDadosCommit["oFields"]
	Local oMdlSG1 := Nil

	nPosRec := oFields["NREG"]

	aNames := oLines:GetNames()
	nTotal := Len(aNames)

	For nIndex := 1 To nTotal
		//Verifica se foi inserido um componente.
		If oLines[aNames[nIndex]] != Nil .And. oLines[aNames[nIndex]][nPosRec] == 0
			//Se o componente foi inserido, verifica se não foi excluído.
			If oLinDel[aNames[nIndex]] != Nil .And. oLinDel[aNames[nIndex]]
				//Componente foi adicionado porém foi marcado como excluído.
				//Pula para o próximo componente
				Loop
			EndIf

			//Componente adicionado. Marca para questionar geração de revisão
			lGerar := .T.
			Exit
		EndIf

		//Verifica se o componente foi excluído.
		If oLinDel[aNames[nIndex]] != Nil .And. oLinDel[aNames[nIndex]]
			//Verifica se o componente excluído não foi adicionado nesta transação.
			If oLines[aNames[nIndex]] != Nil .And. oLines[aNames[nIndex]][nPosRec] == 0
				//Componente foi adicionado nesta mesma transação.
				//Pula para o próximo componente
				Loop
			EndIf
			//Componente excluído. Marca para questionar geração de revisão
			lGerar := .T.
			Exit
		EndIf
	Next nIndex
	aSize(aNames, 0)

	//Se não conseguiu identificar componentes incluídos ou excluídos nos objetos de controle
	//de gravação, verifica no modelo atual se existem componentes incluídos ou excluídos.
	//OBS -> Necessário verificar também no modelo atual, pois esta função é executada
	//antes de alimentar os objetos de gravação para os registros do modelo atual.
	If !lGerar
		oMdlSG1 := oModel:GetModel("SG1_DETAIL")
		nTotal := oMdlSG1:Length()

		For nIndex := 1 To nTotal
			If !Empty(oMdlSG1:GetValue("G1_COMP", nIndex)) .And. ;
			   oMdlSG1:GetValue("NREG", nIndex) == 0 .And. ;
			   !oMdlSG1:IsDeleted(nIndex)
				//G1_COMP informado, em uma linha sem NREG e que não está deletada.
				//Componente incluído. Marca para questionar geração de revisão.
				lGerar := .T.
				Exit
			EndIf

			If oMdlSG1:GetValue("NREG", nIndex) != 0 .And. oMdlSG1:IsDeleted(nIndex)
				//Registro com NREG, e marcado como deletado. -> Componente excluído.
				//Marca para questionar geração de revisão.
				lGerar := .T.
				Exit
			EndIf
		Next nIndex
	EndIf

Return lGerar

/*/{Protheus.doc} vldAlter
Verifica se os alternativos com tipo 2 ou 3 devem ser validados (proteção de dicionário)

@type  Static Function
@author lucas.franca
@since 26/02/2020
@version P12.1.30
@return lRet, Logic, Indica se deve validar os alternativos
/*/
Static Function vldAlter()
	Local aArea := {}
	Local lRet  := .F.

	If slGIEstoq == Nil
		aArea := GetArea()
		dbSelectArea("SGI")
		If SGI->(FieldPos("GI_ESTOQUE")) > 0
			slGIEstoq := .T.
		Else
			slGIEstoq := .F.
		EndIf
		RestArea(aArea)
	EndIf

	lRet := slGIEstoq

Return lRet

/*/{Protheus.doc} produzAlt
Verifica se um produto possui alternativos configurados com
regra do tipo 2 ou 3, onde ocorrerá a produção do produto alternativo.

@type  Static Function
@author lucas.franca
@since 26/02/2020
@version P12.1.30
@param cProduto, Character, Código do produto original para pesquisa
@return cAlterna, Character, Código do produto alternativo que será produzido
/*/
Static Function produzAlt(cProduto)
	Local cAlterna := ""

	SGI->(dbSetOrder(1))
	If SGI->(dbSeek(xFilial("SGI")+cProduto))
		If SGI->GI_ESTOQUE $ "2|3"
			cAlterna := SGI->GI_PRODALT
		EndIf
	EndIf
Return cAlterna

/*/{Protheus.doc} fAjustaStr
Remove caracteres especiais de uma string.
@type  Function
@author mauricio.joao
@since 03/06/2020
@version 1.0
@param cString, string, String sem os caracteres especiais
/*/
Function fAjustaStr(cString)
	//Simbolos para serem removidos.
	aSimbolos := {'"','\','/','<','>'}
	//Remove simbolos
	aEval(aSimbolos,{|x| cString := StrTran( cString, x, " " ) })

Return cString

/*/{Protheus.doc} P200MapDiv
Abre seletor de revisão e a tela com o Mapa de Divergência
@type Function
@author marcelo.neumann
@since 09/08/2022
@version 1.0
/*/
Function P200MapDiv()
	Local cProduto := SG1->G1_COD
	Local lRet     := getRevisao(.T., cProduto)

	If lRet
		P200Diverg(cProduto, scRevisao)
	EndIf

Return lRet

/*/{Protheus.doc} PCPA200Men
Faz com que os botões aparecam corretamento, quando o programado é
chamado via User Function
@type  Function
@author guilherme.bertoldi
@since 22/08/2022
@version v1.0
/*/
Function PCPA200Men()

Return MenuDef()

/*/{Protheus.doc} RevisaoPI
Retorna a revisão do PI

@type Static Function
@author marcelo.neumann
@since 12/09/2022
@version 1.0
@param 01 cCodPai , Character, Código do produto pai
@param 02 cCodComp, Character, Código do componente a ser buscada a revisão
@param 03 cRevPai , Character, Revisão do produto pai
@return   cRevComp, Character, Revisão do componente
/*/
Static Function RevisaoPI(cCodPai, cCodComp, cRevPai)
	Local cRevComp := P200IniRev(cCodComp)

	If slA200rvPi
		If soRevPE == Nil
			soRevPE := JsonObject():New()
		EndIf
		If !soRevPE:HasProperty(cCodPai + cCodComp)
			soRevPE[cCodPai + cCodComp] := ExecBlock("A200RVPI",.F.,.F., {cCodPai, cRevPai, cCodComp, cRevComp})
		EndIf
		cRevComp := soRevPE[cCodPai + cCodComp]
	EndIf

Return cRevComp

/*/{Protheus.doc} P200AltPai
Bloco executado para desabilitar os campos master
@author Vivian Beatriz de Almeida Nogueira
@since 03/10/2022
@version 1.0
@return lAltBkp, valor anterior da variável slAltPai
/*/
Function P200AltPai(lAltPai)
  Local lAltBkp := slAltPai
	
	slAltPai := lAltPai 

Return lAltBkp
