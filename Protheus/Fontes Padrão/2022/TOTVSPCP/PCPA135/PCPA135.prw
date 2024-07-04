#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA135.CH"
#INCLUDE "FWEDITPANEL.CH"

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

//Constantes referentes aos ícones da tree
#DEFINE VALIDO_A   "FOLDER5"
#DEFINE VALIDO_F   "FOLDER6"
#DEFINE INVALIDO_A "FOLDER7"
#DEFINE INVALIDO_F "FOLDER8"

//Estáticas reinicializadas com na função P135IniStc
Static snSeqTree  := 0
Static soDbTree   := NIL
Static soModelAux := NIL
Static soEveDef   := NIL
Static saCargos   := {}
Static saTreeLoad := NIL
Static slAltPai   := NIL
Static slExecChL  := NIL
Static slConfList := .F.
Static slAtuaTree := .T.
Static slChanging := .F.
Static slValQtde  := .F.
Static slCriaTemp := .T.
Static slExpCopia := .F.

//Estáticas que não precisam ser reinicializadas
Static snTamCod   := GetSx3Cache("GG_COD"  ,"X3_TAMANHO")
Static snTamComp  := GetSx3Cache("GG_COMP" ,"X3_TAMANHO")
Static scPicQuant := GetSx3Cache("GG_QUANT","X3_PICTURE")
Static snDecQuant := GetSx3Cache("GG_QUANT","X3_DECIMAL")
Static slReabre   := .F.
Static soMenPopUp := NIL
Static slMontando := .F.
Static slPCPRLEP  := SuperGetMV("MV_PCPRLEP",.F., 2)
Static slGIEstoq  := Nil

/*/{Protheus.doc} PCPA135
Cadastro de Pré-Estrutura (SGG)
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return NIL
/*/
Function PCPA135(xAutoCab, xAutoItens, nOpcAuto)

	Local aArea := GetArea()
	Local oBrowse
	Local lCalcNivel := NIL
	Local l135Auto	 := .F.
	
	If Type("lAutoMacao")!="L" //Desviar a trava quando executado via automação
	   //Proteção do fonte para não ser utilizado pelos clientes neste momento.
	   If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
	      HELP(' ',1,"Help" ,,STR0141,2,0,,,,,,) //"Rotina não disponível nesta release."
	   	  Return
	   EndIf
	EndIf

	soEveDef := Iif(soEveDef == Nil, PCPA135EVDEF():New(), soEveDef)

	If xAutoCab <> Nil
		l135Auto := .T.
		nPos :=	aScan(xAutoCab,{|x| x[1] == "NIVALTP"})
		If ( nPos > 0 .and. xAutoCab[nPos,2] == "S" )
			lCalcNivel	:= .T.
		Else
			lCalcNivel	:= .F.
		EndIf

		ExecutAuto(xAutoCab, xAutoItens, nOpcAuto)
	Else
		oBrowse := BrowseDef()
		oBrowse:Activate()
	EndIf

	//Recalcula os níveis
	If GetMv('MV_NIVALTP') == 'S'
		MA320Nivel(NIL,lCalcNivel,!l135Auto,NIL,.T., NIL)
	Endif

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} BrowseDef
Criação do Browse da rotina
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return oBrowse, object, objeto do tipo FWMBrowse
/*/
Static Function BrowseDef()

	Local oBrowse
	Local nCnt

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SGG")
	oBrowse:SetDescription(STR0001) //"Cadastro de Pré-Estrutura"
	oBrowse:SetParam({ || Pergunte("PCPA135", .T.) })

	ADD LEGEND DATA {|| GG_STATUS == '1'} COLOR "BR_AMARELO"  TITLE STR0025 Of oBrowse //"Em criação"
	ADD LEGEND DATA {|| GG_STATUS == '2'} COLOR "BR_VERDE"    TITLE STR0026 Of oBrowse //"Pré-Estrutura Aprovada"
	ADD LEGEND DATA {|| GG_STATUS == '3'} COLOR "BR_VERMELHO" TITLE STR0027 Of oBrowse //"Pré-Estrutura Rejeitada"
	ADD LEGEND DATA {|| GG_STATUS == '4'} COLOR "BR_AZUL"     TITLE STR0028 Of oBrowse //"Estrutura criada"
	ADD LEGEND DATA {|| GG_STATUS == '5'} COLOR "BR_LARANJA"  TITLE STR0029 Of oBrowse //"Submetida a aprovação"

	//------------------------------------------------
	//Ponto de Entrada para adicionar cores na legenda
	//------------------------------------------------
	If ExistBlock("MT202LEG")
		aCorUsr := ExecBlock("MT202LEG",.F.,.F., { 1 })
		If ValType(aCorUsr) <> "A"
			aCorUsr := {}
		EndIf
		For nCnt := 1 To Len(aCorUsr)
			oBrowse:AddLegend(aCorUsr[nCnt,1],aCorUsr[nCnt,2])/* xCondition, cColor*/
		Next nCnt
	EndIf

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
Static Function MenuDef()

	Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'PCPA135MNU(2)' OPERATION OP_VISUALIZAR ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'PCPA135MNU(3)' OPERATION OP_INCLUIR    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION 'PCPA135MNU(4)' OPERATION OP_VISUALIZAR ACCESS 0 //"Alterar" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0005 ACTION 'PCPA135MNU(5)' OPERATION OP_VISUALIZAR ACCESS 0 //"Excluir" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0033 ACTION 'P135Legend()'  OPERATION OP_VISUALIZAR ACCESS 0 //"Legenda"
	ADD OPTION aRotina TITLE STR0062 ACTION 'A135CEst()'    OPERATION OP_VISUALIZAR ACCESS 0 //"Comparar"
	ADD OPTION aRotina TITLE STR0119 ACTION 'A135Copia()'   OPERATION OP_INCLUIR    ACCESS 0 //"Pré-Estrutura Similar"

	If SuperGetMV("MV_APRESTR",.F.,.F.)
		ADD OPTION aRotina TITLE STR0133 ACTION "P135Aprova('E')" OPERATION OP_VISUALIZAR ACCESS 0 //"Enc.Aprovação"
		ADD OPTION aRotina TITLE STR0168 ACTION "P135LogApr()"    OPERATION OP_VISUALIZAR ACCESS 0 //"Log. Aprovação"
	Else
		ADD OPTION aRotina TITLE STR0134 ACTION "P135Aprova('A')" OPERATION OP_VISUALIZAR ACCESS 0 //"Aprovar"
		ADD OPTION aRotina TITLE STR0135 ACTION "P135Aprova('R')" OPERATION OP_VISUALIZAR ACCESS 0 //"Rejeitar"
	EndIf

	ADD OPTION aRotina TITLE STR0169 ACTION 'P135CriaEs()'    OPERATION OP_VISUALIZAR ACCESS 0 //"Criar Estrutura" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)
	ADD OPTION aRotina TITLE STR0224 ACTION 'P135Subst()' 	  OPERATION OP_VISUALIZAR ACCESS 0 //"Substituir" - OP_ALTERAR -> OP_VISUALIZAR (Nao realiza lock da FwMBrowse)

	If ExistBlock ("MTA202MNU")
		ExecBlock ("MTA202MNU",.F.,.F.)
	Endif

Return aRotina

/*/{Protheus.doc} PCPA135MNU()
Função que executa a view do programa.
Necessário desvio da abertura re-executando sempre a MenuDef e ViewDef

@author brunno.costa
@since 11/12/2018
@version 1.0

@param nOpcao	- Identifica a operação que está sendo executada (inclusão/exclusão/alteração/visualização)
@return nOK	- Identifica se o usuário confirmou (nOk==0) ou cancelou (nOk==1) a operação.
/*/
Function PCPA135MNU(nOpcao)
	Local nOpc   := 2
	Local nOk    := 0
	Local cTexto := ""
	Local nRecno := SGG->(Recno())

	If nOpcao != 3							  //Operacoes de Inclusao, Alteracao e Exclusao
		SGG->(DbSkip())                       //Forca desposicianamento de registro
		SGG->(dbGoTo(nRecno))                 //Forca reposicionamento do registro
		If SGG->(Deleted()) .OR. SGG->(Eof()) //Verifica se o registro esta excluido ou se esta em EOF - sem registros dentro da condicao de filtro
			SGG->(DbSkip())                   //Forca desposicianamento de registro
			SGG->(DbGoTop())                  //Posiciona no primeiro registro
			//Este registro foi excluído por outro usuário.
			//Selecione outro registro e tente novamente.
			Help( ,  , "Help", ,  STR0268, 1, 0, , , , , , {STR0269})
			nOk := -1
		EndiF
	EndiF

	If nOk == 0
		Do Case
			Case nOpcao == 2
				nOpc   := MODEL_OPERATION_VIEW
				cTexto := STR0002 //Visualizar
			Case nOpcao == 3
				nOpc   := MODEL_OPERATION_INSERT
				cTexto := STR0003 //Incluir
			Case nOpcao == 4
				nOpc   := MODEL_OPERATION_UPDATE
				cTexto := STR0004 //Alterar
			Case nOpcao == 5
				nOpc   := MODEL_OPERATION_DELETE
				cTexto := STR0005 //Excluir
		EndCase
		nOk := FWExecView(cTexto, "PCPA135", nOpc,,,{|| .T. },,,,,,)
	EndIf
Return nOk

/*/{Protheus.doc} ModelDef
Definição do Modelo
Os modelos são definidos como SetOnlyQuery, e o commit dos dados é feito através do modelo do fonte PCPA135Grv.
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return oModel, object, modelo de dados da tabela SGG
/*/
Static Function ModelDef()

	Local oModel
	Local oStrMaster := FWFormStruct(1,"SGG",{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local oStrSelect := FWFormStruct(1,"SGG",{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local oStrDetail := FWFormStruct(1,"SGG")
	Local oStrGrava  := FWFormStruct(1,"SGG")
	Local oStruSMW	 := FWFormStruct(1,"SMW",{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|MW_CODIGO|MW_DESCRI|"})
	Local oStruSVG	 := FWFormStruct(1,"SVG")
	Local oEventPes  := PCPA135EVPES():New()

	soEveDef := Iif(soEveDef == Nil, PCPA135EVDEF():New(), soEveDef)

	//Altera os campos das estruturas
	AltStruMod(@oStrMaster, @oStrSelect, @oStrDetail, @oStrGrava, @oStruSMW)

	//Cria o modelo da tela
	oModel := MPFormModel():New('PCPA135')
	oModel:SetDescription(STR0006) //"Pré-Estrutura"
	oModel:InstallEvent("PCPA135EVDEF", /*cOwner*/, soEveDef)
	oModel:InstallEvent("PCPA135EVPES", /*cOwner*/, oEventPes)

	//FLD_MASTER - Modelo do Produto Principal (Cabeçalho)
	oModel:AddFields("FLD_MASTER", /*cOwner*/, oStrMaster)
	oModel:GetModel ("FLD_MASTER"):SetDescription(STR0006) //"Pré-Estrutura"
	oModel:GetModel ("FLD_MASTER"):SetOnlyQuery()

	//FLD_SELECT - Modelo do Componente Selecionado
	oModel:AddFields("FLD_SELECT", "FLD_MASTER", oStrSelect)
	oModel:GetModel("FLD_SELECT"):SetDescription(STR0007) //"Componente Selecionado"
	oModel:GetModel("FLD_SELECT"):SetOptional(.T.)
	oModel:GetModel("FLD_SELECT"):SetOnlyQuery()

	//GRID_DETAIL - Modelo da Grid com os componentes
	oModel:AddGrid ("GRID_DETAIL", "FLD_SELECT", oStrDetail)
	oModel:GetModel("GRID_DETAIL"):SetDescription(STR0008) //"Estrutura do Componente"
	oModel:GetModel("GRID_DETAIL"):SetOptional(.T.)
	oModel:GetModel("GRID_DETAIL"):SetOnlyQuery()
	oModel:GetModel("GRID_DETAIL"):SetUniqueLine({"GG_COMP","GG_TRT"})

	//GRAVA_SGG - Modelo com as alterações realizadas
	oModel:AddGrid ("GRAVA_SGG", "FLD_SELECT", oStrGrava)
	oModel:GetModel("GRAVA_SGG"):SetDescription(STR0009) //"Modelo para Gravação"
	oModel:GetModel("GRAVA_SGG"):SetOptional(.T.)
	oModel:GetModel("GRAVA_SGG"):SetOnlyQuery()

	//FLD_LISTA - Modelo Mestre da tela de importação de Lista de Componentes
	oModel:AddFields("FLD_LISTA", "FLD_SELECT", oStruSMW, , ,{|| LoadSMW()})
	oModel:GetModel ("FLD_LISTA"):SetDescription(STR0049) //"Lista de Componentes (SMW)"
	oModel:GetModel ("FLD_LISTA"):SetOptional(.T.)
	oModel:GetModel ("FLD_LISTA"):SetOnlyQuery()

	//GRID_LISTA - Modelo Mestre da tela de importação de Lista de Componentes
	oModel:AddGrid ("GRID_LISTA", "FLD_LISTA", oStruSVG)
	oModel:GetModel("GRID_LISTA"):SetDescription(STR0050) //"Lista de Componentes (SVG)"
	oModel:GetModel("GRID_LISTA"):SetOptional(.T.)
	oModel:GetModel("GRID_LISTA"):SetOnlyQuery()

	//Realiza carga do Modelo de Pesquisa
	P135PesMod(oModel)

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return oView, object, objeto de View da tabela SGG
/*/
Static Function ViewDef()

	Local oModel     := FWLoadModel("PCPA135")
	Local oView      := FWFormView():New()
	Local oStrMaster := FWFormStruct(2,"SGG",{|cCampo|   "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local oStrSelect := FWFormStruct(2,"SGG",{|cCampo|   "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})
	Local oStrDetail := FWFormStruct(2,"SGG",{|cCampo| ! "|" + AllTrim(cCampo) + "|" $ "|GG_COD|"})

	oView:SetModel(oModel)

	//Altera os campos das estruturas
	AltStrView(@oStrMaster, @oStrSelect, @oStrDetail)

	//V_TREE - Cria View da Tree
	oView:AddOtherObject("V_TREE", {|oPanel| MontaTree(oPanel)})

	//Seta os modelos na View
	oView:AddField("V_FLD_MASTER" , oStrMaster, "FLD_MASTER" )
	oView:AddField("V_FLD_SELECT" , oStrSelect, "FLD_SELECT" )
	oView:AddGrid ("V_GRID_DETAIL", oStrDetail, "GRID_DETAIL")

	//Cria os títulos para aparecerem na tela
	oView:EnableTitleView("V_FLD_MASTER", STR0030)	//"Produto"
	oView:EnableTitleView("V_TREE"      , STR0031)	//"Estrutura"
	oView:EnableTitleView("V_FLD_SELECT", STR0032)	//"Componentes"

	//Cria os BOXs para as Views
	oView:CreateHorizontalBox("CIMA" , 110, , .T.)
	oView:CreateHorizontalBox("BAIXO", 100)

	oView:CreateVerticalBox("BAIXO_ESQ", 20, "BAIXO")
	oView:CreateVerticalBox("BAIXO_DIR", 80, "BAIXO")

	oView:CreateHorizontalBox("BAIXO_DIR_SUP", 110, "BAIXO_DIR", .T.)
	oView:CreateHorizontalBox("BAIXO_DIR_INF", 100, "BAIXO_DIR")

	//Relaciona cada BOX com sua view
	oView:SetOwnerView("V_FLD_MASTER" , "CIMA")
	oView:SetOwnerView("V_TREE"       , "BAIXO_ESQ")
	oView:SetOwnerView("V_FLD_SELECT" , "BAIXO_DIR_SUP")
	oView:SetOwnerView("V_GRID_DETAIL", "BAIXO_DIR_INF")

	//Eventos de ativação da View.
	oView:SetViewCanActivate({|oView| BeforeView(oView)})
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

	//Adiciona botões no menu "Outras Ações"
	If !soEveDef:lOperacAprovacao .And. !soEveDef:lOperacCriaEstr
		oView:AddUserButton(STR0036, "", {|oView| ListaComp(oView) }, , ,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Lista de Componentes"
		oView:AddUserButton(STR0252, "", {|oView| AtalhoTecl("F5")}, , , , .T.) //"Pesquisa [F5]"
	EndIf

	//Habilita barra de progresso para abertura da tela.
	oView:SetProgressBar(.T.)

	//Desabilita a ordenação da grid.
	oView:SetViewProperty( "*", "GRIDNOORDER")
	oView:SetViewProperty( "V_FLD_MASTER", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 4 } )

Return oView

/*/{Protheus.doc} P135Legend
SubMenu de Legenda
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return Nil
/*/
Function P135Legend()

	Local aLegenda := {}
	Local aLegUsr  := {}
	Local nCnt     := 0

	//Montagem da legenda
	AADD(aLegenda, {"BR_AMARELO" , STR0025 })  //"Em criação"
	AADD(aLegenda, {"BR_VERDE"   , STR0026 })  //"Pré-Estrutura Aprovada"
	AADD(aLegenda, {"BR_VERMELHO", STR0027 })  //"Pré-Estrutura Rejeitada"
	AADD(aLegenda, {"BR_AZUL"    , STR0028 })  //"Estrutura criada"
	AADD(aLegenda, {"BR_LARANJA" , STR0029 })  //"Submetida a aprovação"

	//----------------------------------------------------
	// Ponto de Entrada para adicionar legendas na Dialog
	//----------------------------------------------------
	If ExistBlock("MT202LEG")
		aLegUsr := ExecBlock("MT202LEG",.F.,.F., { 2 })
		If ValType(aLegUsr) <> "A"
			aLegUsr := {}
		EndIf
		For nCnt := 1 To Len(aLegUsr)
			Aadd( aLegenda , { aLegUsr[nCnt,1],aLegUsr[nCnt,2] } )
		Next nCnt
	EndIf

	BrwLegenda(STR0033, STR0033, aLegenda)  //"Legenda"

Return

/*/{Protheus.doc} P135IniStc
Inicializa as variáveis do tipo Static deste fonte
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@return Nil
/*/
Function P135IniStc()

	snSeqTree  := 0
	saTreeLoad := NIL
	soModelAux := NIL
	slAltPai   := NIL
	slExecChL  := NIL
	slConfList := .F.
	slAtuaTree := .T.
	slChanging := .F.
	slValQtde  := .F.
	slCriaTemp := .T.

	If soDbTree != NIL
		soDbTree:Reset()
	EndIf

	If saCargos == NIL
		saCargos := {}
	Else
		aSize(saCargos,0)
	EndIf

Return Nil

/*/{Protheus.doc} AltStruMod
Edita os campos das estruturas do Model
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oStrMaster, object, estrutura do modelo FLD_MASTER
@param 02 oStrSelect, object, estrutura do modelo FLD_SELECT
@param 03 oStrDetail, object, estrutura do modelo GRID_DETAIL
@param 04 oStrGrava , object, estrutura do modelo GRAVA_SGG
@param 05 oStruSMW  , object, estrutura do modelo FLD_LISTA
@return NIL
/*/
Static Function AltStruMod(oStrMaster, oStrSelect, oStrDetail, oStrGrava, oStruSMW)

	//Adiciona o CARGO para controle da TREE
	AddCargo(@oStrMaster, "CARGO")
	AddCargo(@oStrSelect, "CARGO")
	AddCargo(@oStrDetail, "CARGO")
	AddCargo(@oStrGrava , "CARGO")

	//Adiciona novos campos
	oStrMaster:AddField(RetTitle("B1_DESC")                ,; // [01]  C   Titulo do campo  - Produto
                        RetTitle("B1_DESC")                ,; // [02]  C   ToolTip do campo - Código do Produto
                        "CDESCPAI"                         ,; // [03]  C   Id do Field
                        "C"                                ,; // [04]  C   Tipo do campo
                        GetSx3Cache("B1_DESC","X3_TAMANHO"),; // [05]  N   Tamanho do campo
                        0                                  ,; // [06]  N   Decimal do campo
                        NIL,NIL,NIL                        ,;
                        .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
                        {|| InicDesc()}                    ,; // [11]  B   Code-block de inicializacao do campo
                        NIL                                ,;
                        .F.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                        .T.)                                  // [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(RetTitle("B1_UM")                  ,; // [01]  C   Titulo do campo  - Produto
                        RetTitle("B1_UM")                  ,; // [02]  C   ToolTip do campo - Código do Produto
                        "CUMPAI"                           ,; // [03]  C   Id do Field
                        "C"                                ,; // [04]  C   Tipo do campo
                        GetSx3Cache("B1_UM","X3_TAMANHO")  ,; // [05]  N   Tamanho do campo
                        0                                  ,; // [06]  N   Decimal do campo
                        NIL,NIL,NIL                        ,;
                        .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
                        {|| InicUniMed()}                  ,; // [11]  B   Code-block de inicializacao do campo
                        NIL                                ,;
                        .F.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                        .T.)                                  // [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(STR0095								,;	// [01]  C   Titulo do campo  //"Quantidade Base"
	                    STR0095     						,;	// [02]  C   ToolTip do campo //"Quantidade Base"
	                    "NQTBASE"							,;	// [03]  C   Id do Field
	                    "N"									,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_QBP","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                    GetSx3Cache("B1_QBP","X3_DECIMAL")	,;	// [06]  N   Decimal do campo
	                    {||VldBase()}						,;	// [07]  B   Code-block de validação do campo
	                    NIL									,;	// [08]  B   Code-block de validação When do campo
	                    NIL									,;	// [09]  A   Lista de valores permitido do campo
	                    .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||IniBase()}						,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.									)	// [14]  L   Indica se o campo é virtual

	oStrSelect:AddField(RetTitle("B1_DESC")                ,; // [01]  C   Titulo do campo  - Produto
                        RetTitle("B1_DESC")                ,; // [02]  C   ToolTip do campo - Código do Produto
                        "CDESCCMP"                         ,; // [03]  C   Id do Field
                        "C"                                ,; // [04]  C   Tipo do campo
                        GetSx3Cache("B1_DESC","X3_TAMANHO"),; // [05]  N   Tamanho do campo
                        0                                  ,; // [06]  N   Decimal do campo
                        NIL,NIL,NIL                        ,;
                        .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
                        {|| InicDesc()}                    ,; // [11]  B   Code-block de inicializacao do campo
                        NIL                                ,;
                        .F.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                        .T.)                                  // [14]  L   Indica se o campo é virtual

	oStrSelect:AddField(RetTitle("B1_UM")                  ,; // [01]  C   Titulo do campo  - Produto
                        RetTitle("B1_UM")                  ,; // [02]  C   ToolTip do campo - Código do Produto
                        "CUMCMP"                           ,; // [03]  C   Id do Field
                        "C"                                ,; // [04]  C   Tipo do campo
                        GetSx3Cache("B1_UM","X3_TAMANHO")  ,; // [05]  N   Tamanho do campo
                        0                                  ,; // [06]  N   Decimal do campo
                        NIL,NIL,NIL                        ,;
                        .F.                                ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
                        {|| InicUniMed()}                  ,; // [11]  B   Code-block de inicializacao do campo
                        NIL                                ,;
                        .F.                                ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
                        .T.)                                  // [14]  L   Indica se o campo é virtual

	//Campo para guardar o RECNO quando é realizado o LOAD da grid
	oStrDetail:AddField(STR0051     ,; // [01]  C   Titulo do campo  - "Registro"
	                    STR0051     ,; // [02]  C   ToolTip do campo - "Registro"
	                    "NREG"      ,; // [03]  C   Id do Field
	                    "N"         ,; // [04]  C   Tipo do campo
	                    10          ,; // [05]  N   Tamanho do campo
	                    0           ,; // [06]  N   Decimal do campo
	                    NIL,NIL,NIL ,;
	                    .F.         ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL,NIL     ,;
	                    .T.         ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.)           // [14]  L   Indica se o campo é virtual

	//Campo para guardar a sequência original do componente (GG_TRT). Utilizado em validações
	oStrDetail:AddField(STR0053                           ,; // [01]  C   Titulo do campo  - "Seq. Original"
	                    STR0053                           ,; // [02]  C   ToolTip do campo - "Seq. original"
	                    "CSEQORIG"                        ,; // [03]  C   Id do Field
	                    "C"                               ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("GG_TRT","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                    0                                 ,; // [06]  N   Decimal do campo
	                    NIL,NIL,NIL                       ,;
	                    .F.                               ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL,NIL                           ,;
	                    .T.                               ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
	                    .T.)                                 // [14]  L   Indica se o campo é virtual

	oStrDetail:AddField(RetTitle("GG_STATUS")                ,; // [01]  C   Titulo do campo
	                    RetTitle("GG_STATUS")                ,; // [02]  C   ToolTip do campo
	                    "CSTATUS"                            ,; // [03]  C   Id do Field
	                    "C"                                  ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("GG_STATUS","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                    0                                    ,; // [06]  N   Decimal do campo
	                    NIL,NIL,NIL                          ,;
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {|| "1"}                             ,; // [11]  B   Code-block de inicializacao do campo
	                    NIL                                  ,;
	                    .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
	                    .T.)                                    // [14]  L   Indica se o campo é virtual

	oStrGrava:AddField(STR0051     ,; // [01]  C   Titulo do campo  - "Registro"
	                   STR0051     ,; // [02]  C   ToolTip do campo - "Registro"
	                   "NREG"      ,; // [03]  C   Id do Field
	                   "N"         ,; // [04]  C   Tipo do campo
	                   10          ,; // [05]  N   Tamanho do campo
	                   0           ,; // [06]  N   Decimal do campo
	                   NIL,NIL,NIL ,;
	                   .F.         ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                   NIL,NIL,NIL ,;
	                   .T.)           // [14]  L   Indica se o campo é virtual

	oStrGrava:AddField(STR0053                           ,; // [01]  C   Titulo do campo  - "Seq. original"
	                   STR0053                           ,; // [02]  C   ToolTip do campo - "Seq. original"
	                   "CSEQORIG"                        ,; // [03]  C   Id do Field
	                   "C"                               ,; // [04]  C   Tipo do campo
	                   GetSx3Cache("GG_TRT","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                   0                                 ,; // [06]  N   Decimal do campo
	                   NIL,NIL,NIL                       ,;
	                   .F.                               ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                   NIL,NIL                           ,;
	                   .T.                               ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
	                   .T.)                                 // [14]  L   Indica se o campo é virtual

	oStrGrava:AddField(STR0014                           ,; // [01]  C   Titulo do campo  - "LINHA"
	                   STR0014                           ,; // [02]  C   ToolTip do campo - "LINHA"
	                   "LINHA"                           ,; // [03]  C   Id do Field
	                   "N"                               ,; // [04]  C   Tipo do campo
	                   5                                 ,; // [05]  N   Tamanho do campo
	                   0                                 ,; // [06]  N   Decimal do campo
	                   NIL,NIL,NIL                       ,;
	                   .F.                               ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                   NIL,NIL                           ,;
	                   .T.                               ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
	                   .T.)                                 // [14]  L   Indica se o campo é virtual

	oStrGrava:AddField(STR0015                           ,;	// [01]  C   Titulo do campo  - "DELETE"
	                   STR0015                           ,;	// [02]  C   ToolTip do campo - "DELETE"
	                   "DELETE"                          ,;	// [03]  C   Id do Field
	                   "L"                               ,;	// [04]  C   Tipo do campo
	                   1                                 ,;	// [05]  N   Tamanho do campo
	                   0                                 ,;	// [06]  N   Decimal do campo
	                   NIL,NIL,NIL                       ,;
	                   .F.                               ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                   NIL,NIL                           ,;
	                   .T.                               ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
	                   .T.)                                 // [14]  L   Indica se o campo é virtual

	oStrGrava:AddField(RetTitle("GG_STATUS")                ,; // [01]  C   Titulo do campo
	                   RetTitle("GG_STATUS")                ,; // [02]  C   ToolTip do campo
	                   "CSTATUS"                            ,; // [03]  C   Id do Field
	                   "C"                                  ,; // [04]  C   Tipo do campo
	                   GetSx3Cache("GG_STATUS","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                   0                                    ,; // [06]  N   Decimal do campo
	                   NIL,NIL,NIL                          ,;
	                   .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                   NIL,NIL                              ,;
	                   .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update
	                   .T.)                                    // [14]  L   Indica se o campo é virtual

	//Campo para controlar a execução automática.
	oStrMaster:AddField(STR0132	    				 	 ,;	// [01]  C   Titulo do campo  //"Descrição"
	                    STR0132 						 ,;	// [02]  C   ToolTip do campo //"Descrição"
	                    "CEXECAUTO"						 ,;	// [03]  C   Id do Field
	                    "C"								 ,;	// [04]  C   Tipo do campo
	                    1								 ,;	// [05]  N   Tamanho do campo
	                    0								 ,;	// [06]  N   Decimal do campo
	                    {||.T.}							 ,;	// [07]  B   Code-block de validação do campo
	                    NIL								 ,;	// [08]  B   Code-block de validação When do campo
	                    NIL								 ,;	// [09]  A   Lista de valores permitido do campo
	                    .F.								 ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    {||"N"}							 ,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL								 ,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL								 ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.)								// [14]  L   Indica se o campo é virtual

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

	//Altera propriedades dos campos do modelo FLD_MASTER
	oStrMaster:SetProperty("GG_COD"    , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValPai()"))
	oStrMaster:SetProperty("GG_COD"    , MODEL_FIELD_WHEN   , FWBuildFeature(STRUCT_FEATURE_WHEN , "P135EdtPai()"))

	//Altera propriedades dos campos do modelo GRID_DETAIL
	oStrDetail:SetProperty("GG_COD"    , MODEL_FIELD_OBRIGAT, .F.)
	oStrDetail:SetProperty("GG_DESC"   , MODEL_FIELD_INIT   , FWBuildFeature(STRUCT_FEATURE_INIPAD, " "))
	oStrDetail:SetProperty("GG_COMP"   , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SB1') .And. P135ValCpo('GG_COMP')"))
	oStrDetail:SetProperty("GG_TRT"    , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValCpo('GG_TRT')"))
	oStrDetail:SetProperty("GG_QUANT"  , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "NaoVazio() .And. P135ValCpo('GG_QUANT')"))
	oStrDetail:SetProperty("GG_INI"    , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "NaoVazio() .And. P135ValCpo('GG_INI')"))
	oStrDetail:SetProperty("GG_FIM"    , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "NaoVazio() .And. P135ValCpo('GG_FIM')"))
	oStrDetail:SetProperty("GG_GROPC"  , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValCpo('GG_GROPC')"))
	oStrDetail:SetProperty("GG_OPC"    , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValCpo('GG_OPC')"))
	oStrDetail:SetProperty("GG_POTENCI", MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValCpo('GG_POTENCI')"))
	oStrDetail:SetProperty("GG_TIPVEC" , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValCpo('GG_TIPVEC')"))
	oStrDetail:SetProperty("GG_VECTOR" , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135ValCpo('GG_VECTOR')"))

	//Altera propriedades dos campos do modelo GRAVA_SGG
	oStrGrava:SetProperty ("GG_COMP"   , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, " "))
	oStrGrava:SetProperty ("GG_QUANT"  , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, " "))

	//Altera propriedades dos campos do modelo GRAVA_SGG
	oStruSMW:SetProperty  ("MW_CODIGO" , MODEL_FIELD_VALID  , FWBuildFeature(STRUCT_FEATURE_VALID, "P135VldLis()"))
	oStruSMW:SetProperty  ("MW_CODIGO" , MODEL_FIELD_OBRIGAT, .F.)
	oStruSMW:SetProperty  ("MW_DESCRI" , MODEL_FIELD_OBRIGAT, .F.)

	//Adiciona gatilhos no modelo
	oStrMaster:AddTrigger("GG_COD", "GG_COD", { || VldGGCod() }, { || AfterGGCod() })

Return

/*/{Protheus.doc} AltStrView
Edita os campos das estruturas da View
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oStrMaster, object, estrutura do modelo FLD_MASTER
@param 02 oStrSelect, object, estrutura do modelo FLD_SELECT
@param 03 oStrDetail, object, estrutura do modelo GRID_DETAIL
@return NIL
/*/
Static Function AltStrView(oStrMaster, oStrSelect, oStrDetail)

	Local cOrdem := ""

	//Adiciona novos campos
	cOrdem := oStrMaster:GetProperty("GG_COD",MVC_VIEW_ORDEM)
	cOrdem := Soma1(cOrdem)
	oStrMaster:AddField("CDESCPAI"                 ,; // [01]  C   Nome do Campo
	                    cOrdem                     ,; // [02]  C   Ordem
	                    RetTitle("B1_DESC")        ,; // [03]  C   Titulo do campo
	                    RetTitle("B1_DESC")        ,; // [04]  C   Descricao do campo
	                    NIL                        ,; // [05]  A   Array com Help
	                    "C"                        ,; // [06]  C   Tipo do campo
	                    "@S20"                     ,; // [07]  C   Picture
	                    NIL,NIL                    ,;
	                    .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                    NIL,NIL,NIL,NIL,NIL        ,;
	                    .T.                        ,; // [16]  L   Indica se o campo é virtual
	                    NIL,NIL)

	cOrdem := Soma1(cOrdem)
	oStrMaster:AddField("CUMPAI"                   ,; // [01]  C   Nome do Campo
	                    cOrdem                     ,; // [02]  C   Ordem
	                    RetTitle("B1_UM")          ,; // [03]  C   Titulo do campo
	                    RetTitle("B1_UM")          ,; // [04]  C   Descricao do campo
	                    NIL                        ,; // [05]  A   Array com Help
	                    "C"                        ,; // [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_UM',3)  ,; // [07]  C   Picture
	                    NIL,NIL                    ,;
	                    .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                    NIL,NIL,NIL,NIL,NIL        ,;
	                    .T.                        ,; // [16]  L   Indica se o campo é virtual
	                    NIL,NIL)

	cOrdem := Soma1(cOrdem)
	oStrMaster:AddField("NQTBASE"										,;	// [01]  C   Nome do Campo
	                    cOrdem											,;	// [02]  C   Ordem
	                    STR0095         								,;	// [03]  C   Titulo do campo    //"Quantidade base"
	                    STR0095											,;	// [04]  C   Descricao do campo //"Quantidade base"
	                    NIL												,;	// [05]  A   Array com Help
	                    "N"												,;	// [06]  C   Tipo do campo
	                    AllTrim(GetSX3Cache("B1_QBP", "X3_PICTURE"))    ,;	// [07]  C   Picture
	                    NIL												,;	// [08]  B   Bloco de Picture Var
	                    NIL												,;	// [09]  C   Consulta F3
	                    .T.												,;	// [10]  L   Indica se o campo é alteravel
	                    NIL,NIL,NIL,NIL,NIL								,;
	                    .T.												,;	// [16]  L   Indica se o campo é virtual
	                    NIL,NIL)

	cOrdem := oStrSelect:GetProperty("GG_COD",MVC_VIEW_ORDEM)
	cOrdem := Soma1(cOrdem)
	oStrSelect:AddField("CDESCCMP"                 ,; // [01]  C   Nome do Campo
	                    cOrdem                     ,; // [02]  C   Ordem
	                    RetTitle("B1_DESC")        ,; // [03]  C   Titulo do campo
	                    RetTitle("B1_DESC")        ,; // [04]  C   Descricao do campo
	                    NIL                        ,; // [05]  A   Array com Help
	                    "C"                        ,; // [06]  C   Tipo do campo
	                    "@S20"                     ,; // [07]  C   Picture
	                    NIL,NIL                    ,;
	                    .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                    NIL,NIL,NIL,NIL,NIL        ,;
	                    .T.                        ,; // [16]  L   Indica se o campo é virtual
	                    NIL,NIL)

	cOrdem := Soma1(cOrdem)
	oStrSelect:AddField("CUMCMP"                   ,; // [01]  C   Nome do Campo
	                    cOrdem                     ,; // [02]  C   Ordem
	                    RetTitle("B1_UM")          ,; // [03]  C   Titulo do campo
	                    RetTitle("B1_UM")          ,; // [04]  C   Descricao do campo
	                    NIL                        ,; // [05]  A   Array com Help
	                    "C"                        ,; // [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_UM',3)  ,; // [07]  C   Picture
	                    NIL,NIL                    ,;
	                    .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                    NIL,NIL,NIL,NIL,NIL        ,;
	                    .T.                        ,; // [16]  L   Indica se o campo é virtual
	                    NIL,NIL)

	//Altera propriedades dos campos
	oStrSelect:SetProperty("GG_COD", MVC_VIEW_CANCHANGE, .F.)

	//Remove campos
	If oStrDetail:HasField("GG_FILIAL")
		oStrDetail:RemoveField("GG_FILIAL")
	EndIf
	If oStrDetail:HasField("GG_COD")
		oStrDetail:RemoveField("GG_COD")
	EndIf
	If oStrDetail:HasField("GG_NIV")
		oStrDetail:RemoveField("GG_NIV")
	EndIf
	If oStrDetail:HasField("GG_NIVINV")
		oStrDetail:RemoveField("GG_NIVINV")
	EndIf
	If oStrDetail:HasField("GG_OK")
		oStrDetail:RemoveField("GG_OK")
	EndIf
	If oStrDetail:HasField("GG_USUARIO")
		oStrDetail:RemoveField("GG_USUARIO")
	EndIf

	/**Força a largura dos campos quando está fora do padrão*/
	If GetSx3Cache("GG_COD", "X3_TAMANHO") > 15
		oStrMaster:SetProperty("GG_COD", MVC_VIEW_PICT, "@!S10")
		oStrSelect:SetProperty("GG_COD", MVC_VIEW_PICT, "@!S10")
	EndIf
	If GetSx3Cache("B1_DESC", "X3_TAMANHO") > 30
		oStrMaster:SetProperty("CDESCPAI", MVC_VIEW_PICT, "@S15")
		oStrSelect:SetProperty("CDESCCMP", MVC_VIEW_PICT, "@S13")
	EndIf
	If GetSx3Cache("GG_COMP", "X3_TAMANHO") > 15
		oStrDetail:SetProperty("GG_COMP", MVC_VIEW_WIDTH, 200)
	EndIf
	If GetSx3Cache("GG_DESC", "X3_TAMANHO") > 30
		oStrDetail:SetProperty("GG_DESC", MVC_VIEW_WIDTH, 250)
	EndIf

Return Nil

/*/{Protheus.doc} VldGGCod
Valida a execução do gatilho do Pai (usado para validar lock de registro)
@author Marcelo Neumann
@since 24/04/2019
@version 1.0
@return logic, indica se deve executar o gatilho ou não
/*/
Static Function VldGGCod()

	Local oView    := FwViewActive()
	Local oModel   := FwModelActive()
	Local oEvent   := gtMdlEvent(oModel,"PCPA135EVDEF")
	Local cProduto := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local lComTela := oView != Nil .And. oView:IsActive() .And. !(oModel:GetModel("FLD_MASTER"):GetValue("CEXECAUTO") == "S")

	If !oEvent:Lock(cProduto, , .T., .F., oModel, .F.)
		If lComTela
			oModel:GetModel("FLD_MASTER"):LoadValue("GG_COD"," ")
			oView:GetViewObj("FLD_MASTER")[3]:getFWEditCtrl("GG_COD"):oCtrl:SetFocus()
		EndIf
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} AfterGGCod
Trigger executado no campo GG_COD
@author Marcelo Neumann
@since 26/11/2018
@version 1.0
@return Nil
/*/
Static Function AfterGGCod()

	Local oView    := FwViewActive()
	Local oModel   := FwModelActive()
	Local oMdlPai  := oModel:GetModel("FLD_MASTER")
	Local cProduto := oMdlPai:GetValue("GG_COD")
	Local cCargo   := ""
	Local lExiste  := .F.

	//Se for operação de inclusão, carrega a tree com o código do produto
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		If soDbTree != NIL
			//Se o produto tiver Pré-estrutura, altera para Modificação
			SGG->(dbSetOrder(1))
			If SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
				oModel:DeActivate()
				//Posiciona no produto após a desativação do modelo
				SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				If oView != Nil .And. oView:IsActive()
					oView:setOperation(OP_ALTERAR)
					oView:oControlBar:cTitle := STR0006 + " - " + STR0013 //"Pré-estrutura" + " - " + "ALTERAR"
				EndIf
				oModel:Activate()
				lExiste := .T.
			EndIf
		EndIf

		cCargo := P135AddPai(cProduto)

		If soDbTree != Nil
			soDbTree:TreeSeek(cCargo)
		EndIf

		P135TreeCh(lExiste,cCargo)
		slAltPai := .F.
	EndIf

	oMdlPai:LoadValue("CUMPAI"  , InicUniMed(cProduto))
	oMdlPai:LoadValue("CDESCPAI", InicDesc(cProduto))
	oMdlPai:LoadValue("NQTBASE" ,IniBase(cProduto))

Return Nil

/*/{Protheus.doc} AddCargo
Adiciona o campo CARGO na estrutura do modelo
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oStru, object    , estrutura a ser adicionada o campo CARGO
@param 02 cID  , characters, identificador para o campo cargo
@return NIL
/*/
Static Function AddCargo(oStru, cID)

	oStru:AddField(STR0052      ,; // [01]  C   Titulo do campo  - "CARGO"
	               STR0052      ,; // [02]  C   ToolTip do campo - "CARGO"
	               cID          ,; // [03]  C   Id do Field
	               "C"          ,; // [04]  C   Tipo do campo
	               GetTmCargo() ,; // [05]  N   Tamanho do campo
	               0            ,; // [06]  N   Decimal do campo
	               NIL          ,; // [07]  B   Code-block de validação do campo
	               NIL          ,; // [08]  B   Code-block de validação When do campo
	               NIL          ,; // [09]  A   Lista de valores permitido do campo
	               .F.          ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	               NIL          ,; // [11]  B   Code-block de inicializacao do campo
	               NIL          ,; // [12]  L   Indica se trata-se de um campo chave
	               .T.          ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	               .T.          )  // [14]  L   Indica se o campo é virtual

	oStru:SetProperty(cID, MODEL_FIELD_NOUPD, .F.)

Return

/*/{Protheus.doc} InicDesc
Inicialização do campo DESC
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cProduto, characters, código do produto para fazer a busca na SB1 (Opcional)
@return cDesc, characters, descrição do produto
/*/
Static Function InicDesc(cProduto)

	Local aAreaSB1 := SB1->(GetArea())
	Local cDesc    := ""
	Default cProduto := SGG->GG_COD

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1") + cProduto))
		cDesc := SB1->B1_DESC
	Else
		cDesc := CriaVar("B1_DESC")
	EndIf

	SB1->(RestArea(aAreaSB1))

Return cDesc

/*/{Protheus.doc} InicUniMed
Inicialização do campo Unidade de Medida
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cProduto, characters, código do produto para fazer a busca na SB1 (Opcional)
@return cUM, characters, unidade de medida do produto
/*/
Static Function InicUniMed(cProduto)

	Local aAreaSB1 := SB1->(GetArea())
	Local cUM      := ""
	Default cProduto := SGG->GG_COD

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1") + cProduto))
		cUM := SB1->B1_UM
	Else
		cUM := CriaVar('B1_UM')
	EndIf

	SB1->(RestArea(aAreaSB1))

Return cUM

/*/{Protheus.doc} MontaTree
Função responsável por fazer a criação do objeto da TREE
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oPanel, object, painel onde deve ser criada a tree
@return Nil
/*/
Static Function MontaTree(oPanel)

	//Inicializa as variáveis do tipo Static deste fonte
	P135IniStc()

	//Cria ou Reseta a Tree
	If soDbTree == Nil
		soDbTree := DbTree():New(0, 0, 100, 100, oPanel, {|| P135TreeCh(.T.)}, /*bRClick*/, .T.)
		soDbTree:Align := CONTROL_ALIGN_ALLCLIENT

		//Cria opções de menu com botão direito
		MenuPopUp()
	Else
		soDbTree:Reset()
	EndIf

Return Nil

/*/{Protheus.doc} MenuPopUp
Criação do menu de contexto da tree (Popup - botão direito) e atribuição de ações
@author Marcelo Neumann
@since 04/11/2018
@version 1.0
@return Nil
/*/
Static Function MenuPopUp()

	MENU soMenPopUp POPUP OF OMainWND

	MENUITEM STR0082 ACTION Expandir(soDbTree:GetCargo()) //"Expandir"
	MENUITEM STR0083 ACTION Recolher(soDbTree:GetCargo()) //"Recolher"

	ENDMENU

	//Ao clicar com o botao direito será exibido o menu popup
	soDbTree:bRClicked := {|o,x,y| soDbTree:Refresh(), (MostraMenu(soMenPopUp, x, y)) } //Posicao x,y em relacao a Dialog
	soDbTree:cToolTip  := STR0081 //"Utilize o botão direito do mouse para expandir ou recolher todos os sub-níveis."

Return

/*/{Protheus.doc} MostraMenu
Exibe menu contexto da Tree (botão direito)
@author Marcelo Neumann
@since 04/11/2018
@version 1.0
@param 01 oMenu , object , objeto oMenu
@param 02 nCoorX, numeric, coordenada X
@param 03 nCoorY, numeric, coordenada Y - com BUG
@param 04 oArea , object , objeto oDbTree passado por referência
@return Nil
/*/
Static Function MostraMenu(oMenu, nCoorX, nCoorY)

	oMenu:Activate(nCoorX, nCoorY)

Return Nil

/*/{Protheus.doc} BeforeView
Função executada antes ativar a view. Utilizado para atualizar a Revisão
@author Marcelo Neumann
@since 09/11/2018
@version 1.0
@param 01 oView, object, objeto da View
@return lRet, logical, identifica se a View será aberta
/*/
Static Function BeforeView(oView)

	Local lRet := .T.

	P135IniStc()

Return lRet

/*/{Protheus.doc} AfterView
Função executada após ativar a view.
@author Marcelo Neumann
@since 09/11/2018
@version 1.0
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function AfterView(oView)

	Local oModel  := oView:GetModel()
	Local oMdlDet := oModel:GetModel("GRID_DETAIL")
	Local cCargo  := ""
	Local nInd    := 0

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .and. !soEveDef:lCopia
		//Se for inclusão, apenas inicializa a variável Static com o valor em branco
		oModel:GetModel("FLD_MASTER"):ClearField("CDESCPAI")
		oModel:GetModel("FLD_MASTER"):ClearField("CUMPAI")
		oModel:GetModel("FLD_MASTER"):ClearField("NQTBASE")
		oModel:GetModel("FLD_SELECT"):ClearField("GG_COD")
		oModel:GetModel("FLD_SELECT"):ClearField("CDESCCMP")
		oModel:GetModel("FLD_SELECT"):ClearField("CUMCMP")

		//Carrega as informações da grid de componentes
		oMdlDet:ClearData(.T.,.T.)

		oView:Refresh()
	Else
		If soEveDef:lCopia
			oModel:GetModel("FLD_MASTER"):SetValue("GG_COD", soEveDef:mvcProdutoDestino)
		EndIf

		//Chama a função para criar a TREE
		cCargo := P135AddPai(oModel:GetModel("FLD_MASTER"):GetValue("GG_COD"))

		//Carrega as informações do componente selecionado
		CargaSelec(oModel:GetModel("FLD_MASTER"):GetValue("GG_COD"),oModel,cCargo)

		//Carrega as informações da grid de componentes
		oMdlDet:ClearData(.F.,.F.)
		oMdlDet:DeActivate()
		oMdlDet:lForceLoad := .T.
		If soEveDef:lCopia
			DbSelectArea("SGG")
			SGG->(DbSetOrder(1))
			//Atribui bloco de carga para carga dos dados de cópia
			oMdlDet:bLoad := {|| LoadGridC(cCargo, oModel)}
			oMdlDet:Activate()

			//Seta todas as linhas como modificadas para que os dados sejam gravados no modelo de gravação
			For nInd := 1 to oMdlDet:Length(.F.)
				oMdlDet:SetLineModify(nInd)
			Next nInd

			//Carrega a TREE com base nos componentes que foram carregados no grid
			AddCmpTree(cCargo,oModel)

			P135GravAl(oModel)
			RecupAlter(cCargo)

			If soEveDef:mvclCopiaTodosNiveis
				//Expande com base produto Origem
				slExpCopia := .T.
				Expandir(cCargo)
				slExpCopia := .F.
			EndIf

			//Atribui bloco de carga padrão
			oMdlDet:bLoad := {|| LoadGrid(cCargo, oModel)}

			//Seta o modelo para alterado
			oModel:lModify := .T.
			slAltPai := .F.

		Else
			oMdlDet:bLoad := {|| LoadGrid(cCargo, oModel)}
			oMdlDet:Activate()

			If oModel:GetOperation() == MODEL_OPERATION_VIEW .And. !oModel:GetModel("GRAVA_SGG"):IsEmpty()
				//Tratativa para visualizar as informações na tela de Divergências do PCPA120.
				RecupAlter(cCargo)
			EndIf

			//Carrega a TREE com base nos componentes que foram carregados no grid
			AddCmpTree(cCargo,oModel)

			//Seta o modelo para não alterado
			oModel:lModify := .F.
		EndIf

		//Atualiza a view.
		oView:Refresh()

	EndIf

	// Função para ser chamada a cada troca de linha
	oView:GetViewObj("GRID_DETAIL")[3]:bChangeLine := {|| ChgLinGrid(oView) }

	//Adiciona teclas de atalho
	HabAtalhos(.T.)

Return Nil

/*/{Protheus.doc} P135TreeCh (Antiga TreeChange)
Execuções de ações durante clique/change na Tree
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 lRefresh, logical, indica se executa o refresh da tela.
@return NIL
/*/
Function P135TreeCh(lRefresh, cCargo, lRunAuto, lForce)
	Local oModel    := FwModelActive()
	Local oView     := FwViewActive()
	Local oMdlSelec := oModel:GetModel("FLD_SELECT")
	Local oMdlDet   := oModel:GetModel("GRID_DETAIL")
	Local lModify   := oModel:lModify
	Local nInd
	Local oEvent    := gtMdlEvent(oModel,"PCPA135EVDEF")
	Local cCodProd

	Default lRefresh := .T.
	Default cCargo   := " "
	Default lRunAuto  := isRunAuto(oModel)
	Default lForce   := .F.

	//Variável de controle para executar o evento de mudança de nó da tree
	If slExecChL == NIL
		slExecChL := .T.
	EndIf

	If !slExecChL
		Return
	EndIf

	//Se não for rotina automática, busca cargo
	If !lRunAuto
		cCargo := soDbTree:GetCargo()
	EndIf

	//Se o nó da tree for o mesmo que está carregado no modelo de componente selecionado, não executa o evento
	If oMdlSelec:GetValue("CARGO") == cCargo .AND. !lForce
		Return
	EndIf

	If oModel:GetOperation() != MODEL_OPERATION_VIEW
		//Verifica se a linha posicionada está válida
		If !oModel:GetModel("GRID_DETAIL"):VldLineData()
			If oView != Nil .And. oView:IsActive()
				oView:ShowLastError()
			EndIf

			//Reposiciona a TREE no item anterior para não permite mudar o item selecionado na tree
			slExecChL := .F.

			If !lRunAuto
				soDbTree:TreeSeek(oMdlSelec:GetValue("CARGO"))
			EndIf

			slExecChL := .T.

			Return
		Else
			//Grava as alterações efetuadas na Grid no modelo "GRAVA_SGG"
			P135GravAl(oModel)
		EndIf
	EndIf

	//Altera cursor do mouse indicando processamento
	CursorWait()

	//Carrega as informações do componente selecionado
	cCodProd  := P135RetInf(cCargo, "COMP")
	CargaSelec(cCodProd, oModel, cCargo)

	oMdlDet:ClearData(.F.,.F.)
	oMdlDet:DeActivate()
	oMdlDet:lForceLoad := .T.

	If slExpCopia .AND. soEveDef:lCopia .AND. !soEveDef:mvlOrigemPreEstrutura
		oMdlDet:bLoad := {|| LoadGridC(cCargo,oModel)}
		oMdlDet:Activate()

		If soEveDef:mvclExcluiPreExistente
			For nInd := 1 to oMdlDet:Length(.F.)
				If oMdlDet:GetValue("NREG", nInd) > 0
					oMdlDet:GoLine(nInd)
					oMdlDet:DeleteLine()
				EndIf
			Next nInd
			oMdlDet:GoLine(1)
		EndIf

		//Seta todas as linhas como modificadas para que os dados sejam gravados no modelo de gravação
		For nInd := 1 to oMdlDet:Length(.F.)
			oMdlDet:SetLineModify(nInd)
		Next nInd
	Else
		oMdlDet:bLoad := {|| LoadGrid(cCargo,oModel)}
		oMdlDet:Activate()
	EndIf

	//Recupera as alterações que estão gravadas no modelo "GRAVA_SGG"
	RecupAlter(cCargo)

	//Adiciona componentes na tree de acordo com o que foi carregado no modelo de componentes
	AddCmpTree(cCargo, oModel)

	//Realiza lock da estrutura
	If !oEvent:lExpandindo .AND.;
		 oModel:GetOperation() != MODEL_OPERATION_VIEW .AND.;
		 (oModel:GetOperation() != MODEL_OPERATION_DELETE .OR.;
		 cCargo == saCargos[1][IND_ACARGO_CARGO_COMP])
		oEvent:Lock(cCodProd, oView, .F.)
	EndIf

	//Retorna cursor do mouse
	CursorArrow()

	If lRefresh .And. !lRunAuto
		If oView != Nil .And. oView:IsActive()
			oView:Refresh("V_GRID_DETAIL")
			oView:Refresh("V_FLD_SELECT")
		EndIf

		soDbTree:SetFocus()
	EndIf

	//Seta o modelo com o status de modificado que estava antes de atualizar os dados da grid
	oModel:lModify := lModify

Return

/*/{Protheus.doc} LoadGrid
Retorna array com os dados a serem inseridos na Grid
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargo, characters, cCargo referente ao item selecionado
@param 02 oModel, object    , modelo principal
@return aLoad, array, array de carga da grid
/*/
Static Function LoadGrid(cCargo, oModel)

	Local aAreaSGG   := SGG->(GetArea())
	Local aLoad      := {}
	Local aDefDados  := {}
	Local aFields    := oModel:GetModel("GRID_DETAIL"):oFormModelStruct:aFields
	Local cProdSelec := P135RetInf(cCargo, "COMP")
	Local nIndCps    := 0
	Local nPos       := 0

	For nIndCps := 1 to Len(aFields)
		aAdd(aDefDados,Nil)
	Next nIndCps

	If Empty(oModel:GetModel("FLD_SELECT"):GetValue("GG_COD"))
		aAdd(aLoad, {0, aClone(aDefDados)})
	Else
		SGG->(dbSetOrder(1))
		If SGG->(dbSeek(xFilial('SGG') + cProdSelec, .F.))
			While !SGG->(Eof()) .And. ;
			       SGG->GG_FILIAL == xFilial("SGG") .And. ;
			       SGG->GG_COD    == cProdSelec

				//Se estiver parametrizado para não exibir os itens vencidos
				If soEveDef:nExibeInvalidos == 2 .And. !CompValido(SGG->GG_INI, SGG->GG_FIM)
					SGG->(dbSkip())
					Loop
				EndIf

				For nIndCps := 1 to Len(aFields)
					//Se for o campo CARGO, verifica se já está na Tree
					If AllTrim(aFields[nIndCps][3]) == "CARGO"
						nPos := aScan(saCargos, {|cCampos| cCampos[IND_ACARGO_PAI]       == cProdSelec   .And. ;
						                                   cCampos[IND_ACARGO_COMP]      == SGG->GG_COMP .And. ;
						                                   cCampos[IND_ACARGO_TRT]       == SGG->GG_TRT  .And. ;
						                                   cCampos[IND_ACARGO_CARGO_PAI] == cCargo})
						//Se está na tree, assume o cargo
						If nPos > 0
							aDefDados[nIndCps] := saCargos[nPos][IND_ACARGO_CARGO_COMP] //CARGO
						Else
							//Se não está na tree, gera um novo CARGO
							aDefDados[nIndCps] := MontaCargo(IND_ESTR,       ;
							                                 SGG->(GG_COD),  ;
							                                 SGG->(GG_COMP), ;
							                                 SGG->(Recno()))
						EndIf

					ElseIf AllTrim(aFields[nIndCps][3]) == "GG_DESC"
						aDefDados[nIndCps] := PadR(InicDesc(SGG->(GG_COMP)), GetSx3Cache("GG_DESC","X3_TAMANHO"))

					ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
						aDefDados[nIndCps] := SGG->(Recno())

					ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
						aDefDados[nIndCps] := SGG->(GG_TRT)

					ElseIf AllTrim(aFields[nIndCps][3]) == "CSTATUS"
						aDefDados[nIndCps] := SGG->(GG_STATUS)

					ElseIf !aFields[nIndCps][14] //Verifica se é campo virtual
						aDefDados[nIndCps] := SGG->(&(aFields[nIndCps][3]))
					Else
						aDefDados[nIndCps] := CriaVar(aFields[nIndCps][3])
					EndIf
				Next nIndCps

				aAdd(aLoad, {0, aClone(aDefDados)})
				SGG->(dbSkip())
			End
		EndIf
	EndIf

	SGG->(RestArea(aAreaSGG))

Return aLoad

/*/{Protheus.doc} LoadGridC
Retorna array com os dados a serem inseridos na Grid - Cópia de Estruturas/Pré-Estruturas
@author brunno.costa
@since 14/12/2018
@version 1.0
@param 01 cCargo, characters, cCargo referente ao item selecionado
@param 02 oModel, object    , modelo principal
@return aLoad, array, array de carga da grid
/*/
Static Function LoadGridC(cCargo, oModel)

	Local aAreaAlias := SGG->(GetArea())
	Local aLoad      := {}
	Local aLoadAux   := {}
	Local aDefDados  := {}
	Local aListas	 := {}
	Local aFields    := oModel:GetModel("GRID_DETAIL"):oFormModelStruct:aFields
	Local cEstrAlias := Iif(soEveDef:mvlOrigemPreEstrutura,"SGG","SG1")
	Local cSeqInc
	Local l1oNivel   := P135RetInf(cCargo, "COMP") == soEveDef:mvcProdutoDestino
	Local cProdSelec := Iif(l1oNivel, soEveDef:mvcEstruturaOrigem, P135RetInf(cCargo, "COMP"))
	Local nIndCps    := 0
	Local nIndAux    := 0
	Local nIndPai    := aScan(aFields, {|x| x[3] == "GG_COD" })
	Local nIndComp   := aScan(aFields, {|x| x[3] == "GG_COMP" })
	Local nIndTRT    := aScan(aFields, {|x| x[3] == "GG_TRT" })
	Local lIgnoraCmp := .F.
	Local nPosicao	 := 0
	Local lMsg		 := .F.

	//Carrega dados pré-existentes para este produto intermediário na SG1
	If !soEveDef:mvlOrigemPreEstrutura .AND. !l1oNivel
		aLoadAux := LoadGrid(cCargo, oModel)
		For nIndAux := 1 to Len(aLoadAux)
			If !Empty(aLoadAux[nIndAux,2,1])
				aAdd(aLoad, aClone(aLoadAux[nIndAux]))
			EndIf
		Next nIndAux
	EndIf

	For nIndCps := 1 to Len(aFields)
		aAdd(aDefDados,Nil)
	Next nIndCps

	If Empty(oModel:GetModel("FLD_SELECT"):GetValue("GG_COD"))
		aAdd(aLoad, {0, aClone(aDefDados)})
	Else
		(cEstrAlias)->(dbSetOrder(1))
		If (cEstrAlias)->(dbSeek(xFilial(cEstrAlias) + cProdSelec, .F.))
			While !(cEstrAlias)->(Eof()) .And. ;
			       (cEstrAlias)->&(CampoCopy("GG_FILIAL")) == xFilial(cEstrAlias) .And. ;
			       (cEstrAlias)->&(CampoCopy("GG_COD"))    == cProdSelec

				//Desconsidera componentes fora de revisão - Origem Estrutura
				If !soEveDef:mvlOrigemPreEstrutura
					If SG1->G1_REVINI > soEveDef:mvcRevisaoOrigem;
					   .OR. SG1->G1_REVFIM < soEveDef:mvcRevisaoOrigem
						SG1->(dbSkip())
						Loop
					EndIf
				Endif

				For nIndCps := 1 to Len(aFields)
					If AllTrim(aFields[nIndCps][3]) == "CARGO"
						//Gera um novo CARGO
						aDefDados[nIndCps] := MontaCargo(IND_ESTR                 , ;
														Iif(l1oNivel, soEveDef:mvcProdutoDestino, (cEstrAlias)->&(CampoCopy("GG_COD"))), ;
														(cEstrAlias)->&(CampoCopy("GG_COMP"))            , ;
														0)

					ElseIf AllTrim(aFields[nIndCps][3]) == "GG_DESC"
						aDefDados[nIndCps] := PadR(InicDesc((cEstrAlias)->&(CampoCopy("GG_COMP"))), GetSx3Cache("GG_DESC","X3_TAMANHO"))

					ElseIf AllTrim(aFields[nIndCps][3]) == "GG_USUARIO"
						aDefDados[nIndCps] := RetCodUsr()

					ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
						aDefDados[nIndCps] := 0

					ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
						aDefDados[nIndCps] := (cEstrAlias)->&(CampoCopy("GG_TRT"))

					ElseIf AllTrim(aFields[nIndCps][3]) == "CSTATUS"
						aDefDados[nIndCps] := "1"

					ElseIf AllTrim(aFields[nIndCps][3]) == "GG_LISTA"
						aDefDados[nIndCps] := (cEstrAlias)->(&(CampoCopy(aFields[nIndCps][3])))
						If !Empty(aDefDados[nIndCps])
							nPosicao := aScan(aListas, { |x| x[1] == aDefDados[nIndCps] })
							If nPosicao = 0
								If ValidLista(aDefDados[nIndCps],cEstrAlias)
									Aadd(aListas, {aDefDados[nIndCps], .T.})
								Else
									lIgnoraCmp := .T.
									Aadd(aListas, {aDefDados[nIndCps], .F., Iif(l1oNivel, soEveDef:mvcProdutoDestino, (cEstrAlias)->&(CampoCopy("GG_COD")))})
									Exit
								EndIf
							Else
								 If !aListas[nPosicao][2]
								 	lIgnoraCmp := .T.
								 	lMsg	   := .T.
								 	Exit
								 EndiF
							EndIf
						EndIf

					ElseIf aFields[nIndCps][14] == .F. //Verifica se é campo virtual
						aDefDados[nIndCps] := (cEstrAlias)->(&(CampoCopy(aFields[nIndCps][3])))
					EndIf
				Next nIndCps

				If lIgnoraCmp
					(cEstrAlias)->(dbSkip())
					lIgnoraCmp := .F.
					Loop
				EndIf

				//Corrige o XX_COD para o produto destino
				If l1oNivel
					aDefDados[nIndPai] := soEveDef:mvcProdutoDestino
				EndIf

				//Correção de sequência (a partir do 2o nível)
				If !l1oNivel .AND. !soEveDef:mvclExcluiPreExistente
					//Quando já existe registro no array para este componente (ou no banco - pré carregado)
					cSeqInc  := aDefDados[nIndTRT]
					While (aScan(aLoad, {|x| x[2,nIndPai]      == aDefDados[nIndPai] ;
						                   .AND. x[2,nIndComp] == aDefDados[nIndComp];
										   .AND. x[2,nIndTRT]  == cSeqInc}) > 0)
						If Empty(cSeqInc)
							cSeqInc := StrZero(1, Len(cSeqInc))
						Else
							cSeqInc := Soma1(cSeqInc)
						EndIf
					EndDo
					aDefDados[nIndTRT] := cSeqInc
				EndIf

				aAdd(aLoad, {0, aClone(aDefDados)})
				(cEstrAlias)->(dbSkip())
			End

			If lMsg
				Help( , , "Help", , STR0253, 1, 0) //"Lista(s) de componente(s) com divergência(s). Será utilizada a lista atualizada do cadastro de Lista de Componentes (PCPA120)."
			EndIF

			(cEstrAlias)->(dbCloseArea())
			For nIndAux := 1 to Len(aListas)
				If aListas[nIndAux][2]
					Loop
				EndIf
				dbSelectArea("SVG")
				SVG->(dbSetOrder(1))
				If SVG->(DbSeek(xFilial("SVG") + aListas[nIndAux][1]))
					While !SVG->(Eof()) .And. SVG->VG_FILIAL == xFilial("SVG") .And. SVG->VG_COD == aListas[nIndAux][1]
						For nIndCps := 1 to Len(aFields)
							aDefDados[nIndCps] := Nil
						Next nIndCps
						For nIndCps := 1 to Len(aFields)
							If AllTrim(aFields[nIndCps][3]) == "CARGO"
								//Gera um novo CARGO
								aDefDados[nIndCps] := MontaCargo(IND_ESTR           , ;
																aListas[nIndAux][3] , ;
																SVG->VG_COMP        , ;
																0)

							ElseIf AllTrim(aFields[nIndCps][3]) == "GG_DESC"
								aDefDados[nIndCps] := PadR(InicDesc(SVG->VG_COMP), GetSx3Cache("GG_DESC","X3_TAMANHO"))

							ElseIf AllTrim(aFields[nIndCps][3]) == "GG_USUARIO"
								aDefDados[nIndCps] := RetCodUsr()

							ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
								aDefDados[nIndCps] := 0

							ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
								aDefDados[nIndCps] := SVG->VG_TRT

							ElseIf AllTrim(aFields[nIndCps][3]) == "CSTATUS"
								aDefDados[nIndCps] := "1"

							ElseIf AllTrim(aFields[nIndCps][3]) == "GG_LISTA"
								aDefDados[nIndCps] := SVG->VG_COD

							ElseIf AllTrim(aFields[nIndCps][3]) == "GG_COD"
								aDefDados[nIndCps] := aListas[nIndAux][3]

							ElseIf AllTrim(aFields[nIndCps][3]) == "GG_INI"
								If !Empty(SVG->VG_INI)
									aDefDados[nIndCps] := SVG->VG_INI
								Else
									aDefDados[nIndCps] := dDataBase
								EndIf

							ElseIf AllTrim(aFields[nIndCps][3]) == "GG_FIM"
								If !Empty(SVG->VG_FIM)
									aDefDados[nIndCps] := SVG->VG_FIM
								Else
									aDefDados[nIndCps] := CTOD("31/12/49")
								EndIf

							ElseIf aFields[nIndCps][14] == .F. .And. ; //Verifica se é campo virtual
									AllTrim(aFields[nIndCps][3]) <> "GG_PERDA" .And. ;
									AllTrim(aFields[nIndCps][3]) <> "GG_OBSERV" .And. ;
									AllTrim(aFields[nIndCps][3]) <> "GG_NIV" .And. ;
									AllTrim(aFields[nIndCps][3]) <> "GG_REVINI" .And. ;
									AllTrim(aFields[nIndCps][3]) <> "GG_REVFIM" .And. ;
									AllTrim(aFields[nIndCps][3]) <> "GG_FANTASM"
								aDefDados[nIndCps] := SVG->(&(CopySVG(aFields[nIndCps][3])))
							ElseIf aFields[nIndCps][14] == .F.
								aDefDados[nIndCps] := Criavar(aFields[nIndCps][3])
							EndIf
						Next nIndCps
						aAdd(aLoad, {0, aClone(aDefDados)})
						SVG->(DbSkip())
					EndDo
				EndIf
			Next nIndAux
		EndIf
	EndIf

	(cEstrAlias)->(RestArea(aAreaAlias))

Return aLoad

/*/{Protheus.doc} CampoCopy
Converte nomenclatura dos campos SGG -> SG1 conforme o caso
@author brunno.costa
@since 14/12/2018
@version 1.0
@param  cCampoSGG, caractere, nome do campo na SGG
@return          , caractere, nome do campo na SGG ou SG1 conforme o caso
/*/
Static Function CampoCopy(cCampoSGG)
Return Iif(soEveDef:mvlOrigemPreEstrutura, cCampoSGG, StrTran(cCampoSGG,'GG_','G1_'))

/*/{Protheus.doc} P135ValPai
Função de validação do item pai informado na tela
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return lOK, logical, indica se o campo está correto
/*/
Function P135ValPai()

	Local oModel   := FwModelActive()
	Local aArea    := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSGG := SGG->(GetArea())
	Local cPai     := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local cQuery   := ""
	Local lOK      := .T.

	If Empty(cPai)
		Help( ,  , "Help", ,  STR0022,;  //"Código do Produto não informado."
			 1, 0, , , , , , {STR0023})  //"Informe um código de produto válido."
		lOK := .F.
	Else
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial('SB1') + cPai, .F.))
			//Valida sub-produto
			If lOK .And. !SuperGetMv("MV_NEGESTR",.F.,.F.)
				cQuery := "SELECT COUNT(*) TOTREC"
				cQuery +=  " FROM " + RetSqlName('SGG') + " SGG"
				cQuery += " WHERE SGG.GG_FILIAL  = '" + xFilial("SGG") + "'"
				cQuery +=   " AND SGG.GG_COMP    = '" + cPai + "'"
				cQuery +=   " AND SGG.GG_QUANT   < 0"
				cQuery +=   " AND SGG.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)

				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSGG",.F.,.T.)
				If QRYSGG->TOTREC > 0
					Help(' ', 1, 'A202NAOINC')
					lOK := .F.
				EndIf
				QRYSGG->(dbCloseArea())
			EndIf

			//Validação de produtos protótipos
			If lOK .And. IsProdProt(cPai) .And. !IsInCallStack("DPRA340INT")
				Help( , , 'Help', , STR0054, 1, 0) //"Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR)."
				lOK := .F.
			EndIf

			If lOK
				If ExistBlock("MT202PAI")
					lRet:=ExecBlock("MT202PAI",.F.,.F.,cPai)
				EndIf
			EndIf
		Else
			Help(' ',1, 'NOFOUNDSB1')
			lOK := .F.
		EndIf
	EndIf

	//Restaura a área de trabalho.
	SGG->(RestArea(aAreaSGG))
	SB1->(RestArea(aAreaSB1))
	RestArea(aArea)

Return lOK

/*/{Protheus.doc} P135ValCpo
Função de validação do componente informado na Grid
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCampo , characters, indica qual campo está sendo validado
@param 02 lInsere, logical   , indica se deverá inserir o item na tree caso esteja válido
@return lOK, logical, indica se o campo está correto
/*/
Function P135ValCpo(cCampo, lInsere)

	Local oModel     := FwModelActive()
	Local oMdlDet    := oModel:GetModel("GRID_DETAIL")
	Local cPai       := oModel:GetModel("FLD_SELECT"):GetValue("GG_COD")
	Local cComp      := oMdlDet:GetValue("GG_COMP")
	Local cTrt       := oMdlDet:GetValue("GG_TRT")
	Local cGrupoOpc  := oMdlDet:GetValue("GG_GROPC")
	Local cItemOpc   := oMdlDet:GetValue("GG_OPC")
	Local cCargo     := ""
	Local nQuant     := oMdlDet:GetValue("GG_QUANT")
	Local dDataIni   := oMdlDet:GetValue("GG_INI")
	Local dDataFim   := oMdlDet:GetValue("GG_FIM")
	Local nPosAtual  := 0
	Local lOK        := .T.
	Local lRunAuto   := isRunAuto(oModel)

	Default lInsere := oMdlDet:IsInserted() .And. Empty(oMdlDet:GetValue("CARGO"))

	//GG_COMP
	If cCampo == 'GG_COMP' .And. !Empty(cComp)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + cComp))
			lOK := CheckEstru(oModel)			
		Else
			Help(' ', 1, 'NOFOUNDSB1')
			lOK := .F.
		EndIf

		If lOK
			oMdlDet:LoadValue("GG_DESC", PadR(SB1->B1_DESC, GetSx3Cache("GG_DESC","X3_TAMANHO")))

			//Incrementa a sequência desse componente
			If Empty(oMdlDet:GetValue("GG_TRT"))
				oMdlDet:SetValue("GG_TRT", ProximoTrt(oMdlDet,cPai,cComp))
			EndIf
		EndIf

	//GG_TRT
	ElseIf cCampo == 'GG_TRT'
		lOK := ValidaTrt(oMdlDet, cPai, cComp, cTrt)

		If lOK
			//Se já existe CARGO é porque já está na Tree, então deve-se atualizar o TRT no array de controle saCargos
			cCargo := oMdlDet:GetValue("CARGO")
			If !Empty(cCargo)
				nPosAtual := P135RetInf(cCargo,"POS")
				If nPosAtual > 0
					saCargos[nPosAtual][IND_ACARGO_TRT] := cTrt
				EndIf
			EndIf
		EndIf

	//GG_QUANT
	ElseIf cCampo == 'GG_QUANT'	
		If IsProdMod(cComp) .And. SuperGetMV('MV_TPHR',.F.,"C") == 'N'
			nQuant := nQuant - Int(nQuant)
			If nQuant > .5999999999
				Help(' ', 1, 'NAOMINUTO')
				lOK := .F.
			Else
				//Restaura o conteúdo do NQUANT
				nQuant := oMdlDet:GetValue("GG_QUANT")
			EndIf
		ElseIf QtdComp(nQuant) < QtdComp(0) .And. !SuperGetMv('MV_NEGESTR',.F.,.F.)
			Help(' ', 1, 'A202NAONEG')
			lOK := .F.
		EndIf
	//GG_INI ou GG_FIM
	ElseIf cCampo == 'GG_FIM'
		If dDataFim < dDataIni
			Help( ,  , "Help", ,  STR0039,; //"Data Final não pode ser menor que Data Inicial."
				 1, 0, , , , , , {STR0040}) //"Verifique o período digitado."
			lOK := .F.
		EndIf

	//GG_GROPC
	ElseIf cCampo == 'GG_GROPC'
		If !Empty(cGrupoOpc)
			lOK := ExistCpo('SGA')
		EndIf

	//GG_OPC
	ElseIf cCampo == 'GG_OPC'
		If !Empty(cGrupoOpc)
			lOK := NaoVazio() .And. ExistCpo('SGA', cGrupoOpc + cItemOpc)
		Else
			lOK := Vazio()
		EndIf

	//GG_TIPVEC
	ElseIf cCampo == "GG_TIPVEC"
		lOK := Vazio() .Or. ExistCpo("SX5", "VC" + oMdlDet:GetValue("GG_TIPVEC"))

	//GG_VECTOR
	ElseIf cCampo == "GG_VECTOR"
		lOK := Vazio() .Or. ExistCpo("SHV", oMdlDet:GetValue("GG_TIPVEC") + oMdlDet:GetValue("GG_VECTOR"), 1)

	//GG_POTENCI
	ElseIf cCampo == 'GG_POTENCI'
		If oMdlDet:GetValue("GG_POTENCI") != 0
			If !Rastro(cComp)
				Help(" ", 1, "NAORASTRO")
				lOK := .F.
			Else
				If !PotencLote(cComp)
					Help(" ", 1, "NAOCPOTENC")
					lOK := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//Tratativa para incluir ou atualizar o item na Tree
	If lOK .And. !Empty(cComp) .And. nQuant != 0 .And. slAtuaTree
		If cCampo $ "/GG_COMP/GG_QUANT/GG_TRT/"
			//Insere o produto na tree se for necessário.
			oMdlDet:LoadValue("GG_COD", cPai)

			If lInsere
				cCargo := MontaCargo(IND_ESTR, cPai, cComp, 0)
				oMdlDet:LoadValue("CARGO",cCargo)
				AddTree(oModel:GetModel("FLD_SELECT"):GetValue("CARGO"),;
				        cCargo,   ;
				        cGrupoOpc,;
				        cItemOpc, ;
				        cTrt,     ;
				        CompValido(dDataIni, dDataFim))
			EndIf

		ElseIf cCampo $ "/GG_GROPC/GG_OPC/" .And. !lRunAuto
			//Atualiza o PROMPT da tree (Opcionais)
			cCargo := oMdlDet:GetValue("CARGO")
			AttPrompt(cCargo, PromptTree(cCargo, cGrupoOpc, cItemOpc))

		ElseIf cCampo $ "/GG_INI/GG_FIM/" .And. !lRunAuto
			//Faz a alteração da imagem da tree
			cCargo := oMdlDet:GetValue("CARGO")
			AttImgTree(cCargo, CompValido(dDataIni, dDataFim))
		EndIf
	EndIf

Return lOK

/*/{Protheus.doc} CheckEstru
Verifica a recursividade da estrutura
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@param 01 oModel, object, modelo principal
@return lRet, logical, indica se o código digitado está válido.
/*/
Static Function CheckEstru(oModel)

	Local aAreaGG    := {}
	Local oMdlSelec  := oModel:GetModel("FLD_SELECT")
	Local oMdlDet    := oModel:GetModel("GRID_DETAIL")
	Local oMdlGrv    := oModel:GetModel("GRAVA_SGG")
	Local cPai       := oMdlSelec:GetValue("GG_COD")
	Local cCargoPai  := oMdlSelec:GetValue("CARGO")
	Local cComp      := oMdlDet:GetValue("GG_COMP")
	Local cMsgEstr   := ""
	Local cHelp      := ""
	Local lRet       := .T.
	Local lErrAltern := .F.

	//Verifica se o componente foi informado na própria estrutura
	If ExistAcima(cComp, cCargoPai)
		Help( ,  , "Help", ,  STR0016,;  //"Esse componente já foi informado nessa estrutura."
		     1, 0, , , , , , {STR0017})  //"Verifique o componente digitado."
		lRet := .F.

	//Verifica se gerará erro em alguma estrutura já carregada na tree
	ElseIf ExistTree(cPai, cComp, @cMsgEstr, @lErrAltern)
		cHelp := STR0035 + AllTrim(cMsgEstr) + " > " + AllTrim(cPai)
		If lErrAltern
			cHelp += ")"
		EndIf
		Help( ,  , "Help", ,  cHelp,;   //"Operação não permitida. Incluir esse componente causará recursividade na estrutura: "
		     1, 0, , , , , , {STR0017}) //"Verifique o componente digitado."
		lRet := .F.

	//Verifica as estruturas que não estão na tela mas que usam o componente
	Else
		aAreaGG := SGG->(GetArea())
		SGG->(dbSetOrder(2))
		If ExistTable(cPai, cComp, @cMsgEstr, oMdlGrv, xFilial("SGG"),.F., .F., @lErrAltern, .F.)
			cHelp := STR0035 + AllTrim(cMsgEstr) + " > " + AllTrim(cPai)
			Help( ,  , "Help", ,  cHelp,;   //"Operação não permitida. Incluir esse componente causará recursividade na estrutura: "
			     1, 0, , , , , , {STR0017}) //"Verifique o componente digitado."
			lRet := .F.
		Else
			//Verifica se esse componente possui estrutura, e se essa estrutura irá se tornar recursiva
			SGG->(dbSetOrder(1))
			If ExistTable(cComp, cPai, @cMsgEstr, oMdlGrv, xFilial("SGG"),.T., .T., @lErrAltern, .F.)
				cHelp := STR0035 + AllTrim(cMsgEstr)
				If !lErrAltern
					cHelp += " > " + AllTrim(cPai)
				EndIf
				Help( ,  , "Help", ,  cHelp,; //"Operação não permitida. Incluir esse componente causará recursividade na estrutura: "
					 1, 0, , , , , , {STR0017})                                             //"Verifique o componente digitado."
				lRet := .F.
			EndIf
		EndIf
		SGG->(RestArea(aAreaGG))
	EndIf

Return lRet

/*/{Protheus.doc} ExistAcima
Verifica se o componente já existe na mesma estrutura em que está digitando
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cComp    , characters, código do componente
@param 02 cCargoPai, characters, CARGO do pai do componente
@return lExiste, logical, indica se o componente já existe na estrutura
/*/
Static Function ExistAcima(cComp, cCargoPai)

	Local nPos    := 0
	Local lExiste := .F.

	//É igual ao Pai?
	If cComp == P135RetInf(cCargoPai, "COMP")
		lExiste := .T.
	Else
		//É igual ao Vô?
		If cComp == P135RetInf(cCargoPai, "PAI")
			lExiste := .T.
		Else
			//Percorre os níveis acima presentes na tela
			nPos := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_COMP] == cCargoPai })
			While nPos > 0
				If cComp == P135RetInf(saCargos[nPos][IND_ACARGO_CARGO_COMP], "PAI")
					lExiste := .T.
					Exit
				Else
					If cComp == P135RetInf(saCargos[nPos][IND_ACARGO_CARGO_PAI], "PAI")
						lExiste := .T.
						Exit
					EndIf
				EndIf

				nPos := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_COMP] == saCargos[nPos][IND_ACARGO_CARGO_PAI] })
			End
		EndIf
	EndIf

Return lExiste

/*/{Protheus.doc} ExistTree
Percorre todas as estruturas da tree onde o pai (cCodPesq) é usado validando se o componente digitado (cCodValid) já existe
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCodPesq  , characters, código do item para pesquisa
@param 02 cCodValid , characters, código do componente a ser comparado
@param 03 cMsgEstr  , characters, (referência) caminho da estrutura que ficará inconsistente
@param 04 lErrAltern, characters, Retorna por referência se ocorreu erro de recursividade em produtos alternativos.
@return lExiste, logical, indica se o item é usado na estrutura
/*/
Static Function ExistTree(cCodPesq, cCodValid, cMsgEstr, lErrAltern)
	Local cAlterna := ""
	Local lExiste  := .F.
	Local nPos     := aScan(saCargos, { |x| x[IND_ACARGO_COMP] == cCodPesq })

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
				cMsgEstr := AllTrim(cCodValid) + " -> (" + STR0292 //"Produto alternativo"
			EndIf
		EndIf
	EndIf

Return lExiste

/*/{Protheus.doc} ExistTable
Percorre todas as estruturas onde o pai (cCodPesq) é usado validando se o componente digitado (cCodValid) já existe
Obs: Por ser uma função recursiva, antes de executar esta função deve ser feito o dbSetOrder()
     para o alias SGG. GetArea e RestArea para o alias SGG deve ser feito também pela função chamadora.
	 Quando lPai := .T., o deverá usar o índice 1 da SGG (SGG->(dbSetOrder(1)))
	 Quando lPai := .F., o deverá usar o índice 2 da SGG (SGG->(dbSetOrder(2)))
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCodPesq , characters, código do item para pesquisa
@param 02 cCodValid, characters, código do componente a ser comparado
@param 03 cMsgEstr , characters, (referência) caminho da estrutura que ficará inconsistente
@param 04 oMdlGrv  , characters, modelo de dados (Passar sempre o sub-model GRAVA_SGG)
@param 05 cFilSGG  , characters, filial utilizada no seek da tabela SGG.
@param 06 lPai     , logical   , identifica se a validação é para o produto pai.
                                 Se sim, faz a busca no sentido PAI->COMPON, verificando se o GG_COMP é igual ao cCodValid
                                 Se não, faz a busca no sentido COMPON->PAI, verificando se o GG_COD é igual ao cCodValid
@param lVerAlt     , logical   , Identifica se serão verificados os produtos alternativos.
@param lErrAltern  , logical   , Retorna por referência se ocorreu erro de recursividade em produtos alternativos.
@param lVldAlt     , logical   , Indica que está executando validação de produto alternativo.
@return lExiste, logical, indica se o item é usado na estrutura
/*/
Static Function ExistTable(cCodPesq, cCodValid, cMsgEstr, oMdlGrv, cFilSGG, lPai, lVerAlt, lErrAltern, lVldAlt)
	Local cAlterna := ""
	Local cCodGG   := ""
	Local lExiste  := .F.
	Local lEntrou  := .F.
	Local nRecAtu  := 0

	//Percorre os pais do item
	If SGG->(dbSeek(cFilSGG + cCodPesq, .F.))
		lEntrou := .T.
		While !SGG->(Eof()) .And. ;
		       SGG->GG_FILIAL == cFilSGG .And. ;
		       Iif(lPai,SGG->GG_COD,SGG->GG_COMP) == cCodPesq

			//Se o item foi deletado da tela deve ser desconsiderado
			If oMdlGrv:SeekLine({ {"GG_COD" , SGG->GG_COD }, ;
			                      {"GG_COMP", SGG->GG_COMP}, ;
			                      {"GG_TRT" , SGG->GG_TRT} }, .F., .T.)

				//Se o item foi deletado da estrutura, desconsidera
				If oMdlGrv:GetValue("DELETE")
					SGG->(dbSkip())
					Loop
				EndIf
			EndIf

			If lPai
				cCodGG := SGG->GG_COMP
			Else
				cCodGG := SGG->GG_COD
			EndIf

			//Se encontrou um item igual, causará erro na estrutura (infinita)
			If cCodValid == cCodGG
				lExiste  := .T.
				cMsgEstr := AllTrim(cCodGG)
				Exit
			EndIf

			//Verifica os avós do item
			nRecAtu := SGG->(Recno())
			If ExistTable(cCodGG, cCodValid, @cMsgEstr, oMdlGrv, cFilSGG, lPai, lVerAlt, @lErrAltern, lVldAlt)
				SGG->(dbGoTo(nRecAtu))
				lExiste  := .T.
				
				If lErrAltern
					If Left(cMsgEstr, Len(AllTrim(cCodGG))+2) == AllTrim(cCodGG) + " >"
						//Validação para não adicionar o código do componente 2x
						cMsgEstr := AllTrim(SGG->GG_COD) + " > " + AllTrim(cMsgEstr)
					Else
						cMsgEstr := AllTrim(SGG->GG_COD) + " > " + AllTrim(cCodGG) + " > " + AllTrim(cMsgEstr)
					EndIf
				Else
					If lVldAlt
						cMsgEstr := AllTrim(cCodGG) + " > " + AllTrim(cMsgEstr)
					Else
						cMsgEstr := AllTrim(cMsgEstr) + " > " + AllTrim(cCodGG)
					EndIf
				EndIf
				
				Exit
			EndIf
			SGG->(dbGoTo(nRecAtu))
			SGG->(dbSkip())
		End
	EndIf

	If !lExiste .And. lVerAlt .And. vldAlter()
		cAlterna := produzAlt(cCodPesq)
		If !Empty(cAlterna)
			If cAlterna == cCodValid
				lExiste    := .T.
				lErrAltern := .T.
				cMsgEstr := "(" + STR0292 + " " + AllTrim(cAlterna) + ")" //"Produto alternativo"
				If !lEntrou
					//Se é um produto sem estrutura, adiciona seu código na mensagem de erro.
					cMsgEstr := AllTrim(cCodPesq) + " > " + cMsgEstr
				EndIf
			Else
				If ExistTable(cAlterna, cCodValid, @cMsgEstr, oMdlGrv, cFilSGG, lPai, lVerAlt, @lErrAltern, .T.)
					lExiste    := .T.
					lErrAltern := .T.
					If Left(cMsgEstr, Len(AllTrim(cCodPesq))+2) == AllTrim(cCodPesq) + " >"
						cMsgEstr := "(" + STR0292 + " " + AllTrim(cAlterna) + ") > " + AllTrim(cMsgEstr) //"Produto alternativo"
					Else
						cMsgEstr := AllTrim(cCodPesq) + " > (" + STR0292 + " " + AllTrim(cAlterna) + ") > " + AllTrim(cMsgEstr) //"Produto alternativo"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lExiste

/*/{Protheus.doc} MontaCargo
Monta o campo CARGO do registro
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cInd  , characters, indicador de tipo de registro:
                              ESTR - Componente da estrutura
                              TEMP - Nó temporário da tree, utilizado apenas para exibir a opção de expandir o nível (+)
@param 02 cPai  , characters, código do pai do registro
@param 03 cComp , characters, código do componente
@param 04 nRecno, characters, RECNO do registro (componente)
@return cCargo, chacacters, campo CARGO formatado com o padrão do programa
/*/
Static Function MontaCargo(cInd,cPai,cComp,nRecno)

	Local cCargo := ""
	Default nRecno := 0

	snSeqTree++

	cCargo := PadR(cPai,  snTamCod)  + ;
	          PadR(cComp, snTamComp) + ;
	          StrZero(nRecno, 9)     + ;
	          StrZero(snSeqTree, 9)  + ;
	          cInd

Return PadR(cCargo,GetTmCargo())

/*/{Protheus.doc} GetTmCargo
Retorna o tamanho total do CARGO utilizado para TREE
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@return nTam, Tamanho utilizado para o CARGO
/*/
Static Function GetTmCargo()

	Local nTam := snTamCod  + ;
	              snTamComp + ;
	              9 + 9 + 4

Return nTam

/*/{Protheus.doc} P135RetInf
Extrai informações do  CARGO da Tree
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargo, characters, CARGO o qual as informações serão extraídas
@param 02 cInfo , characters, indica a informação a ser extraída:
                              "IND"   - Indicador (IND_ESTR, IND_TEMP)
                              "PAI"   - Pai
                              "COMP"  - Componente
                              "RECNO" - Recno
                              "INDEX" - Index
                              "POS"   - Posição no array de controle (saCargos)
@return xRet, caracters, informação solicitada
/*/
Function P135RetInf(cCargo, cInfo)

	Local xRet
	Local nStart   := 0
	Local nTamanho := 0

	Default cInfo := "COMP"

	If cInfo == "IND"
		//Indicador
		xRet := Right(cCargo, 4)

	ElseIf cInfo == "PAI"
		//Pai
		xRet := Left(cCargo, snTamCod)

	ElseIf cInfo == "COMP"
		//Componente
		nStart   := snTamCod + 1
		nTamanho := snTamComp
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "RECNO"
		//Recno
		nStart   := snTamCod + snTamComp + 1
		nTamanho := 9
		xRet := Val(Substr(cCargo, nStart, nTamanho))

	ElseIf cInfo == "INDEX"
		//Index
		nStart   := snTamCod + snTamComp + 10
		nTamanho := 9
		xRet := Val(Substr( cCargo, nStart, nTamanho))

	ElseIf cInfo == "POS"
		//Posição do CARGO no array saCargos
		xRet := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_COMP] == cCargo })

	EndIf

Return xRet

/*/{Protheus.doc} AddItemTr
Adiciona um item na Tree
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargoPai , characters, campo CARGO do pai (GG_COD)
@param 02 cCargoComp, characters, campo CARGO do componente (GG_COMP)
@param 03 cTrt      , characters, campo Sequência do componente (GG_TRT)
@param 04 lValido   , logic     , indica se o registro deve ser exibido como válido ou não (vermelho) na tree
@param 05 cPrompt   , characters, valor a ser exibido no Prompt da tree
@param 06 cGrupoOpc , characters, campo Grupo Opcional do componente (GG_GROPC)
@param 07 cItemOpc  , characters, campo Itme Opcional do componente (GG_OPC)
@param 08 lAddTmp   , logic     , indica se será executada a função para adicionar nós temporários na tree
@return NIL
/*/
Static Function AddItemTr(cCargoPai, cCargoComp, cTrt, lValido, cPrompt, cGrupoOpc, cItemOpc, lAddTmp)

	Local cCargoAtu := ""
	Local cFolderA  := If(lValido, VALIDO_A, INVALIDO_A)
	Local cFolderF  := If(lValido, VALIDO_F, INVALIDO_F)

	Default cPrompt := PromptTree(cCargoComp, cGrupoOpc, cItemOpc)
	Default lAddTmp := .T.

	If !slCriaTemp
		lAddTmp	:= .F.
	EndIf

	aAdd(saCargos,{ P135RetInf(cCargoComp,"PAI") ,; //GG_COD
	                P135RetInf(cCargoComp,"COMP"),; //GG_COMP
	                cTrt                         ,; //GG_TRT
	                cCargoComp                   ,; //CARGO
	                cCargoPai                    ,; //CARGO_PAI
	                cPrompt                      ,; //PROMPT
	                lValido                      ,; //Indicador de imagem de validade válida ou inválida
	                P135RetInf(cCargoComp,"IND") }) //Indicador da tree (IND_ESTR/IND_TEMP)

	If soDbTree == Nil
		Return
	EndIf

	cCargoAtu := soDbTree:GetCargo()

	If cCargoAtu != cCargoPai
		soDbTree:TreeSeek(cCargoPai)
	EndIf

	soDbTree:AddItem(cPrompt, cCargoComp, cFolderA, cFolderF, , , 2)

	//Se este componente possui estrutura, adiciona um item temporário na TREE, para que seja exibido com a opção de navegar na tree (+)
	If lAddTmp
		AddTmpTree(P135RetInf(cCargoComp,"COMP"), cCargoComp)
	EndIf

	If soDbTree:GetCargo() != cCargoAtu
		soDbTree:TreeSeek(cCargoAtu)
	EndIf

Return

/*/{Protheus.doc} P135DelIt
Remove um item da Tree
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargoPai , characters, campo CARGO do pai (GG_COD)
@param 02 cCargoComp, characters, campo CARGO do componente (GG_COMP)
@return NIL
/*/
Function P135DelIt(cCargoPai, cCargoComp)

	Local oModel    := FwModelActive()
	Local nPosAtual := P135RetInf(cCargoComp, "POS")
	Local nPos      := 0
	Local nLenArr   := 0
	Local cPai      := ""
	Local cComp     := ""
	Local cTrt      := ""

	If nPosAtual > 0
		nLenArr := Len(saCargos)
		cPai    := saCargos[nPosAtual][IND_ACARGO_PAI]
		cComp   := saCargos[nPosAtual][IND_ACARGO_COMP]
		cTrt    := saCargos[nPosAtual][IND_ACARGO_TRT]
		nPos    := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
		                                 x[IND_ACARGO_COMP] == cComp .And. ;
		                                 x[IND_ACARGO_TRT]  == cTrt })

		//Percorre a tree buscando o componente removido
		While nPos > 0
			slExecChL := .F.
			If soDbTree != Nil
				soDbTree:TreeSeek(saCargos[nPos][IND_ACARGO_CARGO_COMP])
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

		If soDbTree != Nil
			soDbTree:TreeSeek(cCargoPai)
		EndIf
	EndIf

Return

/*/{Protheus.doc} P135Reload
Recarrega os itens da GRID de detalhes conforme banco

@author brunno.costa
@since 12/04/2019
@version 1.0

@param cOldCargo	- Campo CARGO a ser recarregado
@return NIL
/*/
Function P135Reload(cOldCargo)
	Local nPos      := 0
	Local nLen
	Local cCargoPai
	Local cCargoComp

	Default  cOldCargo := Iif(soDbTree != Nil, soDbTree:GetCargo(), Nil)

	If cOldCargo != Nil
		nPos       := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI]  == cOldCargo })

		//Loop Filhos
		While nPos > 0
			cCargoPai  := saCargos[nPos][IND_ACARGO_CARGO_PAI]
			cCargoComp := saCargos[nPos][IND_ACARGO_CARGO_COMP]
			P135DelIt(cCargoPai, cCargoComp)
			nPos := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI]  == cCargoPai }, nPos+1)
		EndDo

		//Remove cargo do array de controle
		nPos := aScan(saTreeLoad,{|x| x == cOldCargo})
		If nPos > 0
			nLen := Len(saTreeLoad)
			aDel(saTreeLoad , nPos)
			aSize(saTreeLoad, nLen-1)
		Endif

		//Recarrega grid
		P135TreeCh(.T., cOldCargo, , .T.)

		If soDbTree != Nil
			soDbTree:Refresh()
		EndIf
	EndIf

Return


/*/{Protheus.doc} ExcluiAlt
Exclui as alterações realizadas nos componentes excluídos
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargoExcl, characters, CARGO do componente removido
@param 02 oModel    , object    , modelo de dados
@return NIL
/*/
Static Function ExcluiAlt(cCargoExcl, oModel)

	Local nPos    := aScan(saCargos, {|x| x[IND_ACARGO_CARGO_PAI] == cCargoExcl})
	Local oMdlGrv := oModel:GetModel("GRAVA_SGG")

	//Percorre os níveis abaixo do componente para eliminar as alterações salvas
	While nPos > 0
		//Chamada recursiva para o componente do componente
		ExcluiAlt(saCargos[nPos][IND_ACARGO_CARGO_COMP], oModel)

		//Se alguma alteração foi salva no modelo de gravação, remove a mesma
		If oMdlGrv:SeekLine({ {"GG_COD" , saCargos[nPos][IND_ACARGO_PAI]}, ;
		                      {"GG_COMP", saCargos[nPos][IND_ACARGO_COMP]}, ;
		                      {"GG_TRT" , saCargos[nPos][IND_ACARGO_TRT]}, ;
		                      {"CARGO"  , saCargos[nPos][IND_ACARGO_CARGO_COMP]}  }, .F., .T.)
			oMdlGrv:DeleteLine()
		EndIf

		InitACargo(nPos)

		nPos := aScan(saCargos, {|x| x[IND_ACARGO_CARGO_PAI] == cCargoExcl}, nPos+1)
	End

Return

/*/{Protheus.doc} PromptTree
Gera o texto Prompt de exibição do item na Tree
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargo   , characters, campo CARGO do item
@param 02 cGrupoOpc, characters, campo GG_GROPC
@param 03 cItemOpc , characters, campo GG_OPC
@return cPrompt, chacacters, texto Prompt do item na Tree formatado com o tamanho máximo (bug)
/*/
Static Function PromptTree(cCargo, cGrupoOpc, cItemOpc)

	Local cPrompt   := ""
	Local nTamPromp := snTamCod                                  + ;  // Código do Produto
			           3 + Len(STR0034) + 2                      + ;  // " - " + "Opcional" + ": "
			           GetSx3Cache("GG_GROPC", "X3_TAMANHO") + 1 + ;  // Grupo Opcional + "/"
			           GetSx3Cache("GG_OPC"  , "X3_TAMANHO")          // Item Opcional

	Default cGrupoOpc := ""
	Default cItemOpc  := ""

	cPrompt := AllTrim(P135RetInf(cCargo, "COMP"))
	If !Empty(cGrupoOpc) .Or. !Empty(cItemOpc)
		cPrompt += " - " + STR0034 + ": " + AllTrim(cGrupoOpc) + "/" + AllTrim(cItemOpc)  //"Opcional"
	EndIf

Return PadR(cPrompt, nTamPromp)

/*/{Protheus.doc} P135AddPai  (Antiga AddTreePai)
Adiciona o código do produto pai na TREE
Se a tree não estiver vazia, ela será reinicializada para incluir somente o produto pai
@author Marcelo Neumann
@since 08/11/2018
@version 1.0
@param 01 cProduto, characters, código do Produto a ser adicionado
@return cCargo, characters, código do CARGO criado
/*/
Function P135AddPai(cProduto)
	Local cCargo     := ""
	Local nSqTreeBkp := 0

	SGG->(dbSetOrder(1))
	If SGG->(dbSeek(xFilial("SGG") + cProduto))
		If soEveDef:lCopia
			cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, 0)
		Else
			cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, SGG->(Recno()))
		EndIf
	Else
		cCargo := MontaCargo(IND_ESTR, cProduto, cProduto, 0)
	EndIf

	If soDbTree <> NIL
		soDbTree:Reset()

		nSqTreeBkp := snSeqTree
		P135IniStc()
		snSeqTree := nSqTreeBkp

		soDbTree:BeginUpdate()
		soDbTree:AddTree(PromptTree(cCargo), .T., VALIDO_A, VALIDO_F, , , cCargo)
		soDbTree:EndTree()
		soDbTree:EndUpdate()
		soDbTree:Refresh()
	EndIf

Return cCargo

/*/{Protheus.doc} P135EdtPai
Identifica quando será possível alterar o código do produto Pai.
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@return lRet, logical, identifica se o código do produto pai poderá ser alterado
/*/
Function P135EdtPai()

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

/*/{Protheus.doc} AddCmpTree
Adiciona componentes na tree de acordo com o que está carregado no modelo de componentes
@author Marcelo Neumann
@since 12/11/2018
@version 1.0
@param 01 cCargoPai, characters, cargo do nível pai de onde os componentes serão adicionados.
@param 02 oModel   , objects   , modelo de dados
@return Nil
/*/
Static Function AddCmpTree(cCargoPai,oModel)

	Local oMdlDet   := oModel:GetModel("GRID_DETAIL")
	Local nIndFor   := 0
	Local nLen      := 0
	Local nPos      := 0
	Local nLineAnt  := 0
	Local cCargo    := ""
	Local cPrdPai   := P135RetInf(cCargoPai,"COMP")
	Local cIdTree   := ""
	Local cNewCargo := ""
	Local lRunAuto  := isRunAuto(oModel)

	If saTreeLoad == NIL
		saTreeLoad := {}
	EndIf

	If !lRunAuto
		//Se não tiver o Objeto da TREE, retorna
		If soDbTree == NIL
			Return
		EndIf

		//Verifica no array saTreeLoad se este pai já foi carregado
		//Se já foi adicionado na TREE, somente sincroniza a Tree com a Grid
		If aScan(saTreeLoad,{|x| x==cCargoPai}) > 0
			SincTreeGr(oMdlDet, cCargoPai)
			Return
		EndIf

		//Verifica se é necessário posicionar na tree
		If soDbTree:GetCargo() != cCargoPai
			soDbTree:TreeSeek(cCargoPai)
		EndIf

		//Guarda o ID do nó pai para posicionamento
		cIdTree := soDbTree:CurrentNodeId

		//Inicializa atualização da tree
		soDbTree:BeginUpdate()

		//Verifica se existe o componente "TEMP" nesse nível da tree, e o apaga
		cNewCargo := cCargoPai
		cNewCargo := StrTran(cNewCargo, P135RetInf(cNewCargo,"IND"), IND_TEMP)
		If soDbTree:TreeSeek(cNewCargo)
			nPos := aScan(saCargos,{|x| x[IND_ACARGO_CARGO_COMP]==cNewCargo})
			If nPos > 0
				nLen := Len(saCargos)
				aDel(saCargos,nPos)
				aSize(saCargos,nLen-1)
			EndIf

			soDbTree:DelItem()
			soDbTree:PTGotoToNode(cIdTree)
		EndIf

		//Se o componente da tree não possuir estrutura, não faz a carga.
		If Empty(oMdlDet:GetValue("GG_COMP",1))
			soDbTree:EndUpdate()
			Return
		EndIf
	EndIf

	//Se o componente da tree não possuir estrutura, não faz a carga.
	If Empty(oMdlDet:GetValue("GG_COMP",1))
		Return
	EndIf

	For nIndFor := 1 To oMdlDet:Length()
		If oMdlDet:IsDeleted(nIndFor)
			Loop
		EndIf

		//Incrementa a sequência e cria o CARGO
		If Empty(oMdlDet:GetValue("CARGO",nIndFor))
			cCargo   := MontaCargo(IND_ESTR, cPrdPai, oMdlDet:GetValue("GG_COMP",nIndFor), oMdlDet:GetValue("NREG",nIndFor))
			nLineAnt := oMdlDet:GetLine()
			oMdlDet:GoLine(nIndFor)
			oMdlDet:LoadValue("CARGO",cCargo)
			oMdlDet:GoLine(nLineAnt)
		Else
			cCargo := oMdlDet:GetValue("CARGO",nIndFor)

			//Verifica se é necessário gerar um novo cargo
			nPos := P135RetInf(cCargo,"POS")
			If nPos > 0 .And. aScan(saTreeLoad,{|x| x == cCargo}) == 0
				If saCargos[nPos][IND_ACARGO_CARGO_PAI] != cCargoPai
					//Gera um cargo novo, pois o cargo que está no modelo é referente a outro PAI
					cCargo   := MontaCargo(IND_ESTR, cPrdPai, oMdlDet:GetValue("GG_COMP",nIndFor), oMdlDet:GetValue("NREG",nIndFor))
					nLineAnt := oMdlDet:GetLine()
					oMdlDet:GoLine(nIndFor)
					oMdlDet:LoadValue("CARGO",cCargo)
					oMdlDet:GoLine(nLineAnt)
				EndIf
			EndIf
		EndIf

		//Adiciona o componente na TREE
		AddItemTr(cCargoPai,                          ;
		          cCargo,                             ;
		          oMdlDet:GetValue("GG_TRT",nIndFor), ;
		          CompValido(oMdlDet:GetValue("GG_INI",nIndFor), oMdlDet:GetValue("GG_FIM",nIndFor)), ;
		          NIL, ;
		          oMdlDet:GetValue("GG_GROPC",nIndFor), ;
		          oMdlDet:GetValue("GG_OPC",nIndFor)  , ;
		          .T.)
	Next nIndFor

	If !lRunAuto
		soDbTree:EndUpdate()
		soDbTree:PTGotoToNode(cIdTree)
	EndIf

	aAdd(saTreeLoad,cCargoPai)

Return

/*/{Protheus.doc} AddTmpTree
Adiciona um nó temporário na tree, apenas para mostrar o botão + quando o componente possuir estrutura
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@param cComp , characters, código do componente que foi adicionado
@param cCargo, characters, cargo do componente que foi adicionado
@return Nil
/*/
Static Function AddTmpTree(cComp,cCargo)

	Local cIdTreeAtu := ""
	Local cNewCargo  := cCargo
	Local lChangeBkp := slExecChL

	If soDbTree == Nil
		Return
	EndIf

	//Gera o novo cargo para o nó temporário
	cNewCargo := StrTran(cNewCargo, P135RetInf(cNewCargo,"IND"), IND_TEMP)

	//Se esse nó temporário já foi adicionado, não adiciona novamente
	If aScan(saCargos,{|x| x[IND_ACARGO_CARGO_COMP]==cNewCargo}) > 0
		Return
	EndIf

	//Verifica se o componente possui estrutura
	If ExistEstru(cComp)
		//Pega o ID do nó posicionado da tree
		cIdTreeAtu := soDbTree:CurrentNodeId

		//Seta variável para não executar o ChangeLine
		slExecChL := .F.

		//Posiciona no componente que foi adicionado na tree
		soDbTree:TreeSeek(cCargo)

		//Adiciona o nó temporário na tree
		AddItemTr(cCargo,    ; //CargoPai
		          cNewCargo, ; //CargoComp
		          "",        ; //Trt
		          .T.,       ; //Valido
		          ".",       ; //Prompt
		          "",        ; //GrupoOpc
		          "",        ; //ItemOpc
		          .F.)         //AddTmp

		//Retorna para o nó posicionado anteriormente.
		soDbTree:PTGotoToNode(cIdTreeAtu)

		//Retorna o valor da variável do ChangeLine
		slExecChL := lChangeBkp
	EndIf

Return

/*/{Protheus.doc} AttImgTree
Atualiza a imagem da tree do componente em todos os níveis abertos
@author Marcelo Neumann
@since 16/11/2018
@version 1.0
@param 01 cCargoComp, characters, CARGO do item que será alterado o Prompt
@param 02 lNewValido, logic     , indica se o registro deve ser exibido como válido ou não (vermelho) na tree
@return NIL
/*/
Static Function AttImgTree(cCargoComp, lNewValido)

	Local nPosAtual  := P135RetInf(cCargoComp,"POS")
	Local cPai       := saCargos[nPosAtual][IND_ACARGO_PAI]
	Local cComp      := saCargos[nPosAtual][IND_ACARGO_COMP]
	Local cTrt       := saCargos[nPosAtual][IND_ACARGO_TRT]
	Local cFolderA   := If(lNewValido, VALIDO_A, INVALIDO_A)
	Local cFolderF   := If(lNewValido, VALIDO_F, INVALIDO_F)
	Local lOldValido := saCargos[nPosAtual][IND_ACARGO_IMGVALIDO]
	Local nPos       := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
	                                          x[IND_ACARGO_COMP] == cComp .And. ;
	                                          x[IND_ACARGO_TRT]  == cTrt })


	If lOldValido != lNewValido
		If soDbTree != NIL
			//Percorre e atualiza todos os itens da Tree
			While nPos > 0
				soDbTree:ChangeBmp(cFolderA, cFolderF, , , saCargos[nPos][IND_ACARGO_CARGO_COMP])
				saCargos[nPos][IND_ACARGO_IMGVALIDO] := lNewValido

				nPos := aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cPai  .And. ;
				                              x[IND_ACARGO_COMP] == cComp .And. ;
				                              x[IND_ACARGO_TRT]  == cTrt }, (nPos + 1))
			End
		EndIf
	EndIf

Return

/*/{Protheus.doc} AttPrompt
Atualiza o Prompt do componente em todos os níveis abertos
@author Marcelo Neumann
@since 14/11/2018
@version 1.0
@param cCargoComp, characters, CARGO do item que será alterado o Prompt
@param cPrompt   , characters, descrição do novo Prompt para o item
@return NIL
/*/
Static Function AttPrompt(cCargoComp, cPrompt)

	Local nPosAtual := P135RetInf(cCargoComp,"POS")
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

/*/{Protheus.doc} ExistEstru
Verifica se um produto possui estrutura
@author Marcelo Neumann
@since 12/11/2018
@version 1.0
@param cProduto, characters, código do produto a ser verificado
@return lRet, logical, identifica se o produto possui estrutura
/*/
Static Function ExistEstru(cProduto)

	Local aAreaGG   := SGG->(GetArea())
	Local oModel    := FwModelActive()
	Local oMdlGrv   := oModel:GetModel("GRAVA_SGG")
	Local oMdlSelec := oModel:GetModel("FLD_SELECT")
	Local oMdlDet   := oModel:GetModel("GRID_DETAIL")
	Local lRet      := .F.

	If slExpCopia .AND. soEveDef:lCopia .AND. !soEveDef:mvlOrigemPreEstrutura
		SG1->(dbSetOrder(1))
		If SG1->(MsSeek(xFilial("SG1") + cProduto))
			lRet := .T.
		EndIf
	Else
		SGG->(dbSetOrder(1))
		If SGG->(MsSeek(xFilial("SGG") + cProduto))
			lRet := .T.
		EndIf
	EndIf

	If !lRet
		If oMdlGrv:SeekLine({ {"GG_COD", cProduto}, {"DELETE",.F.} }, .F., .F.)
			lRet := .T.
		Else
			If oMdlSelec:GetValue("GG_COD") == cProduto .And. oMdlDet:Length(.T.)
				lRet := .T.
			EndIf
		EndIf
	EndIf

	SGG->(RestArea(aAreaGG))

Return lRet

/*/{Protheus.doc} CargaSelec
Carrega as informações do componente selecionado na tree para o modelo FLD_SELECT
@author Marcelo Neumann
@since 12/11/2018
@version 1.0
@param cProduto, characters, código do produto selecionado.
@param oModel  , objects   , modelo de dados
@param cCargo  , characters, cargo do item selecionado na TREE
@return Nil
/*/
Static Function CargaSelec(cProduto, oModel, cCargo)
	Local oMdlMaster	:= oModel:GetModel("FLD_MASTER")
	Local oMdlSelec 	:= oModel:GetModel("FLD_SELECT")
	Local oView     	:= FwViewActive()
	Local lDelete   	:= oModel:GetOperation() == MODEL_OPERATION_DELETE

	If lDelete
		oMdlSelec:DeActivate()
		oMdlSelec:oFormModel:nOperation := MODEL_OPERATION_VIEW
		oMdlSelec:Activate()
	EndIf

	oMdlSelec:LoadValue("GG_COD"  , cProduto)
	oMdlSelec:LoadValue("CDESCCMP", InicDesc(cProduto))
	oMdlSelec:LoadValue("CUMCMP"  , InicUniMed(cProduto))
	oMdlSelec:LoadValue("CARGO", cCargo)

	If cProduto == oMdlMaster:GetValue("GG_COD")
		oMdlMaster:LoadValue("CARGO", cCargo)
	EndIf

	If lDelete
		oMdlSelec:DeActivate()
		oMdlSelec:oFormModel:nOperation := MODEL_OPERATION_DELETE
		oMdlSelec:Activate()
		If oView != Nil .And. oView:IsActive()
			oView:Refresh("V_FLD_SELECT")
			soDbTree:SetFocus()
		EndIf
	EndIf

Return

/*/{Protheus.doc} P135GravAl
Grava as alterações realizadas na GRID para posteriormente commitar ou recuperar
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oModel, object, modelo principal
@return NIL
/*/
Function P135GravAl(oModel)

	Local oMdlDet    := oModel:GetModel("GRID_DETAIL")
	Local aLinAlt    := {}
	Local aFields    := oMdlDet:oFormModelStruct:aFields
	Local cCampo     := ""
	Local nIndLin    := 0
	Local nIndCps    := 0
	Local oEvent     := gtMdlEvent(oModel,"PCPA135EVDEF")
	Local cProdPai
	Local cProdSelec

	If !oEvent:lOperacCriaEstr .And. !oEvent:lOperacAprovacao
		If Len(oMdlDet:GetLinesChanged()) > 0
			For nIndLin := 1 To oMdlDet:Length()
				If !oMdlDet:IsDeleted(nIndLin)
					oMdlDet:GoLine(nIndLin)
					oMdlDet:LoadValue("CSTATUS","1")
				EndIf
			Next
		EndIf
	Endif

	aLinAlt := oMdlDet:GetLinesChanged()

	For nIndLin := 1 To Len(aLinAlt)
		If Empty(oMdlDet:GetValue("GG_COMP",aLinAlt[nIndLin]))
			Loop
		EndIf

		/*If oMdlDet:IsDeleted(aLinAlt[nIndLin]) .And. oMdlDet:IsInserted(aLinAlt[nIndLin])
			Loop
		EndIf*/

		If !oModel:GetModel("GRAVA_SGG"):IsEmpty()
			oModel:GetModel("GRAVA_SGG"):AddLine()
		EndIf

		oMdlDet:GoLine(aLinAlt[nIndLin])
		oModel:GetModel("GRAVA_SGG"):LoadValue("LINHA" , aLinAlt[nIndLin])
		oModel:GetModel("GRAVA_SGG"):LoadValue("DELETE", oMdlDet:IsDeleted())

		For nIndCps := 1 to Len(aFields)
			cCampo := AllTrim(aFields[nIndCps][3])
			If oMdlDet:GetValue(cCampo, aLinAlt[nIndLin]) != Nil
				oModel:GetModel("GRAVA_SGG"):LoadValue( cCampo, oMdlDet:GetValue(cCampo, aLinAlt[nIndLin]) )
			EndIf
		Next nIndCps
	Next nIndLin

	//Remove lock's
	If Len(aLinAlt) == 0
		cProdPai   := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
		cProdSelec := oModel:GetModel("FLD_SELECT"):GetValue("GG_COD")
		If cProdPai != cProdSelec
			oEvent:UnLock(oModel:GetModel("FLD_SELECT"):GetValue("GG_COD"))
		EndIf
	EndIf

Return

/*/{Protheus.doc} RecupAlter
Recupera as alterações gravadas no modelo de gravação (utilizado quando volta para um item que foi modificado anteriormente)
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 cCargo, characters, CARGO do item da tree a ser recuperado
@return NIL
/*/
Static Function RecupAlter(cCargo)

	Local oModel   := FwModelActive()
	Local oMdlGrv  := oModel:GetModel("GRAVA_SGG")
	Local oMdlDet  := oModel:GetModel("GRID_DETAIL")
	Local aFields  := oMdlDet:oFormModelStruct:aFields
	Local aLineDel := {}
	Local cCampo   := ""
	Local nIndCps  := 0
	Local nLinha   := 0
	Local nIndex   := 0
	Local nPos     := 0
	Local lDiverg  := .F.
	Local bLoad    := NIL

 	If soEveDef:lOperacCriaEstr
        Return
    EndIf

	If oModel:GetOperation() == MODEL_OPERATION_VIEW .And. !oMdlGrv:IsEmpty()
		//Tratativa para visualizar as informações na tela de Divergências do PCPA120.
		lDiverg := .T.

		//Retira o bloco de carga do modelo para não carregar novamente.
		bLoad := oMdlDet:bLoad
		oMdlDet:bLoad := {|X,Y|FORMLOADGRID(X,Y)}

		oMdlDet:DeActivate()
		oMdlDet:oFormModel:nOperation := MODEL_OPERATION_UPDATE
		oMdlDet:Activate()
	EndIf

	While .T.
		//Enquanto encontra modificações no modelo de gravação
		If oMdlGrv:SeekLine({ {"GG_COD", P135RetInf(cCargo, "COMP")} }, .F., .T.)

			nLinha := oMdlGrv:GetValue("LINHA")

			If nLinha > oMdlDet:Length()
				oMdlDet:AddLine()
			Else
				oMdlDet:GoLine(nLinha)
			EndIf

			If oMdlGrv:GetValue("DELETE")
				soEveDef:lExecutaPreValid := .F.
				oMdlDet:DeleteLine()
				soEveDef:lExecutaPreValid := .T.
			EndIf

			For nIndCps := 1 to Len(aFields)
				cCampo := AllTrim(aFields[nIndCps][3])
				If cCampo == "CARGO"
					If aScan(saTreeLoad,{|x| x == cCargo}) == 0
						Loop
					EndIf

					nPos := aScan(saCargos, {|x| x[IND_ACARGO_PAI]       == oMdlGrv:GetValue("GG_COD")  .And. ;
					                             x[IND_ACARGO_COMP]      == oMdlGrv:GetValue("GG_COMP") .And. ;
					                             x[IND_ACARGO_TRT]       == oMdlGrv:GetValue("GG_TRT")  .And. ;
					                             x[IND_ACARGO_CARGO_PAI] == cCargo})
					//Se está na tree, assume o cargo
					If nPos > 0
						oMdlDet:LoadValue( cCampo, saCargos[nPos][IND_ACARGO_CARGO_COMP] ) //CARGO
					Else
						oMdlDet:LoadValue( cCampo, oMdlGrv:GetValue(cCampo) )
					EndIf
				Else
					oMdlDet:LoadValue( cCampo, oMdlGrv:GetValue(cCampo) )
				EndIf
			Next nIndCps
			aAdd(aLineDel,oMdlGrv:GetLine())
			oMdlGrv:DeleteLine()
		Else
			Exit
		EndIf
	End

	If lDiverg
		//Restaura as linhas deletadas do GRAVA_SGG, para que ao mudar de componente na tree seja realizada a carga
		//dos componentes novamente.
		For nIndex := 1 To Len(aLineDel)
			oMdlGrv:GoLine(aLineDel[nIndex])
			oMdlGrv:UnDeleteLine()
		Next nIndex

		oMdlDet:DeActivate()
		oMdlDet:oFormModel:nOperation := MODEL_OPERATION_VIEW
		oMdlDet:Activate()

		//Restaura o bloco de Load.
		oMdlDet:bLoad := bLoad
	EndIf

	oMdlDet:GoLine(1)
Return

/*/{Protheus.doc} AddTree
Adiciona um novo componente na TREE
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@param 01 cCargoPai , characters, CARGO do produto Pai
@param 02 cCargoComp, characters, cargo utilizado para o novo componente
@param 03 cGrupoOpc , characters, grupo de opcionais
@param 04 cItemOpc  , characters, item opcional
@param 05 cTrt      , characters, sequência do componente
@param 06 lValido   , logic     , indica se o registro deve ser exibido como válido ou não (vermelho) na tree
@return Nil
/*/
Static Function AddTree(cCargoPai, cCargoComp, cGrupoOpc, cItemOpc, cTrt, lValido)

	Local cCargoAtu := ""
	Local cPai      := P135RetInf(cCargoComp,"PAI")
	Local nPos      := 0

	If soDbTree != Nil
		cCargoAtu := soDbTree:GetCargo()
	EndIf

	If saTreeLoad == NIL
		saTreeLoad := {}
	EndIf

	nPos := aScan(saCargos, {|x| x[IND_ACARGO_COMP] == cPai})

	//Adiciona no nó que está selecionado na tree
	AddItemTr(cCargoPai,  ; //CargoPai
	          cCargoComp, ; //CargoComp
	          cTrt,       ; //Trt
	          lValido,    ; //Valido
	          NIL,        ; //Prompt
	          cGrupoOpc,  ; //GrupoOpc
	          cItemOpc,   ; //ItemOpc
	          .T.)          //AddTmp
	If aScan(saTreeLoad,{|x| x==cCargoPai}) == 0
		aAdd(saTreeLoad,cCargoPai)
	EndIf

	//Se o PAI estiver na Tree, adiciona o componente em todos os pais
	If nPos <> 0
		While nPos > 0
			//Somente carrega se for diferente do nó selecionado na tree, pois este nó já foi carregado antes do while
			If saCargos[nPos][IND_ACARGO_CARGO_COMP] != cCargoPai
				//Verifica no array saTreeLoad se este pai já foi carregado.
				//Se já foi carregado adiciona o componente. Se não foi carregado ainda, adiciona o nó temporário
				If cCargoPai != saCargos[nPos][IND_ACARGO_CARGO_COMP] .And. aScan(saTreeLoad,{|x| x==saCargos[nPos][IND_ACARGO_CARGO_COMP]}) == 0
					AddTmpTree(P135RetInf(saCargos[nPos][IND_ACARGO_CARGO_COMP],"COMP"),saCargos[nPos][IND_ACARGO_CARGO_COMP])
				Else
					cCargoComp := MontaCargo(P135RetInf(cCargoComp,"IND") , ;
											P135RetInf(cCargoComp,"PAI") , ;
											P135RetInf(cCargoComp,"COMP"), ;
											P135RetInf(cCargoComp,"RECNO"))
					AddItemTr(saCargos[nPos][IND_ACARGO_CARGO_COMP], ; //CargoPai
					          cCargoComp,                            ; //CargoComp
					          cTrt,                                  ; //Trt
					          lValido,                               ; //Valido
					          NIL,                                   ; //Prompt
					          cGrupoOpc,                             ; //GrupoOpc
					          cItemOpc,                              ; //ItemOpc
					          .T.)                                     //AddTmp
					If aScan(saTreeLoad,{|x| x==saCargos[nPos][IND_ACARGO_CARGO_COMP]}) == 0
						aAdd(saTreeLoad,saCargos[nPos][IND_ACARGO_CARGO_COMP])
					EndIf
				EndIf
			Endif

			nPos := aScan(saCargos, { |x| x[IND_ACARGO_COMP] == cPai .And. x[IND_ACARGO_IND] != IND_TEMP}, (nPos + 1))
		End
	EndIf

	If !Empty(cCargoAtu)
		soDbTree:TreeSeek(cCargoAtu)
	EndIf

Return

/*/{Protheus.doc} InitACargo
Inicializa as informações de uma determinada posição do array saCargos
@author Marcelo Neumann
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

/*/{Protheus.doc} CompValido
Verifica se o componente está válido dentro da estrutura
@author Marcelo Neumann
@since 14/11/2018
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

/*/{Protheus.doc} ListaComp
A opção "Lista de Componentes" irá carregar os componentes da lista para a tela de pré cadastro da estrutura
@author Carlos Alexandre da Silveira
@since 09/11/2018
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
	Local cPai      := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local nOldInd   := oModel:GetModel("GRID_DETAIL"):GetLine()
	Local nUltItem  := oModel:GetModel("GRID_DETAIL"):Length(.F.)
	Local lCancelar := .F.
	Local lRet      := .T.
	Local oEvent    := gtMdlEvent(oModel,"PCPA135EVDEF")
	Local cCodProd  := P135RetInf(soDbTree:GetCargo(), "COMP")

	If !Empty(cPai)
		If !oEvent:Lock(cCodProd, oViewPai, .T.)
			lRet := .F.
		Else
			//Grava a última linha da grid principal para posicionar no primeiro registro inserido
			If !Empty(oModel:GetModel("GRID_DETAIL"):GetValue("GG_COMP"))
				nUltItem++
			EndIf

			//Não abrir a tela se a linha posicionada está inválida
			If oModel:GetModel("GRID_DETAIL"):VldLineData()
				oModel:GetModel("GRID_DETAIL"):GoLine( oModel:GetModel("GRID_DETAIL"):Length(.F.) )

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

				oView:AddUserButton(STR0037,"",{|| slConfList := .F., lCancelar := .T., oView:CloseOwner() },STR0037,,,.T.) //"Cancelar"

				//Proteção para execução com View ativa
				If oModel != Nil .And. oModel:isActive()
					oViewExec := FWViewExec():New()
					oViewExec:SetModel(oModel)
					oViewExec:SetView(oView)
					oViewExec:SetTitle(STR0036) //"Lista de Componentes"
					oViewExec:SetOperation(oViewPai:GetOperation())
					oViewExec:SetReduction(70)
					oViewExec:SetButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0038},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Confirmar"
					oViewExec:SetCloseOnOk({|oViewPai| ConfirmLis(oViewPai)})
					oViewExec:SetModal(.T.)
					oViewExec:OpenView(.F.)

					If lCancelar .Or. !slConfList
						oModel:GetModel("GRID_DETAIL"):GoLine(nOldInd)
						CancelList(oView, oViewPai, oViewExec)
					Else
						oModel:GetModel("GRID_DETAIL"):GoLine(nUltItem)
						slConfList := .F.
						CancelList(oView, oViewPai, oViewExec)
					Endif
				EndIf
			Else
				oViewPai:ShowLastError()
			EndIf
		EndIf
	Else
		Help( ,  , "Help", ,  STR0022,;  //"Código do Produto não informado."
			1, 0, , , , , , {STR0023})  //"Informe um código de produto válido."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ConfirmLis
Função para verificar se a tela da Lista de Componentes será fechada ou não após a mensagem
@author Carlos Alexandre da Silveira
@since 09/11/2018
@version 1.0
@param 01 oViewPai, object, objeto da View Pai
@return lRet, logical, identifica se a View será fechada
/*/
Static Function ConfirmLis(oViewPai)

	Local oModel     := oViewPai:GetModel()
	Local oModelGrid := oModel:GetModel("GRID_DETAIL")
	Local oModelList := oModel:GetModel("GRID_LISTA")
	Local oModelAuxG
	Local nX         := 0
	Local aError     := {}
	Local cCompon    := ""
	Local cLoadXML   := ""
	Local nLinErro   := 0
	Local lRet       := .T.

	If Empty(oModelList:GetValue("VG_COMP"))
		Help( , , "Help", , STR0043, 1, 0) //"A lista selecionada não existe."
		Return .F.
	EndIf

	If oModelGrid:SeekLine({{"GG_LISTA",oModelList:GetValue("VG_COD",1)}}, .T., .F. )
		Help( , , "Help", , STR0254, 1, 0) //"Esta lista já está sendo utilizada."
		Return .F.
	EndIf

	If soModelAux == Nil
		soModelAux := FWLoadModel("PCPA135") //Carrega um novo modelo para fazer as validações
	Else
		soModelAux:DeActivate()
		dbSelectArea("SGG")
		SGG->(DbSetOrder(1))
		SGG->(DbSeek(xFilial("SGG") + oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")))
		//soModelAux:Activate()
	EndIf
	oModelAuxG := soModelAux:GetModel("GRID_DETAIL")

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
    	Help( , , "Help", , STR0041, 1, 0) //"Ocorreu um erro ao realizar o backup dos dados."
	Else
 		slConfList := .T.

		If lRet
	 		//Percorre os componentes da lista buscando por componente já informado na grid principal
			nQtdGrid := oModelList:Length(.F.)
			For nX := 1 To nQtdGrid
			  	If oModelGrid:SeekLine({ {"GG_COMP",oModelList:GetValue("VG_COMP",nX)},{"GG_TRT",oModelList:GetValue("VG_TRT", nX)} }, .F., .F. )
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
				Help( , , "Help", , STR0042 + " (" + AllTrim(cCompon) + ")", 1, 0) //"Este componente já está cadastrado na estrutura."
			EndIf
		EndIf

		If lRet
			//Inicia a inserção dos componentes da lista no modelo Auxiliar
			oModelAuxG:SetNoUpdateLine(.F.)
			oModelAuxG:SetNoDeleteLine(.F.)

			nQtdGrid := oModelList:Length(.F.)

			//Seta variável para que a inserção de componentes no modelo auxiliar não crie o item na Tree
			slAtuaTree := .F.
			For nX := 1 To nQtdGrid
				If !( nX == 1 .And. ;
				      oModelAuxG:Length() == 1 .And. ;
				      Empty(oModelAuxG:GetValue("GG_COMP")) .And. ;
				      Empty(oModelAuxG:GetValue("GG_QUANT")) .And. ;
				      !oModelAuxG:IsDeleted() )

					oModelAuxG:AddLine()
				EndIf

				//Valida a atribuição dos valores dos campos principais
				If !oModelAuxG:SetValue("GG_COMP" , oModelList:GetValue("VG_COMP" , nX))
				    nLinErro := nX
					Exit
				EndIf
				IF Empty(oModelList:GetValue("VG_TRT"  , nX))
					oModelAuxG:LoadValue("GG_TRT"  , "123")
				EndIf
				If !oModelAuxG:SetValue("GG_TRT"  , oModelList:GetValue("VG_TRT"  , nX))
					nLinErro := nX
					Exit
				EndIf
				If !oModelAuxG:SetValue("GG_QUANT", oModelList:GetValue("VG_QUANT", nX))
				    nLinErro := nX
					Exit
				EndIf
				oModelAuxG:SetValue("GG_INI"    , oModelList:GetValue("VG_INI"    , nX))
				oModelAuxG:SetValue("GG_FIM"    , oModelList:GetValue("VG_FIM"    , nX))
				oModelAuxG:SetValue("GG_FIXVAR" , oModelList:GetValue("VG_FIXVAR" , nX))
				oModelAuxG:SetValue("GG_GROPC"  , oModelList:GetValue("VG_GROPC"  , nX))
				oModelAuxG:SetValue("GG_OPC"    , oModelList:GetValue("VG_OPC"    , nX))
				oModelAuxG:SetValue("GG_POTENCI", oModelList:GetValue("VG_POTENCI", nX))
				oModelAuxG:SetValue("GG_TIPVEC" , oModelList:GetValue("VG_TIPVEC" , nX))
				oModelAuxG:SetValue("GG_VECTOR" , oModelList:GetValue("VG_VECTOR" , nX))
				oModelAuxG:SetValue("GG_LISTA"  , oModelList:GetValue("VG_COD"    , nX))
				oModelAuxG:SetValue("GG_LOCCONS" , oModelList:GetValue("VG_LOCCONS" , nX))

				If !oModelAuxG:VldLineData(.F.)
				    nLinErro := nX
					Exit
				EndIf

				If !lRet
					aError 	:= soModelAux:GetErrorMessage()
					cCompon := oModelList:GetValue("VG_COMP", nX)
					Exit
				ElseIf !oModelAuxG:VldLineData(.F.)
					lRet   	:= .F.
					Exit
				EndIf
			Next nX
			slAtuaTree := .T.

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
					oModelGrid:SetValue("GG_COMP"   , oModelAuxG:GetValue("GG_COMP"   , nX))
					oModelGrid:SetValue("GG_TRT"    , oModelAuxG:GetValue("GG_TRT"    , nX))
					oModelGrid:SetValue("GG_INI"    , oModelAuxG:GetValue("GG_INI"    , nX))
					oModelGrid:SetValue("GG_FIM"    , oModelAuxG:GetValue("GG_FIM"    , nX))
					oModelGrid:SetValue("GG_FIXVAR" , oModelAuxG:GetValue("GG_FIXVAR" , nX))
					oModelGrid:SetValue("GG_GROPC"  , oModelAuxG:GetValue("GG_GROPC"  , nX))
					oModelGrid:SetValue("GG_OPC"    , oModelAuxG:GetValue("GG_OPC"    , nX))
					oModelGrid:SetValue("GG_POTENCI", oModelAuxG:GetValue("GG_POTENCI", nX))
					oModelGrid:SetValue("GG_TIPVEC" , oModelAuxG:GetValue("GG_TIPVEC" , nX))
					oModelGrid:SetValue("GG_VECTOR" , oModelAuxG:GetValue("GG_VECTOR" , nX))
					oModelGrid:SetValue("GG_LISTA"  , oModelAuxG:GetValue("GG_LISTA"  , nX))
					oModelGrid:SetValue("GG_QUANT"  , oModelAuxG:GetValue("GG_QUANT"  , nX))
					oModelGrid:SetValue("GG_LOCCONS" , oModelAuxG:GetValue("GG_LOCCONS" , nX))

					If nX != oModelAuxG:Length(.F.)
						oModelGrid:AddLine()
					EndIf
				Next nX
			Else
				lRet    := .F.
				aError 	:= soModelAux:GetErrorMessage()
				cCompon := oModelList:GetValue("VG_COMP", nLinErro)

				If Empty(aError[MODEL_MSGERR_SOLUCTION])
					aError[MODEL_MSGERR_SOLUCTION] := STR0044 //"Verifique o Cadastro da Lista de Componentes."
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

	cMsg := STR0047 + CHR(13) + CHR(10) + ; //"Existem erros que impedem a importação da lista: "
	        AllTrim(RetTitle("GG_COMP")) + " " + AllTrim(cCompon)

	If !Empty( AllTrim(aError[MODEL_MSGERR_IDFIELDERR])) .And. ;
	    Upper( AllTrim(RetTitle(aError[MODEL_MSGERR_IDFIELDERR])) ) <> Upper( AllTrim(RetTitle("GG_COMP")) )

		cMsg += " (" + AllTrim(RetTitle(aError[MODEL_MSGERR_IDFIELDERR])) + ")"
	EndIf

	cMsg += ": " + AllTrim(aError[MODEL_MSGERR_MESSAGE])

Return cMsg

/*/{Protheus.doc} LoadSMW
Função para carregar a lista de componentes
@author Carlos Alexandre da Silveira
@since 12/11/2018
@version 1.0
@return aLoad, array, array com os dados da SMW
/*/
Static Function LoadSMW()

	Local aLoad := {CriaVar("MW_CODIGO",.F.), CriaVar("MW_DESCRI",.F.)}

Return aLoad

/*/{Protheus.doc} CancelList
Função para cancelar a opção da lista de componentes
@author Carlos Alexandre da Silveira
@since 12/11/2018
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

/*/{Protheus.doc} P135VldLis
Valida se o código da lista já existe
@author Carlos Alexandre da Silveira
@since 12/11/2018
@version 1.0
@return lRet, logical, identifica se o registro existe
/*/
Function P135VldLis()

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
@since 12/11/2018
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

				For nIndFields := 1  to Len(aFields)
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
@since 14/11/2018
@version 1.0
@param 01 oModelSGG, object, modelo da tabela SGG
@return NIL
/*/
Static Function EnableLine(oModelSGG)

	If Empty(oModelSGG:GetValue("GG_LISTA")) .And. slPCPRLEP == 2
		oModelSGG:SetNoUpdateLine(.F.)
	EndIf

Return

/*/{Protheus.doc} A135CEst
Comparação de Pré-Estruturas - Antiga a202CEst
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - cDescOrig, characters, descrição do produto origem
@param 02 - cDescDest, characters, descrição do produto destino
@param 03 - cOpcOrig , characters, opcionais do produto origem
@param 04 - cOpcDest , characters, opcionais do produto destino
@param 05 - cCodOrig , characters, código do produto origem
@param 06 - cCodDest , characters, código do produto destino
/*/
Function A135CEst(cDescOrig, cDescDest, cOpcOrig, cOpcDest, cCodOrig, cCodDest, dDtRefOrig, dDtRefDest)

	Local aArea      := GetArea()
	Local lOk        := .F.
	Local mOpcOrig 	 := ""
	Local mOpcDest 	 := ""
	Local nAjCoordY  := 10
	Local oSay
	Local oSay2
	Local oslValQtde

	Default cDescOrig  := Criavar("B1_DESC",.F.)
	Default cDescDest  := Criavar("B1_DESC",.F.)
	Default cOpcOrig   := Criavar("C2_OPC" ,.F.)
	Default cOpcDest   := Criavar("C2_OPC" ,.F.)
	Default cCodOrig   := Criavar("GG_COMP",.F.)
	Default cCodDest   := Criavar("GG_COMP",.F.)
	Default dDtRefOrig := dDataBase
	Default dDtRefDest := dDataBase

	If Empty(cCodDest)
		cDescOrig  := Criavar("B1_DESC",.F.)
		cDescDest  := Criavar("B1_DESC",.F.)
		cOpcOrig   := Criavar("C2_OPC" ,.F.)
		cOpcDest   := Criavar("C2_OPC" ,.F.)
		cCodOrig   := Criavar("GG_COMP",.F.)
		cCodDest   := Criavar("GG_COMP",.F.)
		dDtRefOrig := dDataBase
		dDtRefDest := dDataBase
	EndIf

	DEFINE MSDIALOG oDlg FROM  140,000 TO 410,670 TITLE OemToAnsi(STR0063) PIXEL //"Comparador de Pre-Estruturas"
	DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg

	@ 026 + nAjCoordY,006 TO 056 + nAjCoordY,330 LABEL OemToAnsi(STR0064) OF oDlg PIXEL //"Dados Originais"
	@ 062 + nAjCoordY,006 TO 092 + nAjCoordY,330 LABEL OemToAnsi(STR0065) OF oDlg PIXEL //"Dados para Comparação"
	@ 098 + nAjCoordY,006 TO 120 + nAjCoordY,330 LABEL OemToAnsi(STR0075) OF oDlg PIXEL //"Parâmetros"

	@ 038 + nAjCoordY,030 MSGET cCodOrig   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) SIZE 105,09 OF oDlg PIXEL
	@ 038 + nAjCoordY,175 MSGET dDtRefOrig Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefOrig) SIZE 40,09 OF oDlg PIXEL
	@ 038 + nAjCoordY,249 MSGET cOpcOrig   When .F. SIZE 65,09 OF oDlg PIXEL
	@ 038 + nAjCoordY,317 BUTTON "?" SIZE 09,11 Action (cOpcOrig := SeleOpc(4,"PCPA135",cCodOrig,,,,,,1,dDtRefOrig,,.T.,@mOpcOrig)) OF oDlg FONT oDlg:oFont PIXEL

	@ 074 + nAjCoordY,030 MSGET cCodDest   F3 "SB1" Picture PesqPict("SGG","GG_COMP") Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest) SIZE 105,9 OF oDlg PIXEL
	@ 074 + nAjCoordY,175 MSGET dDtRefDest Picture PesqPict("SD3","D3_EMISSAO") Valid NaoVazio(dDtRefDest) SIZE 40,09 OF oDlg PIXEL
	@ 074 + nAjCoordY,249 MSGET cOpcDest   When .F. SIZE 65,09 OF oDlg PIXEL
	@ 074 + nAjCoordY,317 BUTTON "?" SIZE 09,11 Action (cOpcDest:=SeleOpc(4,"PCPA135",cCodDest,,,,,,1,dDtRefDest,,.T.,@mOpcDest)) OF oDlg FONT oDlg:oFont PIXEL

	@ 048 + nAjCoordY,030 SAY oSay  Prompt cDescOrig SIZE 130,6 OF oDlg PIXEL
	@ 084 + nAjCoordY,030 SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL

	@ 040 + nAjCoordY,009 SAY OemtoAnsi(STR0030) SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ 035 + nAjCoordY,145 SAY OemToAnsi(STR0067) SIZE 35,15 OF oDlg PIXEL //"Data Referência"
	@ 040 + nAjCoordY,223 SAY OemtoAnsi(STR0068) SIZE 24,7  OF oDlg PIXEL //"Opcionais"

	@ 075 + nAjCoordY,009 SAY OemToAnsi(STR0030) SIZE 24,7  OF oDlg PIXEL //"Produto"
	@ 072 + nAjCoordY,145 SAY OemToAnsi(STR0067) SIZE 35,15 OF oDlg PIXEL //"Data Referência"
	@ 075 + nAjCoordY,223 SAY OemtoAnsi(STR0068) SIZE 24,7  OF oDlg PIXEL //"Opcionais"

	@ 110 + nAjCoordY,009 CHECKBOX oslValQtde VAR slValQtde PROMPT STR0076 SIZE 65,10 OF oDlg PIXEL Font oDlg:oFont	//"Compara Quantidade"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(CompValida(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest),(lOk := .T.,oDlg:End()),lOk:=.F.) },{||(lOk := .F.,oDlg:End())})

	//Processa comparação das Pre-estruturas
	If lOk
		Processa({|| CompProces(cCodOrig,dDtRefOrig,cOpcOrig,cCodDest,dDtRefDest,cOpcDest,mOpcOrig,mOpcDest) })
	EndIf

	RestArea(aArea)

	//Tratativa para reabrir a tela de parâmetros
	If slReabre
		slReabre := .F.
		A135CEst(cDescOrig, cDescDest, cOpcOrig, cOpcDest, cCodOrig, cCodDest, dDtRefOrig, dDtRefDest)
	EndIf

Return

/*/{Protheus.doc} CompValida
Valida se pode efetuar a comparacao das pre-estruturas - Antiga A202Cok
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - cCodOrig	, caracter	, Codigo do produto origem
@param 02 - dDtRefOrig	, data		, Data de referencia origem
@param 03 - cOpcOrig 	, caracter	, Opcionais do produto origem
@param 04 - cCodDest 	, caracter	, Codigo do produto destino
@param 05 - dDtRefDest 	, data		, Data de referencia destino
@param 06 - cOpcDest 	, caracter	, Opcionais do produto destino
@return     lReturn     , lógico    , indica se pode efetuar a amarração
/*/
Static Function CompValida(cCodOrig, dDtRefOrig, cOpcOrig, cCodDest, dDtRefDest, cOpcDest)

	Local lRet       := .T.
	Local aEstruOrig := {}
	Local aEstruDest := {}

	Private nEstru   := 0

	//Verifica se todas as informacoes estao iguais
	If cCodOrig + DTOS(dDtRefOrig) + cOpcOrig == cCodDest + DTOS(dDtRefDest) + cOpcDest
		Help('  ',1,'A202COMPIG')
		lRet := .F.
	EndIf

	If lRet .And. cCodOrig <> cCodDest
		//Verifica se existe item dentro da outra pre-estrutura - NAO PERMITE COMPARAR PARA EVITAR RECURSIVIDADE
		nEstru     := 0
		aEstruOrig := Estrut(cCodOrig,1,NIL,.T.)
		nEstru     := 0
		aEstruDest := Estrut(cCodDest,1,NIL,.T.)

		If (aScan(aEstruOrig,{|x| x[3] == cCodDest}) > 0) .Or. (aScan(aEstruDest,{|x| x[3] == cCodOrig}) > 0)
			Help('  ',1,'A202COMPES')
			lRet := .F.
		EndIf

		//Avisa ao usuario sobre produtos diferentes
		If lRet
			Help('  ',1,'A202COMPDF')
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} CompProces
Efetua a comparacao das pre-estruturas - Antiga A202PrCom
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - cCodOrig	, caracter	, Codigo do produto origem
@param 02 - dDtRefOrig	, data		, Data de referencia origem
@param 03 - cOpcOrig 	, caracter	, Opcionais do produto origem
@param 04 - cCodDest 	, caracter	, Codigo do produto destino
@param 05 - dDtRefDest 	, data		, Data de referencia destino
@param 06 - cOpcDest 	, caracter	, Opcionais do produto destino
@param 07 - mOpcOrig	, memo		, Opcionais Origem - Memo convertido de array
@param 08 - mOpcDest	, memo		, Opcionais Destino - Memo convertido de array
@return Nil
/*/
Static Function CompProces(cCodOrig, dDtRefOrig, cOpcOrig, cCodDest, dDtRefDest, cOpcDest, mOpcOrig, mOpcDest)

	Local aEstruOri  := {}
	Local aEstruDest := {}
	Local aSize      := MsAdvSize(.T.)
	Local oDlg
	Local oTree
	Local oTree2
	Local aObjects   := {}
	Local aInfo      := {}
	Local aPosObj    := {}
	Local aButtons   := {}
	Local cColunas	 := STR0066 + ";" + STR0077 + ";" + STR0078 //"Código";"Descrição";"Sequência"

	If slValQtde
		cColunas += ";" + STR0079 + ";" + STR0094 //"Quantidade";"Consumo"
	EndIf

	//Monta a  tela com o tree da versao base e com o tree da versao resultado da comparacao.
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T.,.T. )

	slMontando := .T.

	//Monta array com os conteudos dos tree
	SGG->(DbSetOrder(1))
	SGG->(dbSeek(xFilial("SGG")+cCodOrig))
	CompExplo(cCodOrig,dDtRefOrig,cOpcOrig,1,aEstruOri,0,mOpcOrig)
	SGG->(dbSeek(xFilial("SGG")+cCodDest))
	CompExplo(cCodDest,dDtRefDest,cOpcDest,1,aEstruDest,0,mOpcDest)

	//Iguala os arrays de origem e destino da comparacao
	CompAjusAr(aEstruOri,aEstruDest,cCodOrig,cCodDest)

	slMontando := .F.

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0063) FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Comparador de Pré-Estruturas"
		oTree :=  dbTree():New(aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], oDlg,,,.T.,,,cColunas)
		oTree:lShowHint := .F.
		CompMontTr(oTree,aEstruOri,NIL,NIL,aEstruDest)
		oTree2 := dbTree():New(aPosObj[2,1], aPosObj[2,2],aPosObj[2,3],aPosObj[2,4], oDlg,,,.T.,,,cColunas)
		oTree:lShowHint := .F.
		CompMontTr(oTree2,aEstruDest,NIL,NIL,aEstruOri)
		AAdd( aButtons, { "DBG09"      , { || CompLegend() }, STR0033 } )                //"Legenda"
		AAdd( aButtons, { ""           , { || oDlg:End(), slReabre := .T. }, STR0075 } ) //"Parâmetros"

		oTree:bChange  := {|| CompTreeCh(1, @oTree, @oTree2, @aEstruOri, @aEstruDest) }
		oTree2:bChange := {|| CompTreeCh(2, @oTree, @oTree2, @aEstruOri, @aEstruDest) }

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()} ,{||oDlg:End()},,aButtons)

Return Nil

/*/{Protheus.doc} CompTreeCh
Comparação: Ações do Change Tree com Posicionamento Conjunto nas Trees
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - nOpc	, numérico	, Identificador de Origem:
		  - 1 - Tree 1
		  - 2 - Tree 2
@param 02 - oTree		, objeto	, Tree da origem da comparacao
@param 03 - oTree2		, objeto	, Tree do destino da comparacao
@param 04 - aEstruOri	, array		, Array com os dados da estrutura origem da comparacao
@param 05 - aEstruDest	, array		, Array com os dados da estrutura destino da comparacao
@return Nil
/*/
Static Function CompTreeCh(nOpc, oTree, oTree2, aEstruOri, aEstruDest)

	Local lOldChange := slChanging

	If !slChanging .and. !slMontando
		slChanging := .T.
		If nOpc == 1
			CompNavega(3,@oTree,@oTree2,aEstruOri,aEstruDest)
		ElseIf nOpc == 2
			CompNavega(0,@oTree,@oTree2,aEstruOri,aEstruDest)
		EndIf
		slChanging := lOldChange
	Endif

Return Nil

/*/{Protheus.doc} CompExplo
Comparação: Faz a explosao de uma pre-estrutura para comparacao - Antiga M202Expl
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - cProduto	, caracter	, Código do produto
@param 02 - dDataRef	, data		, Data de referência para explosão do produto
@param 03 - cOpcionais 	, caracter	, Grupo de opcionais para explosao do produto
@param 04 - nQuantPai 	, numérico	, Quantidade base para explosão
@param 05 - aEstru 		, array		, Array com o retorno da pre-estrutura
@param 06 - nNivelEstr 	, caracter	, Nivel da pre-estrutura
@param 07 - mOpc		, memo		, Memo com os opcionais para conversão em array
@param 08 - cProdAnt	, caracter	, Código do produto anterior
@param 09 - cCargoPai	, caracter	, Campo CARGO do pai
@param 10 - nQuantPai2 	, numérico	, Quantidade base para explosão - desconsidera validade
@return .T.
/*/
Static Function CompExplo(cProduto, dDataRef, cOpcionais, nQuantPai, aEstru, nNivelEstr, mOpc, cProdAnt, cCargoPai, nQuantPai2)

	Local nReg         := 0
	Local nQuantItem   := 0
	Local nQuantIte2   := 1
	Local nHistorico   := 4
	Local cComp        := ""
	Local cTrt         := ""
	Local cOpcPar      := ""
	Local aOpc         := Str2Array(mOpc,.F.)
	Local nPos         := 0
	Local cCargo	   := ""

	Default cProdAnt   := PadR(cProduto,TamSX3("GG_COD")[1])
	Default cCargoPai  := ""
	Default nQuantPai2 := 1

	// Estrutura do array
	// [1] Produto PAI
	// [2] Componente
	// [3] TRT
	// [4] Quantidade Consumo
	// [5] Historico
	// [6] Nivel
	// [7] Cargo = [6]+[2]+[3]
	// [8] Cargo Pai
	// [9] Quantidade Original
	// [10] Quantidade Consumo - Desconsidera validade
	// [11] cProdAnt

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	dbSelectArea("SGG")
	SGG->(dbSetOrder(1))
	While SGG->(!Eof()) .And. SGG->(GG_FILIAL+GG_COD) == xFilial("SGG")+cProduto
		nReg := SGG->(Recno())

		//Calcula a qtd dos componentes
		nHistorico := 4
		cOpcPar    := cOpcionais
		If aOpc != Nil .And. Len(aOpc) > 0 .And. !Empty(SGG->GG_GROPC)
			nPos := aScan(aOpc,{|x| x[1] == cProdAnt+SGG->GG_COMP+SGG->GG_TRT})
			If nPos > 0
				cOpcPar := aOpc[nPos,2]
			Else
				cOpcPar := "*NAOENTRA*"
			EndIf
		EndIf

		nQuantItem := ExplEstr(nQuantPai,dDataRef,cOpcPar,NIL,@nHistorico,.T.)
		dbSelectArea("SGG")
		SB1->(dbSeek(xFilial("SB1")+SGG->GG_COMP))
		If QtdComp(nQuantItem) < QtdComp(0)
			nQuantItem := If(QtdComp(RetFldProd(SB1->B1_COD,"B1_QBP"))>0,RetFldProd(SB1->B1_COD,"B1_QBP"),1)
		EndIf

		nQuantIte2 := SGG->GG_QUANT * nQuantPai2
		cCargo     := StrZero(nNivelEstr,5,0)+SGG->GG_COMP+SGG->GG_TRT
		AADD(aEstru, { SGG->GG_COD,   ;
		               SGG->GG_COMP,  ;
		               SGG->GG_TRT,   ;
		               nQuantItem,    ;
		               nHistorico,    ;
		               nNivelEstr,    ;
		               cCargo,        ;
		               cCargoPai,     ;
		               SGG->GG_QUANT, ;
		               nQuantIte2,    ;
			       cProdAnt})
		cComp := SGG->GG_COMP
		cTrt  := SGG->GG_TRT

		//Verifica se existe sub-estrutura
		dbSelectArea("SGG")
		If dbSeek(xFilial("SGG")+SGG->GG_COMP)
			nNivelEstr++
			CompExplo(SGG->GG_COD, ;
			          dDataRef,    ;
			          cOpcionais,  ;
			          nQuantItem,  ;
			          aEstru,      ;
			          nNivelEstr,  ;
			          mOpc,        ;
			          cProdAnt + cComp + cTrt, ;
			          cCargo,      ;
			          nQuantIte2)
			nNivelEstr--
		EndIf

		SGG->(dbGoto(nReg))
		SGG->(dbSkip())
	EndDo

Return .T.

/*/{Protheus.doc} CompAjusAr
Compara e ajusta os arrays de origem e destino - Antiga Mt202CpAr
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - aEstruOri	, array		, Array com os dados pre-estrutura origem da comparacao
@param 02 - aEstruDest	, array		, Array com os dados pre-estrutura destino da comparaca
@param 03 - cCodOrig	, caracter	, Codigo do produto origem
@param 04 - cCoddest	, caracter	, Codigo do produto destino
@return .T.
/*/
Static Function CompAjusAr(aEstruOri, aEstruDest, cCodOrig, cCoddest)

	Local nz          := 0
	Local nw          := 0
	Local nAcho       := 0
	Local cProcura    := ""
	Local lFirstLevel := .F.
	Local nIndex      := 0
	Local nIndAux     := 0

	// Estrutura do array
	// [1] Produto PAI
	// [2] Componente
	// [3] TRT
	// [4] Quantidade Consumo
	// [5] Historico
	// [6] Nivel
	// [7] Cargo = [6]+[2]+[3]
	// [8] Cargo Pai
	// [9] Quantidade Original
	// [10] Quantidade Consumo - Desconsidera validade

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
			cProcura := aEstruDest[nz,1]+aEstruDest[nz,2]+aEstruDest[nz,3]
		EndIf

		// Efetua procura no array origem
		nAcho := aScan(aEstruOri, {|x| x[6] == aEstruDest[nz,6] .And. ;
		                               (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura) .And. ;
									   ComProdAnt(5, aEstruDest[nz,8], x[8] )})

		// Caso nao achou soma componentes no array origem com a pre-estrutura do item
		If nAcho == 0
			For nw := nz to Len(aEstruDest)
				AADD(aEstruOri, { If( lFirstLevel, If(Len(aEstruOri) > 0, aEstruOri[1,1], cCodOrig), aEstruDest[nw,1] ), ;
				    aEstruDest[nw,2], ;
				    aEstruDest[nw,3], ;
				    aEstruDest[nw,4], ;
				    5,                ;
				    aEstruDest[nw,6], ;
				    aEstruDest[nw,7], ;
				    aEstruDest[nw,8], ;
				    aEstruDest[nw,9], ;
				    aEstruDest[nw,10],;
				    aEstruDest[nw,11] })

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
			cProcura := aEstruOri[nz,1]+aEstruOri[nz,2]+aEstruOri[nz,3]
		EndIf

		// Efetua procura no array origem
		nAcho := aScan(aEstruDest, {|x| x[6] == aEstruOri[nz,6] .And. ;
		                                (If(lFirstLevel,x[2]+x[3],x[1]+x[2]+x[3]) == cProcura) .And. ;
										ComProdAnt(5, aEstruOri[nz,8], x[8] )})
		// Caso nao achou soma componentes no array origem com a pre-estrutura do item
		If nAcho == 0
			For nw := nz to Len(aEstruOri)
				AADD(aEstruDest, { If( lFirstLevel, If(Len(aEstruDest) > 0, aEstruDest[1,1], cCodDest), aEstruOri[nw,1] ), ;
				                   aEstruOri[nw,2], ;
				                   aEstruOri[nw,3], ;
				                   aEstruOri[nw,4], ;
				                   5,               ;
				                   aEstruOri[nw,6], ;
				                   aEstruOri[nw,7], ;
				                   aEstruOri[nw,8], ;
				                   aEstruOri[nw,9], ;
								   aEstruOri[nw,10],;
				                   aEstruOri[nw,11]})
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
	ASORT(aEstruOri,,, {|x,y| x[7]+X[8] < y[7]+y[8] })
	ASORT(aEstruDest,,,{|x,y| x[7]+X[8] < y[7]+y[8] })

	For nIndex := 1 to Len(aEstruOri)
		//Corrige Cargo Pai do array aEstruOri
		nIndAux := aScan(aEstruOri, {|x| x[8] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][11], x[11]) })
		While nIndAux > 0
			aEstruOri[nIndAux][8]  := aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
			nIndAux := aScan(aEstruOri, {|x| x[8] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][11], x[11]) })
		EndDo

		//Corrige Cargo Pai do array aEstruDest
		nIndAux := aScan(aEstruDest, {|x| x[8] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][11], x[11]) })
		While nIndAux > 0
			aEstruDest[nIndAux][8] := aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
			nIndAux := aScan(aEstruDest, {|x| x[8] == aEstruOri[nIndex][7] .AND. ComProdAnt(1, aEstruOri[nIndex][11], x[11]) })
		EndDo

		//Corrige Cargo do array aEstruDest
		nIndAux := aScan(aEstruDest, {|x| x[7] == aEstruOri[nIndex][7] .AND. x[8] == aEstruOri[nIndex][8] .AND. ComProdAnt(2, x[11], aEstruOri[nIndex][11]) })
		While nIndAux > 0
			aEstruDest[nIndAux][7]	:= aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
			nIndAux := aScan(aEstruDest, {|x| x[7] == aEstruOri[nIndex][7] .AND. x[8] == aEstruOri[nIndex][8] .AND. ComProdAnt(2, x[11], aEstruOri[nIndex][11]) })
		EndDo

		//Corrige Cargo do array aEstruOri
		aEstruOri[nIndex][7]	    := aEstruOri[nIndex][2]  + aEstruOri[nIndex][3]  + PadR(nIndex, 5)
	Next nIndex

Return .T.

/*/{Protheus.doc} ComProdAnt()
Compara árvore cProdAnt do produto desconsiderando o produto PAI
@author brunno.costa
@since 28/11/2018
@version 1.0
@param 01 - nOpc , numérico, indicador do local de chamada
@param 02 - cAnt1, caracter, cProdAnt 1 para comparação
@param 03 - cAnt2, caracter, cProdAnt 2 para comparação
@return lReturn  , lógico  , resultado da comparação entre cAnt1 e cAnt2
/*/
Static Function ComProdAnt(nOpc, cAnt1, cAnt2)

	Local lReturn := .F.

	cAnt1 := Substring(cAnt1, snTamComp + 1, Len(cAnt1) - snTamComp)
	cAnt2 := Substring(cAnt2, snTamComp + 1, Len(cAnt1))
	lReturn := cAnt1 == cAnt2

Return lReturn

/*/{Protheus.doc} CompMontTr
Comparação: Monta o objeto TREE - FUNCAO RECURSIVA - Antiga A202TreeCm
@author brunno.costa
@since 27/11/2018
@version 1.0
@param 01 - oObjTree	, objeto	, Objeto tree utilizado
@param 02 - aEstru		, array		, Array com os dados da pre-estrutura
			{SGG->GG_COD, SGG->GG_COMP, SGG->GG_TRT, nQuantItem, nHistorico, nNivelEstr, StrZero(nNivelEstr,5,0)+SGG->GG_COMP+SGG->GG_TRT}
@param 03 - cCargoPai	, caracter	, Código do Cargo do Pai
@param 04 - nz			, numérico	, Posicao do array de pre-estrutura utilizado
@param 05 - aEstru2		, array		, Array com os dados da OUTRA pre-estrutura
@param 06 - cProdAnt	, caracter	, Chave Produto + TRT Anteriores - Concatenados
@return .T.
/*/
Static Function CompMontTr(oObjTree, aEstru, cCargoPai, nz, aEstru2, cProdAnt)

	Local nAcho       := 0
	Local aOcorrencia := {}
	Local cTexto      := ""
	Local cCargoVazio := Space(Len(SGG->GG_COMP+SGG->GG_TRT)+5)
	Local lMontouTree := .F.
	Local nTipo       := 2

	Default nz        := 1
	Default cCargoPai := ""
	Default cProdAnt  := ""

	// Ordem de pesquisa por codigo
	SB1->(dbSetOrder(1))

	// Array com as ocorrencias cadastradas
	AADD(aOcorrencia,"PMSTASK4") 	//"Componente fora das datas inicio / fim"
	AADD(aOcorrencia,"PMSTASK5") 	//"Componente fora dos grupos de opcionais"
	AADD(aOcorrencia,NIL) 			//"Componente fora das revisoes" - Nao existe na pre-estrutura
	AADD(aOcorrencia,"PMSTASK6") 	//"Componente ok"
	AADD(aOcorrencia,"PMSTASK1") 	//"Componente nao existente"
	AADD(aOcorrencia,"PMSTASK3") 	//"Componente ok - Quantidade diferente"

	// Monta tree na primeira vez
	If !lMontouTree .AND. Empty(cCargoPai) .And. Len(aEstru) > 0
		cCargoPai := aEstru[1,8]
		cProdAnt  := aEstru[1,11]
		oObjTree:BeginUpdate()
		oObjTree:Reset()
		oObjTree:EndUpdate()

		// Coloca titulo no TREE
		SB1->(dbSeek(xFilial("SB1")+aEstru[1,1]))
		oObjTree:AddTree(AllTrim(aEstru[1,1])+;
						";"+Alltrim(Substr(SB1->B1_DESC,1,30))+ Space(40)+;
						";"+AllTrim(aEstru[1,3])+;
						Iif(slValQtde,";;"+Transform(1, scPicQuant),"");
						,.T.,,,aOcorrencia[4],aOcorrencia[4],cCargoVazio)

		lMontouTree := .T.
	EndIf

	While nz <= Len(aEstru)
		// Verifica se componente tem pre-estrutura
		nAcho := aScan(aEstru,{|x| x[8] == aEstru[nz,7]})
		// Monta Texto
		SB1->(dbSeek(xFilial("SB1")+aEstru[nz,2]))
		cTexto := Alltrim(aEstru[nz,2])+;
				  ";"+Alltrim(Substr(SB1->B1_DESC,1,30))+;
				  ";"+AllTrim(aEstru[nz,3])+;
				  Iif(slValQtde,";"+Transform(aEstru[nz,9], scPicQuant)+;
				  ";"+Transform2(aEstru[nz,10]),"")

		//Avalia Quantidade
		If slValQtde .and. aEstru[nz,5] == 4
			If aEstru[nz,9]  != aEstru2[nz,9]
				aEstru[nz,5] := 6
			EndIf
		EndIf

		If aEstru[nz,8] == cCargoPai .AND. ComProdAnt(4, aEstru[nz,11], cProdAnt)
			If nAcho > 0
				oObjTree:AddItem(cTexto, aEstru[nz,7], , , aOcorrencia[aEstru[nz,5]], aOcorrencia[aEstru[nz,5]], nTipo )
				oObjTree:TreeSeek(aEstru[nz,7])

				// Chama funcao recursiva
				CompMontTr(oObjTree, aEstru, aEstru[nz,7], nAcho, aEstru2, aEstru[nz,11]+aEstru[nz,2]+aEstru[nz,3])
				oObjTree:TreeSeek(aEstru[nz,7])
				oObjTree:PTCollapse()
			Else
				// Adiciona item no tree
				oObjTree:AddItem(cTexto, aEstru[nz,7], , , aOcorrencia[aEstru[nz,5]], aOcorrencia[aEstru[nz,5]], nTipo )
				oObjTree:TreeSeek(aEstru[nz,7])
			EndIf
			If nTipo == 2
				nTipo := 1
			EndIf
		EndIf
		nz++
	End

	If lMontouTree
		oObjTree:EndTree()
		oObjTree:TreeSeek(cCargoVazio)
	EndIf

Return .T.

/*/{Protheus.doc} Transform2()
Transforma valor recebido no padrão de casas decimais do campo GG_QUANT
- Constroi picture variável de acordo com o valor recebido
@author brunno.costa
@since 03/12/2018
@version 1.0
@param 01 - nValor, numérico, valor a ser transformado;
/*/
Static Function Transform2(nValor)

Return Transform( nValor, ("@E "+ PadL( ("9." + PadL('9', snDecQuant,'9')), (Len(cValToChar(Int(nValor)))+snDecQuant+1), '9')) )

/*/{Protheus.doc} CompNavega
Comparação: Mantem o posicionamento das duas pre-estruturas - Antiga Mt202Nav
@author brunno.costa
@since 27/11/2018
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
@return .T.
/*/
Static Function CompNavega(nTipo, oTree, oTree2, aEstruOri, aEstruDest)

	Local cCargoAtu   := oTree2:GetCargo()
	Local cCargoVazio := Space(5+Len(SGG->GG_COMP+SGG->GG_TRT))
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
		cCargoAtu := oTree:GetCargo()
		nPos      := aScan(aEstruDest,{|x| x[7] == cCargoAtu})
		oTree2:TreeSeek(If(nPos>0, aEstruDest[nPos,7], cCargoVazio))
		oTree:TreeSeek(oTree:GetCargo())

	//Reposiciona a Tree com base na Tree 2
	Else
		nPos := aScan(aEstruOri,{|x| x[7] == cCargoAtu})
		oTree:TreeSeek( If(nPos>0, aEstruOri[nPos,7] , cCargoVazio))
		oTree2:TreeSeek(oTree2:GetCargo())
	EndIf
	slChanging := lOldChange

	oTree:Refresh()
	oTree2:Refresh()

Return .T.

/*/{Protheus.doc} CompLegend
Legenda do Comparador de estruturas - Antiga Mt202Inf
@author brunno.costa
@since 27/11/2018
@version 1.0
@return .T.
/*/
Static Function CompLegend()

	Local oDlg
	Local oBmp1
	Local oBmp2
	Local oBmp4
	Local oBmp5
	Local oBut1

	DEFINE MSDIALOG oDlg TITLE STR0033 OF oMainWnd PIXEL FROM 0,0 TO 202,550
	@ 02, 003 TO 080,273 LABEL STR0033 PIXEL        //"Legenda"
	@ 18, 010 BITMAP oBmp1 RESNAME "PMSTASK1" SIZE 16,16 NOBORDER PIXEL
	@ 18, 020 SAY OemToAnsi(STR0071) OF oDlg PIXEL  //Componente Não Existe
	@ 18, 150 BITMAP oBmp2 RESNAME "PMSTASK6" SIZE 16,16 NOBORDER PIXEL
	@ 18, 160 SAY OemToAnsi(STR0072) OF oDlg PIXEL  //"Componente Ok"
	@ 30, 010 BITMAP oBmp4 RESNAME "PMSTASK5" SIZE 16,16 NOBORDER PIXEL
	@ 30, 020 SAY OemToAnsi(STR0073) OF oDlg PIXEL  //"Componente Fora Dos Grupos De Opcionais"

	If slValQtde
		@ 30, 150 BITMAP oBmp2 RESNAME "PMSTASK3" SIZE 16,16 NOBORDER PIXEL
		@ 30, 160 SAY OemToAnsi(STR0080) OF oDlg PIXEL  //"Componente ok - Quantidade diferente"
	EndIf

	@ 42, 010 BITMAP oBmp5 RESNAME "PMSTASK4" SIZE 16,16 NOBORDER PIXEL
	@ 42, 020 SAY OemToAnsi(STR0074) OF oDlg PIXEL  //"Componente Fora Das Datas Início / Fim"

	DEFINE SBUTTON oBut1 FROM 085,244 TYPE 1  ACTION (oDlg:End())  ENABLE of oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

/*/{Protheus.doc} Expandir
Executa ação Expandir do menu de contexto
@author Marcelo Neumann
@since 04/11/2018
@version 1.0
@param cCargoPai, characters, código cCargoPai a ser expandido
@return Nil
/*/
Static Function Expandir(cCargoPai)

	Local oProcess
	Local oModel    := FWModelActive()
	Local oEvent    := gtMdlEvent(oModel, "PCPA135EVDEF")

	Default cCargoPai := soDbTree:GetCargo()

	oEvent:lExpandindo := .T.
	oProcess := MSNewProcess():New( { |lEnd| oProcess:SetRegua2(0), ExpandirL(cCargoPai, 1, @lEnd, @oProcess) }, ;
	                                STR0086, ;     //"Aguarde..."
					STR0087, .T. ) //"Expandindo os registros"
	oProcess:Activate()
	oEvent:lExpandindo := .F.

	slCriaTemp := .T.
	soDbTree:TreeSeek(cCargoPai)
	P135TreeCh(.F.)

Return Nil

/*/{Protheus.doc} ExpandirL
Trecho Loop da Ação Expandir do Menu de Contexto
@author Marcelo Neumann
@since 04/11/2018
@version 1.0
@param 01 cCargoPai , characters, código cCargoPai a ser expandido
@param 02 nRecursiva, numeric   , contator de chamadas recursivas
@param 03 lEnd      , logical   , variável recebida por referência utilizada no cancelamentoda expansão
@param 04 oProcess  , object    , objeto barra de processamento
@param 05 nRegistros, numeric   , contador de registros avaliados
@param 06 nNumEstrut, numeric   , contador de estruturas avaliadas
@return Nil
/*/
Static Function ExpandirL(cCargoPai, nRecursiva, lEnd, oProcess, nRegistros, nNumEstrut)

	Local oModel   := FwModelActive()
	Local nIndAux  := 0
	Local nIndTree := 0
	Local cCargo   := ""

	Default cCargoPai  := soDbTree:GetCargo()
	Default nRecursiva := 1
	Default nRegistros := 0
	Default nNumEstrut := 0

	nIndTree := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargoPai })
	If nIndTree > 0
		nNumEstrut++
		oProcess:SetRegua1(oModel:GetModel("GRID_DETAIL"):Length())

		While nIndTree > 0 .AND. !lEnd
			nRegistros++
			cCargo := saCargos[nIndTree][IND_ACARGO_CARGO_COMP]
			oProcess:IncRegua1(STR0088 + AllTrim(P135RetInf(cCargo,"PAI" )) + " (" + cValToChar(nNumEstrut) + STR0089 + ")" ) //"Estrutura: " - " estruturas"
			oProcess:IncRegua2(STR0090 + AllTrim(P135RetInf(cCargo,"COMP")) + " (" + cValToChar(nRegistros) + STR0091 + ")" ) //"Checando: " - " registros"

			If ExistEstru(P135RetInf(cCargo,"COMP"))
				If soDbTree:TreeSeek(cCargo)
					slCriaTemp := .F.
					P135TreeCh(.F.)

					//A Cada 10 estruturas, aguarda 0,5 segundos para funcionar botão cancelar
					If Mod(nNumEstrut, 10) == 0
						Sleep(500)
					EndIf

					ExpandirL(cCargo, nRecursiva + 1, @lEnd, @oProcess, @nRegistros, @nNumEstrut)
				EndIf
			EndIf

			nIndAux  := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargoPai }, (nIndTree + 1))
			nIndTree := nIndAux

			//A Cada 500 registros, aguarda 0,5 segundos para funcionar botão cancelar
			If Mod(nRegistros, 500) == 0
				Sleep(500)
			EndIf
		EndDo
	EndIf

Return Nil

/*/{Protheus.doc} Recolher
Executa ação Recolher do menu de contexto
@author Marcelo Neumann
@since 04/11/2018
@version 1.0
@param 01 cCargoPai, characters, código cCargoPai a ser expandido
@return Nil
/*/
Static Function Recolher(cCargoPai)

	Local oProcess

	Default cCargoPai := soDbTree:GetCargo()

	oProcess := MSNewProcess():New( { |lEnd| oProcess:SetRegua2(0), RecolherP(cCargoPai, @lEnd, @oProcess) }, ;
	                                STR0086, ;     //"Aguarde..."
					STR0092, .T. ) //"Recolhendo os registros"

	oProcess:Activate()

	soDbTree:TreeSeek(cCargoPai)
	P135TreeCh(.F.)

Return Nil

/*/{Protheus.doc} RecolherP
Processamento da Ação Recolher do Menu de Contexto
@author Marcelo Neumann
@since 04/11/2018
@version 1.0
@param cCargoPai, characters, código cCargoPai a ser expandido
@param lEnd     , logic     , variável recebida por referência utilizada no cancelamentoda expansão
@param oProcess , object    , objeto barra de processamento
@return Nil
/*/
Static Function RecolherP(cCargoPai, lEnd, oProcess)

	Local nIndTree   := 0
	Local nIndAux    := 0
	Local cCargo     := ""
	Local oModel     := FwModelActive()
	Local nRegistros := 0
	Local nNumEstrut := 0

	Default cCargoPai := soDbTree:GetCargo()

	nIndTree := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargoPai })
	If nIndTree > 0
		nNumEstrut++
		oProcess:SetRegua1(oModel:GetModel("GRID_DETAIL"):Length())

		While nIndTree > 0 .AND. !lEnd
			nRegistros++
			cCargo	 := saCargos[nIndTree][IND_ACARGO_CARGO_COMP]
			nIndAux  := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargo })

			If nIndAux > 0
				oProcess:IncRegua1(STR0088 + AllTrim(P135RetInf(cCargo,"PAI" )) + " (" + cValToChar(nNumEstrut) + STR0089 + ")" ) //"Estrutura: " - " estruturas"
				oProcess:IncRegua2(STR0093 + AllTrim(P135RetInf(cCargo,"COMP")) + " (" + cValToChar(nRegistros) + STR0091 + ")" ) //"Recolhendo: " - " registros"
				If soDbTree:TreeSeek(cCargo)
					soDbTree:PTCollapse()
				EndIf
			EndIf

			nIndAux  := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargoPai }, (nIndTree + 1))
			nIndTree := nIndAux
		EndDo
	EndIf

Return

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
	Local oMdlPai := oModel:GetModel("FLD_MASTER")

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
	Default cProduto := SGG->GG_COD

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))
Return RetFldProd(cProduto,"B1_QBP")

/*/{Protheus.doc} A135Copia
Copia de Estruturas e Pré-Estruturas
@author brunno.costa
@since 14/11/2018
@version 1.0
/*/
Function A135Copia()

	Local oModelAux     := FWLoadModel("PCPA135")
	Private cProdFiltro := "MV_PAR02"

	//Chama Pergunte PCPA135C
	soEveDef := Iif(soEveDef == Nil, PCPA135EVDEF():New(), soEveDef)
	If !soEveDef:PerguntaPCPA135C(.T.)
		Return
	EndIf

	soEveDef:lCopia := .T.
	FWExecView(STR0119, "PCPA135", MODEL_OPERATION_INSERT,,,{|| .T.},,,,,,oModelAux) //"Pré-Estrutura Similar"
	soEveDef:lCopia := .F.

	//Ponto de Entrada para alteracao da Pre-Estrutura Similar
	If ExistBlock('MT202CSI')
		//-- Sao passados os seguintes parametros:
		//-- aParamIXB[1] = Codigo do Produto
		//-- aParamIXB[2] = Codigo do Produto Similar
		ExecBlock('MT202CSI', .F., .F., {MV_PAR02, MV_PAR04})
	EndIf

Return

/*/{Protheus.doc} isRunAuto
Identifica se o programa está sendo executado por rotina automática ou por tela.

@type  Static Function
@author ricardo.prandi
@since 26/12/2018
@version P12
@param oModel, object, Modelo de dados do programa PCPA135
@return lRet, logical, Indica se o programa está sendo executado por execução automática.
/*/
Static Function isRunAuto(oModel)

	Local lRet := .F.
	Local oSubMdl

	If oModel:GetId() != "FLD_MASTER"
		oSubMdl := oModel:GetModel():GetModel("FLD_MASTER")
	Else
		oSubMdl := oModel
	EndIf

	If oSubMdl:GetValue("CEXECAUTO") == "S"
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} ExecutAuto
Faz a execução automática do cadastro de estruturas, de acordo com os parâmetros recebidos.

@author ricardo.prandi
@since 26/12/2018
@version 12
@param aAutoCab  , array  , Array com as informações do cabeçalho do programa
                            e com parâmetros adicionais para identificar alguns comportamentos do programa.
@param aAutoItens, array  , Array com as informações dos componentes que serão modificados.
                            Para a operação de Exclusão, este array não é considerado.
@param nOpcAuto  , numeric, Opção que será utilizada na execução automática. 3-Inclusão, 4-Modificação, 5-Exclusão.
							6-Encaminhar Aprovação, 7-Aprovar, 8-Rejeitar, 9-Criar Estrutura.
@return Nil
/*/
STATIC FUNCTION ExecutAuto(aAutoCab, aAutoItens, nOpcAuto)

	Local aLinPos   := {}
	Local aSeekLine := {}
	Local cCargo    := ""
	Local cMsgErro  := ""
	Local cMsgSoluc := ""
	Local cPaiAnt   := ""
	Local lAprova   := .F.
	Local lOk       := .T.
	Local nIndField := 0
	Local nIndLine  := 0
	Local nIndSeek  := 0
	Local nLinPos   := 0
	Local nPos      := 0
	Local nPosCmp   := 0
	Local nTamCod   := GetSx3Cache("GG_COD","X3_TAMANHO")
	Local oModel    := Nil
	Local oModelCab := Nil
	Local oModelDet := Nil
	Local oStruCab  := Nil
	Local oStruDet  := Nil
	Local xValue

	// Quando opção selecionada estiver entre 6 e 9, não executa os models (6-Encaminhar Aprovação, 7-Aprovar, 8-Rejeitar, 9-Criar Estrutura.)
	If nOpcAuto >= 6 .and. nOpcAuto <= 9
		lAprova := .T.
	EndIf

	If !lAprova
		oModel    := FwLoadModel("PCPA135")
		oModelCab := oModel:GetModel("FLD_MASTER")
		oModelDet := oModel:GetModel("GRID_DETAIL")
		oStruCab  := oModelCab:GetStruct()
		oStruDet  := oModelDet:GetStruct()
		//Altera o inicializador padrão do campo virtual 'CEXECAUTO', para que a rotina consiga identificar que é uma execução automática.
		oStruCab:SetProperty("CEXECAUTO",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD, "'S'"))
	EndIf

	//INCLUSÃO
	If nOpcAuto == 3
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()

		//Preenche as informações do cabeçalho.
		For nIndField := 1 To Len(aAutoCab)
			//Verifica se o campo existe no modelo
			If oStruCab:HasField(aAutoCab[nIndField][1])
				lOk := soEveDef:SetaValor(oModelCab,aAutoCab[nIndField][1],aAutoCab[nIndField][2])
				If !lOk
					Exit
				EndIf
			EndIf
		Next nIndField

	ElseIf nOpcAuto == 4
		//Busca o código do produto PAI para exclusão da estrutura
		nPos := aScan(aAutoCab, {|x| x[1] == "GG_COD"})
		If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
			lOk := .F.
			Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
		Else
			SGG->(dbSetOrder(1))
			If !SGG->(dbSeek(xFilial("SGG")+PadR(aAutoCab[nPos][2],nTamCod)))
				lOk := .F.
				Help(' ',1,"HELP" ,,STR0122,2,0,,,,,, {STR0123}) //"Produto informado não possui estrutura." //"Alteração não permitida."
			EndIf
		EndIf
		If lOk
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()

			//Adiciona o produto PAI.
			cCargo := P135AddPai(oModelCab:GetValue("GG_COD"))

			//Carrega os componentes
			P135TreeCh(.F.,cCargo)
		EndIf
	EndIf

	If lOk .And. (nOpcAuto == 3 .Or. nOpcAuto == 4)
		//Verifica se recebeu a quantidade base, e altera o valor no modelo.
		nPos := aScan(aAutoCab,{|x| x[1] == 'GG_QUANT'})
		If nPos > 0
			lOk := soEveDef:SetaValor(oModelCab,"NQTBASE",aAutoCab[nPos][2])
		EndIf

		If lOk
			//Se conseguiu atribuir as informações do produto pai, carrega os componentes
			For nIndLine := 1 To Len(aAutoItens)
				//Verifica se o código do produto PAI está informado.
				nPosCmp := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_COD"})
				If nPosCmp <= 0 .Or. (nPosCmp > 0 .And. Empty(aAutoItens[nIndLine][nPosCmp][2]))
					lOk := .F.
					Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
					Exit
				ElseIf nIndLine == 1
					//Se é o primeiro item do array a ser processado, inicializa a variável de controle cPaiAnt
					//com o código do primeiro PAI do array.
					cPaiAnt := PadR(aAutoItens[nIndLine][nPosCmp][2],nTamCod)
				EndIf

				//Verifica se mudou o código do produto PAI
				If PadR(cPaiAnt,nTamCod) != PadR(aAutoItens[nIndLine][nPosCmp][2],nTamCod) .Or. (nIndLine == 1 .And. cPaiAnt != oModelCab:GetValue("GG_COD"))
					cPaiAnt := PadR(aAutoItens[nIndLine][nPosCmp][2],nTamCod)
					//Se o produto pai já existir carregado, busca o CARGO para adicionar novo componente
					nPos := aScan(saCargos,{|x| x[IND_ACARGO_PAI] == cPaiAnt})
					If nPos > 0
						cCargo := saCargos[nPos][IND_ACARGO_CARGO_PAI]
					Else
						//Produto pai ainda não está carregado. Monta um novo cargo para ele.
						cCargo := P135AddPai(cPaiAnt)
					EndIf
					//Executa a função P135TreeCh para carregar como produto pai o código recebido por parâmetro.
					P135TreeCh(.F.,cCargo)
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
							HELP(' ',1,"HELP" ,,STR0124 + STR0127 + AllTrim(aLinPos[nIndSeek]) + STR0125,2,0,,,,,, {STR0126}) //"Parâmetros informados no LINPOS estão incorretos. Campo " + AllTrim(aLinPos[nIndSeek]) + " não existe." //"Ajuste os parâmetros utilizados no LINPOS."
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
					If !oModelDet:SeekLine(aSeekLine)
						HELP(' ',1,"HELP" ,,STR0124 + STR0128,2,0,,,,,, {STR0126}) //"Parâmetros informados no LINPOS estão incorretos. Registro não encontrado." //"Ajuste os parâmetros utilizados no LINPOS."
						lOk := .F.
						Exit
					EndIf
				Else
					//Verifica se é necessário adicionar uma nova linha na grid.
					If (oModelDet:Length() == 1 .And. !Empty(oModelDet:GetValue("GG_COMP"))) .Or. oModelDet:Length() > 1
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
					//GG_COMP
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_COMP"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					Else
						lOk := .F.
						Help(' ',1,"HELP" ,,STR0129,2,0,,,,,, {STR0130})  //"Código do componente não informado." //"Informe o código do componente para prosseguir com a operação."
						Exit
					EndIf

					//GG_TRT
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_TRT"})
					If nPos > 0 .And. aAutoItens[nIndLine][nPos][2] != Nil
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//GG_QUANT
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_QUANT"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//GG_INI
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_INI"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//GG_FIM
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_FIM"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//GG_GROPC
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_GROPC"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//GG_OPC
					nPos := aScan(aAutoItens[nIndLine],{|x| x[1] == "GG_OPC"})
					If nPos > 0 .And. !Empty(aAutoItens[nIndLine][nPos][2])
						lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nPos][1],aAutoItens[nIndLine][nPos][2])
						If !lOk
							Exit
						EndIf
					EndIf

					//Atribui as informações do componente no modelo
					For nIndField := 1 To Len(aAutoItens[nIndLine])
						If aAutoItens[nIndLine][nIndField][1] $ "|GG_COMP|GG_TRT|GG_QUANT|GG_INI|GG_FIM|GG_GROPC|GG_OPC|"
							Loop
						EndIf
						If oStruDet:HasField(aAutoItens[nIndLine][nIndField][1])
							lOk := soEveDef:SetaValor(oModelDet,aAutoItens[nIndLine][nIndField][1],aAutoItens[nIndLine][nIndField][2])
						EndIf
						If !lOk
							Exit
						EndIf
					Next nIndField
				EndIf

				If !lOk
					Exit
				EndIf

				lOk := oModelDet:VldLineData()
				If !lOk
					Exit
				EndIf
			Next nIndLine
		EndIf
	ElseIf nOpcAuto == 5 //Exclusão
		//Busca o código do produto PAI para exclusão da estrutura
		nPos := aScan(aAutoCab, {|x| x[1] == "GG_COD"})
		If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
			lOk := .F.
			Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
		Else
			SGG->(dbSetOrder(1))
			If SGG->(dbSeek(xFilial("SGG")+PadR(aAutoCab[nPos][2],nTamCod)))
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				oModel:Activate()
			Else
				lOk := .F.
				Help(' ',1,"HELP" ,,STR0122,2,0,,,,,, {STR0131}) //"Produto informado não possui estrutura." //"Exclusão não permitida."
			EndIf
		EndIf
	ElseIf nOpcAuto == 6 // Encaminhar Aprovação
		If SuperGetMV("MV_APRESTR",.F.,.F.)
			nPos := aScan(aAutoCab, {|x| x[1] == "GG_COD"})
			If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
				lOk := .F.
				Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
			Else
				SGG->(dbSetOrder(1))
				If !SGG->(dbSeek(xFilial("SGG")+PadR(aAutoCab[nPos][2],nTamCod)))
					lOk := .F.
					Help(' ',1,"HELP" ,,STR0122,2,0,,,,,, {STR0123}) //"Produto informado não possui estrutura." //"Alteração não permitida."
				EndIf
			EndIf
			If lOk
				P135Aprova("E", aAutoCab)
			EndIf
		Else
			lOk := .F.
			cMsgErro := STR0296 			// "Operação não permitida devido ao parâmetro "
			cMsgErro += "MV_APRESTR"
			cMsgSoluc := STR0297  			// "Altere o parâmetro "
			cMsgSoluc += "MV_APRESTR"
			cMsgSoluc += STR0298 			// " para utilizar esta operação"
			Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {cMsgSoluc})
		EndIf
	ElseIf nOpcAuto == 7 // Aprovar
		If !SuperGetMV("MV_APRESTR",.F.,.F.)
			nPos := aScan(aAutoCab, {|x| x[1] == "GG_COD"})
			If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
				lOk := .F.
				Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
			Else
				SGG->(dbSetOrder(1))
				If !SGG->(dbSeek(xFilial("SGG")+PadR(aAutoCab[nPos][2],nTamCod)))
					lOk := .F.
					Help(' ',1,"HELP" ,,STR0122,2,0,,,,,, {STR0123}) //"Produto informado não possui estrutura." //"Alteração não permitida."
				EndIf
			EndIf
			If lOk
				P135Aprova("A", aAutoCab)
			EndIf
		Else
			lOk := .F.
			cMsgErro := STR0296 			// "Operação não permitida devido ao parâmetro "
			cMsgErro += "MV_APRESTR"
			cMsgSoluc := STR0297  			// "Altere o parâmetro "
			cMsgSoluc += "MV_APRESTR"
			cMsgSoluc += STR0298 			// " para utilizar esta operação"
			Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {cMsgSoluc})
		EndIf
	ElseIf nOpcAuto == 8 // Rejeitar
		If !SuperGetMV("MV_APRESTR",.F.,.F.)
			nPos := aScan(aAutoCab, {|x| x[1] == "GG_COD"})
			If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
				lOk := .F.
				Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
			Else
				SGG->(dbSetOrder(1))
				If !SGG->(dbSeek(xFilial("SGG")+PadR(aAutoCab[nPos][2],nTamCod)))
					lOk := .F.
					Help(' ',1,"HELP" ,,STR0122,2,0,,,,,, {STR0123}) //"Produto informado não possui estrutura." //"Alteração não permitida."
				EndIf
			EndIf
			If lOk
				P135Aprova("R", aAutoCab)
			EndIf
		Else
			lOk := .F.
			cMsgErro := STR0296 			// "Operação não permitida devido ao parâmetro "
			cMsgErro += "MV_APRESTR"
			cMsgSoluc := STR0297  			// "Altere o parâmetro "
			cMsgSoluc += "MV_APRESTR"
			cMsgSoluc += STR0298 			// " para utilizar esta operação"
			Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {cMsgSoluc})
		EndIf
	ElseIf nOpcAuto == 9 // Criar Estrutura 
		nPos := aScan(aAutoCab, {|x| x[1] == "GG_COD"})
			If nPos <= 0 .Or. (nPos > 0 .And. Empty(aAutoCab[nPos][2]))
				lOk := .F.
				Help(' ',1,"HELP" ,,STR0120,2,0,,,,,, {STR0121}) //"Código do produto PAI não informado." //"Informe o código do produto PAI para prosseguir com a operação."
			Else
				SGG->(dbSetOrder(1))
				If !SGG->(dbSeek(xFilial("SGG")+PadR(aAutoCab[nPos][2],nTamCod)))
					lOk := .F.
					Help(' ',1,"HELP" ,,STR0122,2,0,,,,,, {STR0123}) //"Produto informado não possui estrutura." //"Alteração não permitida."
				EndIf
			EndIf
			If lOk
				P135CriaEs(aAutoCab)
			EndIf
	EndIf

	If !lAprova
		//Efetiva os dados.
		If lOk
			oModel:lModify := .T.

			If oModel:VldData(,.T.)
				lOk := oModel:CommitData()
			EndIF
		EndIf

		//Verifica se existe alguma mensagem de erro no modelo.
		If oModel:HasErrorMessage()
			TratMsgErr(oModel)
			lOk := .F.
		EndIf

		//Desativa o modelo.
		If oModel:IsActive()
			oModel:DeActivate()
		EndIf
		oModel:Destroy()
	EndIf

	P135IniStc()

Return Nil

/*/{Protheus.doc} TratMsgErr
Trata a mensagem de erro do modelo para o Help (ExecAuto)
@author ricardo.prandi
@since  27/12/2018
@version 1
@param oModel, object, modelo principal
@return Nil
/*/
Static Function TratMsgErr(oModel)
	Local aError   := oModel:GetErrorMessage()
	Local cMsg     := ""
	Local cErro    := AllTrim(aError[MODEL_MSGERR_MESSAGE])
	Local cCampo   := AllTrim(aError[MODEL_MSGERR_IDFIELDERR])
	Local cValor   := AllTrim(aError[MODEL_MSGERR_VALUE])
	Local cSolucao := AllTrim(aError[MODEL_MSGERR_SOLUCTION])

	cMsg := cErro

	If !Empty(cCampo)
		cMsg += " (" + cCampo

		If !Empty(cValor)
			cMsg += " = " + cValor
		EndIf

		cMsg += ")"
	Else
		If !Empty(cValor)
			cMsg += " (" + cValor + ")"
		EndIf
	EndIf

	cMsg += ". " + cSolucao

	Help( , , "Help", , cMsg, 1, 0, , , , , , {} )
Return

/*/{Protheus.doc} ProximoTrt
Busca a próxima Sequência para gravar no campo TRT
@author Marcelo Neumann
@since 14/12/2018
@version 1.0
@param 01 oMdlDet, object    , modelo da Grid com os componentes
@param 02 cPai   , characters, código do produto Pai
@param 03 cComp  , characters, código do componente
@return cProxTrt, characters, próxima sequência que pode ser utilizada
/*/
Static Function ProximoTrt(oMdlDet, cPai, cComp)

	Local nInd      := 0
	Local nTamTrt   := GetSx3Cache("GG_TRT","X3_TAMANHO")
	Local cMaxTrtBd := Space(nTamTrt)
	Local cProxTrt  := Space(nTamTrt)
	Local cQuery    := ""
	Local lExiste   := .F.

	//Se estiver ocultando os inválidos, valida a TRT com o Banco de Dados
	If soEveDef:nExibeInvalidos == 2
		cQuery := "SELECT MAX(GG_TRT) MAXTRT"
		cQuery +=  " FROM " + RetSqlName('SGG') + " SGG"
		cQuery += " WHERE SGG.GG_FILIAL  = '" + xFilial("SGG") + "'"
		cQuery +=   " AND SGG.GG_COD     = '" + cPai  + "'"
		cQuery +=   " AND SGG.GG_COMP    = '" + cComp + "'"
		cQuery +=   " AND ((SGG.GG_INI < '" + DToS(dDataBase) + "' AND SGG.GG_FIM < '" + DToS(dDataBase) + "' ) OR"
		cQuery +=        " (SGG.GG_INI > '" + DToS(dDataBase) + "' AND SGG.GG_FIM > '" + DToS(dDataBase) + "' ))"
		cQuery +=   " AND SGG.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSGG",.F.,.T.)
		If !QRYSGG->(Eof()) .And. !Empty(QRYSGG->MAXTRT)
			cMaxTrtBd := QRYSGG->MAXTRT
			lExiste  := .T.
		EndIf
		QRYSGG->(dbCloseArea())
	EndIf

	//Percorre a grid buscando pelo componente e guardando a maior sequência informada em tela
	For nInd := 1 To oMdlDet:Length()
		If nInd == oMdlDet:GetLine() .Or. oMdlDet:IsDeleted(nInd) .Or. oMdlDet:GetValue("GG_COMP", nInd) != cComp
			Loop
		EndIf

		If !Empty(oMdlDet:GetValue("GG_TRT",nInd)) .And. oMdlDet:GetValue("GG_TRT",nInd) > cProxTrt
			//If ValidaTrt(oMdlDet, cPai, cComp, oMdlDet:GetValue("GG_TRT",nInd))
				cProxTrt := oMdlDet:GetValue("GG_TRT",nInd)
			//EndIf
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
				If ValidaTrt(oMdlDet, cPai, cComp, cProxTrt)
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

Return cProxTrt

/*/{Protheus.doc} ValidaTrt
Busca a próxima Sequência para gravar no campo TRT
@author Marcelo Neumann
@since 14/12/2018
@version 1.0
@param 01 oMdlDet, object    , modelo da Grid com os componentes
@param 02 cPai   , characters, código do produto Pai
@param 03 cComp  , characters, código do componente
@param 04 cTrt   , characters, sequência (TRT) a ser validada
@return lTrtValido, logical, indica se o TRT enviado é válido
/*/
Static Function ValidaTrt(oMdlDet, cPai, cComp, cTrt)

	Local nInd       := 0
	Local cRecno     := cValToChar(oMdlDet:GetValue("NREG", oMdlDet:GetLine()))
	Local cQuery     := ""
	Local lTrtValido := .T.

	For nInd := 1 To oMdlDet:Length()
		If nInd == oMdlDet:GetLine() .Or. ;
			oMdlDet:IsDeleted(nInd)   .Or. ;
			oMdlDet:GetValue("GG_COMP",nInd) != cComp .Or. ;
			(oMdlDet:GetValue("GG_COMP",nInd) == cComp .And. oMdlDet:GetValue("GG_TRT",nInd) != cTrt)
			Loop
		EndIf

		Help(' ', 1, 'MESMASEQ')
		lTrtValido := .F.
		Exit
	Next nInd

	If lTrtValido .And. !soEveDef:lOperacCriaEstr
		cQuery := "SELECT GG_INI, GG_FIM"
		cQuery +=  " FROM " + RetSqlName('SGG') + " SGG"
		cQuery += " WHERE SGG.GG_FILIAL  = '" + xFilial("SGG") + "'"
		cQuery +=   " AND SGG.GG_COD     = '" + cPai  + "'"
		cQuery +=   " AND SGG.GG_COMP    = '" + cComp + "'"
		cQuery +=   " AND SGG.GG_TRT     = '" + cTrt  + "'"
		cQuery +=   " AND SGG.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SGG.R_E_C_N_O_ <> " + cRecno
		cQuery := ChangeQuery(cQuery)

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSGG",.F.,.T.)
		If !QRYSGG->(Eof())
			If soEveDef:nExibeInvalidos == 2 .And. !CompValido(SToD(QRYSGG->GG_INI), SToD(QRYSGG->GG_FIM))
				Help( ,  , 'Help', ,  STR0055 + ; //"Esta sequência de componente já está sendo utilizada nesta estrutura para o mesmo produto."
				                      STR0098,  ; //" O componente não está sendo exibido pois o parâmetro 'Exibe Componentes Inválidos' está desativado."
					 1, 0, , , , , , {STR0099})   //"Para utilizar essa sequência, primeiramente deverá ser ativado o parâmetro 'Exibe Componentes Inválidos' dessa rotina e, em seguida, deverá ser realizada a alteração da sequência do componente invalido."
			Else
				Help( ,  , 'Help', ,  STR0055,  ; //"Esta sequência de componente já está sendo utilizada nesta estrutura para o mesmo produto."
				     1, 0, , , , , , {STR0056 + ; //"Se deseja alterar a sequência deste componente por uma sequência já utilizada para o mesmo produto, primeiro efetive a alteração de sequência do componente que possui a sequência digitada."
					                  STR0096})   //"Após efetivar a alteração, será permitido reutilizar esta sequência para o mesmo produto."
			EndIf

			lTrtValido := .F.
		EndIf
		QRYSGG->(dbCloseArea())
	EndIf

Return lTrtValido

/*/{Protheus.doc} P135Aprova
Função responsável pela Aprovação da pré-estrutura
@author Marcelo Neumann
@since 08/01/2019
@version 1.0
@param 01 cIndAprov, characters, indica a aprovação a ser feita:
                                 'A' - Aprova
								 'R' - Rejeita
								 'E' - Encaminha para aprovação
@return Nil
/*/
Function P135Aprova(cIndAprov, aCabExec)

	Local oViewExec := Nil
	Local oNewModel := FWLoadModel("PCPA135")
	Local oNewView
	Local lOk := .T.

	//Indica que a operação é referente à Aprovação
	soEveDef:lOperacAprovacao := .T.

	If aCabExec <> Nil
		oNewModel:SetOperation(MODEL_OPERATION_UPDATE)
		If !oNewModel:Activate()
			Help( ,  , "Help", ,  STR0306, 1, 0, , , , , , {""})
			lOk := .F.
		EndIf

		If lOk
			If cIndAprov == 'A'
				ExecAprova('2', oNewModel, .F., aCabExec)
			ElseIf cIndAprov == 'R'
				ExecAprova('3', oNewModel, .F., aCabExec)
			ElseIf cIndAprov = 'E'
				If SGG->GG_STATUS $ "5"
					Help( ,  , "Help", ,  STR0144, 1, 0, , , , , , {STR0145})//"Este registro já se encontra aprovado/reprovado ou em processo de aprovação."
					lOk := .F.
				EndIf

				If Empty(UsrGrEng(RetCodUsr())) .And. lOk
					Help( ,  , "A135NOAPROV", ,  STR0142, 1, 0, , , , , , {STR0143})/*"Não existe grupo de engenheiros para este usuário."*/
					lOK := .F.
				EndIf

				If lOk
					ExecAprova('5', oNewModel, .T., aCabExec)
				EndiF
			EndIf
		EndIf

	Else
		oViewExec :=  FWViewExec():New()

		//Carrega o objeto da view para desabilitar a edição dos campos
		oNewView := FWLoadView("PCPA135")
		oNewView:SetOnlyView("V_FLD_MASTER")
		oNewView:SetOnlyView("V_FLD_SELECT")
		oNewView:SetOnlyView("V_GRID_DETAIL")

		If cIndAprov == 'A'
			oViewExec:setTitle(STR0134)
			oViewExec:setOK({|oNewModel| ExecAprova('2', oNewModel, .F.)})

		ElseIf cIndAprov == 'R'
			oViewExec:setTitle(STR0135)
			oViewExec:setOK({|oNewModel| ExecAprova('3', oNewModel, .F.)})

		ElseIf cIndAprov = 'E'
			If SGG->GG_STATUS $ "5"
				Help( ,  , "Help", ,  STR0144, 1, 0, , , , , , {STR0145})//"Este registro já se encontra aprovado/reprovado ou em processo de aprovação."
				lOk := .F.
			EndIf

			If Empty(UsrGrEng(RetCodUsr())) .And. lOk
				Help( ,  , "A135NOAPROV", ,  STR0142, 1, 0, , , , , , {STR0143})/*"Não existe grupo de engenheiros para este usuário."*/
				lOK := .F.
			EndIf

			If lOk
				oViewExec:setTitle(STR0133)
				oViewExec:setOK({|oNewModel| ExecAprova('5', oNewModel, .T.)})
			EndiF
		EndIf

		If lOk
			oViewExec:setSource("PCPA135")
			oViewExec:setView(oNewView)
			oViewExec:setModel(oNewModel)
			oViewExec:setOperation(MODEL_OPERATION_UPDATE)
			oViewExec:setModal(.F.)
			oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0038},; //"Confirmar"
								{.T.,STR0037},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Cancelar"
			oViewExec:openView(.T.)
		EndiF
	EndIf

	//Retorna o indicador da operação
	soEveDef:lOperacAprovacao := .F.

Return Nil

/*/{Protheus.doc} ExecAprova
Função acionada ao pressionar o botão Confirmar nas operações de Aprovação
@author Marcelo Neumann
@since 08/01/2019
@version 1.0
@param 01 cStatus, characters, indica o novo status:
                               '2' - Aprova
							   '3' - Rejeita
							   '5' - Encaminha para aprovação
@param 02 oModel , object    , modelo da tela
@return lOk, logical, indica se todos os componentes foram atualizados
/*/
Static Function ExecAprova(cStatus, oModel, lAlcada, aCabExec)

	Local cNivelApro := ""
	Local cProduto   := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local lAuto      := aCabExec != Nil
	Local lOk        := .T.

	If !lAuto
		cNivelApro := soEveDef:SolicitaNivel()
	Else
		nPos := aScan(aCabExec, {|x| x[1] == "AUTNIVAPROV"})
		If nPos <= 0 .Or. (nPos > 0 .And. Empty(aCabExec[nPos][2]))
			cNivelApro := "1"
		Else
			If "|" + cValToChar(aCabExec[nPos][2]) + "|" $"|1|2|"
				cNivelApro := cValtoChar(aCabExec[nPos][2])
			Else
				Help(' ',1,"HELP" ,, STR0304,2,0,,,,,, {STR0305}) //""Nível de aprovação informado está incorreto" //"Valores permitidos 1: Primeiro nível ou 2: Todos os níveis"
				lOk := .F.
			EndIf
		EndIf
	EndIf

	If cNivelApro $ "12" .and. !Empty(cNivelApro)
		SGG->(dbSetOrder(1))
		If lAlcada
			If lAuto
				lOK := AprovAlc(cProduto, cStatus, cNivelApro)
			Else
				Processa({|| lOK := AprovAlc(cProduto, cStatus, cNivelApro) })
			EndIf
		Else
			If lAuto
				lOK := AprovComps(cProduto, cStatus, cNivelApro)
			Else
				Processa({|| lOK := AprovComps(cProduto, cStatus, cNivelApro) })
			EndIf
			If cStatus == '2' /*aprovado*/
				If ExistBlock ("MTA202APROV")
					ExecBlock ("MTA202APROV",.F.,.F.,{cProduto})
				Endif
			EndIf
		EndIf
		oModel:lModify := .T.
	Else
		lOk := .F.
	EndIf

Return lOk

/*/{Protheus.doc} AprovComps
Grava o novo status nos componentes
@author Marcelo Neumann
@since 08/01/2019
@version 1.0
@param 01 cProduto  , characters, código do produto Pai
@param 02 cStatus   , characters, indica o novo status
@param 03 cNivelApro, characters, indica se será atualizado somente o primeiro nível ou todos
@return lOk, logical, indica se os componentes foram atualizados corretamente
/*/
Static Function AprovComps(cProduto, cStatus, cNivelApro)

	Local aAreaGG := SGG->(GetArea())
	Local oModel  := FWLoadModel("PCPA135Grv")
	Local lOK     := .T.

	If SGG->(dbSeek(xFilial('SGG') + cProduto, .F.))
		While !SGG->(Eof()) .And. ;
		       SGG->GG_FILIAL == xFilial("SGG") .And. ;
		       SGG->GG_COD    == cProduto

			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
			oModel:GetModel("MODEL_COMMIT"):LoadValue("GG_STATUS", cStatus)
			lOK := FWFormCommit(oModel)
			oModel:DeActivate()

			If cNivelApro == '2'
				AprovComps(SGG->GG_COMP, cStatus, cNivelApro)
			EndIf

			SGG->(dbSkip())
		End
	EndIf

	SGG->(RestArea(aAreaGG))

Return lOK

/*/{Protheus.doc} AprovAlc
Atualiza tabela de aprovações de estruturas e também os status de cada um dos componentes
@author Douglas Heydt
@since 30/01/2019
@version 1.0
@param 01 cProduto  , characters, código do produto Pai
@param 02 cStatus   , characters, indica o novo status
@param 03 cNivelApro, characters, indica se será atualizado somente o primeiro nível ou todos
@return lOk, logical, indica se os componentes foram atualizados corretamente
/*/
Static Function AprovAlc(cProduto, cStatus, cNivelApro)

	Local aAreaGG   := SGG->(GetArea())
	Local cUser     := RetCodUsr()
	Local cGrupoEng := UsrGrEng(cUser)
	Local lOK       := .T.
	Local lRegSGn   := .F.
	Local oModel    := FWLoadModel("PCPA135Grv")

	A135DelSGN(cProduto,.T.)

	If SGG->(dbSeek(xFilial("SGG")+cProduto))
		MaAlcEng({PADR(cProduto,30),"SGG",cUser,cGrupoEng,""},,1,@lRegSGn)

		While !SGG->(Eof()) .And. ;
				SGG->GG_FILIAL == xFilial("SGG") .And. ;
				SGG->GG_COD    == cProduto

			IF !lRegSGn
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
				oModel:GetModel("MODEL_COMMIT"):LoadValue("GG_STATUS", cStatus)
				lOK := FWFormCommit(oModel)
				oModel:DeActivate()
			EndIf

			If cNivelApro == '2'
				AprovAlc(SGG->GG_COMP, cStatus, cNivelApro)
			EndIf

			SGG->(dbSkip())
		End
	EndiF

	SGG->(RestArea(aAreaGG))

Return lOK

/*/{Protheus.doc} A135DelSGN
Função para excluir registros da SGN
@author Douglas Heydt
@since 30/01/2019
@version 1.0
@return
/*/
Static Function A135DelSGN(cChave,lSubmit)
	Local aArea   := GetArea()
	Local aAreaSGG := SGG->(GetArea())

	Default cChave  := SGG->GG_COD
	Default lSubmit := .F.

	If SGG->(dbSeek(xFilial("SGG")+cChave)) .And. SGG->GG_STATUS <> If(lSubmit,'2','3')
		SGN->(dbSetOrder(1))
		SGN->(dbSeek(xFilial("SGN")+"SGG"+cChave))
		While !SGN->(EOF()) .And. SGN->(GN_FILIAL+GN_TIPO+GN_NUM) == xFilial("SGN")+"SGG"+cChave
			If SGN->GN_STATUS == '04' .Or. SGG->GG_STATUS == '1'
				SGN->(dbSeek(xFilial("SGN")+"SGG"+cChave))
				While !SGN->(EOF()) .And. SGN->(GN_FILIAL+GN_TIPO+GN_NUM) == xFilial("SGN")+"SGG"+cChave
					Reclock("SGN",.F.)
					SGN->(dbDelete())
					SGN->(MsUnlock())
					SGN->(dbSkip())
				End
				Exit
			EndIf
			SGN->(dbSkip())
		End
	EndIf

	RestArea(aAreaSGG)
	RestArea(aArea)
Return

/*/{Protheus.doc} P135LogApr
Apresenta grid com informações sobre o status da aprovação de estruturas
@author Douglas heydt
@since 28/01/2019
@version 1.0
/*/
Function P135LogApr()

	Local aAreaAnt  := GetArea()
	Local aHeadCols := {STR0158,STR0147,STR0159,STR0160,STR0161,STR0162}
	Local aHeadSize := {30,20,40,100,38,100}
	Local cTitle    := STR0157 +AllTrim(SGG->GG_COD)
	Local cTipoLib  := ""
	Local cStatus	:= ""
	Local aBrowse   := {}
	Local lRet		:= .F.

	If !(GrpEng(RetCodUsr(),SGG->GG_USUARIO))
		Aviso(OemToAnsi(STR0163),STR0164,{"Ok"})
		RETURN
	EndIf

	dbSelectArea("SGN")
	dbSetOrder(1)
	If dbSeek(xFilial("SGN")+"SGG"+SGG->GG_COD)
		Do While !SGN->(Eof()) .And. SGN->GN_FILIAL+SGN->GN_TIPO+SGN->GN_NUM == xFilial("SGN")+"SGG"+	SGG->GG_COD
			Do Case
				Case SGN->GN_TIPOLIB == 'U'
					cTipoLib := STR0146//"Usuario"
				Case SGN->GN_TIPOLIB == 'N'
					cTipoLib := STR0147//"Nivel"
				Case SGN->GN_TIPOLIB == 'E'
					cTipoLib := STR0148//"Engenharia"
			EndCase

			Do Case
				Case SGN->GN_STATUS = '01'
					cStatus = STR0149//"Aguardando outros níveis"
				Case SGN->GN_STATUS = '02'
					cStatus = STR0150//"Aguardando liberação"
				Case SGN->GN_STATUS = '03'
					cStatus = STR0151//"Liberado"
				Case SGN->GN_STATUS = '04'
					cStatus = STR0152//"Rejeitado"
				Case SGN->GN_STATUS = '05'
					cStatus = STR0153//"Aprovado por outro usuário"
				Case SGN->GN_STATUS = '06'
					cStatus = STR0154//"Rejeitado por outro usuário"
				Case SGN->GN_STATUS = '07'
					cStatus = STR0155//"Bloqueado"
				Case SGN->GN_STATUS = '08'
					cStatus = STR0156//"Bloqueado por outro usuário"
			EndCase
			aAdd(aBrowse, {UsrRetName(SGN->GN_USER),SGN->GN_NIVEL,cTipoLib,cStatus,SGN->GN_DATALIB,SGN->GN_OBS})
			SGN->(dbSkip())
		EndDo
	Else
		Aviso(OemToAnsi(STR0165),OemToAnsi(STR0166),{"Ok"})
		lRet := .T.
	EndIf

	If !lRet
		DEFINE MSDIALOG oDialog FROM 000,000 TO 300,980 TITLE cTitle OF oMainWnd PIXEL

		oBrowse := TWBrowse():New(01,01,500,150,,aHeadCols,aHeadSize,oDialog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.F.,.T.)
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := { || aBrowse[oBrowse:nAT] }

		ACTIVATE MSDIALOG oDialog CENTERED
	EndIf
	RestArea(aAreaAnt)

Return

/*/{Protheus.doc} P135CriaEs
Função responsável pela Criação de estrutura a partir da pré-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return Nil
/*/
Function P135CriaEs(aAutoCab)

	Default aAutoCab := Nil

	//Indica que a operação é "Criar Estrutura"
	soEveDef:lOperacCriaEstr := .T.

	PCPA135CrE(aAutoCab)

	//Retorna o indicador da operação
	soEveDef:lOperacCriaEstr := .F.

Return

/*/{Protheus.doc} P135TrSeek
Função para percorrer na tree através de outro fonte
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 cCargo, characters, CARGO da tree em que deve ser posicionado
@return Nil
/*/
Function P135TrSeek(cCargo, cNodeId, lExeTreeCh)
	Default cCargo     := ""
	Default cNodeId    := ""
	Default lExeTreeCh := .F.

	If Empty(cNodeId)
		soDbTree:TreeSeek(cCargo)
	Else
		soDbTree:PTGotoToNode(cNodeID)
	EndIf

	If lExeTreeCh
		P135TreeCh(.T.)
	EndIf

Return

/*/{Protheus.doc} AtalhoTecl
Recupera a referência do objeto dos Eventos do modelo.
@type  Static Function
@author Carlos Alexandre da Silveira
@since 12/03/2019
@version P12
@param cTecla, Character, Tecla de atalho pressionada
@return Nil
/*/
Static Function AtalhoTecl(cTecla)
	Local oViewActiv := FwViewActive()

	//Só permitirá acessar os atalhos quando estiver na view/modelo principal
	If oViewActiv != Nil .And. oViewActiv:IsActive() .And. aScan(oViewActiv:GetModelsIds(), "FLD_SELECT") > 0
		//Tecla F5 (Pesquisa)
		If cTecla == "F5"
			PCPA135Pes(oViewActiv, "PESQUISA")
		//Tecla F6 (Anterior)
		ElseIf cTecla == "F6"
			PCPA135Pes(oViewActiv, "ANTERIOR")
		//Tecla F7 (Próximo)
		ElseIf cTecla == "F7"
			PCPA135Pes(oViewActiv, "PROXIMO")
		EndIf
		//Adiciona teclas de atalho
		HabAtalhos(.T.)
	EndIf

Return

/*/{Protheus.doc} HabAtalhos
Habilita os atalhos das teclas de Pesquisa (F5, F6 e F7)
@author Carlos Alexandre da Silveira
@since 12/03/2019
@version P12
@param lHabilita, logic, indica se deve habilitar ou desabilitar os atalhos
@return Nil
/*/
Static Function HabAtalhos(lHabilita)
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

/*/{Protheus.doc} P135GetF12
Retorna um parâmetro F12
@author Carlos Alexandre da Silveira
@since 13/03/2019
@version P12
@param 01 cParametro, characters, indica qual parâmetro deve ser retornado
@return xValue, valor do parâmetro (o tipo de dado depende do parâmetro)
/*/
Function P135GetF12(cParametro)
	Local oEvent := gtMdlEvent(FWModelActive(), "PCPA135EVDEF")
	Local xValue

	If cParametro == "EXIBE_VENCIDOS"
		xValue := oEvent:nExibeInvalidos
	EndIf

Return xValue

/*/{Protheus.doc} gtMdlEvent
Recupera a referência do objeto dos Eventos do modelo.
@type  Static Function
@author Carlos Alexandre da Silveira
@since 13/03/2019
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

/*/{Protheus.doc} P135GtNoID
Retorna o ID do nó selecionado na tree
@author Carlos Alexandre Silveira
@since 13/03/2019
@version P12
@return soDbTree:CurrentNodeId, characters, Id do nó selecionado
/*/
Function P135GtNoID()

Return soDbTree:CurrentNodeId

/*/{Protheus.doc} ValidaLista
Valida se a lista está igual ao cadastro de listas (PCPA120)
@author Carlos Alexandre da Silveira
@since 21/03/2019
@version P12
@param 01 cLista, characters, indica qual lista de componentes está sendo validada
	   02 cEstrAlias, characters, indica qual o alias da tabela
@return lOk, indica se a lista tem divergências ou não
/*/
Static Function ValidLista(cLista, CEstrAlias)
	Local lOk 		:= .T.
	Local cQuery 	:= ""
	Local cAliasQry	:= ""

	//Se o parâmetro de réplica está desativado, não valida a lista
	If slPCPRLEP <> 1
		Return lOk
	EndIf

	SVG->(dbSetOrder(1))

	//Verifica se a lista existe - Contém na tabela SGG/SG1 e não está na tabela SVG.
	cQuery := " SELECT 1 "
	cQuery +=   " FROM " + RetSqlName(CEstrAlias) + " " + CEstrAlias
	cQuery +=  " WHERE " + CEstrAlias + ".D_E_L_E_T_ = ' ' "
	cQuery +=    " AND " + CEstrAlias + "."+CampoCopy("GG_FILIAL") + " = '" + xFilial(CEstrAlias) + "' "
	cQuery +=    " AND " + CEstrAlias + "."+CampoCopy("GG_LISTA") + "    = '" + cLista + "' "
	cQuery +=    " AND NOT EXISTS (SELECT 1 "
	cQuery +=                      " FROM " + RetSqlName("SVG") + " SVG"
	cQuery +=                     " WHERE SVG.D_E_L_E_T_ = ' ' "
	cQuery +=                       " AND SVG.VG_FILIAL  = '" + xFilial("SVG") + "'"
	cQuery +=                       " AND SVG.VG_COD     = " + CEstrAlias + "."+CampoCopy("GG_LISTA")
	cQuery +=                       " AND SVG.VG_COMP    = " + CEstrAlias + "."+CampoCopy("GG_COMP")
	cQuery +=                       " AND SVG.VG_TRT     = " + CEstrAlias + "."+CampoCopy("GG_TRT") + ")"

	cQuery 		:= ChangeQuery(cQuery)
	cAliasQry 	:= GetNextAlias()

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(!Eof())
		lOk := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())

	If lOk
		//Verifica se a lista existe - Contém na tabela SVG e não está na tabela SGG/SG1.
		cQuery := " SELECT 1 "
		cQuery +=   " FROM " + RetSqlName("SVG") + " SVG"
		cQuery +=  " WHERE SVG.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SVG.VG_FILIAL  = '" + xFilial("SVG") + "'"
		cQuery +=    " AND SVG.VG_COD     = '" + cLista + "'"
		cQuery +=    " AND NOT EXISTS (SELECT 1 "
		cQuery +=                      " FROM " + RetSqlName(CEstrAlias) + " " + CEstrAlias
		cQuery +=                     " WHERE " + CEstrAlias + ".D_E_L_E_T_ = ' ' "
		cQuery +=                       " AND " + CEstrAlias + "."+CampoCopy("GG_FILIAL") + " = '" + xFilial(cEstrAlias) + "'"
		cQuery +=                       " AND " + CEstrAlias + "."+CampoCopy("GG_LISTA")  + " = SVG.VG_COD "
		cQuery +=                       " AND " + CEstrAlias + "."+CampoCopy("GG_COMP")   + " = SVG.VG_COMP "
		cQuery +=                       " AND " + CEstrAlias + "."+CampoCopy("GG_TRT")    + " = SVG.VG_TRT)"

		cQuery 		:= ChangeQuery(cQuery)
		cAliasQry 	:= GetNextAlias()

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(!Eof())
			lOk := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

Return lOk

/*/{Protheus.doc} CopySVG
Converte nomenclatura dos campos SVG -> SGG
@author Carlos Alexandre da Silveira
@since 22/03/2019
@version 1.0
@param  cCampoSGG, caractere, nome do campo na SVG
@return          , caractere, nome do campo na SGG
/*/
Static Function CopySVG(cCampoSVG)
Return StrTran(cCampoSVG,'GG_','VG_')

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

	Local nPos := 0
	Local nInd := 1

	//Verifica se o registro está na tree
	If !oMdlDet:IsEmpty()
		For nInd := 1 To oMdlDet:Length()
			If oMdlDet:IsDeleted(nInd)
				Loop
			EndIf

			If aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI]  == cCargoPai .And. ;
									x[IND_ACARGO_CARGO_COMP] == oMdlDet:GetValue("CARGO", nInd) }) == 0

				//Adiciona o componente na TREE
				AddItemTr(cCargoPai                        , ;
						oMdlDet:GetValue("CARGO" ,nInd)  , ;
						oMdlDet:GetValue("GG_TRT",nInd)  , ;
						CompValido(oMdlDet:GetValue("GG_INI",nInd), oMdlDet:GetValue("GG_FIM",nInd)), ;
						NIL, ;
						oMdlDet:GetValue("GG_GROPC",nInd), ;
						oMdlDet:GetValue("GG_OPC"  ,nInd), ;
						.T.)
			EndIf
		Next nInd
	EndIf

	//Verifica se os Nós ainda existem (se ainda estão na Grid)
	nPos := aScan(saCargos, {|x| x[IND_ACARGO_CARGO_PAI] == cCargoPai })
	While nPos > 0
		If !oMdlDet:SeekLine({ {"CARGO", saCargos[nPos][IND_ACARGO_CARGO_COMP]}  }, .F., .T.)
			P135DelIt(cCargoPai, saCargos[nPos][IND_ACARGO_CARGO_COMP])
		EndIf

		nPos := aScan(saCargos, { |x| x[IND_ACARGO_CARGO_PAI] == cCargoPai }, (nPos + 1))
	End

	oMdlDet:GoLine(1)

Return

/*/{Protheus.doc} ChgLinGrid
Função acionada ao mudar a linha da grid
@author Marcelo Neumann
@since 24/04/2019
@version 1.0
@param 01 oView, objeto, view principal
@return lRet, lógico, indica se pôde mudar a linha
/*/
Static Function ChgLinGrid(oView)

	Local oModel  := oView:GetModel()
	Local oMdlDet := oModel:GetModel("GRID_DETAIL")
	Local oEvent  := gtMdlEvent(oModel,"PCPA135EVDEF")
	Local lRet    := .T.

	If oMdlDet:IsInserted() .And. Empty(oMdlDet:GetValue("CARGO"))
		If !oEvent:GridLinePreVld(oMdlDet, "GRID_DETAIL", oMdlDet:GetLine(), "ADDLINE")
			oMdlDet:ClearData(.F.,.F.)
			oMdlDet:DeActivate()
			oMdlDet:Activate()

			P135Refr(oView, "V_GRID_DETAIL")

			lRet := .F.
		EndIf
	EndIf

	EnableLine(oMdlDet)

Return lRet

/*/{Protheus.doc} P135Refr
Função para forçar a atualização de todas as linhas do Grid
@author Marcelo Neumann
@since 24/04/2019
@version 1.0
@param 01 oView  , objeto   , modelo da View principal
@param 02 cIDView, caractere, ID da view a ser atualizada
@return NIL
/*/
Function P135Refr(oView, cIDView)

	Local oGridView

	If cIDView == "V_GRID_DETAIL"
		oGridView := oView:GetSubView("V_GRID_DETAIL")
		oGridView:DeActivate(.T.)
		oGridView:Activate()
	EndIf

Return

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
