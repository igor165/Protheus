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
Características: 
	- Armazena todas as características fisicas e lógicas do campo.
	- Constraints: Valor default, required, validate.
	- Mascara para o remote e html.
	- Ordem do campo, valor máx e valor min.
--------------------------------------------------------------------------------------*/
class TBIField from TBIEvtObject

	data fcFieldName	// Nome do campo
	data fcType			// Tipo do campo ($"C,N,D,L,M")
	data fnLength		// Tamanho do campo (opcional para campos Data)
	data fnDecimals		// Numero de decimais para campos Numéricos
	data fbDefault		// Gera o valor default para o campo
	data flSensitive	// Define se o indice é Sensitivo
	
	data fbGet			// Pega o valor do campo virtual
	data fbSet			// Seta o valor do campo virtual
	data fcRealName		// Nome verdadeiro do campo virtual

	data fnFieldID		// Id deste campo
	data fcCaption		// Texto para apresentação do campo (form, relatorio)
	data fcMasc			// Mascara de edição/apresentação remote (picture)
	data fcHtmlMasc		// Mascara de edição/apresentação Html - documentação na propriedade(método)
	data fxMax			// Valor máximo permitido para este campo
	data fxMin			// Valor miximo permitido para este campo
	data fnOrder		// Ordem de apresentação do campo
	data flVisible		// Define se este campo será visivel
	data flBrowse		// Define se este campo será visivel no browse
	data flRequired		// Define se este campo é obrigatório
	data flReadOnly		// Define se este campo é somente-leitura
	data fbValidate		// Bloco de validação do campo
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
Constroe o objeto em memória.
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
Define se o campo é sensitivo
@param lEnabled - .t. campo sensitivo  /  .f. não sensitivo
@return - .t. campo sensitivo  /  .f. não sensitivo
--------------------------------------------------------------------------------------*/                         
method lSensitive(lEnabled) class TBIField
	property ::flSensitive := lEnabled
return ::flSensitive

/*--------------------------------------------------------------------------------------
@property bDefault(bCode)
Define/Recupera o bloco que inicializa o valor default deste campo.
@param nCode - Bloco de código que deve resultar o mesmo tipo de dado deste campo.
@return - Bloco de código que deve resultar o mesmo tipo de dado deste campo.
--------------------------------------------------------------------------------------*/                         
method bDefault(bCode) class TBIField
	property ::fbDefault := bCode
return ::fbDefault

/*--------------------------------------------------------------------------------------
@method cDescValue()
Recupera a descrição de valor armazenada no campo <::faDescValues[x][2]> para um 
<::faDescValues[x][1]> correspondente ao xValue do campo no registro corrente. 
Uso geral: Combos, validações, lista de possiveis valores e descrições.
Caso não existam valores em <::faDescValues>, retorna o mesmo que xValue(cFieldName).
@return - Descrição de valor do campo. Será do tipo String (valtype="C").
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
Bloco de codigo receberá como argumento o objeto tabela dono deste campo (::oOwner()), 
exatamente na situação em que for pedido o valor do campo (::xValue()).
@param bCode - Bloco de codigo que pega o valor do campo virtual.
@return - Bloco de codigo que pega o valor do campo virtual.
--------------------------------------------------------------------------------------*/                         
method bGet(bCode) class TBIField
	property ::fbGet := bCode
return ::fbGet

/*--------------------------------------------------------------------------------------
@property bSet(bCode)
Define/Recupera o bloco que seta o valor do campo virtual.
Bloco de codigo receberá:"
O "1o. argumento" o objeto tabela dono do campo (::oOwner()).
O "2o. argumento" será o valor a ser atribuído, passado em ::xValue().
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
Define/Recupera o texto de apresentação.
@param cValue - Texto de apresentação.
@return - Texto de apresentação.
--------------------------------------------------------------------------------------*/                         
method cCaption(cValue) class TBIField
	property ::fcCaption := cValue
return ::fcCaption

/*--------------------------------------------------------------------------------------
@property lIsVirtual()
Informa se o campo é virtual ou não.
@return - Indicação se campo é virtual.
--------------------------------------------------------------------------------------*/                         
method lIsVirtual() class TBIField
return valType(::bGet()) == "B"

/*--------------------------------------------------------------------------------------
@property cMasc(cValue)
Define/Recupera a mascara para remote(GET).
@param cValue - Texto de apresentação.
@return - Texto de apresentação.
--------------------------------------------------------------------------------------*/                         
method cMasc(cValue) class TBIField
	property ::fcMasc := cValue
return ::fcMasc

/*--------------------------------------------------------------------------------------
@property xMax(xValue)
Define/Recupera o valor máximo para este campo.
@param cValue - Valor máximo a ser definido.
@return - Valor máximo definido.
--------------------------------------------------------------------------------------*/                         
method xMax(xValue) class TBIField
	property ::fxMax := xValue
return ::fxMax

/*--------------------------------------------------------------------------------------
@property xMin(xValue)
Define/Recupera o valor mínimo para este campo.
@param cValue - Valor mínimo a ser definido.
@return - Valor mínimo definido.
--------------------------------------------------------------------------------------*/                         
method xMin(xValue) class TBIField
	property ::fxMin := xValue
return ::fxMin

/*--------------------------------------------------------------------------------------
@property aDescValues(aValues)
Define/Recupera as descrições de valores deste campo.
formato: Array(x,2) onde [x,1]:Valor fisico / [x,2]: Descricao do valor
@param aValues - Array multidimensional contendo os valores e respectivas descrições.
@return - Valor mínimo definido.
--------------------------------------------------------------------------------------*/                         
method aDescValues(aValues) class TBIField
	property ::faDescValues := aValues
return ::faDescValues

/*--------------------------------------------------------------------------------------
@property nOrder(nValue)
Define/Recupera a ordem de apresentação do campo.
@param nValue - Numero de ordem do campo.
@return - Numero de ordem do campo.
--------------------------------------------------------------------------------------*/                         
method nOrder(nValue) class TBIField
	property ::fnOrder := nValue
return ::fnOrder

/*--------------------------------------------------------------------------------------
@property lVisible(lEnabled)
Define se o campo será visível ao usuário.
@param lEnabled - .t. campo visível  /  .f. não visível.
@return - .t. campo visível  /  .f. não visível.
--------------------------------------------------------------------------------------*/                         
method lVisible(lEnabled) class TBIField
	property ::flVisible := lEnabled
return ::flVisible

/*--------------------------------------------------------------------------------------
@property lBrowse(lEnabled)
Define se o campo será visível ao usuário.
@param lEnabled - .t. campo visível  /  .f. não visível.
@return - .t. campo visível  /  .f. não visível.
--------------------------------------------------------------------------------------*/                         
method lBrowse(lEnabled) class TBIField
	property ::flBrowse := lEnabled
return ::flBrowse

/*--------------------------------------------------------------------------------------
@property lRequired(lEnabled)
Define se o campo será obrigatório ao usuário.
@param lEnabled - .t. campo obrigatório  /  .f. não obrigatório.
@return - .t. campo obrigatório  /  .f. não obrigatório.
--------------------------------------------------------------------------------------*/                         
method lRequired(lEnabled) class TBIField
	property ::flRequired := lEnabled
return ::flRequired

/*--------------------------------------------------------------------------------------
@property lReadOnly(lEnabled)
Define se o campo será somente-leitura ao usuário.
@param lEnabled - .t. campo somente-leitura  /  .f. não somente-leitura.
@return - .t. campo somente-leitura  /  .f. não somente-leitura.
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
			// Se for Não Sensitivo	
			if(!::lSensitive())
				(::oOwner():cAlias())->(FieldPut(FieldPos("NS"+::cFieldName()), cBIUpper(xValue)))
			endif
		endif
	endif		

return xValue

/*--------------------------------------------------------------------------------------
@property bValidate(bCode)
Define/Recupera o bloco de código referente a validação deste campo.
@param bCode - Bloco de código de validação.
@return - Bloco de código de validação.
--------------------------------------------------------------------------------------*/                         
method bValidate(bCode) class TBIField
	property ::fbValidate := bCode
return ::fbValidate

/*--------------------------------------------------------------------------------------
@property cHtmlMasc(cMasc)
Define/Recupera o mascara de edição/apresentação html para este campo.
Formato:
<mascara picture(clipper)>[;<atributo html>...]
Atributos:
AREADOT - Adiciona 'a direita do componente o botão "..." para o evento de detalhe
CHECKBOX - Campo aparece como checkbox
COLOR - Campo aparece como paleta de cores
HIDDEN - Campo escondido, invisível ao usuário
LABEL - Campo aparece como texto estático
RADIO - Campo aparece como radio button
PASSWORD - Aparecem asteriscos quando se digita
TEXT - DEFAULT -> (Não colocar na máscara)
TEXTAREA(LINES, COLUMNS) - Campo aparece como memo com LINES linhas e COLUMNS colunas
TIME - Campo aparece como TEXT, porém com validação de TIME (HH:MM:SS)
@param cMasc - Máscara no formato indicado.
@return - Máscara no formato indicado.
--------------------------------------------------------------------------------------*/                         
method cHtmlMasc(cMasc) class TBIField
	property ::fcMasc := cValue
return ::fcMasc

function __TBIField()
return nil

// ************************************************************************************
// Fim da definição da classe TBIField
// ************************************************************************************