#include "protheus.ch"

function VEQuery()
return

static cSGBD := TcGetDb()

/*/{Protheus.doc} VEQuery
	Vai controlar query criando objetos e retornando sempre um objeto
	pra poder ser usado como corrente

	Essa classe mantem caches para ajudar a buscar dados retornando um objeto com estes dados, a estrutura
	de JsonObject foi utilizada por ser a mais rapida de retornar valores atraves de strings como oFrota:Get("VC3_FILIAL")

	A utilizacao baseada em cache dela funciona da seguinte forma:
	cache de condicoes campo [aConditions]

	crio o objeto e vou usando como :

	aadd(aConditions, " VAI_FILIAL = '01'")
	aadd(aConditions, " VAI_CODUSR != '' ")

	no final mando gerar a query e ele monta transformando as condicoes em SQL,
	claro que isso tudo usando helpers entao voce verá da seguinte forma nos fontes:

	oFrota := FrotaSql():New()
	oFrota:And("VAI_FILIAL", xFilial('VAI')):NotDeleted():Limit(10)

	Isso vai adicionar condicoes a query e retornar no maximo 10 registros.

	Os metodos sem _ no comeco sao os que podem ser usados sem restricao e é interessante
	estuda-los pois sao os que mais serão utilizados e vistos pelos fontes.

	Os metodos com _ no comeco geralmente envolvem usar os dados de cache ou limpa-los
	ou seja é bom saber o que está fazendo quando for utilizá-los.
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
class VEQuery
	data oArrHlp
	data cScope
	data aConditions
	data aRelFields
	data aSelect
	data nRecno
	data aJoins
	data aRelations
	data lNoLock
	data oSqlHlp
	data cPulaLinha
	data cQAlias
	data lWithRelations
	data nLimit
	data aDefScope
	data cCampoId
	data cOrder
	data cFieldFil
	data aQryFlds

	method New() constructor
	method Cache()
	
	method Clear()
	method Join()
	method LeftJoin()
	method ToSqlQuery()
	method ToJsonArray()
	method GetStrRelField()
	method GetQueryFields()
	method SetPKField()
	method GetQueryAlias()
	method GetLastId()

	method GetFieldAlt()
	method GetFieldInc()
	method HasMorePages()
	method LastCount()
	method IfNullEmpty()

	// Afeta o query mas não resulta em nada
	method AddDefScope()
	method And()
	method AndEq()
	method AndIn()
	method AndNotEq()
	method AndLessThan()
	method AndLessEqual()
	method AndGrThan()
	method AndGrEqual()
	method _From()
	method Limit()
	method NotDeleted()
	method Or()
	method Select()
	method Order()

	// Metodos que realizam query e retornam dados
	// limpando cache
	method Count()
	method Find()
	method FindByRecno()
	method First()
	method GetAll()
	method Last()
	method Paginate()


	method _Where()
	method _CamposString()
	method _CamposArray()
	method _TableName()
	method _GeraCondicao()
	method _ValueToSql()
	method _QueryAlias()
	method _DuplicateEmpty()
	method _ToPaginateQuery()
	method _GetLastRecno()
	method _Join()
	method _GetRelData()
	method _OneRelToJoin()
	method _GetStrWhere()
	method _GetOnlyFldName()
	method _GetAliasName()
	method _GenerifyQuery()
end class

/*/{Protheus.doc} New
	Construtor Basico
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method New(cAlias) class VEQuery
	::oArrHlp        := DMS_ArrayHelper():New()
	::oSqlHlp        := DMS_SqlHelper():New()
	::cScope         := ""
	::aConditions    := {}
	::aSelect        := {}
	::aRelFields     := {}
	::aJoins         := {}
	::aRelations     := {}
	::aDefScope      := {}
	::lNoLock        := .f.
	::lWithRelations := .t.
	::cPulaLinha     := chr(13) + chr(10)
	::nLimit         := 0
	::cCampoId       := 'R_E_C_N_O_'
	::cQAlias        := cAlias
	::cFieldFil      := cAlias + "_FILIAL"
return SELF

/*/{Protheus.doc} GetQueryAlias
	retorna o alias de query

	@type function
	@author Vinicius Gati
	@since 13/12/2018
/*/
Method GetQueryAlias() Class VEQuery
	if empty(self:cQAlias)
		self:cQAlias := self:cAlias
	endif
Return self:cQAlias

/*/{Protheus.doc} SetPKField
	Troca o campo de id da tabela

	@type function
	@author Vinicius Gati
	@since 04/12/2018
/*/
Method SetPKField(cField) Class VEQuery
	self:cCampoId := cField
Return .t.

/*/{Protheus.doc} AddDefScope
	Adiciona uma condicao de escopo global

	@type function
	@author Vinicius Gati
	@since 30/11/2018
/*/
Method AddDefScope(bBlock) Class VEQuery
	aadd(self:aDefScope, bBlock)
Return .t.

/*/{Protheus.doc} ToJsonArray
	Retorna array com jsonobjects para enviar via api
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method ToJsonArray(aObjs) Class VEQuery
return self:oArrHlp:Map(aObjs, {|oEl| oEl:ToJsonApi() })

/*/{Protheus.doc} Paginate
	Pagina a query e retorna os resultados
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method Paginate(nPage, nPerPage) Class VEQuery
	cQuery := self:_ToPaginateQuery()
	cOrderP := "order by " + self:cQAlias + ".R_E_C_N_O_ "
	cQuery := self:_GenerifyQuery(cQuery)
	cQuery := self:oSqlHlp:Offset(cQuery, nPage, nPerPage, cOrderP, self:_CamposArray(), self:cFieldFil)
return self:GetAll(cQuery)

/*/{Protheus.doc} HasMorePages
	Retorna se na ultima paginação pedida existem mais paginas ainda para pedir
	
	@type function
	@author Vinicius Gati
	@since 03/09/2019
/*/
method HasMorePages() Class VEQuery
return self:oSqlHlp:lHasNext

/*/{Protheus.doc} LastCount
	Retorna o count da ultima query
	
	@type function
	@author Vinicius Gati
	@since 03/09/2019
/*/
method LastCount() Class VEQuery
return self:oSqlHlp:nCount

/*/{Protheus.doc} Limit
	Limita quantidade de registros que será retornados

	@type function
	@author Vinicius Gati
	@since 19/11/2018
/*/
Method Limit(nQtd) Class VEQuery
	self:nLimit := nQtd
Return self

/*/{Protheus.doc} NotDeleted
	Coloca where do delete para registros nao deletados
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method NotDeleted() Class VEQuery
return self:And('D_E_L_E_T_', '=', ' ')

/*/{Protheus.doc} Count
	Retorna a quantidade de registros da query em cache atual
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method Count(lClear) Class VEQuery
	local cQuery := self:ToSqlQuery()
	default lClear := .t.
	if lClear
		self:Clear()
	endif
return self:oSqlHlp:Count(cQuery, ::cFieldFil)

/*/{Protheus.doc} VERegistroSql
	Busca cliente pelo id
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method Find(uId) Class VEQuery
	local cQuery := ''
	local oReg

	// Montar query internamente
	self:Select();
		:_From(self:cAlias);
		:AndEq(self:cFieldFil, xFilial(self:cAlias));
		:AndEq(self:cCampoId, uId);
		:NotDeleted()

	// busca primeiro registro
	oReg := self:First()

	// limpa a query interna
	self:Clear()
return oReg

/*/{Protheus.doc} FindByRecno
	Busca pelo recno

	@type function
	@author Vinicius Gati
	@since 06/12/2018
/*/
Method FindByRecno(nRecno) Class VEQuery
	self:Select();
		:_From(self:cAlias);
		:AndEq('R_E_C_N_O_', nRecno);
		:NotDeleted()

	// busca primeiro registro
	oReg := self:First()

	// limpa a query interna
	self:Clear()	
Return oReg

/*/{Protheus.doc} Clear
	Limpa o cache da query atual para que se possa
	usar o mesmo objeto para criar outra query.
	Use com sabedoria
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method Clear() class VEQuery
	self:cScope       := ""
	self:cOrder       := ""
	self:aConditions  := {}
	self:aSelect      := {}
	self:aQryFlds     := {}
	self:aJoins       := {}
	self:lNoLock      := .f.
	self:nLimit       := 0
return self

/*/{Protheus.doc} Select
	Seta os campos que serao retornados no sql
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method Select(aCampos) class VEQuery
	default aCampos := self:aCampos
	self:aQryFlds := aCampos
	if len(self:aRelFields) > 0
		aeval(self:aRelFields, {|campo| aadd(self:aQryFlds, campo)})
	endif
return self

/*/{Protheus.doc} Order
	Seta o order da query

	@type function
	@author Vinicius Gati
	@since 06/12/2018
/*/
Method Order(cOrder) Class VEQuery
	self:cOrder := cOrder
Return self

/*/{Protheus.doc} _From
	Seta o alias
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _From(cAlias) class VEQuery
	self:cAlias := cAlias
	self:cQAlias := cAlias
return self

/*/{Protheus.doc} First
	Busca 1 registro no banco e retorna de acordo com a query
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method First() Class VEQuery
	local nX        := 1
	local oReg      := self:_DuplicateEmpty()
	local aCmpFinal := self:GetQueryFields()
	local cAl       := "VEQUERY_FIRST"
	local nTam      := 0
	local cQuery

	cQuery := self:ToSqlQuery()
	cQuery := self:_GenerifyQuery(cQuery)

	// Trata query para retornar somente 1 registro
	cQuery := self:oSqlHlp:TopFunc(cQuery, 1)

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	dbSelectArea(cAl)
	nTam := FCOUNT()
	While ! (cAl)->(EOF())
		for nX := 1 TO nTam
			if upper(Field(nX)) == "RWN"
				loop
			endif
			
			cCampo := aCmpFinal[nX] //self:_GetAliasName(Field(nX))
			if upper(Field(nX)) $ upper(cCampo)
				oReg:Set(cCampo,  (cAl)->(FieldGet(nX)))
			else
				oReg:Set(cCampo,  Nil)
				conout("CAMPO NAO RETORNADO NA QUERY " + cCampo + " CAMPO RETORNADO " + field(nX))
			endif
		next nX

		//aeval(aCmpFinal, {|campo| oReg:Set(campo, (cAl)->(FieldGet(nX))) , nX += 1 })
		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
	// limpa cache
	self:Clear()
return oReg

/*/{Protheus.doc} GetAll
	Busca registros independente do numero de registros retornados
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method GetAll(cQuery) Class VEQuery
	local oReg
	local aRegistros := {}
	local aCmpFinal  := self:GetQueryFields()
	local nX         := 1
	local cAl        := "VEQUERY_GETALL"
	local nTam       := 0
	default cQuery   := self:ToSqlQuery()

	cQuery := self:_GenerifyQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )
	dbSelectArea(cAl)
	While ! (cAl)->(EOF())
		nX := 1
		oReg := self:_DuplicateEmpty()
		//aeval(aCmpFinal, {|campo| oReg:Set(campo, (cAl)->(FieldGet(nX))) , nX += 1 })
		nTam := FCOUNT()
		for nX := 1 TO nTam // -1 pois o dbaccess sempre retorna 1 campo a mais que é o rwn
			if upper(Field(nX)) == "RWN"
				loop
			endif
			
			cCampo := aCmpFinal[nX] //self:_GetAliasName(Field(nX))
			if upper(Field(nX)) $ upper(cCampo)
				oReg:Set(cCampo,  (cAl)->(FieldGet(nX)))
			else
				oReg:Set(cCampo,  Nil)
				conout("CAMPO NAO RETORNADO NA QUERY " + cCampo + " CAMPO RETORNADO " + field(nX))
			endif
		next
		
		aadd(aRegistros, oReg)
		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
	// limpa cache
	self:Clear()
return aRegistros

/*/{Protheus.doc} Cache
	Pega os resultados e joga em um arquivo em formato json e gzipado
	
	@type function
	@author Vinicius Gati
	@since 20/11/2018
/*/
method Cache(cArrName) Class VEQuery
	local cData      := ''
	local lFirst     := .t.
	local cFileName  := cArrName
	local nX
	local nHandler
	local cJsonFn
	local aCollection

	cFileName += "_" + alltrim(xfilial(self:cAlias)) + "_" + dtos(date())+left(strtran(time(), ':', ''), 2) + ".gzip"
	cJsonFn   := strtran(cFileName, '.gzip', '.json')

	//cache
	if ! file(cFileName)
		// nQtd := self:Count(.f.) // qtd sem limpar cache
		aCollection := self:GetAll()
		oFileStream := FCREATE(cJsonFn)
		FWRITE(oFileStream, '{ "items" : [')

		for nX := 1 to len(aCollection)
			if ! lFirst
				FWRITE(oFileStream, ",")
			endif
			
			FWRITE(oFileStream, aCollection[nX]:toJson())
			freeobj(aCollection[nX])
			lFirst := .f.
		next
		FWRITE(oFileStream, ']}')
		FCLOSE(oFileStream)

		if ! GzCompress(cJsonFn, cFileName, .t.)
			return 'error'
		endif
	endif

	FErase(cJsonFn,/*xParam*/,.f.)
	nHandler := FOPEN(cFileName, 0) // 0=leitura
	cData    := FREADSTR(nHandler, 3000000)
	FCLOSE(nHandler)
 return cData

/*/{Protheus.doc} _CamposString
	Busca diretamente pelo recno
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _CamposString() class VEQuery
return self:oArrHlp:Join(self:oArrHlp:Uniq(self:_CamposArray()), ',')

/*/{Protheus.doc} _CamposArray
	Traz os campos do modelo com alias para evitar erros

	@type function
	@author Vinicius Gati
	@since 14/11/2018
/*/
Method _CamposArray() Class VEQuery
	local aFinal
	local nX := 1

	If empty(self:aQryFlds)
		self:select()
	EndIf

	// coloca alias em todos os campos que nao possuem
	aFinal := self:oArrHlp:Map(self:aQryFlds, {|cFld| IIF('.' $ cFld, cFld, self:GetQueryAlias() + "." + cFld) })

	if self:lWithRelations
		for nX := 1 to len(self:aRelations)
			if self:aRelations[nX]:GetTipo() == "ONE"
				aadd(aFinal, self:aRelations[nX]:GetObj():GetStrRelField())
			endif 
		next
	endif	
Return aFinal

/*/{Protheus.doc} GetQueryFields
	Pega os campos que vieram do sql gerado para adicionar os valores ao json

	@type function
	@author Vinicius Gati
	@since 13/11/2018
/*/
Method GetQueryFields() Class VEQuery
	local aFinal
	local nX := 1

	If empty(self:aQryFlds)
		self:select()
	EndIf
	// coloca alias em todos os campos que nao possuem
	aFinal := self:oArrHlp:Map(self:aQryFlds, {|cFld| self:_GetOnlyFldName(cFld) })

	if self:lWithRelations
		for nX := 1 to len(self:aRelations)
			if self:aRelations[nX]:GetTipo() == "ONE"
				aadd(aFinal, self:_GetAliasName(self:aRelations[nX]:GetObj():GetStrRelField()) )
			endif 
		next
	endif
	aFinal := self:oArrHlp:Uniq(aFinal)
return aFinal

/*/{Protheus.doc} _GetAliasName
	Pega o alias do campo que é seu nome ou o que vem depois do nome do campo

	@type function
	@author Vinicius Gati
	@since 13/11/2018
/*/
Method _GetAliasName(cFldName) Class VEQuery
	local nAt
	cFldName := rtrim(cFldName)
	if " AS " $ UPPER(cFldName)
		nAt := at(" AS ", upper(cFldName))
	elseif ' ' $ rtrim(cFldName)
		nAt := at(" ", cFldName)
	else
		return self:_GetOnlyFldName(cFldName)
	endif
Return right( cFldName, len(cFldName) - nAt - 3)

/*/{Protheus.doc} GetStrRelField
	Retorna o campo que vem de id no
	relacionamento

	@type function
	@author Vinicius Gati
	@since 13/11/2018
/*/
Method GetStrRelField() Class VEQuery
Return self:cAlias + "." + self:cCampoId + " as id_" + self:cAlias

/*/{Protheus.doc} _GeraCondicao
	Gera condicao sql em string formato sql simples para usar nas condicoes
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _GeraCondicao(cCampo, cCondition, uValue) class VEQuery
	if Empty(self:cQAlias)
		self:cQAlias := self:cAlias
	endif
	if ( right(cCampo, 6) == 'DATINC' .or. right(cCampo, 6) == 'DATALT' ) .and. len(uValue) == 20
		return " " + self:cQAlias + "." + cCampo + " " + cCondition + " " + self:_ValueToSql(uValue, .t.)				
	endif
	if "." $ cCampo
		// troca alias normal por alias de query
		cCampo := STRTRAN(cCampo, self:cAlias + ".", self:cQAlias + ".")
		return cCampo + " " + cCondition + " " + self:_ValueToSql(uValue)
	endif
return " " + self:cQAlias + "." + cCampo + " " + cCondition + " " + self:_ValueToSql(uValue)

/*/{Protheus.doc} _GetLastRecno
	Pega o ultimo recno para voltar para o usuario o id do registro recem criado
	
	@type function
	@author Vinicius Gati
	@since 05/11/2018
/*/
method _GetLastRecno() class VEQuery
return FM_SQL("SELECT MAX(R_E_C_N_O_) FROM " + self:_TableName() + " WHERE D_E_L_E_T_ = ' ' ")

/*/{Protheus.doc} GetLastId
	

	@type function
	@author Vinicius Gati
	@since 14/12/2018
/*/
Method GetLastId() Class VEQuery
Return FM_SQL(" select " + self:cCampoId + " from " + self:_TableName() + " WHERE R_E_C_N_O_ = " + cValToChar( self:_GetLastRecno() ))

/*/{Protheus.doc} Last
	Pega o ultimo registro no banco para retornar no rest
	
	@type function
	@author Vinicius Gati
	@since 28/11/2018
/*/
method Last() class VEQuery
return self:FindByRecno(self:_GetLastRecno())

/*/{Protheus.doc} _TableName
	Pega o nome da tabela dependendo do esquema de lock necessario
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _TableName() class VEQuery
	if self:lNoLock
		return self:oSqlHlp:NoLock(self:cAlias)
	endif
	if Empty(self:cQAlias)
		self:cQAlias := self:cAlias
	endif
return RetSqlName(self:cAlias) + " " + self:cQAlias

/*/{Protheus.doc} _ValueToSql
	Pega um valor e tenta converter para um formato de query sql
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _ValueToSql(uVal, lTimeStamp) class VEQuery
	local cVal := ''
	local cType := ValType(uVal)
	default lTimeStamp := .f.

	if lTimeStamp
		uVal := FGX_Timestamp(uVal)
	endif

	Do Case
	case cType == 'N'
		cVal += cValToChar(uVal)
	case cType == 'D'
		cVal += "'" + DTOS(uVal) + "'"
	case cType == 'A'
		cVal += " {[do not use array]} "
	case cType == 'O'
		cVal += " {[do not use object]} "
	case cType == 'L'
		cVal += IIF(uVal == .T., '1', '0')
	case cType == 'U'
		cVal += " '' "
	otherwise
		cVal += "'" + uVal + "'"
	end case
return cVal

/*/{Protheus.doc} Where
	Adiciona uma condicao e retorna o objeto
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _Where(cCampo, cCondition, uValue) class VEQuery
	aadd(self:aConditions, self:_GeraCondicao(cCampo, cCondition, uValue))
return self

/*/{Protheus.doc} AndIn
	AndIn para sql e filtro

	@type function
	@author Vinicius Gati
	@param cAlCampo, Enviar parametro com alias pois esse metodo nao trata alias
	@since 14/11/2018
/*/
method AndIn(cAlCampo, cIn) class VEQuery
	aadd(self:aConditions, cAlCampo + " IN (" + cIn + ")")
return self

/*/{Protheus.doc} And
	Alias para metodo where, o where foi criado para que fique 
	uma sintax mais parecida com sql direto
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method And(cCampo, cCondition, uValue) class VEQuery
	self:_Where(cCampo, cCondition, uValue)
return self

/*/{Protheus.doc} AndEq
	Coloca a condicao de igual sem ter que criar string
	
	@type function
	@author Vinicius Gati
	@since 07/11/2018
/*/
method AndEq(cCampo, uValue) class VEQuery
return self:_Where(cCampo, '=', uValue)

/*/{Protheus.doc} AndNotEq
	adiciona condiao de != no sql

	@type function
	@author Vinicius Gati
	@since 30/11/2018
/*/
Method AndNotEq(cCampo, uValue) Class VEQuery
return self:_Where(cCampo, '!=', uValue)


/*/{Protheus.doc} AndLessThan
	AndLessThan

	@type function
	@author Vinicius Gati
	@since 30/11/2018
/*/
Method AndLessThan(cCampo, uValue) Class VEQuery
return self:_Where(cCampo, '<', uValue)

/*/{Protheus.doc} AndLessEqual
	AndLessEqual

	@type function
	@author Vinicius Gati
	@since 30/11/2018
/*/
Method AndLessEqual(cCampo, uValue) Class VEQuery
return self:_Where(cCampo, '<=', uValue)

/*/{Protheus.doc} AndGrThan
	AndGrThan

	@type function
	@author Vinicius Gati
	@since 30/11/2018
/*/
Method AndGrThan(cCampo, uValue) Class VEQuery
return self:_Where(cCampo, '>', uValue)

/*/{Protheus.doc} AndGrEqual
	AndGrEqual

	@type function
	@author Vinicius Gati
	@since 30/11/2018
/*/
Method AndGrEqual(cCampo, uValue) Class VEQuery
return self:_Where(cCampo, '>=', uValue)

/*/{Protheus.doc} Or
	O Or é um pouco complexo, ele pega a ultima condicao e se cola a ela
	com a condição OR sendo que se você usar oQry:And("Nome", "=", "Vinicius").Or("Idade", "=", "20")
	voce tera `select * from Tabela where Nome = 'vinicius' or Idade = 20`
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method Or(cCampo, cCondition, uValue) class VEQuery
	local cLasCond := ""
	cLasCond := self:aConditions[len(self:aConditions)]
	cCond := " (" + cLasCond + " OR " + self:_GeraCondicao(cCampo, cCondition, uValue) + ") "
	self:aConditions[len(self:aConditions)] := cCond
return self

/*/{Protheus.doc} Join
	method Join class VEQuery
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method Join(cAlias, cQAlias, cWhere) class VEQuery
	self:_Join("JOIN", cAlias, cQAlias, cWhere)
return self

/*/{Protheus.doc} leftJoin
	method leftJoin() class VEQuery

	Cria um alias para a tabela com mesmo nome do parametro porem se 
	a relacao for da mesma tabela pega adicionar um numerador ao alias
	fazendo com que a relacao fique com alias+numero exemplo
	relacionei frota com frota assim o alias base sera VC3 e o alias do join sera VC31
	se fizer outro join vai ser VC32 e assim por diante.

	Além disso no cWhere se quiser utilizar alias use sempre BASE. para referenciar os
	dados base e RELA. para referenciar o join atual
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method LeftJoin(cAlias, cQAlias, cWhere) class VEQuery
	self:_Join("LEFT JOIN", cAlias, cQAlias, cWhere)
return self

/*/{Protheus.doc} _ToPaginateQuery
	retorna do from para frente para usar no offset
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _ToPaginateQuery() class VEQuery
return self:ToSqlQuery(.t.)

/*/{Protheus.doc} toString
	method toString class VEQuery
	
	@param lPrePag, É pra gerar para preparação de paginacao? se sim gera somente do from pra frente
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method ToSqlQuery(lPrePag) class VEQuery
	local cQuery := ""
	local nX     := 1
	default lPrePag := .f.

	if self:lWithRelations
		self:_OneRelToJoin()
	endif

	if ! lPrePag
		cQuery += " SELECT " + self:_CamposString() + self:cPulaLinha
	endif
	cQuery += "   FROM " + self:_TableName() + self:cPulaLinha
	for nX := 1 to len(self:aJoins)
		cQuery += self:aJoins[nX] + self:cPulaLinha
	next

	// isso permite que os escopos entrem na query diretamente antes da criacao dos wheres abaixo
	For nX:= 1 to Len(self:aDefScope)
		eval(self:aDefScope[nX], self)
	Next

	// jogas as condicoes where a query	
	if len(self:aConditions) > 0
		cQuery += "  WHERE " + self:cPulaLinha
		cQuery += self:oArrHlp:Join(self:aConditions, self:cPulaLinha + " AND ")
	endif

	if ! Empty(self:cOrder)
		cQuery += " order by " + self:cOrder + self:cPulaLinha
	endif

	// se tiver limitado os resultados eh aqui que acontece
	if self:nLimit > 0
		cQuery := self:oSqlHlp:TOPFunc(cQuery, self:nLimit)
	endif
	self:Clear()
return cQuery

/*/{Protheus.doc} _DuplicateEmpty
	Cria novo registro com os dados basicos ja preenchidos, provavel que 
	nao sera necessario mais usar isso assim que essa classe nao for usada
	diretamente, esse é o intuito, usar somente com heranca
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method _DuplicateEmpty() Class VEQuery
	local oReg := &(GetClassName(self) + "():New()")
	cAlias     := self:cAlias
	aCampos    := self:aCampos
return oReg

/*/{Protheus.doc} _Join
	Adiciona um Join usando padrao de join pós from à query setando alias conforme seguinte regra:
	
	Cria um alias para a tabela com mesmo nome do parametro cAlias porém se 
	a relacao for da mesma tabela adiciona um numerador ao alias
	fazendo com que a relacao fique com alias+numero exemplo
	relacionando frota com frota assim temos o alias base que sera VC3 e o alias do join que será `VC31`
	se fizer outro join vai ser `VC32` e assim por diante.

	Além disso no cWhere se quiser utilizar alias use sempre `BASE.` para referenciar os
	dados base e `RELA.` para referenciar o join atual eles serão convertidos ao valor 
	conforme configurado no modelo e você evita erros de sql em runtime
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method _Join(cJoin, cAlias, cQAlias, cWhere) class VEQuery
	local cTableName := RetSqlName(cAlias)
	local cAlias
	local cCondition

	if cQAlias == self:cAlias
		cQAlias := self:cAlias + cValToChar(len(self:aJoins) + 1)
	endif

	// usar alias gerado quando o mesmo foi utilizado erroneamente podendo conflitar campos
	// quando usar alias usar a tabela por conta e risco ou usar BASE. para representar o objeto base e RELA. para representar a tabela de join
	cCondition := STRTRAN(cWhere, "BASE.", self:cAlias + '.')
	cCondition := STRTRAN(cCondition, "RELA.", cAlias + '.')

	aadd(self:aJoins, cJoin + " " + cTableName + " " + cQAlias + " ON " + cCondition)
return self

/*/{Protheus.doc} _GetRelData
	Retorna os dados do relacionamento com nome passado por parametro
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method _GetRelData (cRelName) Class VEQuery
	local nX := 1
	for nX := 1 to len(self:aRelations)
		if upper(self:_CleanClassName(self:aRelations[nX]:cClasse)) == upper(cRelName)
			return self:aRelations[nX]
		endif 
	next
return

/*/{Protheus.doc} _OneRelToJoin
	Joga relacoes de 1 pra 1 na query para trazer recno
	isso deve ser feito para que ajude no json
	
	@type function
	@author Vinicius Gati
	@since 13/11/2018
/*/
method _OneRelToJoin() Class VEQuery
	local nX
	for nX := 1 to len(self:aRelations)
		cWhere := self:_GetStrWhere(self:aRelations[nx])
		self:LeftJoin(self:aRelations[nx]:GetAlias(), self:aRelations[nx]:GetQueryAlias(), cWhere)
	next
return

/*/{Protheus.doc} _GetStrWhere
	Gera where de um relacionamento contido no aRelations
	
	@type function
	@author Vinicius Gati
	@since 13/11/2018
/*/
method _GetStrWhere(oRelData) class VEQuery
	local nX        := 1
	local aChaves   := oRelData:GetChaves()
	local cWhere    := ""
	local aWhere    := {}

	if oRelData:lCacheQry
		return oRelData:GetQuery()
	endif

	// calcula se necessario e retorna os valores
	for nX := 1 to len(aChaves)
		// tratamento para usar o valor direto e poder fazer coisas diferentes de =
		if Len(aChaves[nX]) == 1
			aadd(aWhere, " " + aChaves[nX, 1] + " ")
			loop
		endif

		cFld1 := aChaves[nX, 1]
		cFld2 := aChaves[nX, 2]
		if valtype(cFld1) == 'B'
			cFld1 := eval(cFld1)
			cFld1 := self:_ValueToSql(cFld1)
		elseif valtype(cFld2) == 'B'
			cFld2 := eval(cFld2)
			cFld2 := self:_ValueToSql(cFld2)
		endif

		cFld1 := STRTRAN(cFld1, "BASE.", self:cAlias + '.')
		cFld1 := STRTRAN(cFld1, "RELA.", oRelData:GetQueryAlias() + '.')

		cFld2 := STRTRAN(cFld2, "BASE.", self:cAlias + '.')
		cFld2 := STRTRAN(cFld2, "RELA.", oRelData:GetQueryAlias() + '.')

		aadd(aWhere, " " + cFld1 + " = " + cFld2 + " ")
	next

	aeval( oRelData:GetDefaultScope() , {|where|aadd(aWhere, where)} )

	// delete vou colocar padrao, se um dia isso mudar pensamos melhor em como fazer
	// acho que relacao vai ter que virar uma classe pra evitar esses indices de array direto no fonte
	aadd(aWhere, " " + oRelData:GetQueryAlias() + ".D_E_L_E_T_ = ' ' ")

	// gera o where com ands tudo ok
	cWhere := self:oArrHlp:Join(aWhere, " AND ")

	// cria o cache desse resultado
	oRelData:SetQuery(cWhere)
return cWhere

/*/{Protheus.doc} _GetOnlyFldName
	Pega uma string remove os alias e retorna somente o campo

	Usa at pega posicao, remove do tamanho total pegando da direita pra esquerda

	@type function
	@author Vinicius Gati
	@since 13/11/2018
/*/
Method _GetOnlyFldName(cFld) Class VEQuery
	local nAtPonto := at(cFld, '.')
Return right( cFld, len(cFld) - nAtPonto )

/*/{Protheus.doc} GetFieldAlt
	Retorna nome do campo de data de alteração
	
	@type function
	@author Vinicius Gati
	@since 23/08/2019
/*/
method GetFieldAlt() Class VEQuery
Return self:cAlias + "_DATALT"

/*/{Protheus.doc} GetFieldInc
	Retorna nome do campo de data de alteração
	
	@type function
	@author Vinicius Gati
	@since 23/08/2019
/*/
method GetFieldInc() Class VEQuery
Return self:cAlias + "_DATINC"

/*/{Protheus.doc} IfNullEmpty
	Retorna string em branco se o valor for nulo

	@type function
	@author Vinicius Gati
	@since 23/01/2020
/*/
Method IfNullEmpty(uVal) Class VEQuery
	if empty(uVal)
		return ""
	endif
Return uVal

/*/{Protheus.doc} _GenerifyQuery
	Metodo criado para fazer ajustes simples em um query
	tentando deixar mais generica para rodar em varios bancos de dados

	@type function
	@author Vinicius Gati
	@since 23/01/2020
/*/
Method _GenerifyQuery(cQuery) Class VEQuery
	If "ORACLE" $ cSGBD
		return STRTRAN(cQuery, "+", "||")
	endif
Return cQuery