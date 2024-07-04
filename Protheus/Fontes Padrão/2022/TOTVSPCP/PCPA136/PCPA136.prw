#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136.CH"

/*/{Protheus.doc} PCPA136
Cadastro de Demandas do MRP (SVR)
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return Nil
/*/
Function PCPA136()

	Local aArea   := GetArea()
	Local oBrowse

	//Proteção do fonte para não ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		Help(' ',1,"Help" ,,STR0022,2,0,,,,,,) //"Rotina não disponível nesta release."
		Return
	EndIf

	oBrowse := BrowseDef()
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} BrowseDef
Criação do Browse da rotina
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return oBrowse, object, objeto do tipo FWMBrowse
/*/
Static Function BrowseDef()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("SVB")
	oBrowse:SetDescription(STR0001) //"Demandas do MRP"
	oBrowse:SetParam({ || Pergunte("PCPA136", .T.) })

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
Static Function MenuDef()

	Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'ViewDef.PCPA136' OPERATION OP_VISUALIZAR ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'ViewDef.PCPA136' OPERATION OP_INCLUIR    ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION 'ViewDef.PCPA136' OPERATION OP_ALTERAR    ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'PCPA136Exc()'    OPERATION OP_EXCLUIR    ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0023 ACTION 'PCPA136Imp()'    OPERATION OP_ALTERAR    ACCESS 0 //"Importar"
	ADD OPTION aRotina TITLE STR0106 ACTION 'PCPA136Csv()'    OPERATION OP_ALTERAR    ACCESS 0 //"Importar CSV"
	ADD OPTION aRotina TITLE STR0122 ACTION 'PCPA136Atu()'    OPERATION OP_VISUALIZAR ACCESS 0 //"Atualizar Demandas"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return oModel, object, modelo de dados
/*/
Static Function ModelDef()

	Local oStrMaster := FWFormStruct(1,"SVB")
	Local oStrDetail := FWFormStruct(1,"SVR")
	Local oStrGrade
	Local oModel     := MPFormModel():New('PCPA136')
	Local oEventPad  := PCPA136EVDEF():New(oModel)
	Local oEventAPI  := PCPA136API():New()
	Local bLoad
	Local nTamDesc   := GetSx3Cache("B1_DESC","X3_TAMANHO")

	oStrMaster:SetProperty("VB_DTINI", MODEL_FIELD_NOUPD, .T.)
	oStrMaster:SetProperty("VB_DTFIM", MODEL_FIELD_NOUPD, .T.)

	//DMANSMARTSQUAD1-20395 - atribuir para o campo VR_DCSPROD o tamanho do campo SB1_DESC para não correr erro de valor atribuído difere do tamanho do campo.
	oStrDetail:SetProperty("VR_DSCPROD", MODEL_FIELD_TAMANHO, nTamDesc)

	//DMANNEWPCP-5549 - Não obrigar campo de armazém ao gravar uma demanda
	oStrDetail:SetProperty("VR_LOCAL", MODEL_FIELD_OBRIGAT, .F.)

	//SVB_MASTER - Modelo do campo mestre (Cabeçalho)
	oModel:AddFields("SVB_MASTER", /*cOwner*/, oStrMaster)
	oModel:GetModel("SVB_MASTER"):SetDescription(STR0006) //"Demandas - Mestre"

	//Altera a estrutura do modelo detalhe
	AltStrMdl(oStrDetail)

	//Adicao de gatihos na grid de demandas
	oStrDetail:AddTrigger("VR_QUANT","VR_QUANT"  ,{|| lVldOpc(oModel) }, {|| lOpcionais(oModel) })
	oStrDetail:AddTrigger("VR_PROD" ,"VR_PROD"   ,{|| lVldOpc(oModel) }, {|| lOpcionais(oModel) })
	oStrDetail:AddTrigger("VR_DATA" ,"VR_DATA"   ,{|| lVldOpc(oModel) }, {|| lOpcionais(oModel) })

	//SVR_GRADE - Modelo da grade
	//IMPORTANTE -> a criação do modelo da GRADE deve estar antes da criação do modelo DETAIL
	If SVR->(FieldPos("VR_GRADE")) > 0
		oStrDetail:SetProperty("VR_GRADE", MODEL_FIELD_NOUPD, .F.)

		//Cria bloco de load para o modelo de detalhe carregar os registros de grade
	    bLoad := {|oGridModel, lCopy| loadGrid(oGridModel, lCopy)}

		//Adiciona triggers de acionamento da tela de grade
		oEventPad:oGrade:addTriggers(oStrDetail)

		//Cria struct para o modelo "invisível" de grade
		oStrGrade := FWFormStruct(1, "SVR")

		//Altera a estrutura da mesma forma que o oStrDetail
		AltStrMdl(oStrGrade)

		oStrGrade:SetProperty("VR_DATA", MODEL_FIELD_OBRIGAT, .F.)

		//Os campos referentes ao opcional no modelo GRADE não podem ter o mesmo ID dos campos no modelo DETAIL
		oStrGrade:SetProperty("VR_OPC" , MODEL_FIELD_IDFIELD , "VR_OPCGRD")
		oStrGrade:SetProperty("VR_MOPC", MODEL_FIELD_IDFIELD , "VR_MOPCGRD")

		//Deve ser feito antes do AddGrid do modelo "SVR_DETAIL"
		oModel:AddGrid("SVR_GRADE", "SVB_MASTER", oStrGrade)
		oModel:GetModel("SVR_GRADE"):SetDescription(STR0091) //"Demandas - Grade"
		oModel:GetModel("SVR_GRADE"):SetMaxLine(25000)
		oModel:SetRelation("SVR_GRADE",{{"VR_FILIAL", "xFilial('SVR')"},{"VR_CODIGO", "VB_CODIGO"},{"(CASE VR_IDGRADE WHEN ' ' THEN '0' ELSE '1' END)", "'1'"}},SVR->(IndexKey(3)))
		oModel:SetOptional("SVR_GRADE", .T.)
	EndIf

	//SVR_DETAIL - Modelo das demandas (Grid)
	//IMPORTANTE -> a criação do modelo da GRADE deve estar antes da criação do modelo DETAIL
	oModel:AddGrid("SVR_DETAIL", "SVB_MASTER", oStrDetail, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, bLoad)
	oModel:GetModel("SVR_DETAIL"):SetDescription(STR0007) //"Demandas - Detalhe"
	oModel:GetModel("SVR_DETAIL"):SetMaxLine(25000)
	If SVR->(FieldPos("VR_IDGRADE")) > 0
		oModel:SetRelation("SVR_DETAIL",{{"VR_FILIAL", "xFilial('SVR')"},{"VR_CODIGO", "VB_CODIGO"},{"VR_IDGRADE", "' '"}},"VR_FILIAL+VR_TIPO+VR_PROD+DTOS(VR_DATA)")
	Else
		oModel:SetRelation("SVR_DETAIL",{{"VR_FILIAL", "xFilial('SVR')"},{"VR_CODIGO", "VB_CODIGO"}},"VR_FILIAL+VR_TIPO+VR_PROD+DTOS(VR_DATA)")
	EndIf

	//Propriedades do modelo principal
	oModel:SetDescription(STR0001) //"Demandas do MRP"
	oModel:InstallEvent("PCPA136EVDEF", /*cOwner*/, oEventPad)
	oModel:InstallEvent("PCPA136EVAPI", /*cOwner*/, oEventAPI)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return oView, object, objeto de View
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("PCPA136")
	Local oView      := FWFormView():New()
	Local oStrMaster := FWFormStruct(2,"SVB")
	Local oStrDetail := FWFormStruct(2,"SVR")
	Local oEventPad  := gtMdlEvent(oModel, "PCPA136EVDEF")

	oView:SetModel(oModel)

	//Alterações na estrutura da view
	AltStrView(@oStrDetail)

	//Seta os modelos na View
	oView:AddField("V_SVB_MASTER", oStrMaster, "SVB_MASTER")
	oView:AddGrid( "V_SVR_DETAIL", oStrDetail, "SVR_DETAIL")

	//Cria os BOXs para as Views
	oView:CreateHorizontalBox("UPPER" ,  76, , .T.)
	oView:CreateHorizontalBox("BOTTOM", 100)

	//Adiciona um título para a grid.
	oView:EnableTitleView("V_SVR_DETAIL",STR0024) //"Produtos da demanda"

	//Relaciona cada BOX com sua view
	oView:SetOwnerView("V_SVB_MASTER", "UPPER" )
	oView:SetOwnerView("V_SVR_DETAIL", "BOTTOM")

	//Habilita o filtro e busca na grid.
	oView:SetViewProperty("V_SVR_DETAIL","GRIDFILTER",{.T.})
	oView:SetViewProperty("V_SVR_DETAIL","GRIDSEEK",{.T.})

	oView:SetViewProperty( "*", "GRIDNOORDER")

	//Adiciona o botão de importar demandas
	oView:AddUserButton(STR0023, "", {|oView| A136Import(oView, .F.)}, , , {MODEL_OPERATION_INSERT}, .T.) //"Importar"
	If SVR->(FieldPos("VR_ORIGEM")) > 0
		oView:AddUserButton(STR0106, "", {|oView| A136Import(oView, .T.)}, , , {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}, .F.) //"Importar CSV"
	EndIf
	oView:AddUserButton(STR0085, "", {|oView| A136Legend(oView)}, , , , ) //"Legenda"
	oView:AddUserButton(STR0082, "", {|| p136VisOpc(oModel)}, , , {MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT,MODEL_OPERATION_VIEW }, .T.) //"Opcionais"

	//Adiciona botoes referente grade
	If SVR->(FieldPos("VR_GRADE")) > 0
		oEventPad:oGrade:addUserButton(oView)
	EndIf

	//Adiciona barra de progresso.
	oView:SetProgressBar(.T.)

Return oView

/*/{Protheus.doc} AltStrMdl
Alterações nas estruturas do Model
@author Marcelo Neumann
@since 23/12/2019
@version P12
@param 01 oStruct, object, estrutura do modelo a ser alterado
@return Nil
/*/
Static Function AltStrMdl(oStruct)

	//Controle da Execução das Validações de Opcionais
	oStruct:AddField("opcional válido"            ,; // [01] C Titulo do campo
					 ""                           ,; // [02] C ToolTip do campo
					 "VLDOPC"                     ,; // [03] C Id do Field
					 "L"                          ,; // [04] C Tipo do campo
					 1                            ,; // [05] N Tamanho do campo
					 0, NIL, NIL, NIL, .F.        ,;
					 {|| .T. }                    ,; // [11] B Code-block de inicializacao do campo
					 NIL, NIL, .T.)

	//Legenda da demanda
	oStruct:AddField(""                           ,; // [01] C Titulo do campo
	                 ""                           ,; // [02] C ToolTip do campo
	                 "CLEGEND"                    ,; // [03] C Id do Field
	                 "C"                          ,; // [04] C Tipo do campo
	                 11                           ,; // [05] N Tamanho do campo
	                 0                            ,; // [06] N Decimal do campo
	                 NIL, NIL, NIL, .F.           ,;
	                 {|oModel| IniLegend(,oModel)},; // [11] B Code-block de inicializacao do campo
	                 NIL, NIL, .T.)

Return Nil

/*/{Protheus.doc} AltStrView
Alterações nas estruturas da view
@author Marcelo Neumann
@since 17/01/2019
@version P12
@param 01 oStrDetail, object, estrutura do modelo SVR_DETAIL
@return Nil
/*/
Static Function AltStrView(oStrDetail)

	oStrDetail:RemoveField("VR_SEQUEN")
	oStrDetail:RemoveField("VR_REGORI")
	oStrDetail:RemoveField("VR_CODIGO")

	If SVR->(FieldPos("VR_GRADE")) > 0
		oStrDetail:RemoveField("VR_ITEMGRD")
		oStrDetail:RemoveField("VR_REFGRD")
		oStrDetail:RemoveField("VR_GRADE")
	EndIf

	//Retira o campo VR_INTMRP da View, e cria um campo virtual para exibir a legenda.
	oStrDetail:AddField("CLEGEND" ,;	// [01]  C   Nome do Campo
	                    "01"      ,;	// [02]  C   Ordem
	                    ""        ,;	// [03]  C   Titulo do campo    //"Descrição"
	                    ""        ,;	// [04]  C   Descricao do campo //"Descrição"
	                    NIL       ,;	// [05]  A   Array com Help
	                    "C"       ,;	// [06]  C   Tipo do campo
	                    "@BMP"    ,;	// [07]  C   Picture
	                    NIL       ,;	// [08]  B   Bloco de Picture Var
	                    NIL       ,;	// [09]  C   Consulta F3
	                    .F.       ,;	// [10]  L   Indica se o campo é alteravel
	                    NIL       ,;	// [11]  C   Pasta do campo
	                    NIL       ,;	// [12]  C   Agrupamento do campo
	                    NIL       ,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL       ,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL       ,;	// [15]  C   Inicializador de Browse
	                    .T.       ,;	// [16]  L   Indica se o campo é virtual
	                    NIL       ,;	// [17]  C   Picture Variavel
	                    NIL       ) 	// [18]  L   Indica pulo de linha após o campo

	oStrDetail:RemoveField("VR_INTMRP")

	//DMANNEWPCP-5549 - esconder campo de armazém até que a funcionalidade seja desenvolvida
	oStrDetail:RemoveField("VR_LOCAL")
	oStrDetail:RemoveField("VR_LOCDESC")

Return Nil

/*/{Protheus.doc} P136IniPrd
Inicializador padrão do campo VR_DESPROD
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return cDesc, characters, descrição do Produto
/*/
Function P136IniPrd()

	Local oModel := FwModelActive()
	Local cDesc  := CriaVar("B1_DESC")

	If oModel:GetOperation() <> MODEL_OPERATION_INSERT .And. oModel:GetModel("SVR_DETAIL"):GetLine() == 0
		cDesc := GetInfoTab("SB1", 1, SVR->VR_PROD, "B1_DESC")
	EndIf

Return cDesc

/*/{Protheus.doc} P136IniLoc
Inicializador padrão do campo VR_LOCDES
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return cDesc, characters, descrição do Armazém
/*/
Function P136IniLoc()

	Local oModel := FwModelActive()
	Local cDesc  := CriaVar("NNR_DESCRI")

	If oModel:GetOperation() <> MODEL_OPERATION_INSERT .And. oModel:GetModel("SVR_DETAIL"):GetLine() == 0
		cDesc := GetInfoTab("NNR", 1, SVR->VR_LOCAL, "NNR_DESCRI")
	EndIf

Return cDesc

/*/{Protheus.doc} GetInfoTab
Função para buscar uma coluna específica de alguma tabela
@author Marcelo Neumann
@since 17/01/2019
@version P12
@param 01 cAlias, characters, tabela a ser buscada a informação
@param 02 nIndex, numeric   , índice da tabela a ser utilizado
@param 03 cChave, characters, chave de busca da informação
@param 04 cCampo, characters, campo da tabela onde está a informação desejada
@return xInfo   , undefined , valor da coluna solicitada
/*/
Static Function GetInfoTab(cAlias, nIndex, cChave, cCampo)

	Local aArea := (cAlias)->(GetArea())
	Local xInfo := CriaVar(cCampo)

	(cAlias)->(dbSetOrder(nIndex))
	If (cAlias)->(MsSeek(xFilial(cAlias) + cChave))
		xInfo := (cAlias)->&(cCampo)
	EndIf

	(cAlias)->(RestArea(aArea))

Return xInfo

/*/{Protheus.doc} P136ValDat
Função de Validação do campo "Data"
@author Marcelo Neumann
@since 17/01/2019
@version P12
@return lOk, logic, indica se a data informada é válida
/*/
Function P136ValDat()

	Local aArea    := SVZ->(GetArea())
	Local oModel   := FwModelActive()
	Local oMdlSVB  := oModel:GetModel("SVB_MASTER")
	Local dData    := oModel:GetModel("SVR_DETAIL"):GetValue("VR_DATA")
	Local lOk      := .T.
	Local lAchou   := .F.
	Local nDemUtil := SuperGetMv("MV_DEMUTIL",.F.,1)

	If !Empty(oMdlSVB:GetValue("VB_DTINI")) .And. !Empty(oMdlSVB:GetValue("VB_DTFIM"))
		//Data do produto da demanda deve estar entre o período da demanda.
		If dData > oMdlSVB:GetValue("VB_DTFIM") .Or. dData < oMdlSVB:GetValue("VB_DTINI")
			Help(' ',1,"Help" ,,STR0025,; //"Data da demanda deve estar dentro do período da demanda."
			     2,0,,,,,, {STR0026 + DtoC(oMdlSVB:GetValue("VB_DTINI")) + STR0027 + DtoC(oMdlSVB:GetValue("VB_DTFIM")) + "."}) //"Informe a data da demanda entre os dias " XXX " e "
			lOk := .F.
		EndIf
	EndIf

	If lOk .And. nDemUtil == 2
		//Não permite informar datas que não sejam dias úteis no novo cadastro de calendário do MRP
		SVZ->(dbSetOrder(2))
		If SVZ->(MsSeek( xFilial("SVZ") + DToS(dData) ))
			While !SVZ->(Eof())                  .And. ;
				SVZ->VZ_FILIAL == xFilial("SVZ") .And. ;
				SVZ->VZ_DATA   == dData

				//Verifica se o dia é útil
				If SVZ->VZ_HORAFIM <> "00.00"
					lAchou := .T.
					Exit
				EndIf

				SVZ->(dbSkip())
			End

			If !lAchou
				Help( ,  , 'Help', ,  STR0009, ; //"A data informada não é um dia útil no Calendário do MRP."
					1, 0, , , , , , {STR0010})  //"Informe uma data que seja um dia útil no Calendário do MRP."
				lOk := .F.
			EndIf
		Else
			//Caso a data informada não esteja no cadastro de calendário, considerar ela como dia não útil
			Help( ,  , 'Help', ,  STR0011, ; //"A data informada não existe no Calendário do MRP."
				1, 0, , , , , , {STR0012})  //"Cadastre essa data no Calendário do MRP ou informe outra data."
			lOk := .F.
		EndIf
	EndIf

	SVZ->(RestArea(aArea))

Return lOk

/*/{Protheus.doc} P136VldCod
Função para validação do campo VB_CODIGO
@type  Function
@author lucas.franca
@since 24/01/2019
@version P12
@return lRet, logical, .T. quando o código da demanda informada estiver válido.
/*/
Function P136VldCod()
	Local lRet   := .T.
	Local oModel := FwModelActive()

	SVB->(dbSetOrder(1))
	If SVB->(dbSeek(xFilial("SVB")+oModel:GetModel("SVB_MASTER"):GetValue("VB_CODIGO")))
		lRet := .F.
		Help(' ',1,"Help" ,,STR0028,; //"Código de demanda já utilizado."
			     2,0,,,,,, {STR0029}) //"Utilize um código de demanda diferente."
	EndIf
Return lRet

/*/{Protheus.doc} P136DSCPRD
Funcao para preenchimento da descricao do produto / grade
@type  Function
@author brunno.costa
@since 12/06/2019
@version P12
@return cDescricao, caracter, descricao do produto / grade
/*/
Function P136DSCPRD()
	Local oModel     := FwModelActive()
	Local oEventPad  := gtMdlEvent(oModel, "PCPA136EVDEF")
	Local cDescricao := oEventPad:oGrade:getDescricao()
Return cDescricao

/*/{Protheus.doc} P136VldIni
Função para validação do campo VB_DTINI
@type  Function
@author lucas.franca
@since 24/01/2019
@version P12
@return lRet, logical, .T. quando a data inicial informada estiver válida.
/*/
Function P136VldIni()
	Local lRet    := .T.
	Local oModel  := FwModelActive()
	Local oMdlSVB := oModel:GetModel("SVB_MASTER")

	If !Empty(oMdlSVB:GetValue("VB_DTINI")) .And. !Empty(oMdlSVB:GetValue("VB_DTFIM"))
		If oMdlSVB:GetValue("VB_DTINI") > oMdlSVB:GetValue("VB_DTFIM")
			lRet := .F.
			Help(' ',1,"Help" ,,STR0030,; //"Data inicial da demanda não pode ser maior que a data final da demanda."
			     2,0,,,,,, {STR0031 + DtoC(oMdlSVB:GetValue("VB_DTFIM")) + "." }) //"Informe uma data inicial menor que "
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} P136VldFim
Função para validação do campo VB_DTFIM
@type  Function
@author lucas.franca
@since 24/01/2019
@version P12
@return lRet, logical, .T. quando a data final informada estiver válida.
/*/
Function P136VldFim()
	Local lRet    := .T.
	Local oModel  := FwModelActive()
	Local oMdlSVB := oModel:GetModel("SVB_MASTER")

	If !Empty(oMdlSVB:GetValue("VB_DTINI")) .And. !Empty(oMdlSVB:GetValue("VB_DTFIM"))
		If oMdlSVB:GetValue("VB_DTFIM") < oMdlSVB:GetValue("VB_DTINI")
			lRet := .F.
			Help(' ',1,"Help" ,,STR0032,; //"Data final da demanda não pode ser menor que a data inicial da demanda."
			     2,0,,,,,, {STR0033 + DtoC(oMdlSVB:GetValue("VB_DTINI")) + "." }) //"Informe uma data final maior que "
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} A136Import
Faz a importação das demandas a partir da tela de inclusão/modificação
@type  Static Function
@author lucas.franca
@since 28/01/2019
@version P12
@param 01 oView     , Object , Objeto da view ativa.
@param 02 lImportCSV, Logical, Indica se é uma importação de CSV ou normal
@return Nil
/*/
Static Function A136Import(oView, lImportCSV)
	Local oModel  := oView:GetModel()
	Local oMdlSVB := oModel:GetModel("SVB_MASTER")
	Local cCodigo := oMdlSVB:GetValue("VB_CODIGO")
	Local nUltSeq := 0

	If lImportCSV
		If !SVR->(FieldPos("VR_ORIGEM")) > 0
			Return
		EndIf
	Else
		If oModel:GetOperation() != MODEL_OPERATION_INSERT
			Help(' ',1,"Help" ,,STR0066,; //"Importação de demandas disponível somente para operações de inclusão."
				2,0,,,,,, {STR0067}) //"Para executar a importação para uma demanda já existente, utilize a opção disponível no Browse."
			Return
		EndIf
	EndIf

	If Empty(cCodigo)
		Help(' ',1,"Help" ,,STR0034,; //"Código da demanda não informado."
		     2,0,,,,,, {STR0035}) //"Antes de executar a importação, informe o código da demanda."
		Return
	EndIf

	If Empty(oMdlSVB:GetValue("VB_DTINI"))
		Help(' ',1,"Help" ,,STR0036,; //"Data inicial da demanda não informada."
		     2,0,,,,,, {STR0037}) //"Antes de executar a importação, informe a data inicial da demanda."
		Return
	EndIf

	If Empty(oMdlSVB:GetValue("VB_DTFIM"))
		Help(' ',1,"Help" ,,STR0038,; //"Data final da demanda não informada."
		     2,0,,,,,, {STR0039}) //"Antes de executar a importação, informe a data final da demanda."
		Return
	EndIf

	If !lImportCSV
		//Quando a importação é executada a partir da tela de modificação ou inclusão,
		//questiona o usuário se deseja continuar com a importação, pois todos os dados informados em tela
		//serão salvos também.
		If !MsgYesNo(STR0061,STR0062) //"Ao realizar a importação de demandas, todas as alterações realizadas em tela serão salvas. Deseja continuar?" - "Confirmar importação"
			MsgAlert(STR0063) //"Importação de demandas cancelada."
			Return
		EndIf
	EndIf

	//Faz a importação das demandas.
	If lImportCSV
		PCPA136Csv(oModel)
	Else
		If PCPA136Imp(oModel)
			//Atualiza VR_SEQUEN depois da importação
			nUltSeq := getMaxSeq(cCodigo)
			A136AtuSeq(oModel,nUltSeq)

			//Faz a atualização dos dados do Modelo, e recarrega os dados para exibir os dados importados.
			FWMsgRun(,{|| EfetivaMdl(oModel,oView,cCodigo) },STR0050,STR0065) //"Aguarde..." - "Atualizando informações."
		EndIf
	EndIf

Return

/*/{Protheus.doc} EfetivaMdl
Efetiva as alterações do modelo, e recarrega a tela com todas as informações.
@type  Static Function
@author lucas.franca
@since 29/01/2019
@version P12
@param oModel , Object   , Modelo de dados do programa PCPA136
@param oModel , Object   , Objeto da view do programa PCPA136
@param cCodigo, Character, Código da demanda utilizada.
@return Nil
/*/
Static Function EfetivaMdl(oModel,oView,cCodigo)
	Local oMdlSVB := oModel:GetModel("SVB_MASTER")
	Local oMdlSVR := oModel:GetModel("SVR_DETAIL")
	Local aFields := {}
	Local lRet    := .T.
	Local nFields := 0
	Local nPos    := 0

	//Faz o commit do modelo.
	If oMdlSVR:IsEmpty() .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		//É uma inclusão, e o usuário não adicionou nenhuma demanda manual.
		//Adiciona o registro da SVB manualmente.

		//Busca os campos do submodelo.
		aFields := oMdlSVB:oFormModelStruct:GetFields()
		RecLock("SVB",.T.)
			SVB->VB_FILIAL := xFilial("SVB")
			SVB->VB_CODIGO := cCodigo
			SVB->VB_DTINI  := oMdlSVB:GetValue("VB_DTINI")
			SVB->VB_DTFIM  := oMdlSVB:GetValue("VB_DTFIM")
			
			For nFields := 1 to len(aFields)
				//Loop nos campos já adicionados.
				If aFields[nFields,3] $ "VB_FILIAL|VB_CODIGO|VB_DTINI|VB_DTFIM"
					Loop
				EndIf
				//Inclusão do campo customizado.
				SVB->&(aFields[nFields,3]) := oMdlSVB:GetValue(aFields[nFields,3])

			Next nFields
		SVB->(MsUnLock())

	Else
		//Se o usuário preencheu algo no modelo, faz o commit do que foi alterado.
		lRet := (!oModel:lModify) .Or. (oModel:VldData(,.T.) .And. oModel:CommitData())
	EndIf
	If lRet
		//Desativa o modelo para carregar novamente com os dados atualizados.
		oModel:DeActivate()

		//Posiciona na SVB para fazer o LOAD do modelo.
		SVB->(dbSetOrder(1))
		SVB->(dbSeek(xFilial("SVB")+cCodigo))

		//Seta a operação de atualização no modelo e na view.
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oView:SetOperation(OP_ALTERAR)

		//Ajusta o texto de exibição da view.
		oView:oControlBar:SetTitle(STR0001 + " - " + Upper(STR0004)) // "Demandas do MRP - ALTERAR"

		//Desabilita o botão de Importar.
		nPos := aScan(oView:oPanelControlBar:oWnd:aControls,{|x| x!=Nil .And. x:cCaption==STR0023}) //STR0023 == Importar
		If nPos > 0
			oView:oPanelControlBar:oWnd:aControls[nPos]:Disable()
		EndIf
		//Ativa o modelo.
		oModel:Activate()
		//Altera o lModify para .T. para que seja possível clicar no Confirmar.
		oModel:lModify := .T.
	Else
		//Se não validou o modelo, exibe a última mensagem de help.
		oView:ShowLastError()
	EndIf
Return Nil

/*/{Protheus.doc} lOpcionais
Ativa tela para escolha do opcional do produto das demandas inseridas manualmente
@type  Static Function
@author douglas.heydt
@since 24/04/2019
@version P12
@param oModel , Object   , Modelo de dados do programa PCPA136
@return lRet
/*/
Static Function lOpcionais(oModel)
	Local oModelSVR := oModel:GetModel("SVR_DETAIL")
	Local lRet      := .T.
	Local cOpcOld   := oModelSVR:GetValue("VR_OPC")
	Local mOpcOld   := oModelSVR:GetValue("VR_MOPC")

	lRet := SeleOpc(1,"PCPA136",oModelSVR:GetValue("VR_PROD"),,,mOpcOld,"M->VR_MOPC",,oModelSVR:GetValue("VR_QUANT"),oModelSVR:GetValue("VR_DATA"))
	If !lRet
		If !Empty(mOpcOld) .Or. !Empty(cOpcOld)
			//Se cancelou e já tinha opcionais selecionados, retorna para os valores antigos.
			oModelSVR:LoadValue("VR_OPC" , cOpcOld)
			oModelSVR:LoadValue("VR_MOPC", mOpcOld)
			lRet := .T.
		Else
			oModelSVR:LoadValue("VR_QUANT", 0)
		EndIf
	EndIf
	oModelSVR:LoadValue("VLDOPC", lRet)

Return lRet

/*/{Protheus.doc} p136VisOpc
Ativa tela que mostra os opcionais do produto selecionado na grid
@type  Static Function
@author douglas.heydt
@since 24/04/2019
@version P12
@param oModel , Object   , Modelo de dados do programa PCPA136
@return
/*/
Function p136VisOpc(oModel)

	Local oModelSVR:= oModel:GetModel("SVR_DETAIL")

	VisOpcPcp(oModelSVR:GetValue("VR_PROD"),oModelSVR:GetValue("VR_MOPC"),oModelSVR:GetValue("VR_OPC"), MV_PAR01 )

Return .T.

/*/{Protheus.doc} lVldOpc
Valida se estão preenchidos os campos necessários para buscar os opcionais
@type  Static Function
@author douglas.heydt
@since 24/04/2019
@version P12
@param oModel , Object   , Modelo de dados do programa PCPA136
@return lRet
/*/
Static Function lVldOpc(oModel)

	Local oModelSVR := oModel:GetModel("SVR_DETAIL")
	Local lRet := .T.

	If Empty(oModelSVR:GetValue("VR_PROD")) .Or. Empty(oModelSVR:GetValue("VR_DATA")) .Or. Empty(oModelSVR:GetValue("VR_QUANT"))
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} IniLegend
Verifica qual é a legenda que deverá ser exibida em tela.

@type  Static Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param  cIntMrp  , String, Valor do campo VR_INTMRP. Se não passado, utilizará como base o registro posicionado na tabela SVR.
@param  oSubModel, Object, Objeto do submodelo de dados (SVR_DETAIL).
@return cLegend  , String, Indica a legenda que deverá ser exibida em tela.
/*/
Static Function IniLegend(cIntMrp, oSubModel)
	Local cLegend := "BR_AMARELO"
	Local cNrMRP  := SVR->VR_NRMRP

	//Se não passou o valor do VR_INTMRP por parãmetro, verifica a operação do modelo para pegar o valor default.
	If cIntMrp == Nil
		If oSubModel != Nil
			If oSubModel:GetOperation() == MODEL_OPERATION_INSERT
				cIntMrp := '3'
			Else
				//Não é inclusão, pega o valor que está na tabela
				cIntMrp := SVR->VR_INTMRP
			EndIf
		Else
			//Não passou o modelo de dados e não passou o valor do VR_INTMRP, irá
			//utilizar como base o registro posicionado na SVR
			cIntMrp := SVR->VR_INTMRP
		EndIf
	EndIf

	Do Case
		Case cIntMrp == '1' //Integrado com sucesso
			If Empty(cNrMRP)
				cLegend := "BR_VERDE"
			Else
				cLegend := "BR_AZUL"
			EndIf
		Case cIntMrp == '2' //Pendente de integração
			cLegend := "BR_VERMELHO"
		Case cIntMrp == '3' //Não integrado
			cLegend := "BR_AMARELO"
	Endcase

Return cLegend

/*/{Protheus.doc} A136Legend
Apresenta a legenda das opções exibidas em tela.

@type  Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param oView, Object, Objeto da view ativa
@return Nil
/*/
Function A136Legend(oView)
	Local aLegenda := {}

	aAdd(aLegenda, {"BR_AZUL"    , STR0093}) //"Processado pelo MRP."
	aAdd(aLegenda, {"BR_VERDE"   , STR0086}) //"Integrado com sucesso."
	aAdd(aLegenda, {"BR_VERMELHO", STR0087}) //"Pendente de integração"
	aAdd(aLegenda, {"BR_AMARELO" , STR0088}) //"Não integrado"

	BrwLegenda(STR0089, STR0001, aLegenda) //"Integração de demandas com o MRP" //"Demandas do MRP"
Return Nil

/*/{Protheus.doc} loadGrid
Apresenta a legenda das opções exibidas em tela.

@type  Function
@author brunno.costa
@since 11/06/2019
@version P12.1.25
@param 01 - oGridModel, Object, objeto da grid
@param 02 - lCopy     , logico, indica se e operacao de copia
@return aLoad, array, array com os dados para carga
/*/
Static Function loadGrid(oGridModel, lCopy)
	Local oEventPad  := gtMdlEvent(oGridModel:GetModel(), "PCPA136EVDEF")
	Local aLoad      := oEventPad:oGrade:loadGrid(oGridModel, lCopy)
Return aLoad

/*/{Protheus.doc} gtMdlEvent
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 06/06/2019
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

/*/{Protheus.doc} getMaxSeq
Busca a maior sequencia presente na tabela SVR para a demanda

@type  Static Function
@author ricardo.prandi
@since 05/09/2019
@version P12.1.27
@param  cIdDemand, Caracter, Código da demanda que está sendo salva.
@return Nil
/*/
Static Function getMaxSeq(cIdDemand)

	Local cAlias   := GetNextAlias()
	Local cMaxSeq  := 0
	Local cQuery   := ""

	cQuery := " SELECT MAX(VR_SEQUEN) AS MAXSEQ " + ;
	            " FROM " + RetSqlName("SVR")                  + ;
			   " WHERE VR_FILIAL  = '" + xFilial("SVR") + "'" + ;
			     " AND VR_CODIGO  = '" + cIdDemand + "'"      + ;
		 	 	 " AND D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If (cAlias)->(!Eof())
		cMaxSeq := (cAlias)->MAXSEQ
	EndIf

Return cMaxSeq

/*/{Protheus.doc} PCPA136Exc
Função que executa a view do programa para fazer a exclusão.

@type Function
@author marcelo.neumann
@since 29/01/2021
@version P12.1.33
@return nOK, Numérico, Identifica se o usuário confirmou (nOk==0) ou cancelou (nOk==1) a operação.
/*/
Function PCPA136Exc()
	Local nOk    := 0
	Local oModel := FWLoadModel("PCPA136")

	nOk := FWExecView(STR0005, "PCPA136", MODEL_OPERATION_DELETE,,{|| .T. },{|| PCPA136Del(oModel)},,,,,,oModel) //"Excluir"

Return nOk

/*/{Protheus.doc} PCPA136Del
Função que controla a exclusão da demanda.

@type Function
@author marcelo.neumann
@since 29/01/2021
@version P12.1.33
@return lRet, Lógico, Indica se a exclusão foi realizada com sucesso
/*/
Function PCPA136Del(oModel)

	Local lRet := .F.

	Processa({|| lRet := DelDemanda(oModel)}, "Aguarde", "Excluindo os registros...", .F.)

	If !lRet
		Help(' ', 1, "Help", , STR0121, 2, 0) //"Ocorreu um erro ao excluir as demandas."
	EndIf

Return lRet

/*/{Protheus.doc} DelDemanda
Função que executa a exclusão da demanda.

@type Function
@author marcelo.neumann
@since 29/01/2021
@version P12.1.33
@return lRet, Lógico, Indica se a exclusão foi realizada com sucesso
/*/
Static Function DelDemanda(oModel)

	Local cCodigo   := oModel:GetModel("SVB_MASTER"):GetValue("VB_CODIGO")
	Local cQuery    := ""
	Local lRet      := .F.
	Local oEventAPI := gtMdlEvent(oModel, "PCPA136EVAPI")

	cQuery := "UPDATE " + RetSqlName("SVR")                  + ;
	            " SET D_E_L_E_T_   = '*',"                   + ;
				    " R_E_C_D_E_L_ = R_E_C_N_O_"             + ;
			  " WHERE D_E_L_E_T_ = ' '"                      + ;
				" AND VR_FILIAL  = '" + xFilial("SVR") + "'" + ;
				" AND VR_CODIGO  = '" + cCodigo        + "'"

	If TcSqlExec(cQuery) < 0
		lRet := .F.
	Else
		lRet := .T.
		oEventAPI:InTTS(oModel, "SVR_DETAIL")
		oModel:DeActivate()
		oModel:Activate()
	EndIf

Return lRet
