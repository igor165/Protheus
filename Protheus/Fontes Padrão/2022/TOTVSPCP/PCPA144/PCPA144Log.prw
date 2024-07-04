#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA144.CH"

/*/{Protheus.doc} LogTickets
Classe para constru��o de consulta do log de eventos
@author Douglas Heydt
@since 11/05/2020
@version P12
/*/
CLASS LogTickets FROM LongClassName

	DATA oView      AS OBJECT
	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Consulta de log de eventos
@author Douglas Heydt
@since 11/05/2020
@version P12
@return Self, objeto, classe LogTickets
/*/
METHOD New() CLASS LogTickets
	
	::oView      := Nil

Return Self

/*/{Protheus.doc} Destroy
M�todo para limpar da mem�ria os objetos utilizados pela classe
@author Douglas Heydt
@since 11/05/2020
@version P12
@return Nil
/*/
METHOD Destroy() CLASS LogTickets

	If ::oView <> Nil
		::oView:DeActivate()
	EndIf

	FreeObj(::oView)

Return

/*/{Protheus.doc} AbreTela
M�todo para abrir a tela de consulta
@author Douglas Heydt
@since 11/05/2020
@version P12
@return nOpcao, num�rico, indica a op��o selecionada
/*/
METHOD AbreTela() CLASS LogTickets

	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,"Ok"},;
	                     {.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
	Local oViewExec := FWViewExec():New()

	If ::oView == Nil
		::oView := ViewDef()
	EndIf

	oViewExec:setView(::oView)
	oViewExec:setTitle(STR0191)//"Log de Eventos MRP"
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setButtons(aButtons)
	oViewExec:SetCloseOnOk({||.T.})
	oViewExec:openView(.F.)

	RestArea(aArea)

Return

/*/{Protheus.doc} ModelDef
Defini��o do Modelo
@author Douglas Heydt
@since 11/05/2020
@version P12
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New('PCPA144Log')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormStruct( 1, 'HWM' )

	//Cria campo para o modelo invis�vel
	oStruCab:AddField(STR0096, STR0096, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , )

	//FLD_INVISIVEL - Modelo "invis�vel"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0096)
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados (o nome deve ser atribuido atrav�s da propriedade ::cModelName)
	oModel:AddGrid("GRID_RESULTS", "FLD_INVISIVEL", oStruGrid,,,,,{|| LoadLogMRP()})
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0191) //"Log de Eventos MRP"
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_RESULTS"):SetOptional(.T.)

	oModel:SetDescription(STR0096)
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Defini��o da View
@author Douglas Heydt
@since 11/05/2020
@version P12
@return oView, objeto, view definida
/*/
Static Function ViewDef()

	Local oStruGrid := FWFormStruct(2,'HWM')
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel("PCPA144Log")

	//Defini��es da View
	oView:SetModel(oModel)

	oStruGrid:AddField("HWM_FILIAL"					,;	// [01]  C   Nome do Campo
						"01"						,;	// [02]  C   Ordem
						STR0055					    ,;	// [03]  C   Titulo do campo
						STR0055					    ,;	// [04]  C   Descricao do campo //"Seleciona ordem"
						NIL							,;	// [05]  A   Array com Help
						"L"							,;	// [06]  C   Tipo do campo
						NIL							,;	// [07]  C   Picture
						NIL							,;	// [08]  B   Bloco de PictTre Var
						NIL							,;	// [09]  C   Consulta F3
						.T.							,;	// [10]  L   Indica se o campo � alteravel
						NIL							,;	// [11]  C   Pasta do campo
						NIL							,;	// [12]  C   Agrupamento do campo
						NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL							,;	// [14]  N   Tamanho maximo da maior op��o do combo
						NIL							,;	// [15]  C   Inicializador de Browse
						.T.							,;	// [16]  L   Indica se o campo � virtual
						NIL							,;	// [17]  C   Picture Variavel
						NIL							)	// [18]  L   Indica pulo de linha ap�s o campo

	//V_GRID_RESULTS - View da Grid com resultado da consulta
	oView:AddGrid("V_GRID_RESULTS", oStruGrid, "GRID_RESULTS")

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

	//Habilita os bot�es padr�es de filtro e pesquisa
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDFILTER", {.T.})
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDSEEK", {.T.})

	

Return oView

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invis�vel)
@author Douglas Heydt
@since 11/05/2020
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

    aAdd(aLoad, {"A"}) //dados
    aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} LoadLogMRP
Carga do log de eventos da tabela HWM
@author Douglas Heydt
@since 11/05/2020
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadLogMRP()

	Local aLoad    := {}
	Local aLogMRP  := {}
	Local aItems   := {}
	Local nX       := 0
	Local nLenArr  := 0
	Local cError   := ""
	Local oJsonLog := JsonObject():New()

	aLogMRP := MrpGetLog(cTicket)
	cError := oJsonLog:FromJson(DecodeUtf8(aLogMRP[2]))

	If Empty(cError)
		aItems := oJsonLog["items"]
		nLenArr := Len(aItems)
		For nX := 1 to nLenArr
			aAdd(aLoad, {0,{aItems[nX]["branchId"	],;
							aItems[nX]["ticket"		],;
			                aItems[nX]["product"	],;
							aItems[nX]["event"		],;
							aItems[nX]["logMrp"		],;
							aItems[nX]["doc"		],;
							aItems[nX]["logItem"	],;
							aItems[nX]["logAlias"	],;
							aItems[nX]["productOri"	]}})
		Next nX
	EndIf

Return aLoad
