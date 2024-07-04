// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBITable.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "TBITable.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable
Classe para tratamento de "workareas"
Características: 
????????????
--------------------------------------------------------------------------------------*/
class TBITable from TBIDataSet

	method New(cTablename, cAlias) constructor
	method Free()
	method NewTable(cTablename, cAlias) 
	method FreeTable()
	     
	data faSavePos  // Guarda a posicao para as funcoes SavePos e RestPos
	data fcLocateFor  	// Guarda o For do Locate
	data fcLocateWhile  // Guarda o While do Locate
	data foOltpController  // Ponteiro para o controlador de transações do sistema

	// general data
	method oOltpController(oCoreOltpController)

	// control
	method lOpen(lExclusive, lOpenIndexes)
	method _First()
	method _Prior(nSkip)
	method _Next(nSkip)
	method _Last()
	method lGoto(nReg)
	method SavePos()
	method RestPos()
	
	// table
	method lSeek(nIndexNumber, aKeyValue)
	method lSoftSeek(nIndexNumber, aKeyValue)
	method _seek(nIndexNumber, aKeyValue, lSoftseek)
	method lLocate(cFor, cWhile)
	method lLocateRest()
	method lFound()
	method nRecNo()
	method lDeleted()
	method aStruct()

	// write
	method lAppend(aValues)
	method lAppendObj(oDataSet, aIgnoreList)
	method lUpdate(aValues, lUpdOnlyNeed)
	method lUpdateObj(oDataSet, aIgnoreList, lUpdOnlyNeed)
	method lDelete()
	method lRecall()
	method lZap()
	method lPack()
	method lLock(lAppend)
	method lUnLock()
	method NoSensitiveUpdate(cFieldName)

	// Indexes
	method SetOrder(nOrder)
	method nGetOrder()

	// Filter
	method lFiltered(lEnabled)
	method ApplyFilter()   
	method cSQLToADVPL(cFilter)

	// Novos
	method lFireEvent(nMoment, nEvent)
	method aRetPesq(aPesq, aValues)
	method nFieldPos(cFieldName)
	method xFieldGet(nFieldPos)
	method lFieldPut(nFieldPos, xValue)
	
endclass

/*--------------------------------------------------------------------------------------
@constructor New(cTablename, cAlias)
Constroe o objeto em memória.
@param cTablename - Nome da tabela.
@param cAlias - Alias da tabela.
--------------------------------------------------------------------------------------*/
method New(cTablename, cAlias) class TBITable
	::NewTable(cTablename, cAlias)
return

method NewTable(cTablename, cAlias) class TBITable
	::NewDataSet(cTablename, cAlias)
	::fcLocateFor := ""
	::fcLocateWhile := ""
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBITable
	::FreeTable()
return

method FreeTable() class TBITable
	::FreeDataset()
return

// ************************************************************************************
// General Properties
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@property oOltpController(oCoreOltpController)
Define/Recupera o controlador de transações vigente para esta tabela.
@return - Controlador de transações (do tipo TBIOltpController). Default nil.
--------------------------------------------------------------------------------------*/                         
method oOltpController(oCoreOltpController) class TBITable
	property ::foOltpController := oCoreOltpController
return ::foOltpController


// ************************************************************************************
// Control
// ************************************************************************************
/*--------------------------------------------------------------------------------------
@method lOpen(lExclusive, lOpenIndexes)
Abre o DataSet para uso.
@return - .t. se abrir ok / .f. se gerar exceção
--------------------------------------------------------------------------------------*/                         
method lOpen(lExclusive, lOpenIndexes) class TBITable
	local lRet, cRDD
	
	default lExclusive := .f.
	default lOpenIndexes := .t.
	//lRet := _Super:lOpen(lExclusive)
	lRet := ::lIsOpen()
	if lRet
		ExUserException(::cAlias() + " already open")
	endif	                                
	
	if !::lSX()
		cRDD := iif(::lLocal(), "DBFCDX", "TOPCONN")
		if lExclusive
			use (::cTablename()) alias (::cAlias()) exclusive new via (cRDD)
		else
			use (::cTablename()) alias (::cAlias()) shared new via (cRDD)
		endif

		if(lRet := !neterr())
			if(lOpenIndexes)
				::OpenIndexes()
			endif
		   	::InitFields()
		endif
	else
		chkFile(::cAlias())
		::InitField()
	endif
	
return lRet

/*--------------------------------------------------------------------------------------
@method _First()
Move o apontador de registro corrente para o primeiro registro do DataSet.
--------------------------------------------------------------------------------------*/                         
method _First() class TBITable
	dbSelectArea(::cAlias())  
return dbGoTop()

/*--------------------------------------------------------------------------------------
@method _Prior(nSkip)
Move o apontador de registro corrente nSkip registros para trás no DataSet.
@param nSkip - Numero de registros a retroceder.
--------------------------------------------------------------------------------------*/                         
method _Prior(nSkip) class TBITable
	default nSkip := 1
	dbSelectArea(::cAlias())  
return dbSkip(nSkip*-1)

/*--------------------------------------------------------------------------------------
@method _Next(nSkip)
Move o apontador de registro corrente nSkip registros adiante no DataSet.
@param nSkip - Numero de registros a avançar.
--------------------------------------------------------------------------------------*/                         
method _Next(nSkip) class TBITable
	default nSkip := 1
	dbSelectArea(::cAlias())  
return dbSkip(nSkip)

/*--------------------------------------------------------------------------------------
@method _Last()
Move o apontador de registro corrente para o ultimo registro do DataSet.
--------------------------------------------------------------------------------------*/                         
method _Last() class TBITable
	dbSelectArea(::cAlias())
return dbGoBottom()

/*--------------------------------------------------------------------------------------
@method lGoto(nReg)
Posiciona o apontador no registro nReg.
@param nReg - Numero do registro (recno) sequencial dentro do arquivo.
@return - .t. Busca encontrou o registro. / .f. Busca não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method lGoto(nReg) class TBITable
	(::cAlias())->(dbgoto(nReg))
return (nReg == ::nRecno())

/*--------------------------------------------------------------------------------------
@method SavePos()
Armazena na pilha a posição atual (indice e registro)
--------------------------------------------------------------------------------------*/
method SavePos() class TBITable

	dbSelectArea(::cAlias())  
	
	::faSavePos := { IndexOrd(), recno(), ::cSqlFilter() }	
return aClone(::faSavePos)

/*--------------------------------------------------------------------------------------
@method RestPos(aSavedPos)
Restaura da pilha a posição do arquivos (indice e registro)
--------------------------------------------------------------------------------------*/
method RestPos(aSavedPos) class TBITable
	
	dbSelectArea(::cAlias())
	 
	If (aSavedPos == Nil)
		aSavedPos := aClone (::faSavePos)    
	EndIf
	
	dbSetOrder(aSavedPos[1])
	
	if( aSavedPos[3] != "" )
		::cSqlFilter(aSavedPos[3])
		::lFiltered(.t.)
	endif 
	
	dbGoto(aSavedPos[2]) 
return

// ************************************************************************************
// Table
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method lSeek(nIndexNumber, aKeyValue)
Procura no indice escolhido por uma chave especificada (exata).
@param nIndexNumber - Numero da ordem do indice.
@param aKeyValue - Chave a ser procurada. Sempre um array com os valores que a compoem.
@return - .t. Encontrou o registro. / .f. Não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method lSeek(nIndexNumber, aKeyValue) class TBITable
return ::_Seek(nIndexNumber, aKeyValue, .f.)

/*--------------------------------------------------------------------------------------
@method lSeek(nIndexNumber, aKeyValue)
Procura no indice escolhido por uma chave não exata especificada. Se não encontrar 
a chave identica, retorna o 1o. acima dela. Se não houver, found:=.f. e eof:=.t.
@param nIndexNumber - Numero da ordem do indice.
@param aKeyValue - Chave a ser procurada. Sempre um array com os valores que a compoem.
@return - .t. Encontrou o registro. / .f. Não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method lSoftSeek(nIndexNumber, aKeyValue) class TBITable
return ::_Seek(nIndexNumber, aKeyValue, .t.)

/*--------------------------------------------------------------------------------------
@method _Seek(nIndexNumber, aKeyValue, lSoftseek)
Procura no indice escolhido por uma chave especificada.
(Legado de TTable do SigaDW, mantida por questões de compatibilidade).
Deve ser substituida por lSeek ou lSoftseek.
@param nIndexNumber - Numero da ordem do indice.
@param aKeyValue - Chave a ser procurada. Sempre um array com os valores que a compoem.
@param lSoftseek - Se não encontrar a mesma chave, aponta o primeiro logo acima dela.
@return - .t. Encontrou o registro. / .f. Não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method _Seek(nIndexNumber, aKeyValue, lSoftseek) class TBITable
	local nInd, aFields, cKey, nLen, lOk := .f.
                   
	default lSoftseek 	:= .t.	//set(_SET_SOFTSEEK)
	
	dbSelectArea(::cAlias())
	dbSetOrder(nIndexNumber)
	if valType(aKeyValue) != "U"

		aFields := ::aIndexes()[nIndexNumber]:aFields()
		for nInd := 1 to len(aFields)
			if(!::aFields(aFields[nInd]):lSensitive())
				if(valtype(aKeyValue[nInd])=="C")
					aKeyValue[nInd] := cBIUpper(aKeyValue[nInd])
				endif
			endif
		next
		
		if nIndexNumber == 0
			dbGoto(aKeyValue)
			lOk := .t.
		elseif valtype(aKeyValue) == "N" .and. aKeyValue == 0
			dbGoTop()
			lOk := .t.
		else
			aSize(aKeyValue, 16)
			if len(::aIndexes()[nIndexNumber]:aFields()) > 1
				cKey := eval(::aIndexes()[nIndexNumber]:bKeyExpression(), aKeyValue[1], aKeyValue[2], aKeyValue[3], ;
							aKeyValue[4], aKeyValue[5], aKeyValue[6], aKeyValue[7], aKeyValue[8], ;
							aKeyValue[9], aKeyValue[10], aKeyValue[11], aKeyValue[12], aKeyValue[13], ;
							aKeyValue[14], aKeyValue[15], aKeyValue[16])
				if lSoftSeek
					cKey := trim(cKey)
				else
					nLen := len(&(indexkey()))
					cKey := padr(cKey, nLen, " ")
				endif
			else
				cKey := aKeyValue[1]
			end      
			if valType(cKey) == "U"
				cKey := xBIConvTo(valType(&(indexkey())), cKey)
			endif
			dbSeek(cKey, lSoftseek)
		endif		
	else
		lOk := .t.
	endif				
return lOk .or. ::lFound()

/*--------------------------------------------------------------------------------------
@method lLocate(cFor, cWhile)
Executa uma busca não indexada. Atendendo as condições cFor e cWhile como no ADVPL.
@param cFor - Como a clausula FOR do comando locate advpl.
@param cWhile - Como a clausula WHILE do comando locate advpl.
@return - .t. Busca encontrou o registro. / .f. Busca não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method lLocate(cFor, cWhile) class TBITable
	local lRet := .f.
	
	::fcLocateFor := iif(empty(cFor),"",cFor)
	::fcLocateWhile := iif(empty(cWhile),"",cWhile)

	if(!empty(::fcLocateFor) .and. !empty(::fcLocateWhile))
		locate for &(::fcLocateFor) while &(::fcLocateWhile)
		lRet := ::lFound()
	elseif(!empty(::fcLocateFor))
		locate for &(::fcLocateFor)
		lRet := ::lFound()
	elseif(!empty(::fcLocateWhile))
		locate while &(::fcLocateWhile)
		lRet := ::lFound()
	endif
	
return lRet

/*--------------------------------------------------------------------------------------
@method lLocateRest()
Continua uma busca feita anteriormente com lLocate(cFor, cWhile).
@return - .t. Busca encontrou o registro. / .f. Busca não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method lLocateRest() class TBITable
	local lRet := .f.
	
	if(!empty(::fcLocateFor) .and. !empty(::fcLocateWhile))
		::_Next()
		locate rest for &(::fcLocateFor) while &(::fcLocateWhile)
		lRet := ::lFound()
	elseif(!empty(::fcLocateFor))
		::_Next()
		locate rest for &(::fcLocateFor)
		lRet := ::lFound()
	elseif(!empty(::fcLocateWhile))
		::_Next()
		locate rest while &(::fcLocateWhile)
		lRet := ::lFound()
	endif
return lRet

/*--------------------------------------------------------------------------------------
@method lFound()
Indica se uma pesquisa prévia foi ou não bem suscedida.
@return - .t. Busca encontrou o registro. / .f. Busca não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method lFound() class TBITable
return (::cAlias())->(found())

/*--------------------------------------------------------------------------------------
@method nRecno()
Retorna a posição o recno advpl.
@return - .t. Busca encontrou o registro. / .f. Busca não encontrou o registro.
--------------------------------------------------------------------------------------*/                         
method nRecno() class TBITable
return (::cAlias())->(recno())

/*--------------------------------------------------------------------------------------
@method lDeleted()
Retorna se o registro atual está com flag de deletado.
@return - .t. Registro é deletado. / .f. Registro não é deletado.
--------------------------------------------------------------------------------------*/                         
method lDeleted() class TBITable
return (::cAlias())->(deleted())

/*--------------------------------------------------------------------------------------
@method aStruct()
Retorna um array com a estrutura da tabela.(vide DBStruct() Clipper 5.3)
@return - Array com elementos (arrays) no formato (Nome, Tipo, Tamanho, Decimais).
--------------------------------------------------------------------------------------*/                         
method aStruct() class TBITable
return (::cAlias())->(dbstruct())

// ************************************************************************************
// Write
// ************************************************************************************
/*--------------------------------------------------------------------------------------
@method lAppend(aValues)
Adiciona um novo registro.
@param aValues - lista de campos a anexar. Formato: {<nome-do-campo>, <valor>)
@return - .t. Insersão bem suscedida. / .t. Insersão gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lAppend(aValues) class TBITable
	Local oField		:= Nil
	Local oIndex		:= Nil
	Local aFields 	:= ::aFields()
	Local aAux			:= {}
	Local nInd			:= 0	
	Local nPos			:= 0
	Local x			:= 0	
	Local cFieldname	:= ""
	Local lRet 		:= .F.
	Local lOk 			:= .T.
	Local xValue		:= Nil 

	::fnLastError := DBERROR_OK
	::fcMsg := ""	

	if ::lIsValid(aValues) .and. ::lFireEvent(FE_BEFORE, FE_APPEND)      
		dbSelectArea(::cAlias())  
		for x := 1 to len(::aIndexes())
			oIndex := ::aIndexes()[x]
			if oIndex:lUnique()
				::Savepos()
				if(::lSeek(x, ::aRetPesq(oIndex:aFields(), aValues)))
					lOk := .f.
					lRet := .f.
					::fnLastError := DBERROR_UNIQUE
					aAux := {}
					for nInd := 1 to len(oIndex:aFields())
						if( (nPos := aScan(aValues, {|x| x[1]==oIndex:aFields()[nInd]})) != 0)
							aAdd(aAux, aValues[nPos][1]+" = "+cBIStr(aValues[nPos][2]))
						endif	
					next
					::fcMsg := STR0001 + "[" + cBIConcatWSep(";", aAux) + "]" //"Chave única já existente 
					exit
				endif
				::RestPos()
			endif
		next
		if lOk
			for nInd := 1 to len(aFields)	
				cFieldname := upper(aFields[nInd]:cFieldName())
				If(aScan(aValues, { |x| upper(x[1]) == cFieldname }) == 0)
					If( valtype(aFields[nInd]:bDefault()) == "B" )
						aAdd(aValues, { cFieldname, eval(aFields[nInd]:bDefault()) })
					Else
						If( aFields[nInd]:cType()== "C" )
							xValue := ""
						ElseIf( aFields[nInd]:cType() == "N" )
							xValue := 0
						ElseIf( aFields[nInd]:cType() == "D" )
							xValue := CToD("  /  /  ")
						ElseIf( aFields[nInd]:cType() == "L" )
							xValue := .F.
						ElseIf( aFields[nInd]:cType() == "M" )
							xValue := ""
						Endif
						
						aAdd(aValues, { cFieldname, xValue })
					EndIf	
				EndIf
			next
			
			if ::lLock(.T.)
				for nInd := 1 to len(aValues)
					::xValue(aValues[nInd, 1], aValues[nInd,2])
				next
				lRet := .t.	                             
				::lUnlock()
			else
				::fnLastError := DBERROR_LOCK
				::fcMsg := STR0002 //"Arquivo ou registro em uso"
			endif
		else
			lRet := .f.
		endif
		::lFireEvent(FE_AFTER, FE_APPEND)
	else	
		::fnLastError := DBERROR_VALID
		::fcMsg := STR0003 //"Registro nao passou na validacao"
	endif                                   

return lRet

/*--------------------------------------------------------------------------------------
@method lAppendObj(oDataSet, aIgnoreList)
Adiciona um novo registro a partir de um DataSet.
@param oDataSet - Objeto DataSet contendo os valores do registro a ser adicionado.
@param aIgnoreList - nomes de campos a ignorar.
@return - .t. Insersão bem suscedida. / .t. Insersão gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lAppendObj(oDataSet, aIgnoreList) class TBITable
	local aInsFields, aAux, xAux, nInd, nPos
	default aIgnoreList := {}
	
	aAux := {}
	aInsFields := oDataSet:aFields()
	for nInd := 1 to len(aInsFields)
		nPos := aScan(aIgnoreList, aInsFields[nInd]:cFieldName())
		if(nPos == 0)
			nPos := ascan(::aFields(), { |x| upper(x:cFieldName()) == upper(aInsFields[nInd]:cFieldName()) })
			if(nPos != 0)
				xAux := {aInsFields[nInd]:cFieldName(), aInsFields[nInd]:xValue()}
				if(aInsFields[nInd]:cType() == "N")
					xAux[2] := nBITrunc(xAux[2], ::aFields()[nPos]:nLength(), ::aFields()[nPos]:nDecimals())
				endif
				aAdd(aAux, xAux)
			endif
		endif
	next
return ::lAppend(aAux)


/*--------------------------------------------------------------------------------------
@method NoSensitiveUpdate(cFieldName)
Atualiza o campo nao sensitivo de todos os registros.
@param cFieldName - Nome do campo não sensitivo.
--------------------------------------------------------------------------------------*/                         
method NoSensitiveUpdate(cFieldName) class TBITable
	local cvar
	
	dbselectarea(::cAlias())
	dbgotop()   
	replace &("NS"+cFieldName) with cBIUpper(&(cFieldName)) all

return

/*--------------------------------------------------------------------------------------
@method lUpdate(aValues)
Atualiza o registro atual.
@param aValues - lista de campos a anexar. Formato: {<nome-do-campo>, <valor>)
@param lUpdOnlyNeed - atualiza somente se for preciso.
@return - .t. Atualização bem suscedida. / .t. Atualização gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lUpdate(aValues, lUpdOnlyNeed) class TBITable
	local lRet := .f., nInd, aAux, aValAnt, oField
	local lOk := .t., aFields := ::aFields()
	local aAlvo, oIndex
	local x, y
	
	default lUpdOnlyNeed := .f.
	::fnLastError := DBERROR_OK
	::fcMsg := ""	

	if ::lIsValid(aValues) .and. ::lFireEvent(FE_BEFORE, FE_UPDATE)
		if lUpdOnlyNeed 
			lOk := .f.
			lRet := .t.
			aValAnt := ::xRecord(1)
			for nInd := 1 to len(aValAnt)
				nPos := ascan(aValues,  { |x| x[1]==aValAnt[nInd,1] })
				if nPos <> 0 .and. cBIStr(aValAnt[nInd, 2]) <> cBIStr(aValues[nPos, 2])
					lOk := .t.
					exit
				endif
			next
		endif
				
		if lOk
			dbSelectArea(::cAlias())  
			y := recno()
			for x := 1 to len(::aIndexes())
				oIndex := ::aIndexes()[x]
				if(oIndex:lUnique())
					aAlvo := ::aRetPesq(oIndex:aFields(), aValues)
					::Savepos()
					if len(aAlvo) > 0 .and. ::lSeek(x, aAlvo)
						if (y <> recno())
							lOk := .f.
							lRet := .f.
							::fnLastError := DBERROR_UNIQUE
							aAux := {}
							for nInd := 1 to len(oIndex:aFields())
								if( (nPos := aScan(aValues, {|x| x[1]==oIndex:aFields()[nInd]})) != 0)
									aAdd(aAux, aValues[nPos][1]+" = "+cBIStr(aValues[nPos][2]))
								endif	
							next
							::fcMsg := STR0001 + "[" + cBIConcatWSep(";", aAux) + "]" //"Chave única já existente 
							exit
						endif
					endif
					::RestPos()
				endif
			next
		
			if lOk
				if ::lLock()
					for nInd := 1 to len(aValues)	
						::xValue(aValues[nInd, 1], aValues[nInd,2])
					next
					lRet := .t.
					::lUnlock()
				else
					::fnLastError := DBERROR_LOCK
					::fcMsg := STR0002 //"Arquivo ou registro em uso"
				endif
			endif
		else
			lRet := .f.
		endif
		::lFireEvent(FE_AFTER, FE_UPDATE)
	else	
		::fnLastError := DBERROR_VALID
		::fcMsg := STR0003 //"Registro nao passou na validacao"
	endif                                   
	
return lRet

/*--------------------------------------------------------------------------------------
@method lUpdateObj(oDataSet, aIgnoreList)
Atualiza o registro atual a partir de um oDataSet.
@param oDataSet - Objeto DataSet contendo os novos valores do registro. 
@param aIgnoreList - nomes de campos a ignorar.
@param lUpdOnlyNeed - atualiza somente se for preciso.
@return - .t. Atualização bem suscedida. / .t. Atualização gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lUpdateObj(oDataSet, aIgnoreList, lUpdOnlyNeed) class TBITable
	local aUpdFields, aAux, xAux, nInd, nPos
	default aIgnoreList := {}
	
	aAux := {}
	aUpdFields := oDataSet:aFields()
	for nInd := 1 to len(aUpdFields)
		nPos := aScan(aIgnoreList, aUpdFields[nInd]:cFieldName())
		if(nPos == 0)
			nPos := ascan(::aFields(), { |x| upper(x:cFieldName()) == upper(aUpdFields[nInd]:cFieldName()) })
			if(nPos != 0)
				xAux := {aUpdFields[nInd]:cFieldName(), aUpdFields[nInd]:xValue()}
				if(aUpdFields[nInd]:cType() == "N")
					xAux[2] := nBITrunc(xAux[2], ::aFields()[nPos]:nLength(), ::aFields()[nPos]:nDecimals())
				endif
				aAdd(aAux, xAux)
			endif
		endif
	next
return ::lUpdate(aAux, lUpdOnlyNeed)

/*--------------------------------------------------------------------------------------
@method lDelete()
Deletar registro atual. (AdvPl D_E_L_E_T_E_D)
@return - .t. Deleção bem suscedida. / .t. Deleção gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lDelete() class TBITable
	local lRet := (::lFireEvent(FE_BEFORE, FE_DELETE) .and. ::lLock())
	
	::fcMsg := ""	
	::fnLastError := DBERROR_OK

	if(lRet)
		dbDelete()
		::lUnlock()
	else	
		::fnLastError := DBERROR_LOCK
		::fcMsg := STR0002 //"Arquivo ou registro em uso"
	endif
	::lFireEvent(FE_AFTER, FE_DELETE)
	
return lRet

/*--------------------------------------------------------------------------------------
@method lRecall()
Recuperar registro atual. (AdvPl D_E_L_E_T_E_D)
@return - .t. Recuperação bem suscedida. / .t. Recuperação gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lRecall() class TBITable
	local lRet := (::lFireEvent(FE_BEFORE, FE_RECALL) .and. ::lLock())
	
	::fcMsg := ""	
	::fnLastError := DBERROR_OK

	if(lRet)
		dbRecall()
		::lUnlock()
	else	
		::fnLastError := DBERROR_LOCK
		::fcMsg := STR0002 //"Arquivo ou registro em uso"
	endif
	::lFireEvent(FE_AFTER, FE_RECALL)
	
return lRet

/*--------------------------------------------------------------------------------------
@method lZap()
Deletar todos os registros. (AdvPl D_E_L_E_T_E_D)
@return - .t. Deleção bem suscedida. / .t. Deleção gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lZap() class TBITable
	local lOpened := ::lIsOpen(), lRet

	if !::lLocal()
		if(lOpened)
			::lClose()
		endif
		lRet := nBISqlExec({"delete from " + ::cTablename()}) == 0
		if(lOpened)
			::lOpen()
		endif
	else
		if(lOpened)
			::lClose()
		endif
		if(lRet := ::lOpen(.t.))
			Zap
			::lClose()
		endif	
		if(lOpened)
			::lOpen()
		endif
	endif         
	
return lRet

/*--------------------------------------------------------------------------------------
@method lPack()
Excluir fisicamente todos os registros deletados marcados com (AdvPl D_E_L_E_T_E_D).
@return - .t. Exclusão bem suscedida. / .t. Exclusão gerou exceção.
--------------------------------------------------------------------------------------*/                         
Method lPack() class TBITable
	::lClose()
	
	If ( ::lOpen( .T. ) )
		PACK
		::lClose()
	EndIf
Return .t.

/*--------------------------------------------------------------------------------------
@method lLock(lAppend)
Travar o registro corrente para que nenhum outro usuário possa gravá-lo.
@param lAppend -> lógico, indica que é lock com append
@return - .t. Travamento bem suscedida. / .t. Travamento gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lLock(lAppend) class TBITable
	local lRet := .f.

	default lAppend := .f.                         

	dbSelectArea(::cAlias())
	if ::lFireEvent(FE_BEFORE, FE_LOCK)
		if(lAppend)
			dbAppend(.f.)
   			lRet := !NetErr()
		else          
   			lRet := dbRlock()
		endif
		::lFireEvent(FE_AFTER, FE_LOCK)
	endif

return lRet

/*--------------------------------------------------------------------------------------
@method lUnLock()
Destravar o registro corrente para que outros usuários possam gravá-lo.
@return - .t. Destravamento bem suscedida. / .t. Destravamento gerou exceção.
--------------------------------------------------------------------------------------*/                         
method lUnLock() class TBITable
                                  
	::lFireEvent(FE_BEFORE, FE_UNLOCK)
	if(valtype(::oOltpController())=="U")
		(::cAlias())->(dbrUnlock())
	elseif(!::oOltpController():lOnTransaction())
		(::cAlias())->(dbrUnlock()) 
	endif
	::lFireEvent(FE_AFTER, FE_UNLOCK)

return .t.

// ************************************************************************************
// Indexes
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method SetOrder(nOrder)
Seta a ordem dos registros para o índice escolhido.
@param nOrder - Indice dentro de ::faIndexes, do indice que se quer focar.
--------------------------------------------------------------------------------------*/                         
method SetOrder(nOrder) class TBITable
	(::cAlias())->(dbsetOrder(nOrder))
return

/*--------------------------------------------------------------------------------------
@method nGetOrder()
Retorna a ordem dos registros para o índice escolhido.
@return - Indice dentro de ::faIndexes, do indice que se quer focar.
--------------------------------------------------------------------------------------*/                         
method nGetOrder() class TBITable
return (::cAlias())->(indexord())

// ************************************************************************************
// Filters
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@property lFiltered(lEnabled)
Define/Recupera o status(ligado/desligado) de filtragem desta tabela.
@return - Liga/desliga filtragem desta tabela.
--------------------------------------------------------------------------------------*/                         
method lFiltered(lEnabled) class TBITable
	local lOld := ::flFiltered
	
	property ::flFiltered := lEnabled
	if lOld != ::flFiltered
		::ApplyFilter()
	endif
	
return ::flFiltered
                             
/*--------------------------------------------------------------------------------------
@method ApplyFilter()
Aplica ou remove o filtro
--------------------------------------------------------------------------------------*/                         
method ApplyFilter() class TBITable
	Local cFilter := ""
					
	if ::lFiltered()
		if !empty(::cSQLFilter())
			
			/*Verifica se o banco de dados utilizado é o DB2/400.*/
			if (cBIGetSGDB() == "DB2/400") 
				/*Transforma os filtros para ADVPL para serem suportados pelo DB2/400.*/ 
				cFilter := ::cSQLToADVPL(::cSQLFilter())				
			Else 
				/*Os demais banco suportam filtro @.*/
				cFilter := "@" + ::cSQLFilter()
			EndIf 
		
		elseif !empty(::cAdvplFilter())
			cFilter := ::cAdvplFilter()
		endif
	endif
	
	(::cAlias())->(dbClearFilter())
  	
  	if !empty(cFilter)   
  		dbSelectArea(::cAlias())  	    
  		(::cAlias())->(DbSetFilter( { || .T. }, cFilter ))
	endif 
   
	::_First()
return

// ************************************************************************************
// Fields
// ************************************************************************************

/*-------------------------------------------------------------------------------------
@method lFireEvent(nMoment, nEvent)
Dispara o evento.
@param nMoment: constante identifica o momento do disparo. (implementação específica)
@param nEvent: constante identifica o evento ocorrido. (implementação específica)
--------------------------------------------------------------------------------------*/
method lFireEvent(nMoment, nEvent) class TBITable
	// Nada, por enquanto
return .t.

/*-------------------------------------------------------------------------------------
@method aRetPesq(aPesq, aaValues)
Monta a chave para pesquisa.
@param aPesq - .
@param aValues - .
@return 
--------------------------------------------------------------------------------------*/
method aRetPesq(aPesq, aValues) class TBITable
	local aRet := {}
	local x, y

	for x:=1 to len(aPesq)
		for y:=1 to len(aValues)
			if( valtype(aValues[y]) <> "U" )
				if( upper(aPesq[x]) == upper(aValues[y][1]) )
					aAdd(aRet, aValues[y][2])
				endif
			endif
		next
	next
return aRet

/*--------------------------------------------------------------------------------------
@method nFieldPos(acFieldName)
Recupera a posição fisica do campo.
@param cFieldName -> string, nome do campo.
@return - integer, posição do campo.
--------------------------------------------------------------------------------------*/                                 
method nFieldPos(cFieldName) class TBITable
return (::cAlias())->(FieldPos(cFieldName))

/*--------------------------------------------------------------------------------------
@method FieldGet(anFieldPos)
Recupera o valor de um campo.
@param nFieldPos -> integer, posição do campo.
@return - expressao, valor do campo.
--------------------------------------------------------------------------------------*/                                 
method xFieldGet(nFieldPos) class TBITable
return (::cAlias())->(FieldGet(nFieldPos))

/*--------------------------------------------------------------------------------------
@method lFieldPut(nFieldPos, xValue)
Grava o valor de um campo.
@param nFieldPos - posição do campo.
@param xValue - valor a ser atribuido.
@return - se operação foi ok.
--------------------------------------------------------------------------------------*/                                 
method lFieldPut(nFieldPos, xValue) class TBITable
return (::cAlias())->(FieldPut(nFieldPos, xValue))
   
 
/*--------------------------------------------------------------------------------------
@method cSQLToADVPL(cFilter)
Transforma uma expressão SQL simples em uma expressão ADVPL.
@param nFieldPos - posição do campo.
@param cValue - Expressão de filtro SQL.
@return - Expressão de filtro ADVPL.
--------------------------------------------------------------------------------------*/                                 
method cSQLToADVPL(cFilter) class TBITable
	Local cADVPLFilter 	:= "" 
	Local aExpressoes 	:= {{},{}}   
	Local i 			:= 1 

	Default cFilter 	:= "" 	
   
	/*Recupera a expressão de filtro em SQL e muda para caixa alta.*/
	cADVPLFilter :=	Upper(cFilter)	
	/*Array no formato {{Expressão SQL, Expressão ADVPL}}*/	
	aExpressoes := 	{{" AND "," .AND. "}, {" OR "," .OR. "},{" =", " == " }}	 
	
	/*Itera por todas as expressões e faz a substituição pela expressão correspondente. */		
	For i := 1 to len(aExpressoes)			      		
		cADVPLFilter := StrTran(cADVPLFilter , aExpressoes[i][1], aExpressoes[i][2])   
    Next i                                                         

return cADVPLFilter

function _TBITable()
return nil
                                                                                       
// ************************************************************************************
// Fim da definição da classe TBITable
// ************************************************************************************
