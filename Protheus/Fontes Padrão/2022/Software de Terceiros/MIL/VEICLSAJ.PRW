////////////////
// Versao 006 //
////////////////


#include "protheus.ch"

Function VEICLSAJ()
Return()

/*/{Protheus.doc} DMS_Logger
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Classe responsavel por coletar dados de um JSON em STRING.
/*/
CLASS DMS_JsonParse
	DATA cJSON
	DATA nPos
	DATA cCharPos
	DATA nTotLen

	METHOD New() CONSTRUCTOR
	METHOD ParseToObj()
	METHOD Clean()
	METHOD NextChar()
	METHOD forceExit()
	METHOD readObject()
	METHOD readArray()
	METHOD readChar()
	METHOD readUndef()
	METHOD readDate()
	METHOD readHour() // Vai retornar uma hora como inteiro , padrao dms protheus
	METHOD readInt()
ENDCLASS

METHOD New(_cJson) CLASS DMS_JsonParse
	::cJSON := _cJson
	::nTotLen := LEN(_cJson)
RETURN SELF

METHOD ParseToObj() CLASS DMS_JsonParse
	// variavel de progresso na leitura do json(string) previsa
	//ser iniciada toda vez que ler o json, iniciar com 1 pulando o '{' inicial
	::nPos  := 1
	self:Clean()
Return self:readObject()

METHOD readObject() CLASS DMS_JsonParse
	Local aObjData := {}
	Local uValue := nil
	Local cKey   := ''

	while(self:cCharPos != '}')
		cKey   := ""
		uValue := nil
		if(self:NextChar() == '"')
			While self:NextChar() != '"'
				cKey += self:cCharPos
			EndDo
		endIf

		if self:cCharPos != '}' .AND. self:cCharPos != ','
			if( self:NextChar() == '{' )
				uValue := self:readObject()
			ElseIf ( self:cCharPos == '[' )
				uValue := self:readArray()
			ElseIf ( self:cCharPos == '"' )
				uValue := self:readChar()
			Elseif ( UPPER( self:cCharPos ) == "N"  .AND. UPPER(SUBSTR( self:cJSON, self:nPos, 4 )) == "NULL" )
				uValue := nil
				self:NextChar()
				self:NextChar()
				self:NextChar() // ULL do NULL
			Else
				uValue := self:readUndef()
			EndIf

			AADD( aObjData , { cKey, uValue } )
		EndIF
	EndDo
	if self:cCharPos == '}'
		self:NextChar() // sai do } e da ,
	endif
RETURN DMS_DataContainer():New( aObjData )

METHOD readArray() CLASS DMS_JsonParse
	Local aObjects  := {}

	While( self:cCharPos != ']' )
		self:NextChar()
		if self:forceExit()
			Return aObjects
		end 		
		If( self:cCharPos == ']' )
			Return {}			
		elseIf( self:cCharPos == '{' )
			AADD( aObjects, self:readObject() )
			if self:cCharPos == '}'
				self:NextChar()
			end
		ElseIf self:cCharPos == '"'
			AADD( aObjects, self:readChar() )
		ElseIf self:cCharPos == ','
			Loop
		Else
			AADD( aObjects, self:readUndef() )
		end
	EndDo

RETURN aObjects

METHOD readChar() CLASS DMS_JsonParse
	Local cStr := ""

	while self:NextChar(.T.) != '"' .OR. self:forceExit()
		cStr += self:cCharPos
	EndDo

	self:NextChar()
RETURN cStr

METHOD readUndef() CLASS DMS_JsonParse
	Local cStr := self:cCharPos

	self:NextChar()

	while self:cCharPos != ',' .AND. self:cCharPos != '}'
		cStr += self:cCharPos
		self:NextChar()
	EndDo
	if self:cCharPos == '}'
		self:nPos := self:nPos - 1 // isto é necessário pois se for um }(fim de objeto) retorno o valor e volto um char para tras, pois pra fechar o objeto precisa ler um } denovo após este metodo
	end
	if  self:forceExit() // evita loop infinito
	  return cStr
	end
RETURN cStr

// evita que fique em loop infinito se tiver erro no json ou na implementação de leitura
Method forceExit() Class DMS_JsonParse
Return self:nPos > self:nTotLen

METHOD NextChar(lAnyChar) CLASS DMS_JsonParse
	LOCAL   lCharValid := .f.
	LOCAL   cNextChar  := ""
	DEFAULT lAnyChar   := .F.

	while !lCharValid
		self:nPos := self:nPos + 1

		cNextChar  := SUBSTR( self:cJSON, self:nPos , 1 )

		if(lAnyChar)
			lCharValid := .T.
		Elseif (cNextChar == ' ') .OR. (cNextChar == ':')
			lCharValid := .F.
		ElseIF ((cNextChar == '/') .AND. ((SUBSTR(self:cJSON,self:nPos+1,1)=='*') .OR. (SUBSTR(self:cJSON,self:nPos+1,1)=='/')))
			lCharValid := .F.
			self:nPos++
		Else
			lCharValid := .T.
		endIf
	EndDo
	self:cCharPos := cNextChar
Return cNextChar

METHOD Clean() CLASS DMS_JsonParse
	Local aRem := {(CHR(13)+ CHR(10)), CHR(13), CHR(10), CHR(9), CHR(11)} // lista de caracteres que serao limpos do json, pois tudo deve estar em uma linha so e sem caracteres especiais
	Local var := 0

	for var:= 1 to Len(aRem)
		self:cJson := STRTRAN( self:cJson, aRem[var], "" )
	next
	self:cJson := LTRIM(self:cJson)
RETURN .T.

/*/{Protheus.doc} DMS_JsonParse:readHour

	@author       Vinicius Gati
	@since        20/05/2015
	@description  Este metodo converte uma hora em string no formato "00:12" para protheus 12 como inteiro, padrao DMS

/*/
Method readHour(cHour) CLASS DMS_JsonParse
	Local nHour := VAL( STRTRAN(cHour, ":", "") )
return nHour

/*/{Protheus.doc} DMS_JsonParse:readDate

	@author       Vinicius Gati
	@since        20/05/2015
	@description  converte data no formato json para protheus(db)

/*/
METHOD readDate(cDateP) CLASS DMS_JsonParse
	LOCAL cData := nil
	if VALTYPE(cDateP) == 'D'
		return cDateP
	else
		cData := STRTRAN( cDateP, ALLTRIM(' \/ ') )
		cDia := LEFT( cData, 2 )
		cMes := RIGHT( LEFT( cData, 4 ) , 2)
		cAno := RIGHT( cData, 4 )
	EndIf
Return cAno + cMes + cDia

METHOD readInt(cInt) CLASS DMS_JsonParse
	LOCAL nNum := 0
	BEGIN SEQUENCE
		nNum := VAL( cInt )
	RECOVER
		nNum := 0
	END SEQUENCE
Return nNum


/*/{Protheus.doc} DMS_JdFileInterpreter
	Esta classe foi criada para converter uma linha de arquivo john dere para um data container com os dados dessa linha,
	para facilitar a conversão de arquivo da jd para algo utilizavel no protheus, seguindo padrão da classe data container

	@author       Vinicius Gati
	@since        21/12/15

/*/
CLASS DMS_JdFileInterpreter
	Data oData
	Method New() CONSTRUCTOR
	Method GetValue()
	Method SetValue()
ENDCLASS

/*/{Protheus.doc} New
	Cria um data container com os dados conforme estrutura do arquivo(NOTA: ainda não faz conversão alguma de tipo dos dados,  fazer conforme necessidade na UI)

	@author       Vinicius Gati
	@since        26/11/15

/*/
Method New(cData, aStructure) CLASS DMS_JdFileInterpreter
	Local nidx         := 1
	Local aDCData      := {} /*dados para criação do DataContainer */
	Local aDados       := {}
	Default aStructure := {}

	// aDados := STRTOKARR2( cData, chr(9) /*tab*/, .T. )
	// Implementação do STRTOKARR2 já que os concessionários não estão atualizados
	//
	cBck := cData
	cVal := ""
	// SUBSTR(cString, nPosInicial, nCaracteres)
	for nidx := 1 to LEN( cData )
		nPosFrs := AT(chr(9), cData)
		if nPosFrs == 0
			AADD(aDados, cData)
			Exit
		ElseIf nPosFrs > 1
			if SUBSTR(cData, 1, nPosFrs-1) == chr(9)
				AADD(aDados, "")
				cData := RIGHT(cData, (LEN(cData)-1) - Len(cEl) )
			else
				cEl := SUBSTR(cData, 1, nPosFrs-1)
				cData := RIGHT(cData, (LEN(cData)-1) - Len(cEl) )
				AADD(aDados, cEl)
			endif
		ElseIf nPosFrs == 1 .AND. LEN(cData) > 1
			AADD(aDados, "")
			cData := RIGHT(cData, (LEN(cData)-1))
		Elseif nPosFrs == 1
			Exit
		EndIf
	next
	cData := cBck
	//
	for nidx := 1 to LEN(aDados)
		if nidx <= LEN(aStructure) .AND. nidx <= LEN(aDados)
			AADD(aDCData, {aStructure[nidx][1] /*nome do campo*/, aDados[nidx] /*dados*/} )
		EndIf
	next
	::oData := DMS_DataContainer():New( aDCData )
Return SELF

/*/{Protheus.doc} GetValue[DataContainer]
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   21/12/15
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
	@example oObj := DMS_DataContainer:New({ {'Nome', 'Vinicius'} })<br>
						oObj:GetValue('Nome')      => 'Vinicius'<br>
						oObj:GetValue('Idade', 18) => 18
/*/
METHOD GetValue(cLabel, cRetPad) Class DMS_JdFileInterpreter
Return self:oData:GetValue(cLabel, cRetPad)

/*/{Protheus.doc} SetValue[DataContainer]
	Pega o valor relacionado ao label

	@author  Vinicius Gati
	@since   21/12/15
	@param   cLabel  , Array, Busca o valor dentro dos dados contidos no obj de acordo como label
	@param   bBlock  , Bloco, String usada no join
	@param   cRetPad , AnyType,   Caso não encontre valor será retornado esse parametro
	@example oObj := DMS_DataContainer:New({ {'Nome', 'Vinicius'} })<br>
						oObj:SetValue('Nome')      => 'Vinicius'<br>
						oObj:SetValue('Idade', 18) => 18
/*/
METHOD SetValue(cLabel, cRetPad) Class DMS_JdFileInterpreter
Return self:oData:SetValue(cLabel, cRetPad)

/*/{Protheus.doc} DMS_Json
	Classe que trabalhará com JSON criação/alteração

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class DMS_Json
	Data oData
	Method New() CONSTRUCTOR
	Method toJsonAttr()
	Method toJsonArray()
	Method valToJson()
	Method toJson()
ENDCLASS

/*/{Protheus.doc} New
	Construtor Basico

	@author Vinicius Gati
	@since 12/06/2017
/*/
Method New() class DMS_Json
return Self

/*/{Protheus.doc} toJson
	Devolve o Json completo em formato string

	@author Vinicius Gati
	@since 12/06/2017
	@param oDataContainer, DMS_DataContainer , Contendo dados do json
/*/
Method toJson(oData) class DMS_Json
	oArHlp := DMS_ArrayHelper():New()
	aValues := oArHlp:Map(oData:aData, {|aValues| self:toJsonAttr(aValues[1], aValues[2]) })
return "{ " + oArHlp:Join(aValues, ',') + " }"

/*/{Protheus.doc} toJsonAttr
	Converte indice e valor para formato json

	@author Vinicius Gati
	@since 12/06/2017
	@param cIdx, String, Representação do valor
	@param uVal, valor, Valor
	@example toJson('nom', 'Vinicius') => "nome": "Vinicius"
/*/
Method toJsonAttr(cIdx, uVal) class DMS_Json
return ' "'+cIdx+'": ' + self:valToJson(uval)

/*/{Protheus.doc} toJsonArray
	Retorna tipo array em formato json

	@author Vinicius Gati
	@since 12/06/2017
	@param aValues, Array, Array de valores para concatenar no json
/*/
Method toJsonArray(aValues) class DMS_Json
	Local oArHlp := DMS_ArrayHelper():New()
	Local cJson := '[ '
	aJsonValues := oArHlp:Map(aValues, {|value| self:valToJson(value) })
	cJson += oArHlp:Join(aJsonValues, ',')
	cJson += ' ]'
Return cJson

/*/{Protheus.doc} valToJson
	Retorna o valor em formato json para usar após : no json

	@author Vinicius Gati
	@since 12/06/2017
	@param uVal, Any, valor a ser formatado
/*/
Method valToJson(uVal) class DMS_Json
	Local cVal := ''
	Local cType := VALTYPE(uVal)
	Do Case
	case cType == 'U'
		cVal += "null"
	case cType == 'N'
		cVal += cValToChar(uVal)
	case cType == 'D'
		if empty(uVal)
			uVal := STOD('20000101')
		endif
		cData := DTOS(uVal)
		cVal += '"' + LEFT(cData, 4) + '-' + LEFT(RIGHT(cData, 4), 2) + '-' + RIGHT(cData, 2) + '"'
	case cType == 'A'
		cVal += self:toJsonArray(uVal)
	case cType == 'O'
		cVal += self:toJson(uVal)
	case cType == 'L'
		cVal += IIF(uVal == .T., ' true', ' false')
	otherwise
		cVal += '"' + ALLTRIM(uVal) + '"'
	end case
return cVal

/*/{Protheus.doc} DMS_VmiJson
	Classe que trabalhará com JSON criação/alteração

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class DMS_VmiJson from DMS_Json
	Method New() CONSTRUCTOR
	Method valToJson()
ENDCLASS

Method New() CLASS DMS_VmiJson
Return SELF

/*/{Protheus.doc} valToJson
	Retorna o valor em formato json para usar após : no json, este metodo foi <br/>
	reescrito pois o comportamento para o VMI é diferente do padrão em outros <br/>
	sistemas

	@author Vinicius Gati
	@since 01/12/2017
	@param uVal, Any, valor a ser formatado
/*/
Method valToJson(uVal) class DMS_VmiJson
	Local cVal := ''
	Local cType := VALTYPE(uVal)
	if cType == 'N'
		cVal := TRANSFORM(uVal, "@E 999999999.99")
		cVal := " " + ALLTRIM(STRTRAN(cValToChar(cVal), ',', '.'))
		return cVal
	endif
return _Super:valToJson(uval)
