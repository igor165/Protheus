#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA144.CH"

/*/{Protheus.doc} ConsultaTickets
Classe para construção de consulta de tickets do MRP
@author Renan Roeder
@since 25/11/2019
@version P12
/*/
CLASS ConsultaTickets FROM LongClassName

	DATA cCodigo    AS STRING
	DATA nOpcao     AS INTEGER
	DATA oView      AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()
	METHOD GetCodigo()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Consulta de Processamentos do MRP
@author Renan Roeder
@since 26/11/2019
@version P12
@return Self, objeto, classe ConsultaTickets
/*/
METHOD New() CLASS ConsultaTickets

	::cCodigo    := Nil
	::oView      := Nil
	::nOpcao     := 0

Return Self

/*/{Protheus.doc} Destroy
Método para limpar da memória os objetos utilizados pela classe
@author Renan Roeder
@since 26/11/2019
@version P12
@return Nil
/*/
METHOD Destroy() CLASS ConsultaTickets

	If ::oView <> Nil
		::oView:DeActivate()
	EndIf

	FreeObj(::oView)

Return

/*/{Protheus.doc} AbreTela
Método para abrir a tela de consulta
@author Renan Roeder
@since 26/11/2019
@version P12
@return nOpcao, numérico, indica a opção selecionada
/*/
METHOD AbreTela() CLASS ConsultaTickets

	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.T.,STR0080},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Selecionar"
	Local oViewExec := FWViewExec():New()

	::nOpcao := 0

	If ::oView == Nil
		::oView := ViewDef()
		::oView:AddUserButton(STR0081, "", {|| AcaoBotao(self, 0)}   , , , , .T.) //"Cancelar"
		::oView:AddUserButton(STR0161, "", {|| LimpezaMRPMemoria():abreTela(self), AcaoBotao(self, 2)}   , , , , .T.) //"Limpeza"
	EndIf

	oViewExec:setView(::oView)
	oViewExec:setTitle(STR0082) //"Processamentos MRP"
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setReduction(70)
	oViewExec:setButtons(aButtons)
	oViewExec:setCancel({|| AcaoBotao(self, 1)})
	oViewExec:openView(.F.)

	RestArea(aArea)

Return ::nOpcao

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Renan Roeder
@since 26/11/2019
@version P12
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New('PCPA144Con')
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
	oModel:AddGrid("GRID_RESULTS", "FLD_INVISIVEL", oStruGrid,,,,,{|| LoadPrcMRP()})
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0082) //"Processamentos MRP"
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_RESULTS"):SetOptional(.T.)

	oModel:SetDescription(STR0096)
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Renan Roeder
@since 26/11/2019
@version P12
@return oView, objeto, view definida
/*/
Static Function ViewDef()

	Local oStruGrid := FWFormViewStruct():New()
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel("PCPA144Con")

	StrGridPrc(@oStruGrid,.F.)

	//Definições da View
	oView:SetModel(oModel)

	//V_GRID_RESULTS - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID_RESULTS", oStruGrid, "GRID_RESULTS")

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

	//Habilita os botões padrões de filtro e pesquisa
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDFILTER", {.T.})
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDSEEK", {.T.})

Return oView

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invisível)
@author Renan Roeder
@since 26/11/2019
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

   aAdd(aLoad, {"A"}) //dados
   aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} LoadPrcMRP
Carga do grid de processamentos do MRP
@author Renan Roeder
@since 26/11/2019
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadPrcMRP()

	Local aLoad    := {}
	Local aPrcMRP  := {}
	Local nX       := 0
	Local nLenAite := 0
	Local oJsonPrc := JsonObject():New()
	Local cStatus  := "3,6,7,9" //Finalizado,Documentos Gerados

	aPrcMRP := MrpGetAPcd(cFilAnt,"ticket,startDate,startTime,endDate,endTime,status","ticket|DESC",,9999,"Processed_Mrp",cStatus)
	cError := oJsonPrc:FromJson(aPrcMRP[2])

	If Empty(cError)
		aItems := oJsonPrc["items"]
		nLenAite := Len(aItems)
		For nX := 1 to nLenAite
			aAdd(aLoad, {0,{aItems[nX]["ticket"],;
			                StoD(StrTran(aItems[nX]["startDate"],"-","")),;
							aItems[nX]["startTime"],;
							StoD(StrTran(aItems[nX]["endDate"],"-","")),;
							aItems[nX]["endTime"],;
							P144Status(aItems[nX]["status"])}})
		Next nX
	EndIf

Return aLoad

/*/{Protheus.doc} P144Status
Retorna a descrição do status de processamento
@author Renan Roeder
@since 26/11/2019
@version P12
@return cDescricao, caracter, descrição do status
/*/
Function P144Status(cStatus)
Local cDescricao

	Do Case
		Case cStatus == "1"
			cDescricao := STR0083 //"Reservado"
		Case cStatus == "2"
			cDescricao := STR0084 //"Iniciado"
		Case cStatus == "3"
			cDescricao := STR0085 //"Finalizado"
		Case cStatus == "4"
			cDescricao := STR0086 //"Cancelando"
		Case cStatus == "5"
			cDescricao := STR0087 //"Cancelado"
		Case cStatus == "6"
			cDescricao := STR0144 //"Documentos gerados"
		Case cStatus == "7"
			cDescricao := STR0240 //"Documentos gerados com pendências."
		Case cStatus == "8"
			cDescricao := STR0275 //"Excluído"
		Case cStatus == "9"
			cDescricao := STR0277 //"Documentos gerados (integrando)"
	EndCase

Return cDescricao


/*/{Protheus.doc} AcaoBotao
Método chamado ao pressionar algum botão da tela
@author Renan Roeder
@since 26/11/2019
@version P12
@param 01 oSelf , objeto  , classe da tela de consulta
@param 02 nOpcao, numérico, indicador do botão clicado
@return lFechaTela, lógico, indicador para sempre fechar a tela
/*/
Static Function AcaoBotao(oSelf, nOpcao)

	Local lFechaTela := .F.
	Local oGridView
	Local oModel     := oSelf:oView:GetModel()
	Local oGrid      := oModel:GetModel("GRID_RESULTS")

	If nOpcao == 1
		A144ClData()
	EndIf

	oSelf:cCodigo    := oGrid:GetValue("TICKET")

	If Empty(oSelf:cCodigo)
		oSelf:nOpcao := 0
	Else
		oSelf:nOpcao := nOpcao
	EndIf

	If nOpcao == 1
		lFechaTela := .T.

	ElseIf nOpcao == 2 .OR. nOpcao == 3
		If nOpcao == 2
			oGrid:ClearData(.F.,.F.)
		Else
			oGrid:ClearData(.F.,.T.)
		EndIf
		oGrid:DeActivate()
		oGrid:Activate()

		oGridView := oSelf:oView:GetSubView("V_GRID_RESULTS")
		oGridView:DeActivate(.T.)
		oGridView:Activate()

	Else
		oSelf:oView:CloseOwner()
	EndIf

Return lFechaTela


/*/{Protheus.doc} GetCodigo
Método para recuperar os registros que foram selecionados na consulta
@author Renan Roeder
@since 26/11/2019
@version P12
@return cCodigo, caracter, código do setup selecionado na tela
/*/
METHOD GetCodigo() CLASS ConsultaTickets

Return ::cCodigo

/*/{Protheus.doc} StrGridPrc
Monta a estrutura do grid
@author Renan Roeder
@since 25/11/2019
@version P12
@param oStruGrid, objeto, objeto da tela de consulta
@param lModel   , logico, Indica se a chamada é para o model ou view.
@return oStruGrid, objeto, definição dos campos do grid
/*/
Static Function StrGridPrc(oStruGrid, lModel)

	If lModel
		//Campos do ModelDef
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
		oStruGrid:AddField("STATUS"   ,;    // [01]  C   Nome do Campo
						   "06"       ,;    // [02]  C   Ordem
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
