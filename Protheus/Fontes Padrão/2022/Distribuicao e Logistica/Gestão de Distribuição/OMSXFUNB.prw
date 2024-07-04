#include "protheus.ch"
/*
+---------+--------------------------------------------------------------------+
|Função   | OMSXFUNB - Funções Para Automação de Testes                        |
+---------+--------------------------------------------------------------------+
|Objetivo | Deverá agrupar todas as funções que serão utilizadas na            |
|         | automação de testes.                                               |
+---------+--------------------------------------------------------------------+
*/
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OmsAutVld
Realiza a validação do registro da tabela gravada pela automação.
@type function
@author Wander Horongoso | Amanda Rosa Vieira
@since 22/05/2020
@param
oHelper: objeto helper da automação
cTable: tabela que será validada
aWhere: relação de campos que serão utilizados no where.
    aFields[1]: nome do campo
    aFields[2]: conteúdo do campo
aFields: relação de campos a serem validados.
    aFields[1]: nome do campo
    aFields[2]: conteúdo do campo
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
Realiza a validação de relatórios gerados pela automação.
Mais detalhes: https://tdn.totvs.com/pages/viewpage.action?pageId=271860745 (1.2.4. Desenvolvimento de Scripts para Relatórios)
@type function
@author Wander Horongoso
@since 25/05/2020
@param
cRpt: nome do caso de teste a ser executado
cPerg: nome do pergunte a ser carregado
aPerg: array com o pergunte e o valor a ser atribuído
cDtBase: data base para execução da rotina (se necessário).
/*/
//-------------------------------------------------------------------------------------------------
function OMSAutRpt(cRpt, cPerg, aPerg, cDtBase) 
//-------------------------------------------------------------------
Local oHelper := FWTestHelper():New() 
Local nI      := 0 

Default cDtBase := '01/01/2015' //Se não houver necessidade, remover posteriormente este parâmetro

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