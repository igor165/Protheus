
#include "protheus.ch"
#include "VERegistroSql.ch"

function VERegistroSql()
return

/*/{Protheus.doc} VERegistroSql
	Classe para ajudar na criação de APIs rest e regras de negócio para a mesma

	Ela controlará busca de dados, queries em uma DSL parecida com de outras linguagens atuais
	que resolve muito bem e deixa o codigo muito limpo sem uso de strings	nos fontes.

	Além disso regras de negócios poderão ser criadas com a ajuda dessa classe, ela possui diversos
	callbacks para que seja possível utiliza-los nas classes que herdam dessa e que vão ajudar
	a criar regras de negocio por exemplo:

	Antes de jogar no banco a agenda quero criar outra agenda dependendo da data de próxima agenda
	Para resolver esse problema posso utilizar o callback BeforeSave() que roda antes do salvamento
	no banco diretamente.

	Além deste existem diversos outros callbacks que podem ser usados de diversas formas como por exemplo
	o callback de validação Validate() que acontece sempre antes de salvar o modelo no banco e inclusive
	evita o salvamento gravando erros que podem ser recuperados usando o metodo GetErros()

	Para evitar o salvamento ou deleção do registro deve-se usar os callbacks para adicionar erros ao objeto
	fazendo com que o mesmo nao seja excluido, para fazer isso use o metodo AddError()

	Adentro sobre callbacks e pontos de entrada:

	Diversos callbacks existem para os programadores usarem, e para o cliente também foram criados os mesmos callbacks
	em formato de pontos de entrada que eles podem utilizar.
	Segue lista de pontos de entrada:

	Julgando que o alias do registro seja VC3 temos:

	|  VVC3BC   | Ponto de entrada para evento beforeCreate (antes de salvar registros novos)
	|  VVC3BS   | Ponto de entrada para evento beforeSave (antes de salvar qualquer registro novo ou já existente)
	|  VVC3BD   | Ponto de entrada para evento beforeDelete (antes de deletar um registro)
	|  VVC3BV   | Ponto de entrada para evento beforeValidate (antes de salvar é feita validação padrao no modelo, este evento acontece antes dela)
	|  VVC3AC   | Ponto de entrada para evento afterCreate (depois de salvar registros novos)
	|  VVC3AS   | Ponto de entrada para evento afterSave (depois de salvar qualquer registro novo ou já existente)
	|  VVC3AD   | Ponto de entrada para evento afterDelete (depois de deletar um registro)
	|  VVC3AV   | Ponto de entrada para evento afterValidation (depois da validacao padrao)
	|  VVC3FLD  | Ponto de entrada para adicionar campos a entidade, eles serão retornados no webservice alem dos padroes
	|  VVC3FLDD | Ponto de entrada para evento adicionar campos data ao modelo, adiciona estes campos aos campos data do modelo para serem tratados diferente
	|  VVC3FLDM | Ponto de entrada para evento adiciona campos memo ao modelo, adiciona estes campos aos campos memo do modelo para serem tratados diferente
	|  VVC3FLDP | Ponto de entrada para evento adicionar campo permitido ao modelo, por padrao nenhum campo permite alteracao direta a base protheus, para que seja possível alteração deve-se usar este ponto de entrada)
	|  VVC3VA   | Ponto de entrada para evento validation, neste você consegue adicionar validacoes que você precisar ao modelo.
	|  VVC3SFMT | Ponto de entrada para formatar os dados que serão enviados para api externas

	Todos os pontos de entrada recebem na primeira posição do paraixb o proprio modelo e pode-se utilizar obj:Get("CAMPO") e obj:Set("CAMPO")
	para setar ou pegar os valores contidos no objeto.

	Os Pontos de entrada de campos data e memo servem para que o protheus faça um tratamento diferenciado neles para retornar
	o valor via webservice, sempre adicionar os campos tanto nos campos (VVC3FLDD) quanto nos de tratamento adequado de data ou memo.

	Para evitar qualquer evento de alterar o banco de dados deve-se adicionar erros ao modelo da 
	seguinte forma:

	self:AddError("VAI_FILIAL", "Filial deve ser informada.")

	Desta forma o modelo não será salvo, o metodo EstaValido() retornará .f. e o erro será retornado ao cliente em formato json via webservice se for o caso.

	Por exemplo caso você queira evitar que qualquer registro seja deletado da base via serviço rest você pode criar
	o beforeDelete ou o ponto de entrada do beforeDelete adicionando qualquer erro ao modelo:

	self:AddError("CANT_DELETE", "Este modelo não pode ser deletado")

	e pronto, não será possível deletar o modelo de forma alguma e o erro bonitinho será retornado.

	Adentro a desenvolvedores:

	Sempre que for sobrescrever um metodo que possua callback ou PE chamar o metodo original na classe pai usando _Super:Metodo()
	Caso contrário espero que saiba o que está fazendo pois você irá evitar o código do cliente rodar ou até mesmo o código padrão.
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
class VERegistroSql from VEQuery
	Data cAlias
	Data aCampos
	Data aCamposMemo
	Data aCamposData
	Data aCamposTimeStamp
	Data aPermiteAssign
	Data aErros
	Data nRecno
	Data oJsonData
	Data lMemosFetched
	Data oCfgSync

	method New() constructor

	method SetPermitAssign()
	method PermiteAssign()
	method SetFields()
	method AddFields()
	method AddRelFields()
	method AddField()
	method AddFieldsData()
	method AddFieldsMemo()
	method AddFieldsTimestamp()

	// Callbacks seriam privados
	method BeforeCreate()
	method BeforeSave()
	method BeforeDelete()
	method BeforeValidate()
	method AfterCreate()
	method AfterSave()
	method AfterDelete()

	// criado para poder setar valores fora de padrao ou 
	// tipos de campo antigos como memos ao criar ou salvar um registro
	method CustomSetValues()

	//metodos fixos para chamada
	method ForceSave()
	method Save()
	method Delete()
	method Validate()
	method Set()
	method SetRaw()
	method Get()
	method GetId()
	method SetRecno()
	method AddError()
	method EstaValido()
	method ToJson()
	method ToJsonApi()
	method ToJsonData()
	method ToSyncModel()
	method Persistido()
	method IsNew()
	method IsDataField()
	method InternalField()
	method FetchMemoFields()
	method FetchOldMemos() // criado para pegar os dados de memos antigos
	method GetErros()
	method MassAssign()
	method GetRel()
	method GetIntErr()

	// Relational methods
	method HasOne()
	method HasMany()

	// Sincronization
	method Sync()
	method Touch()

	//Validation Methods
	method ValidaTamanho()
	method ValNuloOuTamanho()
	method ValidaCombo()
	method ValidaData()
	method ValNuloData()
	method ValidaNumerico()
	Method ValidaStrNumerica()

	method _Posiciona()
	method _isMemo()
	method _Save()
	method _Delete()
	method _Validate()
	method _Preenche()
	method _GetOne()
	method _CleanClassName()
	method _RelFromAlias()
	method _OrdArr()
end class

/*/{Protheus.doc} New
	Construtor Basico
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method New(cAlias) Class VERegistroSql
	local cPeName,aFldCus
	default cAlias     := 'NULL'
	::oJsonData        := JsonObject():New()
	::cAlias           := cAlias
	::aCampos          := {}
	::aCamposMemo      := {}
	::aCamposData      := {}
	::aPermiteAssign   := {}
	::aErros           := {}
	::nRecno           := 0
	::lMemosFetched    := .f.
	::aCamposTimeStamp := {}
	_Super:New(cAlias)

	/** Chamadas para pontos de entrada de usuarios */

	// campos customizados
	cPeName := "V" + ::cAlias + "FLD"
	if ExistBlock(cPeName)
		aFldCus := ExecBlock(cPeName,.f.,.f.)
		::AddFields(aFldCus)
	endif

	// campos data customizados, devem ser inseridos tambem no ponto de entrada FLD acima
	cPeName := "V" + ::cAlias + "FLDD"
	if ExistBlock(cPeName)
		aFldCus := ExecBlock(cPeName,.f.,.f.)
		::AddFieldsData(aFldCus)
	endif

	// campos memo
	cPeName := "V" + ::cAlias + "FLDM"
	if ExistBlock(cPeName)
		aFldCus := ExecBlock(cPeName,.f.,.f.)
		::AddFieldsMemo(aFldCus)
	endif

	// campos que permitem mass assign (criacao e alteracao no rest)
	cPeName := "V" + ::cAlias + "FLDP"
	if ExistBlock(cPeName)
		aFldCus := ExecBlock(cPeName,.f.,.f.)
		::PermiteAssign(aFldCus)
	endif

	// campos timestamp padrão
	if len(::cAlias) == 3 .and. (::cAlias)->(fieldpos(::cAlias+"_DATINC")) > 0
		::AddFieldsTimestamp({::cAlias + "_DATINC", ::cAlias + "_DATALT"})
		::AddFields({::cAlias + "_DATINC", ::cAlias + "_DATALT"})
	endif
return SELF

/*/{Protheus.doc} HasOne
	Seta uma relacao com 1 registro
	// example aRelation
	// ::aRelations := {;
	// 	{'ONE', 'VE1', { {'VC3_CODMAR', 'VE1_CODMAR'}                              }, {'RELA.R_E_C_N_O_'}, {'RELA.R_E_C_N_O_'}},;
	// 	{'ONE', 'VV2', { {'VC3_MODVEI', 'VV2_MODVEI'}, {'VC3_CODMAR', 'VV2_CODMAR'}}, {'RELA.R_E_C_N_O_'}, {'RELA.R_E_C_N_O_'}},;
	// 	{'ONE', 'SA1', { {'VC3_CODCLI', 'A1_COD'    }, {'VC3_LOJA'  , 'A1_LOJA'   }}, {'RELA.R_E_C_N_O_'}, {'RELA.R_E_C_N_O_'}};
	// }
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method HasOne(cClass, aFieldsChave, aFields, cNomRel) class VERegistroSql
	default cNomRel     := self:_CleanClassName(cClass)
	default aFields     := {} //TODO: talvez implementar futuramente hoje nao uso trazer dados no mesmo objeto pela relacao
	//aadd(::aRelations, VERelacaoApi():New("ONE", cClass, aFieldsChave))
return

/*/{Protheus.doc} _CleanClassName
	Gera um nome limpo parra usar na relacao

	exemplo: VEFrotaApi retorna Frota
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method _CleanClassName(cClassName) class VERegistroSql
	local cName := cClassName
	// se passou nome da classe mesmo
	// remove o prefixo pra pegar o nome limpo 
	if left(cClassName, 2) $ 'OF.VE' .and. 'API' $ UPPER(right(cClassName,3))
		cName := right(cClassName, len(cClassName) - 2)
	endif
	cName := STRTRAN(cName, 'Api', '')
	cName := STRTRAN(cName, 'API', '')
return cName

/*/{Protheus.doc} SetPermitAssign
	Permite alterar via api somente os campos desse metodo
	substituindo os anteriors já permitidos

	@type function
	@author Vinicius Gati
	@since 22/01/2020
/*/
Method SetPermitAssign(aCampos) Class VERegistroSql
	self:aPermiteAssign := {}
Return self:PermiteAssign(aCampos)

/*/{Protheus.doc} PermiteAssign
	adiciona os campos ao array de permissao de mass assign

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method PermiteAssign(aCampos) Class VERegistroSql
	aeval(aCampos, {|campo| aadd(self:aPermiteAssign, campo) })
Return .t.

/*/{Protheus.doc} SetFields
	Seta os campos removendo qualquer campo anterior

	@type function
	@author Vinicius Gati
	@since 22/01/2020
/*/
Method SetFields(aCampos) Class VERegistroSql
	self:aCampos := {}
Return self:AddFields(aCampos)

/*/{Protheus.doc} AddFields
	Adiciona os campoas ao modelo

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method AddFields(aCampos) Class VERegistroSql
	aeval(aCampos, {|campo| self:AddField(campo) })
Return .t.

/*/{Protheus.doc} AddField
	Adiciona o campo

	@type function
	@author Vinicius Gati
	@since 04/12/2018
/*/
Method AddField(cCampo) Class VERegistroSql
	if "UUID" $ cCampo
		self:SetPKField(cCampo)
	endif
	aadd(self:aCampos, cCampo)
Return .t.

/*/{Protheus.doc} AddRelFields
	Adiciona campos que virão de um join
	Ainda não decidi como isso será feito, só usa mesmo isso na carteira do cliente pra economizar
	request com mobile.

	@type function
	@author Vinicius Gati
	@since 30/09/2019
/*/
Method AddRelFields(aFields) Class VERegistroSql
	aeval(aFields, {|campo| aadd(self:aRelFields, campo)})
Return .t.

/*/{Protheus.doc} AddFieldsData
	Adiciona campos de data

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method AddFieldsData(aCampos) Class VERegistroSql
	aeval(aCampos, {|campo| aadd(self:aCamposData, campo) })
Return .t.

/*/{Protheus.doc} AddFieldsTimestamp
	Adiciona campos que serão tratados como timestamp

	@type function
	@author Vinicius Gati
	@since 30/08/2019
/*/
Method AddFieldsTimestamp(aCampos) Class VERegistroSql
		aeval(aCampos, {|campo| aadd(self:aCamposTimeStamp, campo)})
Return .t.

/*/{Protheus.doc} AddFieldsMemo
	Adiciona campos de data

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method AddFieldsMemo(aCampos) Class VERegistroSql
	aeval(aCampos, {|campo| aadd(self:aCamposMemo, campo) })
Return .t.

/*/{Protheus.doc} ValidaCombo
	Valida se o campo possui um valor valido que deve estar configurado no X3_CBOX do  mesmo
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method ValidaCombo(cCampo, cCombo) Class VERegistroSql
	local nX    := 1
	local aCbox
	local cValor
	local cComboXX
	default cCombo := cCampo
	cComboXX := GetSx3Cache(cCampo, "X3_CBOX")
	if !Empty(cComboXX) .and. ';' $ cComboXX
		aCbox := StrTokArr(cComboXX, ';')
		cValor := cValToChar(self:Get(cCampo))
		if empty(cValor)
			return .t.
		endif
		for nX := 1 to len(aCbox)
			if cValor == left(aCbox[nX], 1)
				return .t.
			endif
		next
		self:AddError(cCampo, STR0001 +GetSx3Cache(cCampo, "X3_CBOX"))//"Valor inválido. Valores Válidos: "
		return .f.
	else
		self:AddError(cCampo, STR0002+cCampo) //"X3_CBOX inválido para campo: "
		return .f.
	endif
return .t.

/*/{Protheus.doc} ValidaTamanho
	Valida tamanho do valor que sera enviado ao banco, com configuracao de minimo e maximo
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method ValidaTamanho(cCampo, nTamMin, nTamMax) class VERegistroSql
	local cValue := self:Get(cCampo)
	default nTamMax := nTamMin // valor maximo = valor minimo quando nao informado
	if valtype(cValue) == "U"
		cValue := ""
	endif
	cValue := rtrim(cValue)
	if len(cValue) < nTamMin
		self:AddError(cCampo, STR0003 + cValToChar(nTamMin))//"Tamanho mínimo do valor deve ser "
		return .f.
	endif
	if len(cValue) > nTamMax
		self:AddError(cCampo, STR0003 + cValToChar(nTamMax))//"Tamanho mínimo do valor deve ser "
		return .f.
	endif
return .t.

/*/{Protheus.doc} ValNuloOuTamanho
	Verifica se e nulo, se nao for valida o valor
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method ValNuloOuTamanho(cCampo, nTamMin, nTamMax) class VERegistroSql
	if ! Empty(self:Get(cCampo))
		self:ValidaTamanho(cCampo, nTamMin, nTamMax)
		return .f.
	endif
return .t.

/*/{Protheus.doc} ValidaData
	Valida se o tipo do campo é data realmente para evitar exceptions
	
	@type function
	@author Vinicius Gati
	@since 05/11/2018
/*/
method ValidaData(cCampo) class VERegistroSql
	if valtype(self:Get(cCampo)) != 'D'
		self:AddError(cCampo, STR0004)//"Deve ser uma data."
		return .f.
	endif
return .t.

/*/{Protheus.doc} ValNuloData
	Valida se data e nula ou se e uma data valida
	
	@type function
	@author Vinicius Gati
	@since 07/11/2018
/*/
method ValNuloData(cCampo) class VERegistroSql
	if Empty(self:Get(cCampo))
		return
	endif
	if valtype(self:Get(cCampo)) != 'D'
		self:AddError(cCampo, STR0004)//"Deve ser uma data."
	endif
return

/*/{Protheus.doc} ValidaNumerico
	Verifica se o valor é numerico

	@type function
	@author Vinicius Gati
	@since 09/09/2019
/*/
Method ValidaNumerico(cCampo) Class VERegistroSql
	local uVal := self:Get(cCampo)
	if valtype(uVal) != "N"
		self:AddError(cCampo, STR0005)//"Deve ser numérico"
	endif
Return

/*/{Protheus.doc} ValidaStrNumerica
	Verifica se o valor de uma string contém somente números
	A lógica é usar a função VAL, a mesma retorna 0 se conter qualquer caractere
	diferente de numeros na string, assim se uma string '0' for recebida eu concateno '1' nela
	obtendo '01', usando val devo ter um valor maior de zero, já se receber 'A0' vou receber 0
	do val e vou saber que tem um caractere no valor

	@type function
	@author Vinicius Gati
	@since 09/09/2019
/*/
Method ValidaStrNumerica(cCampo) Class VERegistroSql
	local uVal  := self:Get(cCampo)
	if valtype(uVal) != 'C'
		self:AddError(cCampo, STR0006)//"Deve ser string contendo somente números."
	else
		if ! val(uVal + "1") > 0
			self:AddError(cCampo, STR0006)//"Deve ser string contendo somente números."
		endif
	endif
Return

/*/{Protheus.doc} Set
	Seta o valor ao json interno que contem os dados do objeto que estao sendo trabalhados em memoria
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method Set(cCampo, uValue) Class VERegistroSql
	local nX,oRelObj,oRel,cAlias
	if cCampo == 'R_E_C_N_O_'
		self:SetRecno(uValue)
	endif
	// gravacao de relacionamentos
	if valtype(uValue) == 'N' .and. UPPER(LEFT(cCampo, 5)) == 'RECNO'
		// identificar relacao
		cAlias := right(cCampo, 3)
		oRel := self:_RelFromAlias(cAlias)
		if oRel != nil
			// filtrar o registro
			oRelObj := oRel:GetObj():Find(uValue)
			// gravar os campos chave
			for nX := 1 to len(oRel:GetChaves())
				aChave := oRel:GetChaves()[nX]
				// removendo filial que vem  na relacao pois não interessa pra dar set no objeto
				if ( valtype(aChave[1]) == 'C' .and. "FILIAL" $ aChave[1] ) .or. ( valtype(aChave[2]) == 'C' .and. "FILIAL" $ aChave[2] )
					loop
				endif
				if self:InternalField(aChave[1])
					self:Set(aChave[1], oRelObj:Get(aChave[2]))
				else
					self:Set(aChave[2], oRelObj:Get(aChave[1]))
				endif
			next
		else
			// retorna que nao encontrou a relacao, o campo possivelmente e falso ou uma tentativa de burlar o sistema
			return .f.
		endif
	endif
	// limpa o valor em caso de string remove espacos desnecessarios para economizar memoria
	if valtype(uValue) == 'C' .and. len(uValue) > 20
		uValue := RTRIM(uValue)
	endif

	if self:IsDataField(cCampo) .and. valtype(uValue) == "C"
		uValue := STOD(STRTRAN(uValue, '/', ''))
	endif

	if " AS " $ upper(cCampo)
		cCampo := self:_GetAliasName(cCampo)
		return self:Set(cCampo, uValue)
	endif

	if upper(left(cCampo, 3)) == "ID_"
		self:oJsonData[cCampo] := uValue
	endif

	// Verifico memo pois pode sobrescrever valor caso memo ainda nao foi dado load
	if self:_isMemo(cCampo)
		if ! self:IsNew() .and. ! self:lMemosFetched
			self:FetchMemoFields()
		endif
	endif

	self:oJsonData[cCampo] := uValue
return .t.

/*/{Protheus.doc} SetRaw
	Seta o valor direto sem ver nada, quando string ou campo conhecido beleza

	@type function
	@author Vinicius Gati
	@since 30/06/2020
/*/
Method SetRaw(cCampo, uVal) Class VERegistroSql
	self:oJsonData[cCampo] := uVal
Return .t.

/*/{Protheus.doc} InternalField
	Verifica se o campo é do objeto atual ou não, usado para quando se tem relacoes pra saber 
	de onde pegar o valor, pois não quis deixar fixo que primeira posicao é campo do modelo
	atual e o segundo é a relacao, então eu verifico e crio a query pra
	pegar o valor do objeto e colocar o campo da relacao

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method InternalField(cFieldName) Class VERegistroSql
Return ascan(self:aCampos, {|field| field == cFieldName}) > 0 .or. ascan(self:aRelFields, {|field| field == cFieldName}) > 0

/*/{Protheus.doc} SetID
	Seta o recno no registro tanto no nRecno quanto no json
	
	@type function
	@author Vinicius Gati
	@since 05/11/2018
/*/
method SetRecno(nRecno) class VERegistroSql
	self:nRecno := nRecno
return self:nRecno

/*/{Protheus.doc} Set
	Seta o valor ao json interno que contem os dados do objeto que estao sendo trabalhados em memoria
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method Get(cCampo) Class VERegistroSql
	if ! self:lMemosFetched .and. self:_isMemo(cCampo)
		self:FetchMemoFields()
 	endif
return self:oJsonData[cCampo]

/*/{Protheus.doc} GetId
	Retorna o campo de id do modelo
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method GetId() Class VERegistroSql
return self:Get(self:cCampoId)

/*/{Protheus.doc} GetRel
	Retorna objeto de relacao predefinida exeplo de uso:

	oFrota := oFrotaClass:NotDeleted():First()
	oMarca := oFrota:GetRel('Marca')
	
	@type function
	@author Vinicius Gati
	@since 12/11/2018
/*/
method GetRel(cRelName, lDeleted) Class VERegistroSql
	local oRelacao   := self:_GetRelData(upper(cRelName))
	local oRelClass  := oRelacao:GetObj()
	local aChaves    := oRelacao:GetChaves()
	local nX         := 1
	local aWhere
	local cFld1, cFld2
	local oRet
	default lDeleted := .f.

	if ! lDeleted
		oRelClass:NotDeleted()
	endif
	for nX := 1 to Len(aChaves)
		aWhere := aChaves[nX]
		cFld1 := aWhere[1]
		cFld2 := aWhere[2]

		if (valtype(cFld1) == 'C' .and. 'FILIAL' $ cFld1) .or. (valtype(cFld2) == 'C' .and. 'FILIAL' $ cFld2)
			if valtype(cFld1) == 'C' .and. 'FILIAL' $ cFld1
				oRelClass:AndEq(cFld1, eval(cFld2))
			else
				oRelClass:AndEq(cFld2, eval(cFld1))
			endif
		else
			if valtype(cFld1) == 'B'
				cFld1 := eval(cFld1)
				if self:cAlias $ cFld1 .or. 'BASE.' $ cFld1
					cFld1 := self:_GetOnlyFldName(cFld1)
					cFld1 := self:Get(cFld1)
				endif
				oRelClass:AndEq(cFld2, cFld1)
			elseif valtype(cFld2) == 'B'
				cFld2 := eval(cFld2)
				if self:cAlias $ cFld2 .or. 'BASE.' $ cFld2
					cFld2 := self:_GetOnlyFldName(cFld2)
					cFld2 := self:Get(cFld2)
				endif
				oRelClass:AndEq(cFld1, cFld2)
			else
				if self:cAlias $ cFld1 .or. 'BASE.' $ cFld1
					oRelClass:AndEq(cFld2, self:Get(self:_GetOnlyFldName(cFld1)))
				else
					oRelClass:AndEq(cFld1, self:Get(self:_GetOnlyFldName(cFld2)))
				endif 
			endif
		endif

	next
	oRet := oRelClass:First()
	// se nao encontrou no banco ele nao vem como persistido
	if oRet:IsNew()
		return Nil
	endif
return oRet

/*/{Protheus.doc} Save
	Sera usado para salvar os dados no registro no banco passando antes pela validacao
	caso a validacao esteja ok ele salva, caso não o array de errros (aErros) terá os
	erros para cada campo.
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method Save(bPre, bPos) Class VERegistroSql
	local lNew := self:IsNew()
	default bPre := {||}
	default bPos := {||}
	if ! self:lMemosFetched .and. len(self:aCamposMemo) > 0
		self:FetchMemoFields()
	endif
	
	if lNew
		self:BeforeCreate()
	endif
	self:BeforeSave()
	eval(bPre)
	
	self:_Validate()
	if len(self:aErros) == 0
		if ! self:_Save()
			return .f.
		endif
	else
		return .f.
	endif

	eval(bPos)
	if lNew
		self:AfterCreate()
	endif
	self:AfterSave()
	// self:Sync(self:GetId(), lNew, .f. /** lDel */)
return .t.

/*/{Protheus.doc} Save
	Salva sem fazer validacao nenhuma
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method ForceSave() Class VERegistroSql
	local lNew := self:IsNew()
	if ! self:lMemosFetched .and. len(self:aCamposMemo) > 0
		self:FetchMemoFields()
	endif
	
	if lNew
		self:BeforeCreate()
	endif
	self:BeforeSave()
	
	self:_Validate()
	if ! self:_Save()
		return .f.
	endif

	if lNew
		self:AfterCreate()
	endif
	self:AfterSave()
	// self:Sync(self:GetId(), lNew, .f. /** lDel */)
return .t.

/*/{Protheus.doc} Delete
	Deleta o registro do banco de dados chamando consigo os callbacks caso implementados
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method Delete() Class VERegistroSql
	self:BeforeDelete()
	if len(self:aErros) == 0
		if ! self:_Delete()
			return .f.
		endif
		self:Sync(self:GetId(), .f., .t.)
	endif
	self:AfterDelete()
return .t.

/*/{Protheus.doc} MassAssign
	Pega um objeto json e joga os dados pra dentro do objeto
	
	@type function
	@author Vinicius Gati
	@since 05/11/2018
/*/
method MassAssign(oJson) Class VERegistroSql
	local nX := 1
	local cCampo
	local uVal
	for nX := 1 to len(self:aPermiteAssign)
		cCampo := self:aPermiteAssign[nX]
		uVal   := oJson[cCampo]
		if valtype(uVal) == "U"
			loop
		endif
		if valtype(uVal) == "C" .and. ! upper("id_") $ upper(cCampo) .and. ! upper("UUID") $ upper(cCampo)
			uVal := OFNoAcentoUtf8(uVal)
		endif
		self:Set(cCampo, uVal)
	next
return .t.

/*/{Protheus.doc} OFNoAcentoUtf8
	Unica forma descoberta para remover acentos dos dados vindos de webservice
	
	@type function
	@author Vinicius Gati
	@since 01/02/2019
/*/
function OFNoAcentoUtf8(cAntes)
	cAntes := DecodeUTF8(cAntes)
	if Empty(cAntes)
		return cAntes
	endif
	cAntes := EncodeUtf8(cAntes)
	cAntes := STRTRAN(cAntes, EncodeUtf8("Á"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("À"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Â"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ä"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ã"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("É"), 'e')
	cAntes := STRTRAN(cAntes, EncodeUtf8("È"), 'e')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ê"), 'e')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Í"), 'i')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ì"), 'i')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Î"), 'i')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ó"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ò"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ô"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Õ"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ú"), 'u')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ù"), 'u')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Û"), 'u')
	cAntes := STRTRAN(cAntes, EncodeUtf8("Ç"), 'c')
	cAntes := STRTRAN(cAntes, EncodeUtf8("á"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ä"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("à"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("â"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ã"), 'a')
	cAntes := STRTRAN(cAntes, EncodeUtf8("é"), 'e')
	cAntes := STRTRAN(cAntes, EncodeUtf8("è"), 'e')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ê"), 'e')
	cAntes := STRTRAN(cAntes, EncodeUtf8("í"), 'i')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ì"), 'i')
	cAntes := STRTRAN(cAntes, EncodeUtf8("î"), 'i')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ó"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ò"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ô"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("õ"), 'o')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ú"), 'u')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ù"), 'u')
	cAntes := STRTRAN(cAntes, EncodeUtf8("û"), 'u')
	cAntes := STRTRAN(cAntes, EncodeUtf8("ç"), 'c')
return upper(cAntes)

/*/{Protheus.doc} Validate
	Methodo que realiza validacao do modelo salvando
	no array de erros o campo e o erro encontrado
	para mostrar para usuário se for necessario
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method _Validate() Class VERegistroSql
	self:aErros := {}
	self:BeforeValidate()
	self:Validate()
return self:EstaValido()

/*/{Protheus.doc} Touch
	Criado para atualizar data de alteracao quando salvo e nao disparar validacao
	para não evitar de gravar a alteração, pois quando registro tem alguma validacao falha
	que no X3 está ok ele é alterado no protheus entõ preciso alterar ele na api de todo jeito

	@type function
	@author Vinicius Gati
	@since 18/10/2019
/*/
Method Touch(cUUID) Class VERegistroSql
	default cUUID := self:GetId()
	if ! Empty(cUUID)
		oReg := self:Select();
			:_From(self:cAlias);
			:AndEq(self:cFieldFil, xFilial(self:cAlias));
			:AndEq(self:cCampoId, cUUID);
			:first()

		if oReg:Persistido()
			if self:InternalField(self:GetFieldAlt())
				oReg:Set(self:GetFieldAlt(), FGX_Timestamp())
				oReg:_Save()
			endif
		endif
	endif
Return .t.

/*/{Protheus.doc} _Save
	Metodo de implementacao real da acao salvar 
	que cria ou salva registro no banco dedados usando recklock
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method _Save() Class VERegistroSql
	dbSelectArea(self:cAlias)
	if self:Persistido()// altera
		self:_Posiciona()
		if recno() != self:nRecno
			UserException(STR0007)//"Recno não bateu com o registro correto"
		else
			reclock(self:cAlias, .f.)
		endif
	else
		reclock(self:cAlias, .t.)
	endif
	self:_Preenche()
	msUnlock()
	if self:IsNew()
		self:Set('R_E_C_N_O_', self:_GetLastRecno())
		self:nRecno := self:Get('R_E_C_N_O_')
		self:Set(self:cCampoId, self:GetLastId())
	endif
return .t.

/*/{Protheus.doc} _Delete
	Metodo de implementacao da acao delete, pode ser chamado diretamente para evitar callbacks
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method _Delete() Class VERegistroSql
	if self:Persistido() // se esta no banco
		dbSelectArea(self:cAlias)
		dbGoTo(self:nRecno)
		recLock(self:cAlias, .f.)
		if self:InternalField(self:GetFieldAlt())
			(self:cAlias)->&(self:GetFieldAlt()) := fgx_TimeStamp()
		endif
		dbDelete()
		msUnlock()
	endif
return .t.

/*/{Protheus.doc} Persistido
	Retorna se o recno está digitado no objeto
	o que significa que ele já está no banco de dados
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method Persistido() Class VERegistroSql
return self:nRecno != 0

/*/{Protheus.doc} IsNew()
	Verifica se o recno é em branco ou zerado 
	o que significa que os dados vieram do banco
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method IsNew() Class VERegistroSql
return self:nRecno <= 0

/*/{Protheus.doc} IsDataField
	Verifica se o campo e um campo data para fazer conversao adequada
	
	@type function
	@author Vinicius Gati
	@since 07/11/2018
/*/
method IsDataField(cCampo) Class VERegistroSql
	//local nX := 1
	local lFound := .F.
	aeval( self:aCamposData , {|x| IIF(x == cCampo, lFound := .T.,) })
return lFound

/*/{Protheus.doc} AddError
	Adicionar um erro ao objeto
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method AddError(cCampo, cErro) Class VERegistroSql
	aadd(self:aErros, {cCampo, EncodeUTF8(cErro)})
return .t.

/*/{Protheus.doc} EstaValido
	Retorna se o registro esta valido e pode ser salvo
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method EstaValido() Class VERegistroSql
return Empty(self:aErros)

/*/{Protheus.doc} ToJson
	Retorna o registro em formato json
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method ToJson() Class VERegistroSql
	if len(self:aCamposMemo) > 0 .and. ! self:lMemosFetched
		self:FetchMemoFields()
	endif
return self:oJsonData:ToJson()

/*/{Protheus.doc} ToJsonApi
	Retorna o object json no formato da api para campos timestamp
	
	@type function
	@author Vinicius Gati
	@since 31/10/2018
/*/
method ToJsonApi() Class VERegistroSql
	local nX := 1
	local oJson

	if len(self:aCamposMemo) > 0 .and. ! self:lMemosFetched
		self:FetchMemoFields()
	endif
	// converte os timestamp pro formato padrao dos jsons para apis
	// retorna para o valor do protheus
	if len(self:aCamposTimeStamp) > 0
		for nX := 1 to len(self:aCamposTimeStamp)
			cVal := self:oJsonData[self:aCamposTimeStamp[nX]]
			if ! Empty(cVal)
				self:oJsonData[self:aCamposTimeStamp[nX]] := FGX_ToTimestamp(cVal)
			endif
		next

		oJson := self:oJsonData
	else
		oJson := self:oJsonData
	endif
return oJson

/*/{Protheus.doc} ToJsonData
	retorna um objeto jsonObject para ser formatado para a request
	por enquanto so traz mesmo os dados do objeto, a ideia era ter um que tras mais dados no json
	tipo relacoes, mas ate agora nao precisou visto que o recno das relacoes sao setados agora
	e voltam no json normal

	@type function
	@author Vinicius Gati
	@since 05/11/2018
/*/
method ToJsonData(lOneRelations) Class VERegistroSql
	// local nX := 1
	// local aOnes := {}
	// default lOneRelations := .t.
	// if lOneRelations
	// 	aOnes := self:oArrHlp:Select(self:aRelations, {|oRel| oRel:GetTipo() = "ONE"})
	// 	for nX := 1 to len(aOnes)
	// 		//TODO: implementar, ainda nao surgiu necessidade
	// 	next
	// endif
return self:oJsonData

/*/{Protheus.doc} ToSyncModel
	Retorna uma representacao do modelo no formato 
	neceessário para integracao dependendo do modelo
	passado por parametro

	modelos configuraveis: '1=Cev Web e Mobile', '2=Salesforce', '3=Outros', '4=Outros 2', '5=Outros 3'

	@type function
	@author Vinicius Gati
	@since 11/01/2019
/*/
Method ToSyncModel(cModelo, lNew, lDel) Class VERegistroSql
	local cDados    := STR0008 //"modelo nao encontrado para envio"
	default cModelo := '1'

	if cModelo == '1'
		return self:ToJson()
	else
		cPeName := "V" + self:cAlias + "SFMT"
		if ExistBlock(cPeName)
			cDados := ExecBlock(cPeName,.f.,.f., {self, cModelo, lDel, lNew})
		endif
	endif
Return cDados

/*/{Protheus.doc} FetchMemoFields
	Busca os valores dos campos memo no banco de dados
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method FetchMemoFields() Class VERegistroSql
	local nX := 1

	// se os memos ainda nao foram buscados e o registro nao for novo
	if ! self:lMemosFetched .and. self:_Posiciona()
		for nX := 1 to len(self:aCamposMemo)
			cCampo := self:aCamposMemo[nX]
			self:oJsonData[cCampo] :=  &(self:cAlias+"->"+cCampo)
		next
		self:lMemosFetched := .t.
	endif
	self:FetchOldMemos()
return .t.

/*/{Protheus.doc} FetchOldMemos
	Busca mesmos antigos

	@type function
	@author Vinicius Gati
	@since 01/07/2019
/*/
Method FetchOldMemos() Class VERegistroSql
Return .t.

/*/{Protheus.doc} GetErros
	Retorna os erros de validação do objeto
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method GetErros() Class VERegistroSql
return self:aErros

/*/{Protheus.doc} GetIntErr
	Pega erro da integração e joga no array de erros do registro

	@type function
	@author Vinicius Gati
	@since 28/11/2018
/*/
Method GetIntErr() Class VERegistroSql
	local cPath := '\system\logsmil\'
	local cFileName := 'rest_err.data'
	local cPulaLinha := chr(13) + chr(10)
	local cErro := ''

	MostraErro(cPath, cFileName)
	if File(cPath+cFileName, 0)
		FT_FUse(cPath+cFileName)
		While ! FT_FEof()
			cErro += FT_FReadLN() + cPulaLinha
			FT_FSkip()
		EndDo
		FT_FUse()
		self:AddError(STR0009, cErro) //"INTEGRACAO"
	else
		// isso não deve ocorrer mas prevendo foi tratado
		self:AddError(STR0009, STR0010) //"INTEGRACAO" //"Um erro de integração ocorreu e não foi possível coletar o mesmo, favor verificar logs do protheus"
	endif
Return

/*/{Protheus.doc} _Preenche
	Preenche o objeto do alias selecionado com os dados do objeto

	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method _Preenche() Class VERegistroSql
	local nX := 1
	local cCampo
	for nX := 1 to Len(self:aCampos)
		cCampo := self:aCampos[nX]
		if " AS " $ upper(cCampo)
			loop
		endif
		if cCampo != 'R_E_C_N_O_'
			&(self:cAlias+"->"+cCampo) := self:oJsonData[cCampo]
		endif
	next
	// GetSx3Cache(cCampo, "X3_CONTEXT")
	for nX := 1 to Len(self:aCamposMemo)
		cCampo := self:aCamposMemo[nX]
		&(self:cAlias+"->"+cCampo) := self:oJsonData[cCampo]
	next
	cCampo := self:GetFieldAlt()
	if self:InternalField(cCampo)
		if ! empty(self:oJsonData[cCampo])
			&(self:cAlias+"->"+cCampo) := self:oJsonData[cCampo]
		EndIf
	endif

	cCampo := self:GetFieldInc()
	if self:InternalField(cCampo)
		if ! empty(self:oJsonData[cCampo])
			&(self:cAlias+"->"+cCampo) := self:oJsonData[cCampo]
		endif
	endif
	self:CustomSetValues()
return .t.

/*/{Protheus.doc} CustomSetValues
	Metodo criado para setar valores com reclock dado 
	e o tipo do campo é antigo e chato de setar o valor
	de cabeça somente memos antigos

	geralmente vai ser declarado na classe
	o raic foi o que teve a necessidade deste metodo novo

	@type function
	@author Vinicius Gati
	@since 01/07/2019
/*/
Method CustomSetValues() Class VERegistroSql
Return .t.

/*/{Protheus.doc} _Posiciona
	Posiciona o registro usando dbaccess caso ele seja persistido e
	caso não consiga da exception pois vai impedir o funcionamento
	normal da classe a não posicao
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method _Posiciona() Class VERegistroSql
	if self:Persistido()
		dbSelectArea(self:cAlias)
		dbGoTo(self:nRecno)
		if recno() != self:nRecno
			UserException(STR0011)//"Nao foi possivel posicionar no recno do objeto"
		endif
	else
		return .f.
	endif
return .t.

/*/{Protheus.doc} _isMemo
	Identifica se o campo é um memo para o modelo
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method _isMemo(cCampo) Class VERegistroSql
	local nX := 1

	// tenta encontrar o campo nos memo
	for nX := 1 to len(self:aCamposMemo)
		if cCampo == self:aCamposMemo[nX]
			return .t.
		endif
	next
return .f.

/*/{Protheus.doc} _RelFromAlias
	Pega o relacionamento de acordo com o alias do relacionamento

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method _RelFromAlias(cAlias) Class VERegistroSql
	local oRel := nil
	local nIdx := ascan(self:aRelations, {|rel| rel:GetAlias() == cAlias })
	if nIdx > 0
		oRel := self:aRelations[nIdx]
	endif
Return oRel

/*/{Protheus.doc} Sync
	Envia dados a sistemas externos configurados

	@type function
	@author Vinicius Gati
	@param cUUID, Id unico do registro
	@param lNew, se o registro foi incluido agora
	@param lDel, se o registro foi deletado
	@since 26/12/2018
/*/
Method Sync(cUUID, lNew, lDel, oObj) Class VERegistroSql
	default oObj := self:find(cUUID)
	if Empty(self:oCfgSync)
		//self:oCfgSync := VEConfiguracaoIntegracaoCrm():New()
	endif
	if oObj:Persistido()
		return self:oCfgSync:Sync(self:_CleanClassName(GetClassName(self)), cUUID, oObj, lNew, lDel)
	endif
Return .f.

/*
 * Callbacks, a ideia e usar eles nas classes que herdarao desta, fazendo a customizacao conforme regra de negocio
 *
 */

/*/{Protheus.doc} Validate
	Metodo de implementacao da acao de validacao, pode ser 
	chamado diretamente para evitar callbacks

	Foi criado para ser reimplementado nas classes que herdam
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
method Validate() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "VA"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
return .t.

/*/{Protheus.doc} BeforeCreate
	Se um objeto é novo e não foi ainda persistido esse callback será chamado antes de ele ser persistido
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method BeforeCreate() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "BC"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
	self:Set(self:GetFieldInc(), FGX_Timestamp())
return .t.

/*/{Protheus.doc} BeforeSave
	Este callback sera chamado antes de salvar o objeto 
	independentemente se ele e novo ou nao
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method BeforeSave() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "BS"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
	if self:InternalField(self:GetFieldAlt())
		self:Set(self:GetFieldAlt(), FGX_Timestamp())
	endif
return .t.

/*/{Protheus.doc} BeforeDelete
	Chamado antes de deletar o objeto do banco de dados
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method BeforeDelete() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "BD"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
return .t.

/*/{Protheus.doc} BeforeValidate
	Chamado antes da validacao do objeto, pode ser usado para gravar campos
	que o objeto deve gerar automatico por exemplo encriptar uma senha antes 
	de validar se a mesma esta criptografada
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method BeforeValidate() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "BV"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
return .t.

/*/{Protheus.doc} AfterCreate
	Executado depois de um objeto novo não persistido ser 
	persistido no banco de dados
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method AfterCreate() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "AC"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
return .t.

/*/{Protheus.doc} AfterSave
	Executado depois de salvar qualquer objeto
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method AfterSave() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "AS"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
return .t.

/*/{Protheus.doc} AfterDelete
	Executado após deletar um objeto no banco
	Pode ser usado para gravar informacoes apos o registro ter sido deletado
	como por exemplo gravar um log
	
	@type function
	@author Vinicius Gati
	@since 01/11/2018
/*/
method AfterDelete() Class VERegistroSql
	local cPeName := "V" + self:cAlias + "AD"
	if ExistBlock(cPeName)
		ExecBlock(cPeName, .f., .f., {self})
	endif
return .t.


/*/{Protheus.doc} _OrdArr
	Criado para ajustar ordem em array para legado onde certos campos tem que vir antes de outros

	@type function
	@author Vinicius Gati
	@since 22/04/2020
/*/
Method _OrdArr(aToOrd, aOrd, nPos) Class VERegistroSql
	local aArr := {}
	local nX := 1
	local nFound := 0
	default nPos := 1

	for nX := 1 to len(aOrd)
		nFound := 0
		nFound := ascan(aToOrd, {|aDados| aDados[nPos] == aOrd[nX]})
		if nFound > 0
			aadd(aArr, aClone(aToOrd[nFound]))
			adel(aToOrd, nFound)
		endif
	next

	for nX := 1 to len(aToOrd)
		if valtype(aToOrd[nX]) != "U"
			aadd(aArr, aToOrd[nX])
		endif
	next
	aSize(aToOrd, 0)
Return aArr
