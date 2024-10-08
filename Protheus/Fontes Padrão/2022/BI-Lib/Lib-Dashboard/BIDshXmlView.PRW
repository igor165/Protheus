#include "protheus.ch"
#INCLUDE "parmtype.ch"

// tipos de elementos para express�es
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
Abstra��o do modelo de gera��o do XML contendo a defini��o para uma tabela ou gr�fico
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
@return    	Inst�ncia do objeto
/*/
//-------------------------------------------------------------------------------------
method BIDshXmlView() class BIDshXmlView
	
	::aFilters := {}
	::aData := {}
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} defineTitles
Inicializa os t�tulos.

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
Inicializa os links do gr�fico.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Link para realizar o DrillDown, caso necessite e tenha a possibilidade.
Par�metro opcional com valor padr�o vazio.
@parameter	Link para realizar o DrillUp, caso necessite e tenha a possibilidade.
Par�metro opcional com valor padr�o vazio.
@parameter	Link para realizar a requisi��o de Pr�xima P�gina, caso necessite e tenha
a possibilidade. Par�metro opcional com valor padr�o vazio.
@parameter	Link para realizar a requisi��o de P�gina Anterior, caso necessite e tenha
a possibilidade. Par�metro opcional com valor padr�o vazio.
@parameter	Link para realizar o refresh do gr�fico, caso necessite e tenha a possibilidade.
Par�metro opcional com valor padr�o vazio.
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
Cria��o de uma express�o do tipo estabelecido pelo par�metro cType e que ser� utilizada
por Filtros e Alertas. Foi criado m�todos utilit�rios para cada tipo de express�o dispon�vel
atualmente. Ver os m�todos buildXxxExpression(), onde o Xxx estabelece os tipos de express�o.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Tipo de express�o
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
@parameter	Sinaliza se � uma express�o de somente leitura. Par�metro opcional com valor padr�o .F..
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
Adiciona um atributo do tipo filtro para uma tabela. Para auxiliar na constru��o do par�metro
aExpression, foi criado o m�todo buildExpression() e buildXxxExpression(), sendo respectivamente
o m�todo de constru��o gen�rico e os m�todos espec�ficos para cada tipo de express�o

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Descri��o para o filtro
@parameter	Express�es a serem utilizadas pelo filtro. Ver m�todos buildXxxExpression()
@parameter	Sinaliza se o filtro j� se encontra aplicado nos dados para o gr�fico
@parameter	Sinaliza se o filtro n�o pode ser modificado (aplicado ou deselecionado). Par�metro
opcional com valor padr�o .F.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
/*/
//-------------------------------------------------------------------------------------
method addFilter(cDesc, cExpression, lApplied, lReadOnly, cId) class BIDshXmlView
	Local oFilter := ::addAttribute("filter", cDesc, aExpression, lApplied, lReadOnly, cId)
	aAdd(::aFilters, oFilter)
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addAttribute
Adiciona um atributo para uma tabela. Para auxiliar na constru��o do par�metro aExpression, foi criado
o m�todo buildExpression() e buildXxxExpression(), sendo respectivamente o m�todo de constru��o
gen�rico e os m�todos espec�ficos para cada tipo de express�o

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Tipo do atributo a ser adicionado
@parameter	Descri��o para o atributo
@parameter	Express�es a serem utilizadas pelo atributo. Ver m�todos buildXxxExpression()
@parameter	Sinaliza se o atributo j� se encontra aplicado nos dados para o gr�fico
@parameter	Sinaliza se o atributo n�o pode ser modificado (aplicado ou deselecionado). Par�metro
opcional com valor padr�o .F.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
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
Gera o Xml que representa os dados passado como par�metro.

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
Cria��o de uma express�o do tipo TEXT (Texto) e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
/*/
//-------------------------------------------------------------------------------------
method buildTextExpression(xValue) class BIDshXmlView
return ::buildExpression(EXPR_TEXT, xValue)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildTextExpression
Cria��o de uma express�o do tipo LABEL (t�tulo de campo) e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
/*/
//-------------------------------------------------------------------------------------
method buildLabelExpression(xValue) class BIDshXmlView
return ::buildExpression(EXPR_LABEL, xValue)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildSpanExpression
Cria��o de uma express�o do tipo SPAN e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
/*/
//-------------------------------------------------------------------------------------
method buildSpanExpression(xValue) class BIDshXmlView
return ::buildExpression(EXPR_SPAN, xValue)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildDateExpression
Cria��o de uma express�o do tipo DATE (campo data) e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
@parameter	Sinaliza se � uma express�o de somente leitura. Par�metro opcional com valor padr�o .F..
/*/
//-------------------------------------------------------------------------------------
method buildDateExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_DATE, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildEditExpression
Cria��o de uma express�o do tipo EDIT (campo edit�vel) e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
@parameter	Sinaliza se � uma express�o de somente leitura. Par�metro opcional com valor padr�o .F..
/*/
//-------------------------------------------------------------------------------------
method buildEditExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_EDIT, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildCheckboxExpression
Cria��o de uma express�o do tipo CHECKBOX e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
@parameter	Sinaliza se � uma express�o de somente leitura. Par�metro opcional com valor padr�o .F..
/*/
//-------------------------------------------------------------------------------------
method buildCheckboxExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_CHECKBOX, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildRadioExpression
Cria��o de uma express�o do tipo RADIO BUTTON e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
@parameter	Sinaliza se � uma express�o de somente leitura. Par�metro opcional com valor padr�o .F..
/*/
//-------------------------------------------------------------------------------------
method buildRadioExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_RADIO, xValue, cId, lReadOnly)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildComboboxExpression
Cria��o de uma express�o do tipo COMBOBOX (campo selecion�vel) e que ser� utilizada por Filtros e Alertas.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor para a express�o. Poder� ser um caracter ou array, dependendo do tipo deste.
@parameter	Identificador. Par�metro opcional com valor padr�o vazio.
@parameter	Sinaliza se � uma express�o de somente leitura. Par�metro opcional com valor padr�o .F..
/*/
//-------------------------------------------------------------------------------------
method buildComboboxExpression(xValue, cId, lReadOnly) class BIDshXmlView
return ::buildExpression(EXPR_COMBOBOX, xValue, cId, lReadOnly)
