#include "protheus.ch"
#INCLUDE "parmtype.ch"
#include "BIDSHXMLGraphView.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIDshXmlGraphView
Gera um XML contendo a definição para um gráfico do Dashboard

@author		2481 - Paulo R Vieira
@version	P11 
@since		28/12/2009

/*/
//-------------------------------------------------------------------------------------
Class BIDshXmlGraphView from BIDshXmlView
	
	data aAxises
	
	method BIDshXmlGraphView() constructor
	method defineTitles(cTitle, cAxisTop, cAxisLeft, cAxisBottom, cAxisRight)
	
	method buildRangeProperties(initialValue, finalValue, cRgbColor)
	
	method addLineAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addAreaAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addPieAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addBarAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addStackedBarAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addCandlestickAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addScatterAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addAnalogGaugeAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, aRanges, nMin, nMax)
	method addFloatingBarAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addTrendAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addOpenHighLowCloseAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)
	method addFunctionAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, cJavaScriptFunction, nMin, nMax)

	method addAxis(cTitle, cType, aData, cId, cPosAxisX, cPosAxisY, aParameters, nMin, nMax)
	method getXml()
	
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIDshXmlGraphView
Inicializa uma nova instancia.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@return    	Instância do objeto
/*/
//-------------------------------------------------------------------------------------
method BIDshXmlGraphView() class BIDshXmlGraphView
	
	::BIDshXmlView()
	::aAxises := {}
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} defineTitles
Inicializa os títulos do gráfico.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título principal do gráfico
@parameter	Título para o eixo superior do gráfico. Parâmetro opcional com valor padrão vazio.
@parameter	Título para o eixo esquerdo do gráfico. Parâmetro opcional com valor padrão vazio.
@parameter	Título para o eixo inferior do gráfico. Parâmetro opcional com valor padrão vazio.
@parameter	Título para o eixo direito do gráfico. Parâmetro opcional com valor padrão vazio.
/*/
//-------------------------------------------------------------------------------------
method defineTitles(cTitle, cAxisTop, cAxisLeft, cAxisBottom, cAxisRight) class BIDshXmlGraphView
	
	paramtype 0 var cTitle as character
	paramtype 1 var cAxisTop as character optional default ""
	paramtype 2 var cAxisLeft as character optional default ""
	paramtype 3 var cAxisBottom as character optional default ""
	paramtype 4 var cAxisRight as character optional default ""
	
	::aTitles := {}
	aAdd(::aTitles, TBIXMLNode():New("axistop", cTitle))
	aAdd(::aTitles, TBIXMLNode():New("axisbottom", cAxisTop))
	aAdd(::aTitles, TBIXMLNode():New("axisleft", cAxisBottom))
	aAdd(::aTitles, TBIXMLNode():New("axisright", cAxisRight))
	aAdd(::aTitles, TBIXMLNode():New("title", cTitle))
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addAxis
Adição de um Eixo (Axis) ao gráfico do tipo estabelecido pelo parâmetro cType. Foi criado
métodos utilitários para cada tipo de gráfico disponível atualmente. Ver os métodos
addXxxAxis(), onde o Xxx estabelece os tipos de gráfico.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Tipo de gráfico a ser exibido para o eixo
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional
com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional
com valor padrão LEFT.
@parameter	Parâmetros a ser passados para a construção do gráfico. Deverá ser um array de
elemtentos chave e valor, sendo a chave o nome da propriedade. Parâmetro opcional com valor padrão {}.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addAxis(cTitle, cType, aData, cId, cPosAxisX, cPosAxisY, aParameters, nMin, nMax) class BIDshXmlGraphView
	
	Local oAxis, oParms, oAux, nInd
	
	paramtype 0 var cTitle as character
	paramtype 1 var cType as character
	paramtype 2 var aData as array
	paramtype 3 var cId as character optional default ""
	paramtype 4 var cPosAxisX as character optional default "BOTTOM"
	paramtype 5 var cPosAxisY as character optional default "LEFT"
	paramtype 6 var aParameters as array optional default {}
	paramtype 7 var nMin as numeric optional
	paramtype 8 var nMax as numeric optional

	oAxis := TBIXMLNode():New("axis")
	oAxis:AddChild(TBIXMLNode():New("id", cId))
	oAxis:AddChild(TBIXMLNode():New("titleleg", cTitle))
	oAxis:AddChild(TBIXMLNode():New("position", "x"+cPosAxisX + " y"+cPosAxisY))
	oAxis:AddChild(TBIXMLNode():New("type", cType))
	oAxis:AddChild(TBIXMLNode():New("min", nMin))
	oAxis:AddChild(TBIXMLNode():New("max", nMax))
	
	oParms := oAxis:oAddChild(TBIXMLNode():New("typeParm"))
	oParms := oParms:oAddChild(TBIXMLNode():New("parameters"))
	For nInd := 1 to len(aParameters)
		oAux := oParms:oAddChild(TBIXMLNode():New("parameter"))
		aSize(aParameters[nInd], 2)
		
		If valType(aParameters[nInd, 2]) == "A"
			aParameters[nInd, 2] := cBIConcatWSep("|", aParameters[nInd, 2])
		EndIf
		
		oAux:AddChild(TBIXMLNode():New("name", aParameters[nInd, 1]))
		oAux:AddChild(TBIXMLNode():New("value", aParameters[nInd, 2]))
	Next
	
	aAdd(::aAxises, oAxis)
	
	aAdd(::aData, {cId, aData})
	
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getXml
Gera o Xml que representa os dados passado como parâmetro.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@return		Retorna o Xml gerado em formato String
/*/
//-------------------------------------------------------------------------------------
method getXml() class BIDshXmlGraphView
	
	Local oXml, oAttr, oDefs, oData, oAxis, oAux, oAux2, aAux, nInd, nInd2
	
	If !(valType(::aTitles) == "A")
		ClassException BIDshXmlGraphView Message STR0001 //"Defina os títulos do gráfico. Método defineTitles(..)"
		return nil
	EndIf
	
	If !(valType(::aLinks) == "A")
		ClassException BIDshXmlGraphView Message STR0002 //"Defina os Links do gráfico. Método defineLinks(..)"
		return nil
	EndIf
	
	If !(valType(::aAxises) == "A") .OR. len(::aAxises) == 0
		ClassException BIDshXmlGraphView Message STR0003 //"Defina os Eixos do gráfico"
		return nil
	EndIf
	
	oAttr := TBIXMLAttrib():new()
	oAttr:lSet("xmlns", 'http://www.w3schools.com')
	oAttr:lSet("xmlns:xsi", 'http://www.w3.org/2001/XMLSchema-instance')
	oAttr:lSet("xsi:schemaLocation", 'http://www.w3schools.com')
	
	oXml	:= TBIXMLNode():New("dashboard", , oAttr)
	oAux 	:= oXml:oAddChild(TBIXMLNode():New("graph"))
	
	oDefs	:= oAux:oAddChild(TBIXMLNode():New("definition"))
	oData	:= oAux:oAddChild(TBIXMLNode():New("data"))
	
	// adiciona os titulos
	For nInd := 1 to len(::aTitles)
		oDefs:addChild(::aTitles[nInd])
	Next
	
	// adiciona os Links
	For nInd := 1 to len(::aLinks)
		oDefs:addChild(::aLinks[nInd])
	Next
	
	// adiciona os Axis
	oAux := oDefs:oAddChild(TBIXMLNode():New("axises"))
	For nInd := 1 to len(::aAxises)
		oAux:addChild(::aAxises[nInd])
	Next
	
	// adiciona os Filters
	oAux := oDefs:oAddChild(TBIXMLNode():New("filters"))
	For nInd := 1 to len(::aFilters)
		oAux:addChild(::aFilters[nInd])
	Next
	
	// adiciona os Dados/Data
	oAux 	:= oData:oAddChild(TBIXMLNode():New("axises"))
	oAxis 	:= oAux:oAddChild(TBIXMLNode():New("axis"))
	For nInd := 1 to len(::aAxises)
		oAxis:addChild(TBIXMLNode():New("id", ::aData[nInd, 1]))
		
		oAux := oAxis:oAddChild(TBIXMLNode():New("xys"))
		aAux := ::aData[nInd, 2]
		For nInd2 := 1 to len(aAux)
			oAux2 := oAux:oAddChild(TBIXMLNode():New("xy"))
			oAux2:addChild(TBIXMLNode():New("x", aAux[nInd2, 1]))
			oAux2:addChild(TBIXMLNode():New("y", aAux[nInd2, 2]))
		Next
	Next
	
return oXml:cXMLString(.t., "ISO-8859-1")

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addLineAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo LINE (Linha).

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addLineAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "LINE", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addAreaAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo AREA (Área).

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addAreaAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "AREA", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addPieAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo PIE (Pizza).

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addPieAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "PIE", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addBarAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo BAR (Barras).

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addBarAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "BAR", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addStackedBarAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo STACKED BAR.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addStackedBarAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "STACKED_BAR", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addCandlestickAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo CANDLESTICK.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addCandlestickAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "CANDLESTICK", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addScatterAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo SCATTER.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addScatterAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "SCATTER", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addAnalogGaugeAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo ANALOG GAUGE (Hodômetro).

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional
com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional
com valor padrão LEFT.
@parameter  Delimitações das áres do gráfico. Foi criado um método utilitário para
auxiliar (buildRangeProperties) nessa construção.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addAnalogGaugeAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, aRanges, nMin, nMax) class BIDshXmlGraphView
	
	Local nInd
	
	For nInd := 1 to len(aRanges)
		aRanges[nInd] := {"ranges", aRanges[nInd]}
	Next
	
return ::addAxis(cTitle, "ANALOG_GAUGE", aData, cId, cPosAxisX, cPosAxisY, aRanges, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addFloatingBarAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo FLOATING BAR.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional
com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional
com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addFloatingBarAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "FLOATING_BAR", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addTrendAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo TREND (tendência).

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addTrendAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "TREND", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addOpenHighLowCloseAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo OPEN HIGH LOW CLOSE.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addOpenHighLowCloseAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "OPEN_HIGH_LOW_CLOSE", aData, cId, cPosAxisX, cPosAxisY, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addFunctionAxis
Método utilitário para criação de um Eixo (Axis) ao gráfico do tipo FUNCTION, ou seja, 
gráfico customizável através de uma function javascript para gerar os dados para o gráfico.

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Título do Eixo, a ser exibido na legenda
@parameter	Dados para o eixo. Deverá ser um array de pontos X e y.
@parameter	Identificador do eixo. Parâmetro opcional com valor padrão vazio.
@parameter	Posicionamento do gráfico ao eixo X. Pode ser BOTTOM ou TOP. Parâmetro opcional com valor padrão BOTTOM.
@parameter	Posicionamento do gráfico ao eixo Y. Pode ser LEFT ou RIGHT. Parâmetro opcional com valor padrão LEFT.
@parameter	Função JavaScript responsável por gerar os dados do gráfico.
@parameter	Valor mínimo do eixo
@parameter	Valor máximo do eixo
/*/
//-------------------------------------------------------------------------------------
method addFunctionAxis(cTitle, aData, cId, cPosAxisX, cPosAxisY, cJavaScriptFunction, nMin, nMax) class BIDshXmlGraphView
return ::addAxis(cTitle, "FUNCTION", aData, cId, cPosAxisX, cPosAxisY, {"function", cJavaScriptFunction}, nMin, nMax)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} buildRangeProperties
Método auxiliar para a construção de valores delimitadores para os eixos do gráfico

@author		2481 - Paulo R Vieira
@version	P11
@since		28/12/2009
@parameter	Valor Mínimo do delimitador
@parameter	Valor Máximo do delimitador
@parameter	Cor de preenchimento da área do delimitador.
/*/
//-------------------------------------------------------------------------------------
method buildRangeProperties(initialValue, finalValue, cRgbColor) class BIDshXmlGraphView
return { initialValue, finalValue, cRgbColor }
