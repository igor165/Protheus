#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA144.CH"

#DEFINE CRLF Chr(13) + Chr(10)

Static _aLoad    := {}
Static o144Exc   := Nil
Static lChanging := .F.

/*/{Protheus.doc} LimpezaMRPMemoria
Limpeza de Processamentos do MRP em Memória - PCPA712
@author brunno.costa
@since 17/03/2020
@version P12.1.30
/*/
CLASS LimpezaMRPMemoria FROM LongClassName

	DATA aItems     AS ARRAY
	DATA dDataIni   AS DATE
	DATA dDataFim   AS DATE
	DATA nOpcao     AS INTEGER
	DATA nRadio     AS INTEGER
	DATA oDataIni   AS OBJECT
	DATA oDataFim   AS OBJECT
	DATA oModel     AS OBJECT
	DATA oRadio     AS OBJECT
	DATA oView      AS OBJECT
	DATA oViewExec  AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()
	METHOD GeraStringTickets()
	METHOD LimpaBase(cTickets, nSelecao, nTotal)
	METHOD MarcaTodos()
	METHOD MarcaDatas(dDataIni, dDataFim)

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Limpeza da Base do MRP
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return Self, objeto, classe LimpezaMRPMemoria
/*/
METHOD New() CLASS LimpezaMRPMemoria
Return Self

/*/{Protheus.doc} Destroy
Método para limpar da memória os objetos utilizados pela classe
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return Nil
/*/
METHOD Destroy() CLASS LimpezaMRPMemoria

	If Self:aItems != Nil
		aSize(Self:aItems, 0)
		Self:aItems   := Nil
		Self:dDataIni := Nil
		Self:dDataFim := Nil
		Self:nRadio   := Nil
		Self:oRadio   := Nil

		If Self:oView <> Nil
			Self:oView:DeActivate()
		EndIf

		FreeObj(Self:oView)
		Self:oView    := Nil

		FreeObj(Self:oDataIni)
		Self:oDataIni := Nil

		FreeObj(Self:oDataFim)
		Self:oDataFim := Nil
	EndIf
Return

/*/{Protheus.doc} GeraStringTickets
Gera String de Concatenação dos Tickets
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 - nSelecao - número, retorna por referência a quantidade de tickets selecionados
@param 02 - nTotal   - número, retorna por referência a quantidade total de tickets contidos na base
@return cTickets, carcter, string concatenada com todos os tickets marcados para eliminação: "'000001', '000002', '000003',...."
/*/
METHOD GeraStringTickets(nSelecao, nTotal) CLASS LimpezaMRPMemoria

	Local cTickets   := ""
	Local nInd       := 0
	Local oGrid      := o144Exc:oModel:GetModel("GRID")
	Local nOldLine   := oGrid:GetLine()

	Default nSelecao := 0

	If o144Exc:nRadio == 1
		cTickets := "*"
	Else
		nTotal   := oGrid:Length(.F.)
		For nInd := 1 to nTotal
			oGrid:GoLine(nInd)
			If oGrid:GetValueByPos(1) .AND. !Empty(oGrid:GetValueByPos(2))
				nSelecao++
				If Empty(cTickets)
					cTickets +=  "'" + oGrid:GetValueByPos(2) + "'"
				Else
					cTickets += ", '" + oGrid:GetValueByPos(2) + "'"
				EndIf
			EndIf
		Next
		oGrid:GoLine(nOldLine)
	EndIf

Return cTickets

/*/{Protheus.doc} LimpaBase
Consome API MRPResults (MrpRClear) para limpeza da base de dados
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 - cTickets, caracter, string concatenada com todos os tickets marcados para eliminação: "'000001', '000002', '000003',...."
@param 02 - nSelecao, número  , quantidade de tickets selecionados
@param 03 - nTotal  , número  , quantidade total de tickets contidos na base
@return lTotal, lógico, indica se efetuou limpeza completa da base de dados
/*/
METHOD LimpaBase(cTickets, nSelecao, nTotal) CLASS LimpezaMRPMemoria

	Local aNames
	Local aResults
	Local cErros   := ""
	Local nInd     := 0
	Local lTotal   := .F.
	Local oBody    := JsonObject():New()

	If (nSelecao > 0 .OR. AllTrim(cTickets) == "*") .AND. !Empty(cTickets) .AND. ApMsgYesNo( STR0162 + Iif(AllTrim(cTickets) == "*", STR0180, cValToChar(nSelecao) + STR0163) )//"Deseja remover " + cValToChar(nSelecao) + "todos os tickets?" + " ticket(s) selecionados?"
		oBody["cTickets"] := cTickets
		FWMsgRun(, {|| aResults := MrpRClear(oBody)  }, STR0164, STR0165) //"Aguarde...", "Limpando registros..."
		FreeObj(oBody)
		oBody := JsonObject():New()
		oBody:fromJson(aResults[2])

		If aResults[1] == 201
			lTotal := nTotal == nSelecao
		Else
			aNames := oBody["items"]:getNames()
			nTotal := Len(aNames)
			For nInd := 1 to nTotal
				If Upper(oBody["items"][aNames[nInd]]) != "OK"
					cErros += "- " + oBody["items"][aNames[nInd]] + CRLF
				EndIf
			Next
			ApMsgStop("<b>" + STR0166 + ":</b>" + cErros, STR0167) //Ocorreram erros no processamento + ATENÇÃO !!!
		EndIf

	//Respondeu NÃO - Mantém a janela aberta
	Else
		nSelecao := -1
	EndIf

Return lTotal

/*/{Protheus.doc} AbreTela
Método para abrir a tela
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 o144Con, objeto, classe ConsultaTickets (PCPA144Con)
@return nReturn, número, indicador da operação:
						0 - Cancelada
						1 - Confirmada
						2 - Concluída - Limpeza Parcial
						3 - Concluída - Limpeza Total
/*/
METHOD AbreTela(o144Con) CLASS LimpezaMRPMemoria

	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.T.,STR0168},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Confirmar"
	Local oViewExec := FWViewExec():New()
	Local nReturn   := 0

	LoadPrcMRP()

	If Empty(_aLoad)
		ApMsgInfo(STR0169, STR0170) //"Todos os tickets já foram eliminados!", "Alerta!"
	Else
		Self:nOpcao := 0
		o144Exc  := Self

		If Self:oView == Nil
			Self:oView := ViewDef()
			Self:oView:AddUserButton(STR0081, "", {|| AcaoBotao(self, 0, o144Con)}   , , , , .T.) //"Cancelar"
		EndIf

		o144Exc:oModel    := Self:oView:oModel
		o144Exc:oView     := Self:oView
		o144Exc:oViewExec := oViewExec

		oViewExec:setView(::oView)
		oViewExec:setTitle(STR0171) //"Limpeza Base de Processamento do MRP"
		oViewExec:setOperation(MODEL_OPERATION_UPDATE)
		oViewExec:setReduction(40)
		oViewExec:setButtons(aButtons)
		oViewExec:setCancel({|| AcaoBotao(self, 1, o144Con)})
		oViewExec:openView(.F.)

		nReturn := Self:nOpcao
	EndIf

	RestArea(aArea)

	Self:Destroy()
	o144Exc := Nil

Return nReturn

/*/{Protheus.doc} MarcaTodos
Marca Todos os Tickets para Processamento
@author brunno.costa
@since 18/03/2020
@version P12.1.30
/*/
METHOD MarcaTodos() CLASS LimpezaMRPMemoria

	Local nInd     := 0
	Local oGrid    := o144Exc:oModel:GetModel("GRID")
	Local nTotal   := oGrid:Length(.F.)
	Local nOldLine := oGrid:GetLine()
	Local lChecked := .F.

	If !lChanging
		For nInd := 1 to nTotal
			oGrid:GoLine(nInd)
			If nInd == 1
				lChecked := !oGrid:GetValueByPos(1)
			EndIf
			oGrid:LdValueByPos(1, lChecked) //oGrid:LoadValue("CHECK", !oGrid:GetValue("CHECK"))
		Next
		oGrid:GoLine(nOldLine)
	EndIf

Return

/*/{Protheus.doc} MarcaDatas
Marca todos os tickets dentro do intervalo e desmarca os demais
@author brunno.costa
@since 18/03/2020
@version P12.1.30
/*/
METHOD MarcaDatas(dDataIni, dDataFim) CLASS LimpezaMRPMemoria

	Local nInd   := 0
	Local oGrid  := o144Exc:oModel:GetModel("GRID")
	Local nTotal := oGrid:Length(.F.)
	Local dData
	Local nOldLine   := oGrid:GetLine()

	For nInd := 1 to nTotal
		oGrid:GoLine(nInd)
		dData := oGrid:GetValueByPos(3)//oGrid:GetValue("DTINI")
		If dDataIni <= dData .AND. dData <= dDataFim
			oGrid:LdValueByPos(1, .T.) //oGrid:LoadValue("CHECK", .T.)
		Else
			oGrid:LdValueByPos(1, .F.) //oGrid:LoadValue("CHECK", .F.)
		EndIf
	Next
	oGrid:GoLine(nOldLine)

Return

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New('PCPA144Exc')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormModelStruct():New()

	StrGridPrc(@oStruGrid, .T.)

	//Cria campo para o modelo invisível
	oStruCab:AddField(STR0096, STR0096, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , )

	//FLD_INVISIVEL - Modelo "invisível"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0096)
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados (o nome deve ser atribuido através da propriedade ::cModelName)
	oModel:AddGrid("GRID", "FLD_INVISIVEL", oStruGrid,,,,,{|| _aLoad})
	oModel:GetModel("GRID"):SetDescription(STR0082) //"Processamentos MRP"
	oModel:GetModel("GRID"):SetOptional(.T.)
	oModel:GetModel("GRID"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID"):SetNoInsertLine(.T.)
	oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

	oModel:SetDescription(STR0096)
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return oView, objeto, view definida
/*/
Static Function ViewDef()

	Local oStruGrid := FWFormViewStruct():New()
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel("PCPA144Exc")

	lChanging := .T.

	StrGridPrc(@oStruGrid,.F.)

	//Definições da View
	oView:SetModel(oModel)

	//Adiciona Other Object de Parâmetros da Limpeza
	oView:AddOtherObject("V_PARAM", {|oPanel| MontaParam(oPanel) })
	oView:EnableTitleView("V_PARAM", STR0172) //"Parâmetros"

	//V_GRID - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID", oStruGrid, "GRID")
	oView:EnableTitleView("V_GRID", STR0173) //"Seleção de Ticket's para Limpeza"

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_PARAM", 30)
	oView:CreateHorizontalBox("BOX_GRID" , 70)

	//Vincula View aos BOX
	oView:SetOwnerView("V_PARAM", 'BOX_PARAM')
	oView:SetOwnerView("V_GRID" , 'BOX_GRID' )

	//Habilita os botões padrões de filtro e pesquisa
	oView:SetViewProperty("V_GRID", "GRIDFILTER", {.T.} )
	oView:SetViewProperty("V_GRID", "GRIDSEEK"  , {.T.} )

	//Função chamada após ativar a View
    oView:SetAfterViewActivate({|oView| AfterView(oView)})

Return oView

/*/{Protheus.doc} AfterView
Função executada após ativar a view
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function AfterView(oView)

	//Seta funcionalidade de marcar/desmarcar todos clicando no cabeçalho
	oView:GetSubView("V_GRID"):oBrowse:aColumns[1]:bHeaderClick := {|| Iif(o144Exc:nRadio == 2, MudaModo(4), .T.) }

	lChanging := .F.

Return Nil

/*/{Protheus.doc} MontaParam
Carga do modelo mestre (invisível)
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 - oPanel , objeto, painel onde serão montados os parametros
/*/

Static Function MontaParam(oPanel)

	Local oFont    := TFont():New( , , 14, , .T.,,,,, .F. , .F.)

	//Modo de Limpeza
	TSay():New(20, 10,{||STR0177}, oPanel, , oFont,,,,.T., CLR_RED, CLR_WHITE, 200, 20)   //'Modo de Limpeza:'
	o144Exc:nRadio         := 1
	o144Exc:aItems         := {STR0174,STR0175,STR0176}                                   //'Limpeza Total','Seleção Manual','Seleção por Data'
	o144Exc:oRadio         := TRadMenu():New(30, 10, o144Exc:aItems, {|u| MudaModo(u) }, oPanel,,,,,,,, 170, 20,,,, .T., .T.)

	//Data de Processamento
	TSay():New(20, 210,{|| STR0178}, oPanel, , oFont,,,,.T., CLR_RED, CLR_WHITE, 200, 20) //'Data de Processamento:'
	o144Exc:dDataIni := StoD("")
	o144Exc:dDataFim := StoD("")
	o144Exc:oDataIni := TGet():New( 30, 210, bSetGet(o144Exc:dDataIni), oPanel, 040, 009,"@D",,0,,,.F.,,.T.,,.F., {|| o144Exc:nRadio == 3 },.F.,.F.,{|| MudaModo(o144Exc:nRadio) },.F.,.F.)
	o144Exc:oDataFim := TGet():New( 30, 260, bSetGet(o144Exc:dDataFim), oPanel, 040, 009,"@D",,0,,,.F.,,.T.,,.F., {|| o144Exc:nRadio == 3 },.F.,.F.,{|| MudaModo(o144Exc:nRadio) },.F.,.F.)

Return

/*/{Protheus.doc} MudaModo
Ações da Mudança na Seleção do Modo de Execução
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 - nNewRadio, número, nova seleção no tRadMenu
@return nReturn, número, retorna o novo número selecionado
/*/

Static Function MudaModo(nNewRadio)

	Local nReturn   := 1

	If nNewRadio != Nil .and. !lChanging
		nReturn     := (o144Exc:nRadio := Iif(nNewRadio == 4, 2, nNewRadio))

		If o144Exc:oView != Nil .AND. o144Exc:oView:IsActive()
			CursorWait()
			nReturn := MudaModoMR(nNewRadio)
			CursorArrow()
		EndIf
	EndIf

	lChanging := .F.

Return nReturn

/*/{Protheus.doc} MudaModoMR
Ações da Mudança na Seleção do Modo de Execução
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 - nNewRadio, número, nova seleção no tRadMenu
@return nReturn, número, retorna o novo número selecionado
/*/

Static Function MudaModoMR(nNewRadio)

	Local nReturn   := 1
	Local oGridView
	Local lMudou    := .F.

	If nNewRadio == 1
		lChanging        := .T.
		o144Exc:dDataIni := StoD("")
		o144Exc:dDataFim := StoD("")
		lMudou           := .T.
	ElseIf nNewRadio == 2
		lMudou           := .T.
	ElseIf nNewRadio == 3
		If !Empty(o144Exc:dDataIni) .AND. !Empty(o144Exc:dDataFim)
			o144Exc:MarcaDatas(o144Exc:dDataIni, o144Exc:dDataFim)
		EndIf
		lMudou           := .T.
	ElseIf nNewRadio == 4
		o144Exc:MarcaTodos()
		lChanging        := .T.
		o144Exc:dDataIni := StoD("")
		o144Exc:dDataFim := StoD("")
		lMudou           := .T.
	EndIf

	If lMudou
		oGridView := o144Exc:oView:GetSubView("V_GRID")
		oGridView:DeActivate(.T.)
		oGridView:Activate()
		o144Exc:oView:Refresh("V_PARAM")
		o144Exc:oDataIni:Refresh()
		o144Exc:oDataFim:Refresh()
		lChanging        := .F.
		o144Exc:oDataIni:SetFocus()
	EndIf
	o144Exc:oView:oModel:lModify := .F.

Return nReturn

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invisível)
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

	aAdd(aLoad, {"A"}) //dados
	aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} LoadPrcMRP
Carga do grid de processamentos do MRP
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return Nil
/*/
Static Function LoadPrcMRP()
	Local aItems    := {}
	Local aPrcMRP   := {}
	Local cError    := ""
	LocaL cNameUsr  := ""
	Local lCheckDef := .T.
	Local nLenAite  := 0
	Local nX        := 0
	Local oJsonPrc  := JsonObject():New()
	Local oUsers    := JsonObject():New()

	aPrcMRP := MrpGetTick(/*cTicket*/, /*initialDate*/, /*finalDate*/, .T., /*cOrder*/, /*nPage*/, 9999999)
	cError := oJsonPrc:FromJson(aPrcMRP[2])

	If Empty(cError)
		aItems := oJsonPrc["items"]
		nLenAite := Len(aItems)
		For nX := 1 to nLenAite
			If nX == nLenAite
				If aItems[nX]["idStatus"] $"|1|2|" //Reservado/Iniciado
					Loop
				EndIf
			EndIf
			If oUsers[aItems[nX]["user"]] == Nil
				cNameUsr                   := UsrFullName(aItems[nX]["user"])
				oUsers[aItems[nX]["user"]] := cNameUsr
			Else
				cNameUsr := oUsers[aItems[nX]["user"]]
			EndIf

			aAdd(_aLoad, {0,{lCheckDef,;
							aItems[nX]["ticket"],;
			                CToD(aItems[nX]["initialDate"]),;
							aItems[nX]["initialTime"],;
							CToD(aItems[nX]["finalDate"]),;
							aItems[nX]["finalTime"],;
							cNameUsr,;
							aItems[nX]["status"]}})
		Next nX
	EndIf

	FreeObj(oJsonPrc)
	FwFreeArray(aItems)
	FwFreeArray(aPrcMRP)
Return Nil

/*/{Protheus.doc} AcaoBotao
Método chamado ao pressionar algum botão da tela
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 oSelf  , objeto  , classe da tela de consulta
@param 02 nOpcao , numérico, indicador do botão clicado
@param 03 o144Con, objeto  , instância da classe ConsultaTickets (PCPA144Con)
@return lFechaTela, lógico, indicador para fechar a tela
/*/
Static Function AcaoBotao(oSelf, nOpcao, o144Con)

	Local lFechaTela := .F.
	Local nSelecao   := 0
	Local nTotal     := 0
	Local lResult    := .F.

	oSelf:nOpcao := nOpcao

	oSelf:oModel:lModify := .F.
	If nOpcao == 1
		lFechaTela := .T.
		lResult    := oSelf:LimpaBase(oSelf:GeraStringTickets(@nSelecao, @nTotal), @nSelecao, nTotal)
		If nSelecao == -1
			o144Con:nOpcao := 4
			lFechaTela     := .F.
		ElseIf lResult
			o144Con:nOpcao := 3
		Else
			o144Con:nOpcao := 2
		EndIf

	Else
		oSelf:oView:CloseOwner()

	EndIf

	oSelf:oModel:lModify := .F.

Return lFechaTela

/*/{Protheus.doc} StrGridPrc
Monta a estrutura do grid
@author brunno.costa
@since 17/03/2020
@version P12.1.30
@param oStruGrid, objeto, objeto da tela de consulta
@param lModel   , logico, Indica se a chamada é para o model ou view.
@return oStruGrid, objeto, definição dos campos do grid
/*/
Static Function StrGridPrc(oStruGrid, lModel)

	If lModel
		//Campos do ModelDef
		oStruGrid:AddField(""                       ,;    //    [01]  C   Titulo do campo  //"Ticket"
						   ""                       ,;    //    [02]  C   ToolTip do campo
						   "CHECK"                  ,;    //    [03]  C   Id do Field
						   "L"                      ,;    //    [04]  C   Tipo do campo
						   6                        ,;    //    [05]  N   Tamanho do campo
						   0                        ,;    //    [06]  N   Decimal do campo
						   NIL                      ,;    //    [07]  B   Code-block de validação do campo
						   {|| o144Exc:nRadio == 2} ,;    //    [08]  B   Code-block de validação When do campo
						   {}                       ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.                      ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil                      ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL                      ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL                      ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0002     ,;    //    [01]  C   Titulo do campo  //"Ticket"
						   STR0002     ,;    //    [02]  C   ToolTip do campo
						   "TICKET"    ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   6           ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0088     ,;    //    [01]  C   Titulo do campo //"Data Ini."
						   STR0088     ,;    //    [02]  C   ToolTip do campo
						   "DTINI"     ,;    //    [03]  C   Id do Field
						   "D"         ,;    //    [04]  C   Tipo do campo
						   10          ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0089     ,;    //    [01]  C   Titulo do campo //"Hora Ini."
						   STR0089     ,;    //    [02]  C   ToolTip do campo
						   "HRINI"     ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   8           ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0090     ,;    //    [01]  C   Titulo do campo //"Data Fim"
						   STR0090     ,;    //    [02]  C   ToolTip do campo
						   "DTFIM"     ,;    //    [03]  C   Id do Field
						   "D"         ,;    //    [04]  C   Tipo do campo
						   10          ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0091     ,;    //    [01]  C   Titulo do campo //"Hora Fim"
						   STR0091     ,;    //    [02]  C   ToolTip do campo
						   "HRFIM"     ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   8           ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0179     ,;    //    [01]  C   Titulo do campo //"Usuário"
						   STR0179     ,;    //    [02]  C   ToolTip do campo
						   "USER"      ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   50          ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0092     ,;    //    [01]  C   Titulo do campo //"Status"
						   STR0092     ,;    //    [02]  C   ToolTip do campo
						   "STATUS"    ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   15          ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
	Else
		oStruGrid:AddField("CHECK"    ,;    // [01]  C   Nome do Campo
						   "00"       ,;    // [02]  C   Ordem
                           ""         ,;    // [03]  C   Titulo do campo //"Ticket"
                           ""         ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "L"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .T.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("TICKET"   ,;    // [01]  C   Nome do Campo
						   "01"       ,;    // [02]  C   Ordem
                           STR0002    ,;    // [03]  C   Titulo do campo //"Ticket"
                           STR0002    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "C"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("DTINI"    ,;    // [01]  C   Nome do Campo
						   "02"       ,;    // [02]  C   Ordem
                           STR0088    ,;    // [03]  C   Titulo do campo //"Data Ini."
                           STR0088    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "D"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("HRINI"    ,;    // [01]  C   Nome do Campo
						   "03"       ,;    // [02]  C   Ordem
                           STR0089    ,;    // [03]  C   Titulo do campo //"Hora Ini."
                           STR0089    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "C"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("DTFIM"    ,;    // [01]  C   Nome do Campo
						   "04"       ,;    // [02]  C   Ordem
                           STR0090    ,;    // [03]  C   Titulo do campo //"Data Fim"
                           STR0090    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "D"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("HRFIM"    ,;    // [01]  C   Nome do Campo
						   "05"       ,;    // [02]  C   Ordem
                           STR0091    ,;    // [03]  C   Titulo do campo //"Hora Fim"
                           STR0091    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "C"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("USER"     ,;    // [01]  C   Nome do Campo
						   "06"       ,;    // [02]  C   Ordem
                           STR0179    ,;    // [03]  C   Titulo do campo //"Usuário"
                           STR0179    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "C"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
		oStruGrid:AddField("STATUS"   ,;    // [01]  C   Nome do Campo
						   "07"       ,;    // [02]  C   Ordem
                           STR0092    ,;    // [03]  C   Titulo do campo //"Status"
                           STR0092    ,;    // [04]  C   Descricao do campo
                           NIL        ,;    // [05]  A   Array com Help
                           "C"        ,;    // [06]  C   Tipo do campo
                           Nil        ,;    // [07]  C   Picture
                           NIL        ,;    // [08]  B   Bloco de PictTre Var
                           NIL        ,;    // [09]  C   Consulta F3
                           .F.        ,;    // [10]  L   Indica se o campo é alteravel
                           NIL        ,;    // [11]  C   Pasta do campo
                           NIL        ,;    // [12]  C   Agrupamento do campo
                           NIL        ,;    // [13]  A   Lista de valores permitido do campo (Combo)
                           NIL        ,;    // [14]  N   Tamanho maximo da maior opção do combo
                           NIL        ,;    // [15]  C   Inicializador de Browse
                           .T.        ,;    // [16]  L   Indica se o campo é virtual
                           NIL        ,;    // [17]  C   Picture Variavel
                           NIL)             // [18]  L   Indica pulo de linha após o campo
	EndIf

Return oStruGrid
