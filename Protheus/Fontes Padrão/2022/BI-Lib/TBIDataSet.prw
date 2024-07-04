// #######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIDataSet.prw
// -----------+-----------------------+---------------------------------------------------
// Data       | Autor                 | Descricao
// -----------+-----------------------+---------------------------------------------------
// 15.04.03   | BI Development Team   |
// 08.06.09   | 3510 Gilmar P. Santos | Corre��o do m�todo xRecord
//									  | Estavam sendo testadas vari�veis com nomes errados
//									  | FNC: 00000012280/2009
// 23.06.09   | 3510 Gilmar P. Santos | Corre��o do m�todo nMakeID
//									  | N�o funcionava em aplica��es multithread
//									  | FNC: 00000008745/2009
// ---------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "TBIDataSet.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet
Classe abstrata para cria��o de DataSets padronizados.
Caracter�sticas: 
	- Criar, dropar, alterar estrutura de tabelas.
	- Tratar automaticamente Area, Alias, Indices, Recno, Deleted.
	- Acesso a dados por nome ou indice de campo.
	- Aplica��o de filtros Advpl ou Sql.
--------------------------------------------------------------------------------------*/
class TBIDataSet from TBIEvtObject

	data fcAlias		// Alias da tabela
	data fcTablename	// Nome da tabela
	data fcEntity		// Descricao a respeito da tabela
	data faFields		// Objetos campos da tabela, cont�m: Nome, Tipo, Tam, Dec, etc.
	data faIndexes		// Indices da tabela
	data flSX			// Indica se o arquivo e SX (esta no dicionario do Protheus)
	data flLocal		// Se o arquivo � local RDD, se .f. ent�o � TopConnect
	data flIndexed		// Indica se a tabela esta ordenada
	data fcAdvplFilter	// Filtro no formato AdvPl
	data fcSQLFilter	// Filtro no formato SQL
	data flFiltered		// Indica se a tabela esta filtrada
	data fbValidate		// Bloco de c�digo que valida a consist�ncia do registro antes da grava��o
	data fbLogger		// Bloco que faz o log das opera��es de tabela 
	data faCopyColumn	// Opcao para copiar dados entre colunas

	data fnLastError	// Armazena o ultimo erro ocorrido em operacoes de io na tabela
	data fcMsg			// Armazena mensagens (textos) especificas da tabela ao usu�rio/programador
	data flCanAlert  	// Indica que a tabela pode emitir alerta mesmo quando a opera��o � realizada com sucesso. 
		
	method New(cTablename, cAlias) constructor
	method Free()
	method NewDataSet(cTablename, cAlias) 
	method FreeDataSet()
               
	// General properties
	method cAlias()
	method cTablename()
	method cEntity(cValue)
	method lSX(lEnabled)
	method lLocal(lValue)
	method bLogger(bBlock)

	method nLastError()
	method cMsg()
	
	// Control
	method lOpen(lExclusive, lOpenIndexes)
	method lClose()
	method lIsOpen()
	method lExists()
	method _First()
	method _Prior(nSkip)
	method _Next(nSkip)
	method _Last()
	method lBof()
	method lEof()
	method ApplyFilter()
	
	// Read
	method xValue(cFieldName, xValue)
	method cValue(cFieldName)
	method nValue(cFieldName)
	method dValue(cFieldName)
	method lValue(cFieldName)
	method cDescValue(cFieldName)

	method xValByPos(nFieldPos)
	method cValByPos(nFieldPos)
	method nValByPos(nFieldPos)
	method dValByPos(nFieldPos)
	method lValByPos(nFieldPos)
	method cDescByPos(nFieldPos)

	method nRecCount()
	method nSqlCount()
	method xRecord(nFormat, aIgnoreList)
	
	// Write
	method CreateTable(cTableName, lLocal)
	method DropTable()
	method ChkStruct(lChkIndexes, lVerOnly, lVerHigher)
	method nMakeID()  
	method cFastMakeID()
	method cMakeID()  
	method bValidate(bCode)
	method lIsValid(aValues)
	method lAppend(aValues)
	method lAppendObj(oDataSet, aIgnoreList)
	method lUpdate(aValues, lUpdOnlyNeed)
	method lUpdateObj(oDataSet, aIgnoreList, lUpdOnlyNeed)
	method lDelete()
	method lZap()
	method lPack()
	method lLock(lAppend)
	method lUnLock()
	method lSaveOldCol(aOldValues) 
	method aGetOldCol(aTableStruct,aClassStruct) 

	// Indexes
	method aIndexes(cIndexName)
	method AddIndex(oIndex)
	method lIndexed(lEnabled)
	method CreateIndexes()
	method OpenIndexes()
	method DropIndexes()

	// Filters
	method cAdvplFilter(cFilter)
	method cSqlFilter(cFilter)
	method lFiltered(lEnabled)

	// Fields
	method aFields(cFieldName)
	method AddField(oField)
	method InitFields()
	method ResetFields()
	
endclass

/*--------------------------------------------------------------------------------------
@constructor New(cTablename, cAlias)
Constroe o objeto em mem�ria.
@param cTablename - Nome da tabela.
@param cAlias - Alias da tabela.
--------------------------------------------------------------------------------------*/
method New(cTablename, cAlias) class TBIDataSet
	::NewDataSet(cTablename, cAlias)
return

method NewDataSet(cTablename, cAlias) class TBIDataSet
	::NewEvtObject()
              
	default cAlias := cTablename
	
	::fcAlias 		:= cAlias
	::fcTablename 	:= cTablename
	::faFields 		:= {}
	::flSX 	   		:= .F.
	::faIndexes 	:= {}
	::flIndexed 	:= .T.
	::flFiltered 	:= .F.
	::flLocal 		:= .F.
	::faCopyColumn	:= {}

	::fnLastError 	:= DBERROR_OK
	::fcMsg			:= ""     
	::flCanAlert 	:= .F.  
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Destroe o objeto (limpa recursos).
--------------------------------------------------------------------------------------*/
method Free() class TBIDataSet
	::FreeDataset()
return

method FreeDataSet() class TBIDataSet
	::lClose()
	::FreeEvtObject()
return

// ************************************************************************************
// General Properties
// ************************************************************************************
/*--------------------------------------------------------------------------------------
@property cAlias()
Recupera o alias da tabela.
@return - alias da tabela.
--------------------------------------------------------------------------------------*/                         
method cAlias() class TBIDataSet
return ::fcAlias

/*--------------------------------------------------------------------------------------
@property cTablename()
Recupera o nome da tabela.
@return - nome da tabela.
--------------------------------------------------------------------------------------*/                         
method cTablename( lIgnorePath ) class TBIDataSet
	Local cTableName	:= ::fcTablename
	Local nBar			:= 0

	Default lIgnorePath := .F.

	If ( lIgnorePath )
		//-------------------------------------------------------------------
		// Verifica se o diret�rio faz parte do nome do arquivo.  
		//------------------------------------------------------------------- 
		cTableName := StrTran( cTableName, "/", "\" )
	
		//-------------------------------------------------------------------
		// Define o nome do arquivo de transfer�ncia com e sem diret�rio.  
		//------------------------------------------------------------------- 
		If ( "\" $ cTableName )
			nBar := RAt( "\", cTableName ) 
			
			If ! ( nBar == 0 )
				cTableName := Substr( cTableName, nBar + 1 ) 
			EndIf 				
		EndIf 
	EndIf
return cTableName

/*--------------------------------------------------------------------------------------
@property cEntity(cValue)
Define/Recupera a entidade da tabela.
@return - Entidade da tabela.
--------------------------------------------------------------------------------------*/                                 
method cEntity(cValue) class TBIDataSet
	property ::fcEntity := cValue
return ::fcEntity

/*--------------------------------------------------------------------------------------
@property cMsg()
Recupera a mensagem desde a ultima opera��o.
@return - Mensagem texto.
--------------------------------------------------------------------------------------*/                         
method cMsg() class TBIDataSet
return ::fcMsg

/*--------------------------------------------------------------------------------------
@property nLastError()
Recupera o ultimo erro ocorrido desde a ultima opera��o.
@return - Numero do erro ocorrido. (ver constantes DBERROR_ em bidefs.ch)
--------------------------------------------------------------------------------------*/                         
method nLastError() class TBIDataSet
return ::fnLastError

/*--------------------------------------------------------------------------------------
@property lSX(lEnabled)
Define/Recupera se esta tabela e SX do Protheus.
@return - .t. se for SX / .f. se nao for SX.
--------------------------------------------------------------------------------------*/                         
method lSX(lEnabled) class TBIDataSet
	property ::flSX := lEnabled
return ::flSX

/*--------------------------------------------------------------------------------------
@property lLocal(lValue)
Define/Recupera se esta tabela e RDD ou TopConnect. O default � .f.(TopConnect).
@return - .t. se for RDD / .f. se nao for TopConnect.
--------------------------------------------------------------------------------------*/                         
method lLocal(lValue) class TBIDataSet
	property ::flLocal := lValue
return ::flLocal

/*--------------------------------------------------------------------------------------
@property bLogger(bBlock)
Define/Recupera se esta tabela e RDD ou TopConnect. O default � .f.(TopConnect).
@return - .t. se for RDD / .f. se nao for TopConnect.
--------------------------------------------------------------------------------------*/                         
method bLogger(bBlock) class TBIDataSet
	property ::fbLogger := bBlock
return ::fbLogger

// ************************************************************************************
// Control
// ************************************************************************************
/*--------------------------------------------------------------------------------------
@method lOpen(lExclusive, lOpenIndexes)
Abre o DataSet para uso.
@param lExclusive - Indica se a abertura do arquivo � em modo exclusivo (.t.) ou n�o (.f.).
O valor default � "n�o exclusivo" (.f.).
@return - .t. se abrir ok / .f. se gerar exce��o
--------------------------------------------------------------------------------------*/                         
method lOpen(lExclusive, lOpenIndexes) class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lClose()
Fecha o DataSet em uso.
@return - .t. se fechar ok / .f. se gerar exce��o
--------------------------------------------------------------------------------------*/                         
method lClose() class TBIDataSet
   local lRet := .f.        
	
	if ::lIsOpen()
		dbSelectArea(::cAlias())
		dbCloseArea()
		lRet := .t.
	endif

return lRet

/*--------------------------------------------------------------------------------------
@method lIsOpen()
Verifica se o DataSet esta em uso(aberto).
@return - .t. se estiver / .f. se n�o estiver
--------------------------------------------------------------------------------------*/                         
method lIsOpen() class TBIDataSet
return select(::cAlias()) != 0

/*--------------------------------------------------------------------------------------
@method lExists()
Verifica se o DataSet fisico(tabela) existe na fonte(disco/banco).
@return - .t. se existir / .f. se n�o existir
--------------------------------------------------------------------------------------*/                         
method lExists() class TBIDataSet
return iif(::lLocal(), file(::cTableName()), tcCanOpen(::cTableName()))

/*--------------------------------------------------------------------------------------
@method _First()
Move o apontador de registro corrente para o primeiro registro do DataSet.
--------------------------------------------------------------------------------------*/                         
method _First() class TBIDataSet
	abstract
return nil

/*--------------------------------------------------------------------------------------
@method _Prior(nSkip)
Move o apontador de registro corrente nSkip registros para tr�s no DataSet.
@param nSkip - Numero de registros a retroceder.
--------------------------------------------------------------------------------------*/                         
method _Prior(nSkip) class TBIDataSet
	abstract
return nil

/*--------------------------------------------------------------------------------------
@method _Next(nSkip)
Move o apontador de registro corrente nSkip registros adiante no DataSet.
@param nSkip - Numero de registros a avan�ar.
--------------------------------------------------------------------------------------*/                         
method _Next(nSkip) class TBIDataSet
	default nSkip := 1
	
	dbSelectArea(::cAlias())  

return dbSkip(nSkip)

/*--------------------------------------------------------------------------------------
@method _Last()
Move o apontador de registro corrente para o ultimo registro do DataSet.
--------------------------------------------------------------------------------------*/                         
method _Last() class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lBof()
Verifica se a ultima opera��o de movimenta��o tentou retroceder al�m do 1o. registro.
@return - .t. se tentou retroceder al�m do 1o. registro / .f. se n�o
--------------------------------------------------------------------------------------*/                         
method lBof() class TBIDataSet
return (::cAlias())->(bof())

/*--------------------------------------------------------------------------------------
@method lEof()
Verifica se a ultima opera��o de movimenta��o tentou avancar al�m do �ltimo registro.
@return - .t. se tentou avancar al�m do ultimo registro / .f. se n�o
--------------------------------------------------------------------------------------*/                         
method lEof() class TBIDataSet
return (::cAlias())->(eof())

// ************************************************************************************
// Read
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method xValue(cFieldName, xValue)
Recupera valor armazenado no campo <cFieldName> do registro corrente.
@param cFieldName - Nome do campo do qual se deseja obter o valor.
@param xValue - Quando infomardo, muda o valor do campo para o informado.
@return - Valor do campo. Ser� do mesmo tipo de dado (valtype) do campo na tabela.
--------------------------------------------------------------------------------------*/                         
method xValue(cFieldName, xValue) class TBIDataSet
return ::aFields(cFieldName):xValue(xValue)

/*--------------------------------------------------------------------------------------
@method cValue(cFieldName)
Recupera como String o valor armazenado no campo <cFieldName> do registro corrente.
@param cFieldName - Nome do campo do qual se deseja obter o valor.
@return - Valor do campo. Ser� do tipo String (valtype="C").
--------------------------------------------------------------------------------------*/                         
method cValue(cFieldName) class TBIDataSet
return xBIConvTo("C", ::xValue(cFieldName))

/*--------------------------------------------------------------------------------------
@method nValue(cFieldName)
Recupera como Num�rico o valor armazenado no campo <cFieldName> do registro corrente.
@param cFieldName - Nome do campo do qual se deseja obter o valor.
@return - Valor do campo. Ser� do tipo Num�rico (valtype="N").
--------------------------------------------------------------------------------------*/                         
method nValue(cFieldName) class TBIDataSet
return xBIConvTo("N", ::xValue(cFieldName))

/*--------------------------------------------------------------------------------------
@method dValue(cFieldName)
Recupera como Data o valor armazenado no campo <cFieldName> do registro corrente.
@param cFieldName - Nome do campo do qual se deseja obter o valor.
@return - Valor do campo. Ser� do tipo Data (valtype="D").
--------------------------------------------------------------------------------------*/                         
method dValue(cFieldName) class TBIDataSet
return xBIConvTo("D", ::xValue(cFieldName))

/*--------------------------------------------------------------------------------------
@method lValue(cFieldName)
Recupera como L�gico o valor armazenado no campo <cFieldName> do registro corrente.
@param cFieldName - Nome do campo do qual se deseja obter o valor.
@return - Valor do campo. Ser� do tipo L�gico (valtype="L").
--------------------------------------------------------------------------------------*/                         
method lValue(cFieldName) class TBIDataSet
return xBIConvTo("L", ::xValue(cFieldName))

/*--------------------------------------------------------------------------------------
@method cDescValue(cFieldName)
Recupera a descri��o de valor armazenada no campo <TBIField:faDescValues[x][2]> para um 
<faDescValues[x][1]> correspondente ao xValue do campo no registro corrente. 
Uso geral: Combos, valida��es, lista de possiveis valores e descri��es.
Caso n�o existam valores em <TBIField:faDescValues>, retorna o mesmo que cValue(cFieldName).
@param cFieldName - Nome do campo do qual se deseja obter a descri��o de valor.
@return - Descri��o de valor do campo. Ser� do tipo String (valtype="C").
--------------------------------------------------------------------------------------*/                         
method cDescValue(cFieldName) class TBIDataSet
return ::aFields(cFieldName):cDescValue()

/*--------------------------------------------------------------------------------------
@method xValByPos(nFieldPos)
Recupera valor armazenado no campo de posi��o <nFieldPos> do registro corrente.
@param nFieldPos - Posi��o de ordem do campo dentro do registro.
@return - Valor do campo. Ser� do mesmo tipo de dado (valtype) do campo na tabela.
--------------------------------------------------------------------------------------*/                         
method xValByPos(nFieldPos) class TBIDataSet
return (::cAlias())->(FieldGet(nFieldPos))

/*--------------------------------------------------------------------------------------
@method cValByPos(nFieldPos)
Recupera como String o valor armazenado no campo posi��o <nFieldPos> do registro corrente.
@param nFieldPos - Posi��o de ordem do campo dentro do registro.
@return - Valor do campo. Ser� do tipo String (valtype="C").
--------------------------------------------------------------------------------------*/                         
method cValByPos(nFieldPos) class TBIDataSet
return xBIConvTo("C", ::xValByPos(nFieldPos))

/*--------------------------------------------------------------------------------------
@method nValByPos(nFieldPos)
Recupera como Num�rico o valor armazenado no campo posi��o <nFieldPos> do registro corrente.
@param nFieldPos - Posi��o de ordem do campo dentro do registro.
@return - Valor do campo. Ser� do tipo String (valtype="N").
--------------------------------------------------------------------------------------*/                         
method nValByPos(nFieldPos) class TBIDataSet
return xBIConvTo("N", ::xValByPos(nFieldPos))

/*--------------------------------------------------------------------------------------
@method dValByPos(nFieldPos)
Recupera como Data o valor armazenado no campo posi��o <nFieldPos> do registro corrente.
@param nFieldPos - Posi��o de ordem do campo dentro do registro.
@return - Valor do campo. Ser� do tipo String (valtype="D").
--------------------------------------------------------------------------------------*/                         
method dValByPos(nFieldPos) class TBIDataSet
return xBIConvTo("D", ::xValByPos(nFieldPos))

/*--------------------------------------------------------------------------------------
@method lValByPos(nFieldPos)
Recupera como L�gico o valor armazenado no campo posi��o <nFieldPos> do registro corrente.
@param nFieldPos - Posi��o de ordem do campo dentro do registro.
@return - Valor do campo. Ser� do tipo String (valtype="L").
--------------------------------------------------------------------------------------*/                         
method lValByPos(nFieldPos) class TBIDataSet
return xBIConvTo("L", ::xValByPos(nFieldPos))

/*--------------------------------------------------------------------------------------
@method cDescByPos(nFieldPos)
Recupera a descri��o de valor armazenada no campo <TBIField:faDescValues[x][2]> para um 
<faDescValues[x][1]> correspondente ao xValByPos(nFieldPos) do campo no registro corrente. 
Uso geral: Combos, valida��es, lista de possiveis valores e descri��es.
Caso n�o existam valores em <TBIField:faDescValues>, retorna o mesmo que cValByPos(cFieldPos).
@param cFieldName - Nome do campo do qual se deseja obter a descri��o de valor.
@return - Descri��o de valor do campo. Ser� do tipo String (valtype="C").
--------------------------------------------------------------------------------------*/                         
method cDescByPos(nFieldPos) class TBIDataSet
return ::cDescValue((::cAlias())->(fieldname(nFieldPos)))

/*--------------------------------------------------------------------------------------
@method nRecCount()
Retorna numero de registros d tabela.
@return - Numero de registros.
--------------------------------------------------------------------------------------*/                         
method nRecCount() class TBIDataset
return (::fcAlias)->(recCount())

/*--------------------------------------------------------------------------------------
@method nSqlCount()
Retorna numero de registros n�o deletados da tabela.
@return - Numero de registros.
--------------------------------------------------------------------------------------*/                         
method nSqlCount() class TBIDataset
	local oQuery, cQuery, nRec
                                  
	cQuery := "SELECT COUNT(*) AS NCOUNT FROM " + ::fcTableName + " WHERE D_E_L_E_T_ <> '*'"

	oQuery := TBIQuery():New("_" + ::fcAlias)
	oQuery:lOpen(cQuery)
	oQuery:SetField("NCOUNT", "N", 10)
	nRec := oQuery:nValue("NCOUNT")
	DbCloseArea()

return nRec

/*--------------------------------------------------------------------------------------
@method xRecord(nFormat, aIgnoreList)
Recupera cadeia dos valores armazenados no registro corrente, no formato especificado.
@param nFormat - Formato da cadeia. Est�o dispon�veis os seguintes RecordFormats:
	RF_ARRAY - Array contendo {nome, valor} dos campos. (onde valor e do tipo de dado orginal)
	RF_ARRAYSTR - Array contendo {nome, valor} dos campos. (onde valor � convertido em string)
	RF_STRSIZE - String contendo elementos com mesmo tamanho do campo(sem separador).
	RF_STRSDF - String contendo elementos entre aspas e separados por virgula.
	RF_STRCRLF - String contendo elementos separados por CRLF.
	RF_WWWURLENCODE - String contendo os campos no formato WWW-URL-ENCODE
	RF_STRTAB - String contendo elementos separados por TAB (\t).
	RF_ARRAYFLD - Array contendo os nomes dos campos
	RF_ARRAYOBJ - Array, com pares os objetos de defini��o a 1a linha conter� o n�mero de campos
	RF_ARRAYDOC - Array para documenta��o
@param aIgnoreList - Lista de nomes de campos a ignorar.
@return - Cadeia dos valores armazenados no registro corrente.
--------------------------------------------------------------------------------------*/                         
method xRecord(nFormat, aIgnoreList) class TBIDataSet
	local aRet := {}, xRet, nInd, aAux :={}, lIgnID := .f.
	local oField, aFieldList := {}

	default aIgnoreList := {}
	
	// Filtra ignorelist
	if len(aIgnoreList) == 0
		aFieldList := ::aFields()
	else 
		for nInd := 1 to len(::aFields())
			if ascan(aIgnoreList, { |y| ::aFields()[nInd]:cFieldName()==y }) == 0
				aAdd(aFieldList, ::aFields()[nInd])
			endif
		next
	endif

	if nFormat == RF_WWWURLENCODE
		xRet := ""
		aSize(aRet, len(aFieldList))
		for nInd := 1 to len(aRet)
			oField := ::aFields()[nInd]
			aRet[nInd] := cBIURLEncode(oField:cFieldName()) + "="
			if oField:cType() == "L"
				aRet[nInd] += if(oField:xValue(), "=true", "=false")
			elseif !empty(::Value(nInd))
				aRet[nInd] += cBIURLEncode(trim(cBIStr(oField:xValue())))
			endif
		next
		xRet := cBIConcatWSep("&", aRet)
	elseif nFormat == RF_ARRAY 
		xRet := {}
		for nInd := 1 to len(aFieldList)
			aAdd(xRet, {upper(aFieldList[nInd]:cFieldName()), aFieldList[nInd]:xValue()} )
		next	
	elseif nFormat == RF_STRTAB
		xRet := array(len(aFieldList))
		aEval(xRet, { |x,i| xRet[i] := aFieldList[i]:cValue() } )
		xRet := cBIConcatWSep("\t", xRet)
	elseif nFormat == RF_ARRAYFLD
		xRet := array(len(aFieldList))
		for nInd := 1 to len(xRet)
			if aFieldList[nInd]:cType() ==  "N"
				xRet[nInd] := padr(aFieldList[nInd]:cFieldName(), 20)
			else
				xRet[nInd] := padr(aFieldList[nInd]:cFieldName(), max(aFieldList[nInd]:nLength(),10))
			endif	
		next	
	elseif nFormat == RF_ARRAYSTR
		xRet := array(len(aFieldList))
		for nInd := 1 to len(xRet)
			if aFieldList[nInd]:cType() == "N"
				xRet[nInd] := padl(cBIStr(aFieldList[nInd]:xValue()), 20)
			else
				xRet[nInd] := padl(aFieldList[nInd]:xValue(), max(aFieldList[nInd]:nLength(),10))
			endif	
		next	
	elseif nFormat == RF_ARRAYOBJ 
		xRet := {}
		aEval(aFieldList, { |x, i| ;
				aAdd(xRet, "OBJECT=FIELD"), ;
				aAdd(xRet, "FIELDNAME=" + x:cFieldName()), ;
				aAdd(xRet, "VALUE=" + cBIStr(x:xValue())), ;
				aAdd(xRet, "END") } )
	elseif nFormat == RF_ARRAYDOC
		xRet := array(len(aFieldList))
		aEval(xRet, { |x,i| xRet[i] := { x:cCaption(), x:xValue() } } )
	endif

return xRet

// ************************************************************************************
// Write
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@method CreateTable(cTableName, lLocal)
Criar a tabela na base de dados/disco.
@param cTableName - Nome para tabela, caso queira cri�-la com outro nome.
@param lLocal - Indica que a tabela deve ser criar localmente (valor default .f.)
@param lIdentity - Indica se ser� utlizado R_E_C_N_O_ auto-incremental. 
--------------------------------------------------------------------------------------*/                         
method CreateTable( cTableName, lLocal, lIdentity ) class TBIDataset
	Local cRDD 			:= Iif( ( "CTREE" $ RealRDD() ), "CTREECDX", "DBFCDX" )  
	Local nInd        	:= 0
	Local oField       	:= Nil 
	Local aFields 		:= ::aFields()
	Local aRealFields 	:= {}   

	Default cTablename 	:= ::cTablename()
	Default lLocal 		:= ::lLocal()
	Default lIdentity	:= .F. 

	for nInd := 1 to len(aFields)
		oField := aFields[nInd]
		if(!oField:lIsVirtual())
			if(!oField:lSensitive())
				aAdd(aRealFields, {"NS"+substr(oField:cFieldName(), 1, 8), oField:cType(), oField:nLength(), oField:nDecimals()})
			endif
			aAdd(aRealFields, {oField:cFieldName(), oField:cType(), oField:nLength(), oField:nDecimals()})
		endif
	next
   
	BILog(::fcMsg := STR0001 + cTablename + "...", ::fbLogger) //"Criando tabela "		
	
	If( ! ::lExists() )
		If ( lLocal )  
			DBCreate( cTablename, aRealFields, cRDD )
		Else 
			If ( lIdentity )
				FWDBCreate( cTablename, aRealFields, "TOPCONN", .T. )
			Else
				DBCreate( cTablename, aRealFields, "TOPCONN", .T. )
			EndIf
		EndIf
	EndIf
return 

/*--------------------------------------------------------------------------------------
@method DropTable(cTableName)
Elimina a tabela fisicamente.
--------------------------------------------------------------------------------------*/                         
method DropTable() class TBIDataSet
	local lLocal 	:= ::lLocal()
	local lDeleted		:= .F. 
	local cIndexName:= ""
	local cTableName:= ::cTablename()	
	local nInd		:= 0
	
	while(::lIsOpen() .and. !KillApp())
		::lClose()
	enddo

	If( lLocal )
		lDeleted := ( FErase( cTableName ) == 0 ) 
		
		If ( 'CTREE' $ RealRdd() )
			If ! ( lDeleted )
	 			If ( MsFile( cTableName,,RealRdd() ) )
					CTDelFileIdxs( cTableName )
				EndIf		
			EndIf
		Else
			For nInd := 1 to Len( ::faIndexes )
				cIndexName := alltrim(::faIndexes[nInd]:FCINDEXNAME)
					
				If ( File( cIndexName ) )
				   Ferase(cIndexName)
				EndIf
			Next nInd
		EndIf
	Else      
		lDeleted := TCDelFile( ::cTablename() ) 
	
		If( ! lDeleted )
			BILog("SQL error (DropTable) - "+cBIStr(tcSqlError()), ::fbLogger)
		endif
	endif		
Return lDeleted

/*--------------------------------------------------------------------------------------
@method ChkStruct(lChkIndexes, lVerOnly, lVerHigher)
Verificar e atualizar a estrutura da tabela na base de dados/disco. Se houver diferen�as,
tentar� atualizar sem perda de dados, embora sempre crie uma copia de seguran�a desta 
tabela com o nome "XX"+<nome-desta-tabela>.
@param lChkIndexes - Indica se faz a checagem e atualiza��o dos indices. Default .t.
@param lVerOnly - Apenas verificar diferen�as na estrutura, sem atualizar. Default .f.
@param lVerHigher - Apenas marca como diferen�a se o novo tamanho for maior que o atual
@param lChgUpd - Indica que valida os �ndices apenas quando houver diferen�a na estrutura.
@param lIdentity - Indica se ser� usado R_E_C_N_O_ auto-incremental. 
--------------------------------------------------------------------------------------*/                         
method ChkStruct( lChkIndexes, lVerOnly, lVerHigher, lChgUpd, lIdentity ) class TBIDataset
	Local aTableFields 	:= {} 
	Local aClassFields 	:= {}
	Local aTableStruct  := {}
	Local aClassStruct  := {}
	Local aFieldData	:= {}
	Local nField     	:= 0
	Local nPosition      := 0 
	Local nHandle		:= 0
	Local cApplication	:= Upper( AllTrim( GetJobProfString( "INSTANCENAME", "DATASET" ) ) )  
	Local cLock			:= GetPathSemaforo() + cApplication + "_" + ::cTablename( .T. )
	Local cTemporary    := "" 
	Local cTime       	:= ""
	Local lHasData    	:= .F.
	Local lHasDiff      := .F.

	Default lChkIndexes 	:= .F.
	Default lVerOnly 		:= .F.
	Default lVerHigher 		:= .F.
	Default lChgUpd			:= .F.
	Default lIdentity		:= .F. 

	// ------------------------------------------------------
	// Insere um bloqueio para evitar concorr�ncia. 
	// ------------------------------------------------------	
	While ( ( nHandle := FCreate( cLock, 1 ) ) == -1 )
		Sleep( 100 ) 
	EndDo 

	// ------------------------------------------------------
	// Verifica se a tabela j� foi criada. 
	// ------------------------------------------------------	
	If ! ( ::lExists() )
		// ------------------------------------------------------
		// Cria a tabela. 
		// ------------------------------------------------------
		::CreateTable( ,,lIdentity )
		
		// ------------------------------------------------------
		// Cria os �ndices da tabela. 
		// ------------------------------------------------------
		::CreateIndexes()
		
		// ------------------------------------------------------
		// Indica diferen�a na estrutura. 
		// ------------------------------------------------------			
		lHasDiff := .T.
	Else
		//-------------------------------------------------------------------
		// Verifica se a tabela j� foi aberta anteriormente, aborta a verifica��o.  
		//------------------------------------------------------------------- 
		If( ::lIsOpen() )
			//-------------------------------------------------------------------
			// Remove o lock do processo. 
			//-------------------------------------------------------------------		
			FClose( nHandle )
			FErase( cLock )
			
			Return lHasDiff 
		EndIf

		//-------------------------------------------------------------------
		// Recupera os campos da nova estrutura  
		//------------------------------------------------------------------- 
		aClassFields := aClone( ::aFields() )
		
		For nField := 1 to len( aClassFields )
			If( aClassFields[nField]:lIsVirtual() )
				aClassFields[nField] := NIL
			Else
				If !( aClassFields[nField]:lSensitive() )
					aAdd(aClassFields, TBIField():New( "NS"+substr(aClassFields[nField]:cFieldName(), 1, 8), ;
						aClassFields[nField]:cType(), aClassFields[nField]:nLength(), aClassFields[nField]:nDecimals() ))
				EndIf
			EndIf
		Next
		aClassFields := aBIPackArray( aClassFields )

		//-------------------------------------------------------------------
		// Recupera a estrutura da tabela.  
		//------------------------------------------------------------------- 
		::lOpen(.f., .f.) 
		
		If ( ::lIsOpen() )
			aTableFields := DBStruct()
			::lClose()  
		EndIf
		
		//-------------------------------------------------------------------
		// Verifica se recuperou a estrutura da tabela do banco de dados.
		//-------------------------------------------------------------------
		If ! ( Empty( aTableFields ) )
			//-------------------------------------------------------------------
			// Verifica a diferen�a na estrutura da tabela.  
			//------------------------------------------------------------------- 
			For nField := 1 To Len( aTableFields )
				nPosition := aScan( aClassFields, { |x| Upper( AllTrim( x:cFieldName() ) ) == Upper( AllTrim( aTableFields[nField][1] ) ) })

				//-------------------------------------------------------------------
				// Verifica se todos os campos f�sicos existem na classe.  
				//------------------------------------------------------------------- 			
				If( nPosition == 0 )
					//-------------------------------------------------------------------
					// Loga o progresso, "h� diferen�as entre o banco de dados e o modelo de dados"   
					//-------------------------------------------------------------------
					BILog( ::fcMsg := STR0002, ::fbLogger ) 	
				
					// ------------------------------------------------------
					// Indica diferen�a na estrutura. 
					// ------------------------------------------------------
					lHasDiff := .T. 
					Exit
				EndIf

				//-------------------------------------------------------------------
				// Verifica se todos os campos tem a mesma estrutura da classe.  
				//------------------------------------------------------------------- 			
				If 	aClassFields[nPosition]:cType() != aTableFields[nField][2] .Or. ;
					( aClassFields[nPosition]:cType() != "M" .And. ;
				   	( If ( lVerHigher, aClassFields[nPosition]:nLength() > aTableFields[nField][3], aClassFields[nPosition]:nLength() != aTableFields[nField][3] ) .Or. ;
				   	  aClassFields[nPosition]:nDecimals()	!= aTableFields[nField][4] ) )

					//-------------------------------------------------------------------
					// Loga o progresso, "h� diferen�as entre o banco de dados e o modelo de dados"   
					//-------------------------------------------------------------------
					BILog( ::fcMsg := STR0002, ::fbLogger ) 
					
					If ( aClassFields[nPosition]:cType() != aTableFields[nField][2] )
						BILog( aTableFields[nField][1] + ", " + STR0014 + ": " +  aTableFields[nField][2] + " x " + aClassFields[nPosition]:cType(), ::fbLogger ) //"tipo"
			   	  	EndIf 
			   	  	 		
			   	  	If ( If ( lVerHigher, aClassFields[nPosition]:nLength() > aTableFields[nField][3], aClassFields[nPosition]:nLength() != aTableFields[nField][3] ) ) 			   	  
			   	  		BILog( aTableFields[nField][1] + ", " + STR0015 + ": " +  cBIStr( aTableFields[nField][3] ) + " x " + cBIStr( aClassFields[nPosition]:nLength() ), ::fbLogger )  //"tamanho"
				  	EndIf
				  	
				  	If (  aClassFields[nPosition]:nDecimals() != aTableFields[nField][4] )
				  		BILog( aTableFields[nField][1] + ", " + STR0016 + ": " + cBIStr( aTableFields[nField][4] ) + " x " + cBIStr( aClassFields[nPosition]:nDecimals() ), ::fbLogger ) //"decimal"				  
				  	EndIf
				  	
				   	// ------------------------------------------------------
					// Indica diferen�a na estrutura. 
					// ------------------------------------------------------	  
					lHasDiff := .T.
					Exit
				EndIf
			Next	

			If !( lHasDiff )
				For nField := 1 To Len( aClassFields )
					nPosition := ascan(aTableFields, { |x| upper(alltrim(x[1])) == upper(alltrim(aClassFields[nField]:cFieldName())) })
				
					//-------------------------------------------------------------------
					// Verifica se todos os campos da classe existem na tabela.  
					//------------------------------------------------------------------- 
					If ( nPosition == 0 )
						//-------------------------------------------------------------------
						// Loga o progresso, "h� diferen�as entre o banco de dados e o modelo de dados"   
						//-------------------------------------------------------------------
						BILog( ::fcMsg := STR0002, ::fbLogger ) 				
										
						// ------------------------------------------------------
						// Indica diferen�a na estrutura. 
						// ------------------------------------------------------
						lHasDiff := .T. 
						Exit
					EndIf

					//-------------------------------------------------------------------
					// Verifica se todos os campos tem a mesma estrutura da tabela.  
					//------------------------------------------------------------------- 		
					If 	aClassFields[nField]:cType() != aTableFields[nPosition][2] .Or. ;
						( aClassFields[nField]:cType() 	!= "M" .And. ;
						( If ( lVerHigher, aClassFields[nField]:nLength() > aTableFields[nPosition][3], aClassFields[nField]:nLength() != aTableFields[nPosition][3] ) .Or. ;
						  aClassFields[nField]:nDecimals() != aTableFields[nPosition][4] ) )
						
						//-------------------------------------------------------------------
						// Loga o progresso, "h� diferen�as entre o banco de dados e o modelo de dados"   
						//-------------------------------------------------------------------
						BILog( ::fcMsg := STR0002, ::fbLogger ) 
						
						If ( aClassFields[nField]:cType() != aTableFields[nPosition][2] )
							BILog( aClassFields[nField]:cFieldName() + ", " + STR0014 + ": " +  aTableFields[nPosition][2] + " x " + aClassFields[nField]:cType(), ::fbLogger ) //"tipo"
				   	  	EndIf 
				   	  	 		
				   	  	If ( If ( lVerHigher, aClassFields[nField]:nLength() > aTableFields[nPosition][3], aClassFields[nField]:nLength() != aTableFields[nPosition][3] ) ) 			   	  
				   	  		BILog( aClassFields[nField]:cFieldName() + ", " + STR0015 + ": " + cBIStr( aTableFields[nPosition][3] ) + " x " + cBIStr( aClassFields[nField]:nLength() ), ::fbLogger ) //"tamanho"
						EndIf
					  	
					  	If ( aClassFields[nField]:nDecimals() != aTableFields[nPosition][4] )
					  		BILog( aClassFields[nField]:cFieldName() + ", " + STR0016 + ": " +  cBIStr( aTableFields[nPosition][4] ) + " x " + cBIStr( aClassFields[nField]:nDecimals() ), ::fbLogger )	//"decimal"		
						EndIf

						// ------------------------------------------------------
						// Indica diferen�a na estrutura. 
						// ------------------------------------------------------
						lHasDiff := .T. 
						Exit
					EndIf
				Next
			EndIf

			//-------------------------------------------------------------------
			// Verifica se deve atualizar a estrutura da tabela.  
			//-------------------------------------------------------------------
			if( ! lVerOnly .and. lHasDiff )
				if( ::lLocal() )
					//-------------------------------------------------------------------
					// Define o nome do arquivo tempor�rio.  
					//------------------------------------------------------------------- 
					cTemporary := GetNextAlias()  	
                    
					//-------------------------------------------------------------------
					// Loga o progresso, "copiando tabela "###" para "
					//-------------------------------------------------------------------                    
             		BILog(STR0003 + ::cTablename() + STR0004 + cTemporary, ::fbLogger) 
  
					//-------------------------------------------------------------------
					// Copia os dados para o arquivo tempor�rio.  
					//-------------------------------------------------------------------
					If ( ::lOpen(.F., .F.) )
						cTime := Time()
					
						//-------------------------------------------------------------------
						// Loga o progresso, "Total de registros: "  
						//-------------------------------------------------------------------
						BILog( cBIConcat( STR0005, RecCount() ), ::fbLogger ) 
	
						DBSetOrder(0)
						DBGoTop()

						If !( lHasData := Eof() )
							Copy to ( cTemporary ) VIA 'TOPCONN'
						EndIf 
					
						::lClose()
					
						//-------------------------------------------------------------------
						// Loga o progresso, "Copia efetuada em "  
						//-------------------------------------------------------------------
						BILog(cBIConcat(STR0006, ElapTime( cTime, Time() ) ), ::fbLogger ) 
					EndIf	
	
					//-------------------------------------------------------------------
					// Loga o progresso, "Criando estrutura atualizada para ".  
					//-------------------------------------------------------------------
					BILog(STR0007 + ::cTablename(), ::fbLogger) 		
				
					//-------------------------------------------------------------------
					// Recria a estrutura da tabela e copia os dados.  
					//-------------------------------------------------------------------	
					If ( ::DropTable() )
						cTime := Time()
					
						//-------------------------------------------------------------------
						// Loga o progresso.  
						//-------------------------------------------------------------------
						BILog(STR0008 + cTemporary, ::fbLogger) //"Atualizando registros a partir de "	
					
						//-------------------------------------------------------------------
						// Cria a tabela com a estrutura atualizada.  
						//-------------------------------------------------------------------
						::CreateTable( ,,lIdentity )                                      
				
						//-------------------------------------------------------------------
						// Copia os dados da tabela tempor�ria para o tabela.  
						//-------------------------------------------------------------------
						If ( ::lOpen(.F., .F.) )	
							If (! lHasData )
								Append from ( cTemporary ) VIA 'TOPCONN'
							EndIf
						
							::lClose()
						EndIf 
					
						//-------------------------------------------------------------------
						// Loga o progresso, " OK. Atualiza��o efetuada em ".  
						//-------------------------------------------------------------------
						BILog(::cTablename() + STR0009 + ElapTime( cTime, Time() ), ::fbLogger ) 			
					EndIf 
					//-------------------------------------------------------------------
					// Exclui a tabela tempor�ria
					//-------------------------------------------------------------------
					If MsFile( cTemporary, , "TOPCONN")
						MSErase( cTemporary, , "TOPCONN")
					EndIf
				Else  
					cTime 			:= Time()
					aTableStruct 	:= {}
					aClassStruct 	:= {}
				
					//-------------------------------------------------------------------
					// Loga o progresso, "criando estrutura atualizada para"  
					//-------------------------------------------------------------------
					BILog( STR0007 + ::cTablename(), ::fbLogger ) 

					aEval(aTableFields, {|x| aAdd(aTableStruct, {x[1], x[2], x[3], x[4]}) })
					aEval(aClassFields, {|x| aAdd(aClassStruct, {x:cFieldName(), x:cType(), x:nLength(), x:nDecimals()}) })
	
					//-------------------------------------------------------------------
					// Recupera os dados das colunas alteradas.  
					//-------------------------------------------------------------------
					If ( Len( ::faCopyColumn ) > 0 )
						aFieldData := ::aGetOldCol( aTableStruct, aClassStruct )
					EndIf			
				
					//-------------------------------------------------------------------
					// Recria a estrutura da tabela e mant�m os dados.  
					//-------------------------------------------------------------------
					TCAlter( ::cTablename(), aTableStruct, aClassStruct )
					TCRefresh( ::cTablename() )
					
					//-------------------------------------------------------------------
					// Grava os dados das colunas alteradas.  
					//-------------------------------------------------------------------
					If ( Len( ::faCopyColumn ) > 0 .and. Len( aFieldData ) > 0 )
						::lSaveOldCol( aFieldData ) 
					EndIf
				
					//-------------------------------------------------------------------
					// Loga o progresso, " OK. Atualiza��o efetuada em ".  
					//-------------------------------------------------------------------
					BILog(::cTablename() + STR0009 + ElapTime( cTime, Time() ), ::fbLogger )
				EndIf	
			EndIf

			//-------------------------------------------------------------------
			// Verifica se deve reconstruir os �ndices.  
			//------------------------------------------------------------------- 
			If lChgUpd
				If ( lHasDiff )
					::DropIndexes()
					::CreateIndexes()
				EndIf
			Else
				If ( lChkIndexes )
					::DropIndexes()
					::CreateIndexes()
				EndIf
			EndIf	
		EndIf
	EndIf

	::faCopyColumn := {}

	//-------------------------------------------------------------------
	// Remove o lock do processo. 
	//-------------------------------------------------------------------		
	FClose( nHandle )  
	FErase( cLock )   
Return lHasDiff

/*--------------------------------------------------------------------------------------
@method cMakeID()
Recupera um ID unico e sequencial para um novo registro.
Ao colocar um conjunto de thread do tipo Web ou WebEx, a primeira thread que for inicia-
da deve criar a variavel global, via setGlbValue(), BIFirstStart com valor "T" e ap�s  o
termino da inicializa��o, esta variavel deve ser ajustada para "F".
@return - Bloco de codigo para notificar diferen�as.
--------------------------------------------------------------------------------------*/                         
method cMakeID() class TBIDataSet
	Local cID			:= ""                                               			//ID Gerado. 
	Local nPosID		:= aScan( ::faFields, {|y|y:FCFIELDNAME == "ID"} ) 				//Posi��o do campo ID na tabela. 
	Local cAlias 		:= "__TRB"                                   					//Alias da workarea tempor�ria.
	Local aArea			:= ::SavePos()                                      			//Posi��o da tabela.
	Local cTabela		:= ::cTableName()                                 				//Tabela Corrente.
	Local cApplication	:= Upper(AllTrim(getJobProfString("INSTANCENAME", "DATASET"))) 	//InstanceName da Aplica��o.
	Local nPosCache		:= 0                                                           	//Posi��o do item procurado no cache.
	Local lEmCache		:= .F.                                                         	//Identifica se o ID est� em cache.
	Local aCache		:= {}                                                          	//Array utilizado como cache. 
	Local cBrokerinUse	:= Upper(AllTrim(getJobProfString("BROKERINUSE", "0"))) 		//Identifica se est� sendo utilizado o Broker

	// ------------------------------------------------------
	// Realiza o bloqueio da "tabela" para gera��o do ID. 
	// ------------------------------------------------------
	While ( ! GlbLock( cApplication + "_" + cTabela ) .And. ! KillApp() )
		Sleep(100)    
	EndDo

	// ------------------------------------------------------
	// Verifica se o ID est� sendo controlado em cache 
	// ------------------------------------------------------
	If ! ( cApplication == "DATASET" )  .And. ( cBrokerInUse == "0" )    
		lEmCache	:=	GetGlbVars( cTabela, @aCache ) 
		
		If( lEmCache )
			nPosCache := aScan( aCache, {| aChave | Upper( aChave[1] ) == cApplication } )
			
			If ! ( nPosCache == 0 )
				cID 		:= aCache[ nPosCache, 2 ]
			Else
				lEmCache 	:= .F. 			
			EndIf			
		EndIf
	Else
		BIConOut( STR0013 ) //"Aten��o, a chave INSTANCENAME deve ser configurada."  
	EndIf 		

	// ------------------------------------------------------
	//  ou recupera o maior ID da tabela. 
	// ------------------------------------------------------
	If ! ( lEmCache )
		dbUseArea(.T., "TOPCONN", tcGenQry(,,"SELECT MAX(ID) MAXID FROM " + ::cTableName() ), cAlias, .F., .T.)
		 
		If ( (cAlias)->( !EoF() ) )
			cID := cBIStr( FieldGet(1) ) 
		Else
			cID := "0" 
		EndIf	   
	
		(cAlias)->( dbCloseArea() )   
		::RestPos(aArea)			
	EndIf
   
   	// ------------------------------------------------------
	// Ajusta o tamanho do ID ao tamanho do campo. 
	// ------------------------------------------------------   
	If ( nPosID != 0 )		
		cID := Padr( AllTrim( cID ), ::faFields[nPosID]:FNLENGTH, " ")
	EndIf	
   
   	// ------------------------------------------------------
	// Incrementa o ID. 
	// ------------------------------------------------------   
	cID :=	Soma1( cID )
	
	// ------------------------------------------------------
	// Passa o controle do ID da tabela para o cache. 
	// ------------------------------------------------------   
	If( nPosCache == 0 )
		aAdd(aCache, { cApplication, cID } )  
	Else
		aCache[ nPosCache, 2 ]:= cID
	EndIf
	
	putGlbVars( cTabela , aCache )

	// ------------------------------------------------------
	// Remove o bloqueio. 
	// ------------------------------------------------------ 		
	GlbUnlock( cApplication + "_" + cTabela )	   
return cID
          
 /*--------------------------------------------------------------------------------------
@method cFastMakeID()
Recupera um ID unico e sequencial para inclus�es em lote. 
--------------------------------------------------------------------------------------*/                         
method cFastMakeID() class TBIDataSet
 	Local cTabela 		:= ::cTableName() + "FAST"                         	//Nome da tabela.  
	Local cID			:= ""                                               //ID Gerado. 
	Local nPosID		:= aScan( ::faFields, {|y|y:FCFIELDNAME == "ID"} ) 	//Posi��o do campo ID na tabela. 
	Local cAlias 		:= GetNextAlias()                                   //Alias da workarea tempor�ria.
	Local aArea			:= ::SavePos()                                      //Posi��o da tabela.

	While ( ! GlbLock( cTabela ) .and. ! KillApp() )
		Sleep(100)                           
	EndDo
 
	cID := GetGlbValue( cTabela ) 

	If ( Empty(cID) )
		dbUseArea(.T., "TOPCONN", tcGenQry(,,"SELECT MAX(ID) MAXID FROM " + ::cTableName() ), cAlias, .F., .T.)
		 
		If ( (cAlias)->( !EoF() ) )
			cID := cBIStr( FieldGet(1) ) 
		Else
			cID := "0" 
		EndIf	   
	
		(cAlias)->( dbCloseArea() )   
		::RestPos(aArea)
	EndIf

	If ( nPosID != 0 )		
		cID := Padr( lTrim( cID ), ::faFields[nPosID]:FNLENGTH, " ")
	EndIf		

	cID := Soma1(cID)

	PutGlbValue( cTabela, cID )  
	GlbUnlock( cTabela )
return cID
  
/*--------------------------------------------------------------------------------------
@method nMakeID()
Recupera um ID unico e sequencial para um novo registro.
@return - ID Gerado.
--------------------------------------------------------------------------------------*/                         
method nMakeID() class TBIDataSet
	Local nRet		:=	0
	local cSql		:=	""
	local cOldAlias	:=	""
	local nCont 	:= 	50
	local cVarName	:=	::cTableName()
	local cInsName	:=	""
	local cJobName	:=	getWebJob()
	local lExisteVar:=	.F.
	local aRet		:=	{}
	local nVarPos 	:=	0

	//Retira underlines do final do nome do JOB
	while right( cJobName, 1 ) == "_"
		cJobName := substr( cJobName, 1, rat( "_", cJobName ) - 1 )
   	enddo

	//Procura chave INSTANCENAME na Se��o definida para o JOB no INI
	cInsName := GetPvProfString( cJobName, "INSTANCENAME", "", getadv97() )

	//Se n�o encontrou a chave, retorna 0 (ERRO DE CONFIGURA��O)
	if( empty( cInsName ) )
		BILog( ::fcMsg := STR0011, ::fbLogger ) //"Chave INSTANCENAME n�o configurada"

		return 0
	endif

	while !GlbLock() .and. !KillApp()
		sleep(100)                           
		nCont--
		if nCont == 0
			nCont := 50
		endif
	enddo

	lExisteVar	:=	GetGlbVars(cVarName,@aRet)

	if(lExisteVar)
		nVarPos := ascan(aRet, {|aVal| upper(aVal[1]) == cInsName})
		if(nVarPos != 0)
			nRet 	:= aRet[nVarPos,2]		
		endif			
	endif		

	if ! lExisteVar .or. nVarPos == 0	
		cOldAlias := alias()
		cSql := "select max(ID) maxid from " + ::cTableName()
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"__TRB",.f.,.t.)
		nRet := FieldGet(1)
		dbCloseArea()
		dbSelectArea(cOldAlias)
	Endif
	
	nRet++

	if(nVarPos == 0)
		aAdd(aRet,{cInsName,nRet})
	else
		aRet[nVarPos,2]:= nRet
	endif
		
	putGlbVars(cVarName,aRet)		
	
	GlbUnlock()	   
 
return nRet
	
/*--------------------------------------------------------------------------------------
@property bValidate(bCode)
Define um bloco de c�digo para validar o registro antes de grav�-lo.
Se o bloco n�o for definido, ou NIL, n�o haver� verifica��o antes de gravar.
Se o retorno do bloco for .t., o update ou append ser� executado.
Se o retorno do bloco for .f., o update ou append n�o ser� executado e retornar� .f..
@return - O bloco de codigo utilizado para validar registros.
--------------------------------------------------------------------------------------*/                         
method bValidate(bCode) class TBIDataSet
	property ::fbValidate := bCode
return ::fbValidate

/*--------------------------------------------------------------------------------------
@method lIsValid()
Valida o registro de acordo com o bloco bValidate.
Se o bloco n�o for definido, ou NIL, retorna .t., ou seja, v�lido para qualquer situa��o.
param aValues - Nomes de campos e valores no formato para update a serem validados.
@return - .t. o bloco � v�lido. .f. � inv�lido.
--------------------------------------------------------------------------------------*/                         
method lIsValid(aValues) class TBIDataSet
	local lValid := .t.
	if(valtype(::fbValidate)=="B")
		lValid := eval(::fbValidate, aValues)
	endif	
return lValid

/*--------------------------------------------------------------------------------------
@method lAppend(aValues)
Adiciona um novo registro.
@param aValues - lista de campos a anexar. Formato: {<nome-do-campo>, <valor>)
@return - .t. Insers�o bem suscedida. / .t. Insers�o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lAppend(aValues) class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lAppendObj(oDataSet, aIgnoreList)
Adiciona um novo registro a partir de um DataSet.
@param oDataSet - Objeto DataSet contendo os valores do registro a ser adicionado.
@param aIgnoreList - nomes de campos a ignorar.
@return - .t. Insers�o bem suscedida. / .t. Insers�o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lAppendObj(oDataSet, aIgnoreList) class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lUpdate(aValues, aIgnoreList)
Atualiza o registro atual.
@param aValues - lista de campos a anexar. Formato: {<nome-do-campo>, <valor>)
@param lUpdOnlyNeed - atualiza somente se for preciso.
@return - .t. Atualiza��o bem suscedida. / .t. Atualiza��o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lUpdate(aValues, lUpdOnlyNeed) class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lUpdateObj(oDataSet, aIgnoreList)
Atualiza o registro atual a partir de um oDataSet.
@param oDataSet - Objeto DataSet contendo os novos valores do registro. 
@param aIgnoreList - nomes de campos a ignorar.
@param lUpdOnlyNeed - atualiza somente se for preciso.
@return - .t. Atualiza��o bem suscedida. / .t. Atualiza��o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lUpdateObj(oDataSet, aIgnoreList, lUpdOnlyNeed) class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lDelete()
Deletar registro atual. (AdvPl D_E_L_E_T_E_D)
@return - .t. Dele��o bem suscedida. / .t. Dele��o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lDelete() class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lZap()
Deletar todos os registros. (AdvPl D_E_L_E_T_E_D)
@return - .t. Dele��o bem suscedida. / .t. Dele��o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lZap() class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lPack()
Excluir fisicamente todos os registros deletados marcados com (AdvPl D_E_L_E_T_E_D).
@return - .t. Exclus�o bem suscedida. / .t. Exclus�o gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lPack() class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lLock(lAppend)
Travar o registro corrente para que nenhum outro usu�rio possa grav�-lo.
@param lAppend -> l�gico, indica que � lock com append
@return - .t. Travamento bem suscedida. / .t. Travamento gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lLock() class TBIDataSet
	abstract
return .t.

/*--------------------------------------------------------------------------------------
@method lUnLock()
Destravar o registro corrente para que outros usu�rios possam grav�-lo.
@return - .t. Destravamento bem suscedida. / .t. Destravamento gerou exce��o.
--------------------------------------------------------------------------------------*/                         
method lUnLock() class TBIDataSet
	abstract
return .t.


// ************************************************************************************
// Indexes
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@property aIndexes(cIndexName)
Recupera objetos indice (TBIIndex) desta tabela.
@param cIndexName - Nome do indice desejado. Se n�o especificado retorna todos.
@return - Array de objetos indice (TBIIndex).
--------------------------------------------------------------------------------------*/                         
method aIndexes(cIndexName) class TBIDataSet
	local nPos, xRet := ::faIndexes
	
	if valType(cIndexName) == "C"
		nPos := ascan(xRet, { |x| x:cIndexName() == cIndexName})
		xRet := iif(nPos != 0, xRet[nPos], nil)
	endif
	
return xRet

/*--------------------------------------------------------------------------------------
@method AddIndex(oIndex)
Adiciona um objeto indice (TBIIndex) a esta tabela.
@param oIndex - Objeto indice (TBIIndex).
--------------------------------------------------------------------------------------*/                         
method AddIndex(oIndex) class TBIDataSet
	local nPos
	
	nPos := ascan(::faIndexes, { |x| x:cIndexName() == oIndex:cIndexName() })
	if nPos == 0
		aAdd(::faIndexes, oIndex)
		oIndex:oOwner(self)
	endif
	
return 

/*--------------------------------------------------------------------------------------
@property lIndexed(lEnabled)
Define/Recupera o status(ligado/desligado) de ordena��o desta tabela.
@return - Liga/desliga ordena��o desta tabela.
--------------------------------------------------------------------------------------*/                         
method lIndexed(lEnabled) class TBIDataSet
	if valType(lEnabled) == "L"
		::flIndexed := lEnabled
		if ::lIsOpen()
			::Close() 
			::Open()
		endif
	endif
return ::flIndexed

/*--------------------------------------------------------------------------------------
@method CreateIndexes()
Cria todos os indices da tabela a partir dos objetos em faIndexes.
--------------------------------------------------------------------------------------*/                         
method CreateIndexes() class TBIDataSet
	local nInd, aIndexes
	local lOpenAfterCreate := ::lIsOpen()
	
	if(lOpenAfterCreate)
		::lClose()
	endif

	::lOpen(.t., .f.) // Abre a tabela sem os indices
	aIndexes := ::aIndexes()
    for nInd := 1 to len(aIndexes)
		aIndexes[nInd]:lCreate()    
    next

	if(lOpenAfterCreate)
		::lOpen()
	else
		::lClose()
	endif
return 

/*--------------------------------------------------------------------------------------
@method OpenIndexes()
Abre todos os indices da tabela a partir dos objetos em faIndexes.
--------------------------------------------------------------------------------------*/                         
method OpenIndexes() class TBIDataSet
	local nInd, aIndexes
//	aEval(::aIndexes(), { |x| x:lOpen() })
	                  
	aIndexes := ::aIndexes()
	for nInd := 1 to len(aIndexes)
		aIndexes[nInd]:lOpen()
	next
	
	if(!empty(::aIndexes()))
		ordSetFocus(1) // Assume como indice padr�o o 1o.
	endif	
return

/*--------------------------------------------------------------------------------------
@method DropIndexes()
Dropa todos os indices da tabela a partir dos objetos em faIndexes.
--------------------------------------------------------------------------------------*/                         
method DropIndexes() class TBIDataSet
	local lOpenAfterDrop := ::lIsOpen()
	
	if(lOpenAfterDrop)
		::lClose()
	endif
	
	// TCInternal(op=69, comando=nome-da-tabela)
	// Dropa todos os indices da tabela
	TCInternal(69, ::cTablename())

	if(lOpenAfterDrop)
		::lOpen()
	endif
return

// ************************************************************************************
// Filters
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@property cAdvplFilter(cFilter)
Define/Recupera filtro Advpl para esta tabela.
@param cFilter - Filtro Advpl.
@return - Filtro Advpl.
--------------------------------------------------------------------------------------*/                         
method cAdvplFilter(cFilter) class TBIDataSet	
	local cOld := ::fcAdvplFilter
	
	property ::fcAdvplFilter := cFilter
	if(cOld != ::fcAdvplFilter)
		::ApplyFilter()
	endif
	
return ::fcAdvplFilter

/*--------------------------------------------------------------------------------------
@method cSqlFilter(cFilter)
Define/Recupera filtro Sql para esta tabela.
@param cFilter - Filtro Sql.
@return - Filtro Sql.
--------------------------------------------------------------------------------------*/                         
method cSqlFilter(cFilter) class TBIDataSet
	local cOld := ::fcSqlFilter

	property ::fcSqlFilter := cFilter
	if(cOld != ::fcSQLFilter)
		::ApplyFilter()
	endif

return ::fcSqlFilter

/*--------------------------------------------------------------------------------------
@property lFiltered(lEnabled)
Define/Recupera o status(ligado/desligado) de filtragem desta tabela.
@return - Liga/desliga filtragem desta tabela.
--------------------------------------------------------------------------------------*/                         
method lFiltered(lEnabled) class TBIDataSet
	property ::flFiltered := lEnabled
return ::flFiltered

/*--------------------------------------------------------------------------------------
@method ApplyFilter()
Aplica ou remove o filtro
--------------------------------------------------------------------------------------*/                         
method ApplyFilter() class TBIDataSet
	abstract
return

// ************************************************************************************
// Fields
// ************************************************************************************

/*--------------------------------------------------------------------------------------
@property aFields(cFieldName)
Recupera objetos fields (TBIField) desta tabela.
@param cFieldName - Nome do campo desejado. Se n�o especificado retorna todos.
@return - Array de objetos fields (TBIField).
--------------------------------------------------------------------------------------*/                         
method aFields(cFieldName) class TBIDataSet
	local nPos, xRet := ::faFields
	
	if valType(cFieldName) == "C"
		nPos := ascan(xRet, { |x| upper(x:cFieldName()) == upper(cFieldName)})
		xRet := iif(nPos != 0, xRet[nPos], nil)
	endif
	
return xRet

/*--------------------------------------------------------------------------------------
@method AddField(oField)
Adiciona um objeto field (TBIField) a esta tabela.
@param oField - Objeto field (TBIField).
--------------------------------------------------------------------------------------*/                         
method AddField(oField) class TBIDataSet
	local nPos

	nPos := ascan(::faFields, { |x| x:cFieldName() == oField:cFieldName() })
	if nPos == 0
		aAdd(::faFields, oField)
		oField:oOwner(self)
	endif

return 

/*--------------------------------------------------------------------------------------
@method InitFields()
Inicializa os Fields desta tabela a partir da estrutura fisica.
--------------------------------------------------------------------------------------*/                         
method InitFields() class TBIDataSet
	local aFields, nInd
	
	if len(::aFields()) == 0
		aFields := DBStruct()
		for nInd := 1 to len(aFields)
			::AddField(TBIField():New(aFields[nInd, 1], aFields[nInd, 2], aFields[nInd, 3], aFields[nInd, 4]))
		next
	endif

return 

/*--------------------------------------------------------------------------------------
@method ResetFields()
Trunca(Zera) o array de fields desta tabela.
--------------------------------------------------------------------------------------*/                         
method ResetFields() class TBIDataSet
	::faFields := {}
return 

/*--------------------------------------------------------------------------------------
@method lSaveOldCol(aLstColumn, aOldValues)
@param 	aOldValues - Valores para serem gravados
Grava os dados da coluna antiga na nova
Para utilizacao desta metodo a estrutura da tabela deve estar diferente.
--------------------------------------------------------------------------------------*/                         
method lSaveOldCol(aOldValues) class TBIDataSet
	local aFields	:=	{}
	local lOk 		:=	.t.
	local nQtdCol	:=	len(::faCopyColumn) 
	local nQtdItem	:=	0
	local nCol		:=	0
	local nItem		:=	0

	if(::lOpen())
		nQtdCol	:= len(::faCopyColumn)
		
		for nCol := 1 to nQtdCol
		   	::_First()
			nQtdItem := len(aOldValues[nCol])
			for nItem := 1 to nQtdItem
				aAdd(aFields, {::faCopyColumn[nCol,2],aOldValues[nCol,nItem,1]})

				if(!::lUpdate(aFields))
					lOk := .f.
					BILog(STR0012 + ::faCopyColumn[nCol,2], ::fbLogger) //"Erro gravando registro para um nova Coluna"
				endif	
				
				::_Next()
			next nItem				
		next nCol
	endif

	::lClose()	
	
return lOk 

/*--------------------------------------------------------------------------------------
@method aGetOldCol(aTableStruct,aClassStruct)
@param 	aTableStruct 	- Estrutura da tabela.
		aClassStruct	- Estrutura da classe.
Salva na memoria os valores da coluna antiga.
Para utilizacao desta metodo a estrutura da tabela deve estar diferente.
--------------------------------------------------------------------------------------*/                         
method aGetOldCol(aTableStruct,aClassStruct) class TBIDataSet
	local aOldValues:= {}
	local nCol		:=	0
	local nQtdCol	:=	0
	local nPosOri	:=	0
	local nPosDest	:=	0
	local cType		:=	""
	local cCampo	:=	""
	
	if(::lOpen())
		nQtdCol	:= len(::faCopyColumn) 

		for nCol := 1 to nQtdCol
			//Verifica se a coluna origem ainda esta na base de dados.
			nPosOri	:= ascan(aTableStruct, {|x| x[1] == ::faCopyColumn[nCol,1]})
			cCampo	:= ::faCopyColumn[nCol,1]
			//Verifica se a coluna destino ainda esta na base.
			nPosDest:= ascan(aClassStruct, {|x| x[1] == ::faCopyColumn[nCol,2]})
		
			if(nPosOri > 0 .and. nPosDest > 0)
				cType := aTableStruct[nPosOri,2]
			   	::_First()
				aadd(aOldValues,{})
				do while ! ::lEof()
					aadd(aOldValues[nCol],{xBIConvTo(cType, &cCampo)})
					::_Next()
				enddo
			endif				
				
		next nCol
	endif

	::lClose()	
	
return aOldValues 

function _TBIDataSet()
return nil 

// ************************************************************************************
// Fim da defini��o da classe TBIDataSet
// ************************************************************************************