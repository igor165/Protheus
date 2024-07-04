////////////////
// Versao 09  //
////////////////

#include "protheus.ch"

Function VEIXFUNC()
Return .T.

CLASS Mil_JsonParse
	DATA cJSON
	DATA nPos
	DATA cCharPos    
		
	METHOD New() CONSTRUCTOR
	METHOD ParseToObj()
	METHOD Clean()
	METHOD NextChar()
	METHOD nextValue()
	METHOD readObject()
	METHOD readArray()
	METHOD readChar()
	METHOD readUndef()
	METHOD readDate()
	METHOD readHour() // Vai retornar uma hora como inteiro , padrao dms protheus
	METHOD readInt()
ENDCLASS
		
METHOD New(_cJson) CLASS Mil_JsonParse
	::cJSON := _cJson
RETURN SELF

METHOD ParseToObj() CLASS Mil_JsonParse
	// variavel de progresso na leitura do json(string) previsa 
	//ser iniciada toda vez que ler o json, iniciar com 1 pulando o '{' inicial
	::nPos  := 1 
	self:Clean()
Return self:readObject()

METHOD readObject() CLASS Mil_JsonParse
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
RETURN Mil_DataContainer():New( aObjData )

METHOD readArray() CLASS Mil_JsonParse
	Local aObjects  := {}

	While( self:cCharPos != ']' )
		self:NextChar()
		
		If( self:cCharPos == '{' )
			AADD( aObjects, self:readObject() )
		ElseIf self:cCharPos == '"'
			AADD( aObjects, self:readChar() )
		Else
			AADD( aObjects, self:readUndef() )
		end
	EndDo

RETURN aObjects

METHOD readChar() CLASS Mil_JsonParse
	Local cStr := ""
	
	while self:NextChar(.T.) != '"'
		cStr += self:cCharPos
	EndDo
	
	self:NextChar()
RETURN cStr 

METHOD readUndef() CLASS Mil_JsonParse
	Local cStr := self:cCharPos
	
	self:NextChar()
	
	while self:cCharPos != ',' .AND. self:cCharPos != '}'
		cStr += self:cCharPos
		self:NextChar()
	EndDo
	if self:cCharPos == '}'
		self:nPos := self:nPos - 1 // isto é necessário pois se for um }(fim de objeto) retorno o valor e volto um char para tras, pois pra fechar o objeto precisa ler um } denovo após este metodo
	end
RETURN cStr 

METHOD NextChar(lAnyChar) CLASS Mil_JsonParse
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

METHOD Clean() CLASS Mil_JsonParse
	Local aRem := {(CHR(13)+ CHR(10)), CHR(13), CHR(10), CHR(9), CHR(11)} // lista de caracteres que serao limpos do json, pois tudo deve estar em uma linha so e sem caracteres especiais
	Local var := 0

	for var:= 1 to Len(aRem)
		self:cJson := STRTRAN( self:cJson, aRem[var], "" )
	next
	self:cJson := LTRIM(self:cJson)
RETURN .T.

/*/{Protheus.doc} Mil_JsonParse:readHour

	@author       Vinicius Gati
	@since        20/05/2015
	@description  Este metodo converte uma hora em string no formato "00:12" para protheus 12 como inteiro, padrao DMS

/*/
Method readHour(cHour) CLASS Mil_JsonParse
	Local nHour := VAL( STRTRAN(cHour, ":", "") )
return nHour

/*/{Protheus.doc} Mil_JsonParse:readDate

	@author       Vinicius Gati
	@since        20/05/2015
	@description  converte data no formato json para protheus(db)

/*/
METHOD readDate(cDateP) CLASS Mil_JsonParse
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

METHOD readInt(cInt) CLASS Mil_JsonParse
	LOCAL nNum := 0
	BEGIN SEQUENCE
		nNum := VAL( cInt )
	RECOVER
		nNum := 0
	END SEQUENCE	
Return nNum

/*/{Protheus.doc} Mil_MetasDeInteresseDAO

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Helper para manipulação de arrays no protheus

/*/
CLASS Mil_MetasDeInteresseDAO

	DATA cCodigo      // VDY_CODIGO
	DATA cCodCampanha // VDY_CAMPOP
	DATA cMesCampanha // VDY_MESMET
	Data cAnoCampanha // VDY_ANOMET
	DATA cCodVendedor // VDY_CODVEN
	DATA cCodMarca    // VDY_CODMAR
	DATA cCodModelo   // VDY_MODVEI
	DATA nQtd         // VDY_QTDINT
	DATA nQtdAtendida
	DATA nQtdValidas
	DATA nQtdCanceladas
	DATA nQtdFaturadas

	METHOD New() CONSTRUCTOR
	METHOD Andamento()
	METHOD Buscar()

ENDCLASS

/*/{Protheus.doc} New

	@author       Vinicius Gati
	@since        31/10/2014
	@description  

/*/
METHOD New(aData) CLASS Mil_MetasDeInteresseDAO
	oData           := Mil_DataContainer():New(aData)
	::cCodigo       := oData:GetValue('cCodigo')
	::cCodCampanha  := oData:GetValue('cCodCampanha')
	::cMesCampanha  := oData:GetValue('cMesCampanha')
	::cAnoCampanha  := oData:GetValue('cAnoCampanha')
	::cCodVendedor  := oData:GetValue('cCodVendedor')
	::cCodMarca     := oData:GetValue('cCodMarca')
	::cCodModelo    := oData:GetValue('cCodModelo')
	::nQtd          := oData:GetValue('nQtd')
Return SELF

/*/{Protheus.doc} Buscar

	@author       Vinicius Gati
	@since        01/11/2014
	@description  Retorna as metas do banco de dados de acordo com o filtro passado
	@example  Atributos válidos
						aData := {
								{'mes'             , '06'       }, 
								{'ano'             , '2014'     }, 
								{'codigo_campanha' , '00000001' }, 
								{'codigo_vendedor' , '00000001' }, 
								{'codigo_marca'    , '00000001' }, 
								{'codigo_modelo'   , '00000001' }
						}
						aUsados := o_MetasI:Todos( aData )

/*/
Method Buscar(aData, lObj) CLASS Mil_MetasDeInteresseDAO
	Local aResults := {}
	Local oData := Mil_DataContainer():New(aData)

	cAlias    := "Metas"
	cTblVDY   := RetSqlName("VDY")
	cSqlMetas := ""
	cSqlMetas += " SELECT VDY_CODIGO, VDY_CAMPOP , VDY_MESMET , VDY_ANOMET , VDY_CODVEN , VDY_CODMAR , VDY_MODVEI , VDY_QTDINT "
	cSqlMetas += "   FROM " + cTblVDY + " VDY "
	cSqlMetas += "  WHERE VDY.VDY_FILIAL = '" + xFilial("VDY") + "' "
	cSqlMetas += "    AND VDY.D_E_L_E_T_ = ' ' "

	If !Empty(oData:GetValue("mes"))
		cSqlMetas += "  AND VDY.VDY_MESMET = '" + oData:GetValue('mes') + "' "
	EndIf

	If !Empty(oData:GetValue("ano"))
		cSqlMetas += "  AND VDY.VDY_ANOMET = '" + oData:GetValue('ano') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_campanha"))
		cSqlMetas += "  And VDY.VDY_CAMPOP = '" + oData:GetValue('codigo_campanha') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_vendedor"))
		cSqlMetas += "  AND VDY.VDY_CODVEN = '" + oData:GetValue('codigo_vendedor') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_marca"))
		cSqlMetas += "  AND VDY.VDY_CODMAR = '" + oData:GetValue('codigo_marca') + "' "
	EndIf

	If !Empty(oData:GetValue("codigo_modelo"))
		cSqlMetas += "  AND VDY.VDY_MODVEI = '" + oData:GetValue('codigo_modelo') + "' "
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSqlMetas),cAlias, .F., .T. )

	(cAlias)->(DbGoTop())
	While !EOF()
		aEl := {                ;
			{'cCodigo'      , (cAlias)->VDY_CODIGO},;
			{'cCodCampanha' , (cAlias)->VDY_CAMPOP},;
			{'cMesCampanha' , (cAlias)->VDY_MESMET},;
			{'cAnoCampanha' , (cAlias)->VDY_ANOMET},;
			{'cCodVendedor' , (cAlias)->VDY_CODVEN},;
			{'cCodMarca'    , (cAlias)->VDY_CODMAR},;
			{'cCodModelo'   , (cAlias)->VDY_MODVEI},;
			{'nQtd'         , (cAlias)->VDY_QTDINT} ;
		}
		If lObj
			AADD(aResults, Mil_MetasDeInteresseDAO():New(aEl))
		Else
			oArrHlp := Mil_ArrayHelper():New()
			aMapped := oArrHlp:Map(aEl, {|el| el[2] })
			AADD(aResults, aMapped)
		EndIf

		DbSkip()
	End
	(cAlias)->(dbCloseArea())

Return aResults

/*/{Protheus.doc} Andamento

	@author       Vinicius Gati
	@since        02/11/2014
	@description  Retorna o andamento atual da meta
	@return  {16, 25} // primeira posição quantidade atendida do montante da meta, e segunda posição porcentagem atendida

/*/
Method Andamento() CLASS Mil_MetasDeInteresseDAO
	Local oSqlHelp       := Mil_SqlHelper():New()
	Local cTblVDM        := RetSqlName("VDM")
	Local cTblVV9        := RetSqlName("VV9")
	Local cFilVDM        := xFilial("VDM")
	Local cSql           := ""
	Local cWhereCanc     := "   AND ( VDM.VDM_MOTCAN <> ' ' OR  VV9.VV9_STATUS =  'C' ) "
	Local cWhereValid    := "   AND ( VDM.VDM_MOTCAN =  ' ' AND COALESCE(VV9.VV9_STATUS, '') <> 'C' ) "
	Local cWhereFat      := "   AND VV9.VV9_STATUS   =  'F' "

	cSql += " SELECT COALESCE( SUM(VDM_QTDINT), 0 ) as SOMA "
	cSql += "      FROM  " + cTblVDM + " VDM "
	cSql += " LEFT JOIN  " + cTblVV9 + " VV9 on VDM.VDM_FILATE = VV9_FILIAL and VDM.VDM_NUMATE = VV9_NUMATE AND VV9.D_E_L_E_T_ = ' ' "
	cSql += "     WHERE VDM.VDM_FILIAL = '" + cFilVDM + "' AND VDM.D_E_L_E_T_ = ' ' "

	If !Empty(self:cMesCampanha)
		cSql += "   AND ("+ oSqlHelp:CompatFunc('SUBSTR') +"(VDM_DATINT, 5, 2) = '" + self:cMesCampanha + "' OR VDM_DATINT = ' ') "
	EndIf

	If !Empty(self:cAnoCampanha)
		cSql += "   AND ("+ oSqlHelp:CompatFunc('SUBSTR') +"(VDM_DATINT, 1, 4) = '" + self:cAnoCampanha + "' OR VDM_DATINT = ' ') "
	EndIf

	If !Empty(self:cCodCampanha)
		cSql += "   AND VDM.VDM_CAMPOP = '" + self:cCodCampanha + "' "
	EndIf

	If !Empty(self:cCodVendedor)
		cSql += "   AND VDM.VDM_CODVEN = '" + self:cCodVendedor + "' "
	EndIf

	If !Empty(self:cCodMarca)
		cSql += "   AND VDM.VDM_CODMAR = '" + self:cCodMarca + "' "
	EndIf

	If !Empty(self:cCodModelo)
		cSql += "   AND VDM.VDM_MODVEI = '" + self:cCodModelo + "' "
	EndIf

	self:nQtdAtendida   := FM_SQL(cSql) // sql contendo quantidade total
	self:nQtdValidas    := FM_SQL(cSql + cWhereValid)
	self:nQtdCanceladas := FM_SQL(cSql + cWhereCanc)
	self:nQtdFaturadas  := FM_SQL(cSql + cWhereFat)
Return {self:nQtdAtendida, self:nQtdValidas, self:nQtdCanceladas, self:nQtdFaturadas}

/*/{Protheus.doc} Mil_CampanhaDAO

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Classe criada para acoplar metodos relacionados a campanha, assim como seus dados de tabela já que a mesma está no VX5

/*/
CLASS Mil_CampanhaDAO
	
	METHOD New() CONSTRUCTOR
	METHOD TableCode() // codigo da tabela no vx5
ENDCLASS

METHOD New() CLASS Mil_CampanhaDAO
Return SELF

METHOD TableCode() CLASS Mil_CampanhaDAO
Return '026'


/*/{Protheus.doc} Mil_XmlHelper

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Classe criada para ajudar a coletar dados em XMls sem que errorlogs sejam exibidos

/*/
CLASS Mil_XmlHelper
	Data oXml

	Method New() CONSTRUCTOR
	METHOD GetValue()
ENDCLASS

/*/{Protheus.doc} Mil_XmlHelper

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Construtor base
	@parameter oXmlObj , Objeto xml criado usando XmlParseFile

/*/
METHOD New(oXmlObj) CLASS Mil_XmlHelper
	::oXml := oXmlObj
Return SELF

/*/{Protheus.doc} GetValue

	@author       Vinicius Gati
	@since        29/05/2015
	@description  Usado para colher os dados de um objeto xml porem é feita checagem de existencia para cada nó
	@parameter    oXmlObj , Objeto xml criado usando XmlParseFile

/*/
Method GetValue(cTagTree, iDefault) CLASS Mil_XmlHelper
	Local   nIdx     := 1
	Local   oXmlAt   := nil
	DEFAULT iDefault := ""
	oXmlAt           := Self:oXml
	aTags            := STRTOKARR(cTagTree, ":")

	for nIdx:= 1 to LEN(aTags)
		cTag := aTags[nIdx]
		if UPPER(cTag) != "TEXT"
			oXmlAt := XmlChildEx(oXmlAt, UPPER(cTag))
			if VALTYPE( oXmlAt ) == "U"
				return iDefault // tag não encontrada
			EndIf
		else
			return oXmlAt:Text
		EndIf
	next
Return oXmlAt

/*/{Protheus.doc} Mil_NotaFiscal

	@author       Vinicius Gati
	@since        02/06/2015
	@description  Representa nota fiscal no protheus e conterá metodos para manipulacao das notas
/*/
Class Mil_NotaFiscal
	METHOD New() CONSTRUCTOR
	METHOD Exists()
EndClass

/*/{Protheus.doc} Mil_NotaFiscal:Exists

	@author       Vinicius Gati
	@since        02/06/2015
	@description  Verifica se a nota fiscal já existe
/*/
METHOD Exists(cA2Cod, cA2Loja, cNf, cSerie) CLASS Mil_NotaFiscal
	Local cQuery := "" 
	cQuery       += " SELECT COALESCE( COUNT(*), 0 ) FROM " + RetSqlName("SF1") + " WHERE D_E_L_E_T_ <> '*' AND F1_FILIAL = '" + xfilial("SF1") + "' " // busca padrao dados f1
	cQuery       += " AND F1_FORNECE = '"+cA2Cod+"' AND F1_LOJA = '"+cA2Loja+"' AND F1_DOC = '"+cNf+"' AND F1_SERIE = '" + cSerie + "' "
	nQtd         := VAL( FM_SQL(cQuery) )
Return nQtd > 0