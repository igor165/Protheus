// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIQuery.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "TopConn.ch"

#define EXEC_SELECT 0
#define EXEC_DELETE 1

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBIQuery
Permite o uso de comandos SQL para acesso e manutenção das tabelas
Características: 
???????????????????
--------------------------------------------------------------------------------------*/
class TBIQuery from TBIDataSet
	data fcFieldList // lista de campos a serem selecionados na tabela
	data fcFromList // lista de tabelas envolvidas na query
	data fcWhereClause // clausula where
	data fcHavingClause // clausula Having
	data fcOrderBy // clausula order
	data fcGroupBy // clausula group
	data flDistinct // indica se select é "distinct" ou não
	data flDeleted // indica se deve trazer ou não os registros deletados
	data faParams // lista de parametros para complentar o where
	data fnRecLimit // limita o numero de registros da query
	data fnLastRec // controla qtde de registros lidos
	data fnExecOper // tipo de operação SQL desejada
	
	method New(acTablename, acAlias) constructor
	method Free()
	method NewQuery(acTablename, acAlias) 
	method FreeQuery()

	method lDistinct(lEnable)
	method nRecLimit(nValue)
	method cWhereClause(cValue)
	method lDeleted(lEnable)
	method cGroupBy(cValue)
	method cHavingClause(cValue)
	method cOrderBy(cValue)

	method SQL(lRecno)
	method lOpen(cSQL)
	method _First()
	method _Last()
	method nRecCount()
	method CreateTable(cTableName)
	method ApplyFilter()

	method SetField(cField, cType, nSize, nDecimals)
	
endclass

/*--------------------------------------------------------------------------------------
@constructor New(cTablename, cAlias)
Constroe o objeto em memória.
@param cTablename - Nome da tabela.
@param cAlias - Alias da tabela.
--------------------------------------------------------------------------------------*/
method New(cTablename, cAlias) class TBIQuery
	::NewQuery(cTablename, cAlias)
return

method NewQuery(cTablename, cAlias) class TBIQuery
	::NewDataset(cTablename, cAlias)

	::fcFieldList := ""
	::fcFromList := ""
	::fcWhereClause := ""
	::fcHavingClause := ""
	::fcOrderBy := ""
	::fcGroupBy := ""
	::flDistinct := .f.
	::flDeleted := .F.
	::fnExecOper := EXEC_SELECT
	::faParams := {}
	::fnRecLimit := 0
	::fnLastRec := 0
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIQuery
	::FreeQuery()
return

method FreeQuery() class TBIQuery
	::FreeDataSet()
return

// ************************************************************************************
// General Properties
// ************************************************************************************

// ************************************************************************************
// Control
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method cSQL(lRecno)
Monta o comando SQL conforme os valores das propriedades.
@param lRecno - Indica se há ou não a coluna "R_E_C_N_O_"
@return - comando SQL
--------------------------------------------------------------------------------------*/                         
method SQL(lRecno) class TBIQuery
	local cRet, cFrom := ::fcFromList, aWhere, aFrom, nInd, aAux, aHaving
	local nPos, nPosF, cAux, cAux2, cAlvo
	               
	default lRecno := .f.
	
	if empty(cFrom)
		cFrom := ::cTablename()
	endif
          
	if ::fnExecOper == EXEC_SELECT
		::fnLastRec := 0
		cRet := cBIConcatWSep(" ", "select", iif(::lDistinct(), "distinct", ""), ;
					 iif(::nRecLimit()<>0,"top " + cBIStr(::nRecLimit()),""), ;
					 ::fcFieldList + iif(lRecno, ", 0",""), "from", upper(cFrom))
	elseif ::fnExecOper == EXEC_DELETE
		cRet := cBIConcatWSep(" ", "delete from ", upper(cFrom))
	else
		cRet := "( operacao invalida )"
	endif	

	if !empty(::cWhereClause())
		cRet := cBIConcatWSep(" ", cRet, "where", ::cWhereClause())
	endif
	if !empty(::cSQLFilter())
		if empty(::cWhereClause())
			cRet := cBIConcatWSep(" ", cRet, "where", ::cSQLFilter())
		else
			cRet := cBIConcatWSep(" ", cRet, "and", ::cSQLFilter())
		endif
	endif

	if !::lDeleted()
		aWhere := {}
		aFrom := aBIToken(alltrim(::fcFromList), ",", .f.)
		for nInd := 1 to len(aFrom)
			aAux := aBIToken(alltrim(aFrom[nInd]), " ", .f.)
			if len(aAux) == 1
				aAdd(aWhere, aAux[1] + ".D_E_L_E_T_ <> '*'")
			else	
				aAdd(aWhere, aAux[2] + ".D_E_L_E_T_ <> '*'")
			endif
		next
		if empty(::cWhereClause())
			cRet := cBIConcatWSep(" ", cRet, "where", cBIConcatWSep(" and ", aWhere))
		else
			aWhere := aSize(aWhere, len(aWhere)+1)
			aWhere := aIns(aWhere, 1)            
			aWhere[1] := cRet
			cRet := cBIConcatWSep(" and ", aWhere)
		endif
	endif
	
	if ::fnExecOper == EXEC_SELECT
		if !empty(::cGroupBy())
			cRet := cBIConcatWSep(" ", cRet, "group by", upper(::cGroupBy()))
		endif  

		if !empty(::cHavingClause())
			cRet := cBIConcatWSep(" ", cRet, "having", ::cHavingClause())
		endif                                                        

		if !empty(::cOrderBy())
			cRet := cBIConcatWSep(" ", cRet, "order by", upper(::cOrderBy()))
		endif  
	endif  
                          
	aEval(::faParams, { |x| cRet := strTran(cRet, "[" + x[1] + "]", cBIStr(x[2]))})

	while (nPos := at("[", cRet)) > 0
		nPosF := at("]", substr(cRet, nPos)) 
		cAlvo := substr(cRet, nPos, nPosF)
		cAux := substr(cRet, nPos+1, nPosF-2)
		if !("RETURN" $ upper(cAux))
			cAux := "return("+cAux+")"
		endif
		cAux2 := ""
		if execSintax(cAux, @cAux2)
			cRet := strTran(cRet, cAlvo, cBIStr(cAux2))
		else
			cRet := strTran(cRet, cAlvo, '0')
		endif
	enddo
			
return cRet

/*--------------------------------------------------------------------------------------
@method lOpen(cSQL)
Abre o DataSet para uso.
@param cSQL - comando SQL "select" a ser executado. Os valores das propriedades serão 
ignorados quando este parametro for informado.
@return - .t. se abrir ok / .f. se gerar exceção
--------------------------------------------------------------------------------------*/                         
method lOpen(cSQL) class TBIQuery
	local lRet := .t., aFName, aTypes, aLen, aDec, nFCount, nInd

	default cSQL := ::SQL()
	
	//lRet := _Super:lOpen(lExclusive)
	lRet := ::lIsOpen()
	if lRet
		ExUserException(::cAlias() + " already open")
	endif	                                

	// 30/03/05 Nao estamos mais usando o parser por determinação do Marcelo Abe
	// tcquery (cBIParseSQL(cSQL)) alias (::cAlias()) new
	tcquery (cSQL) alias (::cAlias()) new

	::ResetFields()
	nFCount := fCount()
	aFName := array(nFCount)
	aTypes := array(nFCount)
	aLen   := array(nFCount)
	aDec   := array(nFCount)
	aFields(aFName, aTypes, aLen, aDec)
		
	for nInd := 1 to nFCount
		::addField(TBIField():New(aFName[nInd], aTypes[nInd], aLen[nInd], aDec[nInd]))
	next
	::fnLastRec := 0
	
return lRet

/*--------------------------------------------------------------------------------------
@method _First()
Move o apontador de registro corrente para o primeiro registro do DataSet.
--------------------------------------------------------------------------------------*/                         
method _First() class TBIQuery
	::lClose()
	::lOpen()
return nil

/*--------------------------------------------------------------------------------------
@method _Last()
Move o apontador de registro corrente para o ultimo registro do DataSet.
--------------------------------------------------------------------------------------*/                         
method _Last() class TBIQuery
	while !::Eof()
		::_Next()
	enddo		
return 

// ************************************************************************************
// Read
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method nRecCount()
Retorna numero de registros d tabela.
@return - Numero de registros.
--------------------------------------------------------------------------------------*/                         
method nRecCount() class TBIQuery
	local nRet := 0, cSQL := "", cOldAlias

	cOldAlias := alias()
	cSQL := ::cSQL()
	tcquery (cSQL) alias ("_"+::cAlias()) new
	while !eof()
		nRet++
		dbSkip()
	enddo
	dbCloseArea()
	if !empty(cOldAlias)
		dbSelectArea(cOldAlias)
	endif

return nRet

// ************************************************************************************
// Write
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method CreateTable(cTableName)
Criar a tabela na base de dados/disco.
@param cTableName - Nome para tabela, caso queira criá-la com outro nome.
--------------------------------------------------------------------------------------*/                         
method CreateTable(cTableName) class TBIQuery

return _Super:CreateTable(cTablename, .f.)

// ************************************************************************************
// Indexes
// ************************************************************************************

// ************************************************************************************
// Filters
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method ApplyFilter()
Aplica ou remove o filtro
--------------------------------------------------------------------------------------*/                         
method ApplyFilter() class TBIQuery
	if ::lFiltered() .and. ::lIsOpen()
		::_First()
	endif
return

// ************************************************************************************
// Fields
// ************************************************************************************
method SetField(cField, cType, nSize, nDecimals) class TBIQuery
	TcSetField(::cAlias(), cField, cType, nSize, nDecimals)
return
                                                                                       
/*--------------------------------------------------------------------------------------
@property lDistinct(lEnabled)
Define/Recupera se é distinct
@return - .t. se for distinct / .f. se nao for distinct
--------------------------------------------------------------------------------------*/                         
method lDistinct(lEnabled) class TBIQuery
	property ::flDistinct := lEnabled
return ::flDistinct

/*--------------------------------------------------------------------------------------
@property nRecLimit(nValue)
Define/Recupera o limite de registro da query
@return - valor limite
--------------------------------------------------------------------------------------*/                         
method nRecLimit(nValue) class TBIQuery
	property ::fnRecLimit := nValue
return ::fnRecLimit
                                                                                       
/*--------------------------------------------------------------------------------------
@property cWhereClause(cValue)
Define as clausulas da query
@return - clausula
--------------------------------------------------------------------------------------*/                         
method cWhereClause(cValue) class TBIQuery
	property ::fcWhereClause := cValue
return ::fcWhereClause
                                                                                       
/*--------------------------------------------------------------------------------------
@property lDeleted(lEnable)
Define/Recupera se esta deletado
@return - .t. se deletado / .f. se nao deletado
--------------------------------------------------------------------------------------*/                         
method lDeleted(lEnable) class TBIQuery
	property ::flDeleted := lEnable
return ::flDeleted

/*--------------------------------------------------------------------------------------
@property cGroupBy(cValue)
Define as clausulas de grupo
@return - clausula
--------------------------------------------------------------------------------------*/                         
method cGroupBy(cValue) class TBIQuery
	property ::fcGroupBy := cValue
return ::fcGroupBy
                                                                                       
/*--------------------------------------------------------------------------------------
@property cHavingClause(cValue)
Define as clausulas Having
@return - clausula
--------------------------------------------------------------------------------------*/                         
method cHavingClause(cValue) class TBIQuery
	property ::fcHavingClause := cValue
return ::fcHavingClause
                                                                                       
/*--------------------------------------------------------------------------------------
@property cOrderBy(cValue)
Define as clausulas Order
@return - clausula
--------------------------------------------------------------------------------------*/                         
method cOrderBy(cValue) class TBIQuery
	property ::fcOrderBy := cValue
return ::fcOrderBy

function _TBIQuery()
return nil

// ************************************************************************************
// Fim da definição da classe TBIQuery
// ************************************************************************************