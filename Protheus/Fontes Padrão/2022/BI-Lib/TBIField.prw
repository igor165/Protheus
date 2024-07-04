// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIField.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIField
Classe para os objetos Fields da classe TBIDataSet.
Caracter�sticas: 
	- Armazena todas as caracter�sticas fisicas e l�gicas do campo.
	- Constraints: Valor default, required, validate.
	- Mascara para o remote e html.
	- Ordem do campo, valor m�x e valor min.
--------------------------------------------------------------------------------------*/
class TBIField from TBIEvtObject

	data fcFieldName	// Nome do campo
	data fcType			// Tipo do campo ($"C,N,D,L,M")
	data fnLength		// Tamanho do campo (opcional para campos Data)
	data fnDecimals		// Numero de decimais para campos Num�ricos
	data fbDefault		// Gera o valor default para o campo
	data flSensitive	// Define se o indice � Sensitivo
	
	data fbGet			// Pega o valor do campo virtual
	data fbSet			// Seta o valor do campo virtual
	data fcRealName		// Nome verdadeiro do campo virtual

	data fnFieldID		// Id deste campo
	data fcCaption		// Texto para apresenta��o do campo (form, relatorio)
	data fcMasc			// Mascara de edi��o/apresenta��o remote (picture)
	data fcHtmlMasc		// Mascara de edi��o/apresenta��o Html - documenta��o na propriedade(m�todo)
	data fxMax			// Valor m�ximo permitido para este campo
	data fxMin			// Valor miximo permitido para este campo
	data fnOrder		// Ordem de apresenta��o do campo
	data flVisible		// Define se este campo ser� visivel
	data flBrowse		// Define se este campo ser� visivel no browse
	data flRequired		// Define se este campo � obrigat�rio
	data flReadOnly		// Define se este campo � somente-leitura
	data fbValidate		// Bloco de valida��o do campo
	data faDescValues	// Array(x,2) onde [x,1]:Valor fisico / [x,2]: Descricao do valor 
		
	method New(cFieldName, cType, nLength, nDecimals) constructor
	method Free()
	method NewField(cFieldName, cType, nLength, nDecimals)
	method FreeField()

	method cFieldName(cValue)
	method cType(cValue)
	method nLength(nValue)
	method nDecimals(nValue)
	method cDescValue()
	method bDefault(bCode)
	method lSensitive(lEnabled)
	
	method bGet(bCode)
	method bSet(bCode)
	method cRealName(cValue)

	method nFieldID(nValue)
	method cCaption(cValue)
	method lIsVirtual()
	method cMasc(cValue)
	method cHtmlMasc(cMasc)
	method xMax(xValue)
	method xMin(xValue)
	method nOrder(nValue)
	method lVisible(lEnabled)
	method lBrowse(lEnabled)
	method lRequired(lEnabled)
	method lReadOnly(lEnabled)
	method xValue(xValue)
	method bValidate(bCode)
	method aDescValues(aValues)

	
endclass

/*--------------------------------------------------------------------------------------
@constructor New()
Constroe o objeto em mem�ria.
--------------------------------------------------------------------------------------*/
method New(cFieldName, cType, nLength, nDecimals) class TBIField
	::NewField(cFieldName, cType, nLength, nDecimals)
return

method NewField(cFieldName, cType, nLength, nDecimals) class TBIField
	::NewEvtObject() 

	cType := upper(cType)

	If(cType=="C")
		default nLength := 10
		default nDecimals := 0
	ElseIf(cType=="N")
		default nLength := 10
		default nDecimals := 0
	ElseIf(cType=="D")
		default nLength := 8
		default nDecimals := 0
	ElseIf(cType=="L")
		default nLength := 1
		default nDecimals := 0
	ElseIf(cType=="M")
		default nLength := 10
		default nDecimals := 0
	EndIf

	::flSensitive 	:= .T.
	::fcFieldName 	:= cFieldName
	::fcType 			:= cType
	::fnLength 		:= nLength
	::fnDecimals 		:= nDecimals
	::faDescValues	:= {}
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIField
	::FreeField()
return

method FreeField() class TBIField
	::FreeEvtObject()
return


// ************************************************************************************
// General Properties
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@property cFieldName(cValue)
Define/Recupera o nome do campo.
@param cValue - Nome do campo.
@return - Nome do campo.
--------------------------------------------------------------------------------------*/                         
method cFieldName(cValue) class TBIField
	property ::fcFieldName := cValue
return ::fcFieldName

/*--------------------------------------------------------------------------------------
@property cType(cValue)
Define/Recupera o tipo do campo.
@param cValue - Tipo do campo.
@return - Tipo do campo.
--------------------------------------------------------------------------------------*/                         
method cType(cValue) class TBIField
	property ::fcType := cValue
return ::fcType

/*--------------------------------------------------------------------------------------
@property nLength(nValue)
Define/Recupera o tamanho do campo.
@param nValue - Tamanho do campo.
@return - Tamanho do campo.
--------------------------------------------------------------------------------------*/                         
method nLength(nValue) class TBIField
	property ::fnLength := nValue
return ::fnLength

/*--------------------------------------------------------------------------------------
@property nDecimals(nValue)
Define/Recupera o numero de casas decimais do campo.
@param nValue - Numero de casas decimais.
@return - Numero de casas decimais.
--------------------------------------------------------------------------------------*/                         
method nDecimals(nValue) class TBIField
	property ::fnDecimals := nValue
return ::fnDecimals

/*--------------------------------------------------------------------------------------
@property lSensitive(lEnable)
Define se o campo � sensitivo
@param lEnabled - .t. campo sensitivo  /  .f. n�o sensitivo
@return - .t. campo sensitivo  /  .f. n�o sensitivo
--------------------------------------------------------------------------------------*/                         
method lSensitive(lEnabled) class TBIField
	property ::flSensitive := lEnabled
return ::flSensitive

/*--------------------------------------------------------------------------------------
@property bDefault(bCode)
Define/Recupera o bloco que inicializa o valor default deste campo.
@param nCode - Bloco de c�digo que deve resultar o mesmo tipo de dado deste campo.
@return - Bloco de c�digo que deve resultar o mesmo tipo de dado deste campo.
--------------------------------------------------------------------------------------*/                         
method bDefault(bCode) class TBIField
	property ::fbDefault := bCode
return ::fbDefault

/*--------------------------------------------------------------------------------------
@method cDescValue()
Recupera a descri��o de valor armazenada no campo <::faDescValues[x][2]> para um 
<::faDescValues[x][1]> correspondente ao xValue do campo no registro corrente. 
Uso geral: Combos, valida��es, lista de possiveis valores e descri��es.
Caso n�o existam valores em <::faDescValues>, retorna o mesmo que xValue(cFieldName).
@return - Descri��o de valor do campo. Ser� do tipo String (valtype="C").
--------------------------------------------------------------------------------------*/                         
method cDescValue() class TBIDataSet
	local xRet := ::xValue(), nInd
	local aDescValues := ::aDescValues()
	
	for nInd := 1 to len(aDescValues)
		if aDescValues[nInd, 1] == xRet
			xRet := aDescValues[nInd, 2]
			exit
		endif
	next
	
return xRet

/*--------------------------------------------------------------------------------------
@property bGet(bCode)
Define/Recupera o bloco que pega o valor do campo virtual.
Bloco de codigo receber� como argumento o objeto tabela dono deste campo (::oOwner()), 
exatamente na situa��o em que for pedido o valor do campo (::xValue()).
@param bCode - Bloco de codigo que pega o valor do campo virtual.
@return - Bloco de codigo que pega o valor do campo virtual.
--------------------------------------------------------------------------------------*/                         
method bGet(bCode) class TBIField
	property ::fbGet := bCode
return ::fbGet

/*--------------------------------------------------------------------------------------
@property bSet(bCode)
Define/Recupera o bloco que seta o valor do campo virtual.
Bloco de codigo receber�:"
O "1o. argumento" o objeto tabela dono do campo (::oOwner()).
O "2o. argumento" ser� o valor a ser atribu�do, passado em ::xValue().
@param bCode - Bloco de codigo que seta o valor do campo virtual.
@return - Bloco de codigo que seta o valor do campo virtual.
--------------------------------------------------------------------------------------*/                         
method bSet(bCode) class TBIField
	property ::fbSet := bCode
return ::fbSet

/*--------------------------------------------------------------------------------------
@property cRealName(cValue)
Define/Recupera o bloco que seta o valor do campo virtual.
@param bCode - Bloco de codigo que seta o valor do campo virtual.
@return - Bloco de codigo que seta o valor do campo virtual.
--------------------------------------------------------------------------------------*/                         
method cRealName(cValue) class TBIField
	property ::fcRealName := cValue
return ::fcRealName

/*--------------------------------------------------------------------------------------
@property nFieldID(nValue)
Define/Recupera o ID do campo.
@param nValue - Numero do ID.
@return - Numero do ID.
--------------------------------------------------------------------------------------*/                         
method nFieldID(nValue) class TBIField
	property ::fnFieldID := nValue
return ::fnFieldID

/*--------------------------------------------------------------------------------------
@property cCaption(cValue)
Define/Recupera o texto de apresenta��o.
@param cValue - Texto de apresenta��o.
@return - Texto de apresenta��o.
--------------------------------------------------------------------------------------*/                         
method cCaption(cValue) class TBIField
	property ::fcCaption := cValue
return ::fcCaption

/*--------------------------------------------------------------------------------------
@property lIsVirtual()
Informa se o campo � virtual ou n�o.
@return - Indica��o se campo � virtual.
--------------------------------------------------------------------------------------*/                         
method lIsVirtual() class TBIField
return valType(::bGet()) == "B"

/*--------------------------------------------------------------------------------------
@property cMasc(cValue)
Define/Recupera a mascara para remote(GET).
@param cValue - Texto de apresenta��o.
@return - Texto de apresenta��o.
--------------------------------------------------------------------------------------*/                         
method cMasc(cValue) class TBIField
	property ::fcMasc := cValue
return ::fcMasc

/*--------------------------------------------------------------------------------------
@property xMax(xValue)
Define/Recupera o valor m�ximo para este campo.
@param cValue - Valor m�ximo a ser definido.
@return - Valor m�ximo definido.
--------------------------------------------------------------------------------------*/                         
method xMax(xValue) class TBIField
	property ::fxMax := xValue
return ::fxMax

/*--------------------------------------------------------------------------------------
@property xMin(xValue)
Define/Recupera o valor m�nimo para este campo.
@param cValue - Valor m�nimo a ser definido.
@return - Valor m�nimo definido.
--------------------------------------------------------------------------------------*/                         
method xMin(xValue) class TBIField
	property ::fxMin := xValue
return ::fxMin

/*--------------------------------------------------------------------------------------
@property aDescValues(aValues)
Define/Recupera as descri��es de valores deste campo.
formato: Array(x,2) onde [x,1]:Valor fisico / [x,2]: Descricao do valor
@param aValues - Array multidimensional contendo os valores e respectivas descri��es.
@return - Valor m�nimo definido.
--------------------------------------------------------------------------------------*/                         
method aDescValues(aValues) class TBIField
	property ::faDescValues := aValues
return ::faDescValues

/*--------------------------------------------------------------------------------------
@property nOrder(nValue)
Define/Recupera a ordem de apresenta��o do campo.
@param nValue - Numero de ordem do campo.
@return - Numero de ordem do campo.
--------------------------------------------------------------------------------------*/                         
method nOrder(nValue) class TBIField
	property ::fnOrder := nValue
return ::fnOrder

/*--------------------------------------------------------------------------------------
@property lVisible(lEnabled)
Define se o campo ser� vis�vel ao usu�rio.
@param lEnabled - .t. campo vis�vel  /  .f. n�o vis�vel.
@return - .t. campo vis�vel  /  .f. n�o vis�vel.
--------------------------------------------------------------------------------------*/                         
method lVisible(lEnabled) class TBIField
	property ::flVisible := lEnabled
return ::flVisible

/*--------------------------------------------------------------------------------------
@property lBrowse(lEnabled)
Define se o campo ser� vis�vel ao usu�rio.
@param lEnabled - .t. campo vis�vel  /  .f. n�o vis�vel.
@return - .t. campo vis�vel  /  .f. n�o vis�vel.
--------------------------------------------------------------------------------------*/                         
method lBrowse(lEnabled) class TBIField
	property ::flBrowse := lEnabled
return ::flBrowse

/*--------------------------------------------------------------------------------------
@property lRequired(lEnabled)
Define se o campo ser� obrigat�rio ao usu�rio.
@param lEnabled - .t. campo obrigat�rio  /  .f. n�o obrigat�rio.
@return - .t. campo obrigat�rio  /  .f. n�o obrigat�rio.
--------------------------------------------------------------------------------------*/                         
method lRequired(lEnabled) class TBIField
	property ::flRequired := lEnabled
return ::flRequired

/*--------------------------------------------------------------------------------------
@property lReadOnly(lEnabled)
Define se o campo ser� somente-leitura ao usu�rio.
@param lEnabled - .t. campo somente-leitura  /  .f. n�o somente-leitura.
@return - .t. campo somente-leitura  /  .f. n�o somente-leitura.
--------------------------------------------------------------------------------------*/                         
method lReadOnly(lEnabled) class TBIField
	property ::flReadOnly := lEnabled
return ::flReadOnly

/*--------------------------------------------------------------------------------------
@property xValue(xValue)
Define/Recupera o valor de um campo.
@param xValue - Novo valor do campo.
@return - Valor do campo.
--------------------------------------------------------------------------------------*/                         
method xValue(xValue) class TBIField
	if ::lIsVirtual() // Campo Virtual
    	if valType(xValue) == "U"
    		xValue := eval(::bGet(), ::oOwner()) // GET
    	else
    		eval(::bSet(), ::oOwner(), xValue) // SET
    	endif	
	else // Campo Fisico
		if valType(xValue) == "U"
			xValue := (::oOwner():cAlias())->(FieldGet(FieldPos(::cFieldName()))) // GET
		else
			if(valtype(xValue)=="B") // SET
				xValue := eval(xValue)
			endif
			(::oOwner():cAlias())->(FieldPut(FieldPos(::cFieldName()), xValue))
			// Se for N�o Sensitivo	
			if(!::lSensitive())
				(::oOwner():cAlias())->(FieldPut(FieldPos("NS"+::cFieldName()), cBIUpper(xValue)))
			endif
		endif
	endif		

return xValue

/*--------------------------------------------------------------------------------------
@property bValidate(bCode)
Define/Recupera o bloco de c�digo referente a valida��o deste campo.
@param bCode - Bloco de c�digo de valida��o.
@return - Bloco de c�digo de valida��o.
--------------------------------------------------------------------------------------*/                         
method bValidate(bCode) class TBIField
	property ::fbValidate := bCode
return ::fbValidate

/*--------------------------------------------------------------------------------------
@property cHtmlMasc(cMasc)
Define/Recupera o mascara de edi��o/apresenta��o html para este campo.
Formato:
<mascara picture(clipper)>[;<atributo html>...]
Atributos:
AREADOT - Adiciona 'a direita do componente o bot�o "..." para o evento de detalhe
CHECKBOX - Campo aparece como checkbox
COLOR - Campo aparece como paleta de cores
HIDDEN - Campo escondido, invis�vel ao usu�rio
LABEL - Campo aparece como texto est�tico
RADIO - Campo aparece como radio button
PASSWORD - Aparecem asteriscos quando se digita
TEXT - DEFAULT -> (N�o colocar na m�scara)
TEXTAREA(LINES, COLUMNS) - Campo aparece como memo com LINES linhas e COLUMNS colunas
TIME - Campo aparece como TEXT, por�m com valida��o de TIME (HH:MM:SS)
@param cMasc - M�scara no formato indicado.
@return - M�scara no formato indicado.
--------------------------------------------------------------------------------------*/                         
method cHtmlMasc(cMasc) class TBIField
	property ::fcMasc := cValue
return ::fcMasc

function __TBIField()
return nil

// ************************************************************************************
// Fim da defini��o da classe TBIField
// ************************************************************************************