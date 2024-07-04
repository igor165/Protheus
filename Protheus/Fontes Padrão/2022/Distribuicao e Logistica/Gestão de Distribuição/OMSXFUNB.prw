#include "protheus.ch"
/*
+---------+--------------------------------------------------------------------+
|Fun��o   | OMSXFUNB - Fun��es Para Automa��o de Testes                        |
+---------+--------------------------------------------------------------------+
|Objetivo | Dever� agrupar todas as fun��es que ser�o utilizadas na            |
|         | automa��o de testes.                                               |
+---------+--------------------------------------------------------------------+
*/
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OmsAutVld
Realiza a valida��o do registro da tabela gravada pela automa��o.
@type function
@author Wander Horongoso | Amanda Rosa Vieira
@since 22/05/2020
@param
oHelper: objeto helper da automa��o
cTable: tabela que ser� validada
aWhere: rela��o de campos que ser�o utilizados no where.
    aFields[1]: nome do campo
    aFields[2]: conte�do do campo
aFields: rela��o de campos a serem validados.
    aFields[1]: nome do campo
    aFields[2]: conte�do do campo
/*/
//-------------------------------------------------------------------------------------------------
Function OmsAutVld(oHelper, cTable, aWhere, aFields)
Local cQuery := ""
Local nField := 0
Local xVal   := Nil
	For nField := 1 To Len(aWhere)
		xVal := aWhere[nField][2]
	    xVal := Iif(ValType(xVal) == 'C',"'" + xVal + "'",xVal)
		If nField == 1
	    	cQuery  += cTable + "." + aWhere[nField][1] + " = " + xVal
		Else
			cQuery  += ' AND ' + cTable + "." + aWhere[nField][1] + " = " + xVal
		EndIf
	Next nField

	For nField := 1 To Len(aFields)
		xVal := aFields[nField][2]
		xVal := Iif(ValType(xVal) == 'D',DTOS(xVal),xVal)
		oHelper:UTQueryDB(cTable,aFields[nField][1],cQuery,xVal)
	Next nField
Return oHelper

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OmsAutRpt
Realiza a valida��o de relat�rios gerados pela automa��o.
Mais detalhes: https://tdn.totvs.com/pages/viewpage.action?pageId=271860745 (1.2.4. Desenvolvimento de Scripts para Relat�rios)
@type function
@author Wander Horongoso
@since 25/05/2020
@param
cRpt: nome do caso de teste a ser executado
cPerg: nome do pergunte a ser carregado
aPerg: array com o pergunte e o valor a ser atribu�do
cDtBase: data base para execu��o da rotina (se necess�rio).
/*/
//-------------------------------------------------------------------------------------------------
function OMSAutRpt(cRpt, cPerg, aPerg, cDtBase) 
//-------------------------------------------------------------------
Local oHelper := FWTestHelper():New() 
Local nI      := 0 

Default cDtBase := '01/01/2015' //Se n�o houver necessidade, remover posteriormente este par�metro

	oHelper:UTSetParam( "MV_TREPORT", 2, .T. ) // 2 = Utiliza
	oHelper:Activate()
	dDatabase := CtoD(cDtBase)

	For nI := 1 To Len(aPerg)
		oHelper:UTChangePergunte(cPerg, PadL(Str(aPerg[nI,1],2),2,'0'), aPerg[nI,2])
	Next nI
 
	oHelper:UTStartRpt(cRpt)
	oHelper:UTPrtCompare(cRpt)
	oHelper:AssertTrue(oHelper:lOk, "")
 
	dDatabase := Date()
	oHelper:UTRestParam(oHelper:aParamCT)
 
Return(oHelper)