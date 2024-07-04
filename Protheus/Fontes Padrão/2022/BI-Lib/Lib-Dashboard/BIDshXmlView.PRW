#include "protheus.ch"
#INCLUDE "parmtype.ch"

// tipos de elementos para expressões
#define EXPR_TEXT		"TEXT"
#define EXPR_LABEL		"LABEL"
#define EXPR_SPAN		"SPAN"
#define EXPR_DATE		"DATE"
#define EXPR_EDIT		"EDIT"
#define EXPR_CHECKBOX	"CHECKBOX"
#define EXPR_RADIO    	"RADIO"
#define EXPR_COMBOBOX	"COMBOBOX"
#define EXPR_COMMAND	"COMMAND"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIDshXmlView
Abstração do modelo de geração do XML contendo a definição para uma tabela ou gráfico
do Dashboard

@author		2481 - Paulo R Vieira
@version	P11 
@since		28/12/2009

/*/
//-------------------------------------------------------------------------------------
Class BIDshXmlView from LongClassName
	
	data aTitles
	data aLinks
	data aFilters
	data aData
	
	method BIDshXmlView() constructor
	method defineTitles()
	method defineLinks(cDrillDown, cDrillUp, cPageNext, cPagePrev, cRefresh)
	method addFilter(cDesc, cExpression, lApplied, lReadOnly, cId)
	method getXml()
	
	method buildTextExpression(xValue)
	method buildLabelExpression(xValue)
	method buildSpanExpression(xValue)
	method buildDateExpression(xValue, cId, lReadOnly)
	method buildEditExpression(xValue, cId, lReadOnly)
	method buildCheckboxExpression(xValue, cId, lReadOnly)
	method buildRadioExpression(xValue, cId, lReadOnly)
	method buildComboboxExpression(xValue, cId, lReadOnly)
	
	method buildExpression(cType, xValue, cId, lReadOnly)
	method addAttribute(cAttrType, cDesc, aExpression, lApplied, lReadOnly, cId)
	
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIDshXmlTableView
Inicializa uma nova instancia.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@return    	Instância do objeto
/*/
//-------------------------------------------------------------------------------------
method BIDshXmlView() class BIDshXmlView
	
	::aFilters := {}
	::aData := {}
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} defineTitles
Inicializa os títulos.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
/*/
//-------------------------------------------------------------------------------------
method defineTitles(cTitle) class BIDshXmlView
	// implementar pelas classes filhas
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} defineLinks
Inicializa os links do gráfico.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Link para realizar o DrillDown, caso necessite e tenha a possibilidade.
Parâmetro opcional com valor padrão vazio.
@parameter	Link para realizar o DrillUp, caso necessite e tenha a possibilidade.
Parâmetro opcional com valor padrão vazio.
@parameter	Link para realizar a requisição de Próxima Página, caso necessite e tenha
a possibilidade. Parâmetro opcional com valor padrão vazio.
@parameter	Link para realizar a requisição de Página Anterior, caso necessite e tenha
a possibilidade. Parâmetro opcional com valor padrão vazio.
@parameter	Link para realizar o refresh do gráfico, caso necessite e tenha a possibilidade.
Parâmetro opcional com valor padrão vazio.
/*/
//-------------------------------------------------------------------------------------
method defineLinks(cDrillDown, cDrillUp, cPageNext, cPagePrev, cRefresh) class BIDshXmlView
	
	paramtype 0 var cDrillDown as character optional default ""
	paramtype 1 var cDrillUp as character optional default ""
	paramtype 2 var cPageNext as character optional default ""
	paramtype 3 var cPagePrev as character optional default ""
	paramtype 4 var cRefresh as character optional default ""
	
	::aLinks := {}
	aAdd(::aLinks, TBIXMLNode():New("drilldown", cDrillDown))
	aAdd(::aLinks, TBIXMLNode():New("drillup", cDrillUp))
	aAdd(::aLinks, TBIXMLNode():New("pagenext", cPageNext))
	aAdd(::aLinks, TBIXMLNode():New("pageprev", cPagePrev))
	aAdd(::aLinks, TBIXMLNode():New("refresh", cRefresh))
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildExpression
Criação de uma expressão do tipo estabelecido pelo parâmetro cType e que será utilizada
por Filtros e Alertas. Foi criado métodos utilitários para cada tipo de expressão disponível
atualmente. Ver os métodos buildXxxExpression(), onde o Xxx estabelece os tipos de expressão.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Tipo de expressão
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
@parameter	Sinaliza se é uma expressão de somente leitura. Parâmetro opcional com valor padrão .F..
/*/
//-------------------------------------------------------------------------------------
method buildExpression(cType, xValue, cId, lReadOnly) class BIDshXmlView
	
	Local oXmlNode, oAttr, nInd
	
	paramtype 0 var cType as character
	paramtype 2 var cId as character optional default ""
	paramtype 3 var lReadOnly as logical optional default .F.
	
	If upper(cType) == EXPR_TEXT .OR. upper(cType) == EXPR_LABEL .OR. upper(cType) == EXPR_SPAN
		oXmlNode := TBIXMLNode():New(lower(cType), xValue)
	Else
		oAttr := TBIXMLAttrib():new()
		oAttr:lSet("id", cId)
		oAttr:lSet("readonly", iif(lReadOnly, "true", "false"))
	
		If upper(cType) == EXPR_COMBOBOX
			oXmlNode := TBIXMLNode():New(lower(cType), , oAttr)
			
			For nInd := 1 to len(xValue)
				oXmlNode:addChild(TBIXMLNode():New("option", xValue[nInd]))
			Next
		ElseIf upper(cType) == EXPR_DATE .OR. upper(cType) == EXPR_EDIT .OR. upper(cType) == EXPR_CHECKBOX .OR. upper(cType) == EXPR_RADIO
			oXmlNode := TBIXMLNode():New(lower(cType), xValue, oAttr)
		EndIf
	EndIf
	
return oXmlNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addFilter
Adiciona um atributo do tipo filtro para uma tabela. Para auxiliar na construção do parâmetro
aExpression, foi criado o método buildExpression() e buildXxxExpression(), sendo respectivamente
o método de construção genérico e os métodos específicos para cada tipo de expressão

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Descrição para o filtro
@parameter	Expressões a serem utilizadas pelo filtro. Ver métodos buildXxxExpression()
@parameter	Sinaliza se o filtro já se encontra aplicado nos dados para o gráfico
@parameter	Sinaliza se o filtro não pode ser modificado (aplicado ou deselecionado). Parâmetro
opcional com valor padrão .F.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
/*/
//-------------------------------------------------------------------------------------
method addFilter(cDesc, cExpression, lApplied, lReadOnly, cId) class BIDshXmlView
	Local oFilter := ::addAttribute("filter", cDesc, aExpression, lApplied, lReadOnly, cId)
	aAdd(::aFilters, oFilter)
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addAttribute
Adiciona um atributo para uma tabela. Para auxiliar na construção do parâmetro aExpression, foi criado
o método buildExpression() e buildXxxExpression(), sendo respectivamente o método de construção
genérico e os métodos específicos para cada tipo de expressão

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Tipo do atributo a ser adicionado
@parameter	Descrição para o atributo
@parameter	Expressões a serem utilizadas pelo atributo. Ver métodos buildXxxExpression()
@parameter	Sinaliza se o atributo já se encontra aplicado nos dados para o gráfico
@parameter	Sinaliza se o atributo não pode ser modificado (aplicado ou deselecionado). Parâmetro
opcional com valor padrão .F.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
/*/
//-------------------------------------------------------------------------------------
method addAttribute(cAttrType, cDesc, aExpression, lApplied, lReadOnly, cId) class BIDshXmlView
	
	Local oAux, oAux2, nInd
	
	paramtype 0 var cDesc as character
	paramtype 1 var aExpression as array
	paramtype 2 var lApplied as logical
	paramtype 3 var lReadOnly as logical optional default .T.
	paramtype 4 var cId as character optional default ""
	
	oAux := TBIXMLNode():New(cAttrType)
	oAux:AddChild(TBIXMLNode():New("id", cId))
	oAux:AddChild(TBIXMLNode():New("desc", cDesc))
	
	oAux2 := oAux:oAddChild(TBIXMLNode():New("expression"))
	For nInd := 1 to len(aExpression)
		oAux2:addChild(aExpression[nInd])
	Next
	
	oAux:AddChild(TBIXMLNode():New("applied", iif(lApplied, "true", "false")))
	oAux:AddChild(TBIXMLNode():New("readonly", iif(lReadOnly, "true", "false")))
	
return oAux

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getXml
Gera o Xml que representa os dados passado como parâmetro.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@return		Retorna o Xml gerado em formato String
/*/
//-------------------------------------------------------------------------------------
method getXml() class BIDshXmlView
	// implementar pelas classes filhas
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildTextExpression
Criação de uma expressão do tipo TEXT (Texto) e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
/*/
//-------------------------------------------------------------------------------------
method buildTextExpression(xValue) class BIDshXmlView
return ::buildExpression(EXPR_TEXT, xValue)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildTextExpression
Criação de uma expressão do tipo LABEL (título de campo) e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
/*/
//-------------------------------------------------------------------------------------
method buildLabelExpression(xValue) class BIDshXmlView
return ::buildExpression(EXPR_LABEL, xValue)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildSpanExpression
Criação de uma expressão do tipo SPAN e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
/*/
//-------------------------------------------------------------------------------------
method buildSpanExpression(xValue) class BIDshXmlView
return ::buildExpression(EXPR_SPAN, xValue)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildDateExpression
Criação de uma expressão do tipo DATE (campo data) e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
@parameter	Sinaliza se é uma expressão de somente leitura. Parâmetro opcional com valor padrão .F..
/*/
//-------------------------------------------------------------------------------------
method buildDateExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_DATE, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildEditExpression
Criação de uma expressão do tipo EDIT (campo editável) e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
@parameter	Sinaliza se é uma expressão de somente leitura. Parâmetro opcional com valor padrão .F..
/*/
//-------------------------------------------------------------------------------------
method buildEditExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_EDIT, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildCheckboxExpression
Criação de uma expressão do tipo CHECKBOX e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
@parameter	Sinaliza se é uma expressão de somente leitura. Parâmetro opcional com valor padrão .F..
/*/
//-------------------------------------------------------------------------------------
method buildCheckboxExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_CHECKBOX, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildRadioExpression
Criação de uma expressão do tipo RADIO BUTTON e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
@parameter	Sinaliza se é uma expressão de somente leitura. Parâmetro opcional com valor padrão .F..
/*/
//-------------------------------------------------------------------------------------
method buildRadioExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_RADIO, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildComboboxExpression
Criação de uma expressão do tipo COMBOBOX (campo selecionável) e que será utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a expressão. Poderá ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Parâmetro opcional com valor padrão vazio.
@parameter	Sinaliza se é uma expressão de somente leitura. Parâmetro opcional com valor padrão .F..
/*/
//-------------------------------------------------------------------------------------
method buildComboboxExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_COMBOBOX, xValue, cId, lReadOnly)
