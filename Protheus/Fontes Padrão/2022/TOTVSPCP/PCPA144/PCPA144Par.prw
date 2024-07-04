#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA144.CH"

/*/{Protheus.doc} ConsultaParametros
Classe para construção de consulta de parametros do MRP
@author Renan Roeder
@since 25/11/2019
@version P12
/*/
CLASS ConsultaParametros FROM LongClassName

	DATA aParMRP    AS ARRAY
	DATA cTicket    AS Character
	DATA oView      AS OBJECT
	DATA oModel     AS OBJECT

	METHOD New(aParMRP, cTicket) CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Consulta de Parametros
@author Renan Roeder
@since 26/11/2019
@version P12
@return Self, objeto, classe ConsultaParametros
/*/
METHOD New(aParMRP, cTicket) CLASS ConsultaParametros

	::oView      := Nil
	::oModel     := Nil
	::aParMRP    := aClone(aParMRP)
	::cTicket    := cTicket

Return Self

/*/{Protheus.doc} Destroy
Método para limpar da memória os objetos utilizados pela classe
@author Renan Roeder
@since 26/11/2019
@version P12
@return Nil
/*/
METHOD Destroy() CLASS ConsultaParametros

	If ::oModel <> Nil
		::oModel:DeActivate()
		::oModel:Destroy()
	EndIf

	FreeObj(::oModel)

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
@return
/*/
METHOD AbreTela() CLASS ConsultaParametros

	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.T.,STR0013},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Fechar"
	Local oViewExec := FWViewExec():New()

	If ::oModel == Nil
		::oModel := ModelDef(::aParMrp)
	EndIf

	If ::oView == Nil
		::oView := ViewDef(::cTicket)
	EndIf

	oViewExec:setModel(::oModel)
	oViewExec:setView(::oView)
	oViewExec:setTitle(STR0093) //"Parametros MRP"
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setReduction(55)
	oViewExec:setButtons(aButtons)
	oViewExec:setCancel({|| .T. })
	oViewExec:openView(.F.)

	RestArea(aArea)

Return

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Renan Roeder
@since 26/11/2019
@version P12
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef(aParMrp)

	Local oModel    := MPFormModel():New('PCPA144Par')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormModelStruct():New()

	 StrGridPar(@oStruGrid, .T.)

	//Cria campo para o modelo invisível
	oStruCab:AddField(STR0096, STR0096, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , )

	//FLD_INVISIVEL - Modelo "invisível"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0096)
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados (o nome deve ser atribuido através da propriedade ::cModelName)
	oModel:AddGrid("GRID_RESULTS", "FLD_INVISIVEL", oStruGrid,,,,,{|| aParMrp })
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0093) //"Parametros MRP"
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
Static Function ViewDef(cTicket)

	Local oStruGrid := FWFormViewStruct():New()
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel("PCPA144Par")

	StrGridPar(@oStruGrid,.F.)

	//Definições da View
	oView:SetModel(oModel)

	//V_GRID_RESULTS - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID_RESULTS", oStruGrid, "GRID_RESULTS")

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

	oView:addUserButton(STR0278, "",{|x, y| exportTXT(x,y,cTicket)}) // "Exportar parâmetros"
	//Habilita os botões padrões de filtro e pesquisa
	//oView:SetViewProperty("V_GRID_RESULTS", "GRIDFILTER", {.T.})
	//oView:SetViewProperty("V_GRID_RESULTS", "GRIDSEEK", {.T.})

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

/*/{Protheus.doc} StrGridPar
Monta a estrutura do grid
@author Renan Roeder
@since 25/11/2019
@version P12
@return cDescricao, caracter, descrição do setup selecionado na tela
/*/
Static Function StrGridPar(oStruGrid, lModel)

	If lModel
		//Campos do ModelDef
		oStruGrid:AddField(STR0094     ,;    //    [01]  C   Titulo do campo //"Parâmetro"
						   STR0094     ,;    //    [02]  C   ToolTip do campo
						   "PARAM"     ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   150         ,;    //    [05]  N   Tamanho do campo
						   0           ,;    //    [06]  N   Decimal do campo
						   NIL         ,;    //    [07]  B   Code-block de validação do campo
						   NIL         ,;    //    [08]  B   Code-block de validação When do campo
						   {}          ,;    //    [09]  A   Lista de valores permitido do campo
						   .F.         ,;    //    [10]  L   Indica se o campo tem preenchimento obrigatório
						   Nil         ,;    //    [11]  B   Code-block de inicializacao do campo
						   NIL         ,;    //    [12]  L   Indica se trata-se de um campo chave
						   NIL         ,;    //    [13]  L   Indica se o campo pode receber valor em uma operação de update.
						   .T.)              //    [14]  L   Indica se o campo é virtual
		oStruGrid:AddField(STR0095     ,;    //    [01]  C   Titulo do campo //"Valor"
						   STR0095     ,;    //    [02]  C   ToolTip do campo
						   "VALOR"     ,;    //    [03]  C   Id do Field
						   "C"         ,;    //    [04]  C   Tipo do campo
						   100         ,;    //    [05]  N   Tamanho do campo
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
		oStruGrid:AddField("PARAM"    ,;    // [01]  C   Nome do Campo
						   "02"       ,;    // [02]  C   Ordem
                           STR0094    ,;    // [03]  C   Titulo do campo //"Parâmetro"
                           STR0094    ,;    // [04]  C   Descricao do campo
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
		oStruGrid:AddField("VALOR"    ,;    // [01]  C   Nome do Campo
						   "03"       ,;    // [02]  C   Ordem
                           STR0095    ,;    // [03]  C   Titulo do campo //"Valor"
                           STR0095    ,;    // [04]  C   Descricao do campo
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

/*/{Protheus.doc} exportTXT
Exporta os parâmetros em arquivo txt
@type  Static Function
@author Lucas Fagundes
@since 07/06/2022
@version P12
@param 01 - oView, Object, View (MVC).
@param 02 - oButton, Object, Botão (MVC).
@paran 03 - cTicket, Caracter, Ticket que irá exportar os parâmetros.
@return Nil
/*/
Static Function exportTXT(oView, oButton, cTicket)
	Local cDir := ""
	Local oModel := oView:GetModel("GRID_RESULTS")
	Local nIndex := 0
	Local cParam := ""
	Local cValor := ""
	Local nHandle := -1

	cDir := cGetFile("", STR0278, /*nMascpadrao*/, /*cDirinicial*/, .F.,; // "Exportar parâmetros"
	 nOr(GETF_RETDIRECTORY,  GETF_LOCALHARD), /*lArvore*/, /*lKeepCase*/)

	If !Empty(cDir) .and. oModel != Nil
		cDir += "MRP_PARAM_" + cTicket + ".txt"
		nHandle := FCreate(cDir, Nil, Nil, .F.)

		If nHandle == -1
			Help(' ', 1,"FError" + CValToChar(FError()) ,,STR0279 + cValtoChar(FError()), 1, 1, , , , , , {STR0280}) // "Erro na criação do arquivo com os parâmetros do MRP. FError: "  "Consulte o suporte para mais informações."
		Else
			For nIndex := 1 To oModel:Length()
				cParam := oModel:GetValue("PARAM", nIndex)
				cValor := oModel:GetValue("VALOR", nIndex)
				
				FWrite(nHandle, cParam + " | " + cValor + CHR(10))
			Next
			FClose(nHandle)
		EndIf
	EndIf

Return Nil
