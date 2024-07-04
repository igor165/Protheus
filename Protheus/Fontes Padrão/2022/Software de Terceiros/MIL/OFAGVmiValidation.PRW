#include "protheus.ch"

function OFAGVmiValidation()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiValidation
	Classe responsável por validar os tipos de dados documentados nas <br>
	interfaces do VMI

	@author Vinicius Gati
	@since 13/06/2017
/*/
Class OFAGVmiValidation
	Data oArrHlp
	Data oStrHlp

	Method New() CONSTRUCTOR
	Method validate()
	Method getMappedValue()
	Method attrValidate()
	Method valV001()
	Method valV002()
	Method valV003()
	Method valV004()
	Method valV005()
	Method valV006()
	Method valV007()
	Method valV008()
	Method valV009()
	Method valV010()
	Method valV011()
	Method valP002()
	Method valP001()
	Method valP003()
	Method valP004()
	Method valObri()
	Method valDate()
EndClass

Method New() Class OFAGVmiValidation
	::oArrHlp := DMS_ArrayHelper():New()
	::oStrHlp := DMS_StringHelper():New()
	//::oArrHlp := OFAGArrayHelper():New()
	//::oStrHlp := OFAGStringHelper():New()
return self

/*/{Protheus.doc} validate
	Chama validação correspondente com valor e codigo
	@author Vinicius Gati
	@since 13/06/2017
	@param uValue, Any , Valor que será validado
	@param cCode, String, Código para direcionar a validação conforme documentação
/*/
Method validate(oVmiBase) class OFAGVmiValidation
	Local nX := 1
	Local nX2 := 1
	Local lValid := .T.
	oVmiBase:aErros := {} // limpa os erros antes de validar
	for nX := 1 to LEN(oVmiBase:aMapValid)
		aDados := oVmiBase:aMapValid[nX]
		cMap   := aDados[1]
		cCode  := aDados[2]
		uVal   := self:getMappedValue(oVmiBase:oDados, cMap)
		if VALTYPE(uVal) == "A" // valores das coleções
			For nX2 := 1 to LEN(uVal)
				lValid := self:attrValidate(uVal[nX2, cCode])
				if lValid == .F.
					AADD(oVmiBase:aErros, "Erro validação no atributo:" + cMap + ", validação: " + cCode)
				end
			next
		else
			lValid := self:attrValidate(uVal, cCode)
			if lValid == .F.
				AADD(oVmiBase:aErros, "Erro validação no atributo:" + cMap + ", validação: " + cCode)
			end
		end
	next
Return lValid

/*/{Protheus.doc} getMappedValue
	Pega a string com caminho para chegar ao valor e retorna o valor
	~Talvez essa seja o metodo mais dificil de enteder, verificar com atenção~

	@author Vinicius Gati
	@since 13/06/2017
	@param oObj, data container, DataContainer com os dados do VMI
	@param cMap, String, caminho para chegar ao valor
/*/
Method getMappedValue(oObj, cMap) class OFAGVmiValidation
	Local nX  := 1
	Local nX2 := 1
	Local aCampos := self:oStrHlp:Strtokarr2(cMap, ':')
	Local uVal := Nil
	Local lArray := .F.
	uVal := oObj // o proprio objeto para chamar em loop os campos
	For nX:= 1 to Len(aCampos)
		uVal := uVal:GetValue(aCampos[nX], "SEM_VALOR") // SEM_VALOR é a flag para não validar quando não passar o valor ao JSON, usado em campos não obrigatorios
		if ValType(uVal) == "A" // se array, significa que preciso fazer pra todos os elementos pois é uma coleção no JSON
			lArray := .T. // retorna que o valor desejado é de uma coleção
			For nX2:= 1 to Len(uVal)
				AADD(aDados, self:getMappedValue( uVal[nX2], aCampos[nX+1] )) // nX + 1 significa o atributo do objeto que vai ser retornado ex items:nome quero pegar o nome dos itens individualmente
			Next
			exit
		end
	Next
Return IIF(lArray, aDados, uVal) // valor do ultimo getvalue

/*/{Protheus.doc} attrValidate
	Chama validação correspondente e codigo

	@author Vinicius Gati
	@since 13/06/2017
	@param uValue, Any , Valor que será validado
	@param cCode, String, Código para direcionar a validação conforme documentação
/*/
Method attrValidate(uValue, cCode) class OFAGVmiValidation
	if cCode != "Obri" .AND. VALTYPE(uValue) == "C" .AND. uValue == "SEM_VALOR"
		return .T.
	end
Return eval(&("{|| self:val" + cCode + "(uValue) }")) // chama metodo correto sem fazer if

/*/{Protheus.doc} valV001
	Valida modelo V001 da documentação do VMI
	deve ser booleano somente

	@author Vinicius Gati
	@since 13/06/2017
	@param lVal, Any, Verifica se é logico
/*/
Method valV001(lVal) class OFAGVmiValidation
Return ValType( lVal ) == "L"

/*/{Protheus.doc} valV002
	Valida modelo V002 da documentação do VMI
	deve ser booleano somente

	@author Vinicius Gati
	@since 13/06/2017
	@param lVal, Any, Verifica se é logico
/*/
Method valV002(lVal) class OFAGVmiValidation
Return ValType( lVal ) == "L"

/*/{Protheus.doc} valV003
	Valida modelo V003 da documentação do VMI
	deve ser booleano somente

	@author Vinicius Gati
	@since 13/06/2017
	@param lVal, Any, Verifica se é logico
/*/
Method valV003(lVal) class OFAGVmiValidation
Return ValType( lVal ) == "L"

/*/{Protheus.doc} valV004
	Valida modelo V004 da documentação do VMI<br>
	Conforme:<br>
	<br>
	STOCK_ORDER: pedido de estoque, semanal, etc<br>
	VOR: pedidos emergenciais ou de máquina parada<br>
	SERVICE: pedidos de garantia<br>
	TRANSFER: pedidos de transferência entre filiais<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV004(cVal) class OFAGVmiValidation
	Local aValues := {'STOCK_ORDER', 'VOR', 'SERVICE', 'TRANSFER'}
Return self:oArrHlp:Exists(aValues, cVal)

/*/{Protheus.doc} valV005
	Valida modelo V005 da documentação do VMI<br>
	Conforme:<br>
	<br>
	REPVT03: pedidos atendidos por Jundiaí<br>
	REPVT06: pedidos atendidos por Ernestina<br>
	Vazio: pedidos não atendidos pela AGCO<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV005(cVal) class OFAGVmiValidation
	Local aValues := {'REPVT03', 'REPVT06'}
Return EMPTY(cVal) .OR. self:oArrHlp:Exists(aValues, cVal)

/*/{Protheus.doc} valV006
	Valida modelo V006 da documentação do VMI<br>
	Conforme:<br>
	<br>
	OPEN: linha do pedido está pendente de atendimento<br>
	CLOSED: linha do pedido entrou no estoque da concessionária<br>
	CANCELLED: linha do pedido foi cancelada<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV006(cVal) class OFAGVmiValidation
	Local aValues := {'OPEN', 'CLOSED', 'CANCELLED'}
Return self:oArrHlp:Exists(aValues, cVal)

/*/{Protheus.doc} valV007
	Valida modelo V007 da documentação do VMI conforme:<br>
<br>
	S: venda<br>
	W: oficina<br>
	T: transferência<br>
	R: devolução<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV007(cVal) class OFAGVmiValidation
Return self:oArrHlp:Exists({"S", "W", "T", "R"}, cVal)

/*/{Protheus.doc} valV008
	Valida modelo V008 da documentação do VMI conforme:<br>
<br>
	REGULAR: entrega normal<br>
	EXPEDITE: entrega expressa<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV008(cVal) class OFAGVmiValidation
Return self:oArrHlp:Exists({"REGULAR", "EXPEDITE"}, cVal)

/*/{Protheus.doc} valV009
	Valida modelo V009 da documentação do VMI conforme:<br>
<br>
	OPEN: linha da venda está pendente de atendimento<br>
	RESERVED: linha da venda tem reserva no estoque<br>
	CLOSED: linha da venda foi enviado para o cliente<br>
	CANCELLED: linha da venda foi cancelada pelo cliente<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV009(cVal) class OFAGVmiValidation
	Local aValues := {'OPEN','RESERVED','CLOSED','CANCELLED'}
Return self:oArrHlp:Exists(aValues, cVal)

/*/{Protheus.doc} valV010
	Valida modelo V010 da documentação do VMI conforme:<br>
<br>
	RC: cliente regular<br>
	GE: orgão público<br>
	IN: indústria<br>
	FO: frotista<br>

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Valor a se identificado
/*/
Method valV010(cVal) class OFAGVmiValidation
	Local aValues := {'RC','GE','IN','FO'}
Return self:oArrHlp:Exists(aValues, cVal)


/*/{Protheus.doc} valV011
	Valida modelo V011 da documentação do VMI
	deve ser booleano somente

	@author Vinicius Gati
	@since 13/06/2017
	@param lVal, Any, Verifica se é logico
/*/
Method valV011(lVal) class OFAGVmiValidation
Return ValType( lVal ) == "L"

/*/{Protheus.doc} valP002
	Valida modelo P002 da documentação do VMI conforme:<br>
	O ISO 4217 é um padrão internacional que define códigos de três letras para <br>
	as moedas correntes estabelecido pela Organização Internacional para Padronização<br>

	Somente os mais comuns clients protheus (brasil, Eua e espanha)

	@since 13/06/2017
/*/
Method valP002(cVal) class OFAGVmiValidation
Return cVal == "BRL" .OR. cVal == "USD" .OR. cVal == "EUR"

/*/{Protheus.doc} valP001
	Valida modelo P001 da documentação do VMI
	Valor ISO 8601 para data , famoso formato timestamp YYYY-MM-DDThh:mm:ss+03:00
	Acredito que não seja necessário validar nada além do tamanho.

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Verifica se está dentro dos valores esperados
/*/
Method valP001(cTimeStamp) class OFAGVmiValidation
Return LEN(cTimeStamp) <= 25 .AND. LEN(cTimeStamp) > 20

/*/{Protheus.doc} valP003
	Valida modelo P003 da documentação do VMI
	Valores ISO 3166-2 de país-estado nosso caso só brasil por enquanto

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Verifica se está dentro dos valores esperados
/*/
Method valP003(cVal) class OFAGVmiValidation
Return "BR" == cVal

/*/{Protheus.doc} valP004
	Valida modelo P004 da documentação do VMI
	Valores ISO 3166-2 de país-estado

	@author Vinicius Gati
	@since 13/06/2017
	@param cVal, String, Verifica se está dentro dos valores esperados
/*/
Method valP004(cVal) class OFAGVmiValidation
	Local aValues := {'BR-AC', 'BR-AL', 'BR-AP', 'BR-AM', 'BR-BA', 'BR-CE',;
	'BR-DF','BR-ES','BR-GO','BR-MA','BR-MT','BR-MS','BR-MG','BR-PR','BR-PB',;
	'BR-PA','BR-PE','BR-PI','BR-RN','BR-RS','BR-RJ','BR-RO','BR-RR','BR-SC',;
	'BR-SE','BR-SP','BR-TO'}
Return self:oArrHlp:Exists(aValues, cVal)

/*/{Protheus.doc} valObri
	Valida se o campo sendo obrigatório foi preenchido

	@author Vinicius Gati
	@since 14/06/2017
	@param uVal, Any, Verifica se existe algum valor
/*/
Method valObri(uVal) class OFAGVmiValidation
	if VALTYPE(uVal) == "N" .OR. VALTYPE(uVal) == "L"
		return .T.
	end
Return !Empty(uVal)

/*/{Protheus.doc} valObri
	Valida se o campo data está preenchido ok

	@author Vinicius Gati
	@since 14/06/2017
	@param cData, Any, Verifica se existe algum valor
/*/
Method valDate(cData) class OFAGVmiValidation
	if LEN(cData) != 10 // formato definido YYYY-MM-DD em string
		return .F.
	else
		cData := STRTRAN(cData, "-", "") // verifica se data é valida
		dData := STOD(cData)
		if Empty(DTOS(dData))
			return .F.
		end
	end
Return .T.