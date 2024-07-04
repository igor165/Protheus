#include "TOTVS.CH"
//#include "autorizador.ch"

/*/{Protheus.doc} 
    Classe abstrata de uma entidade de negócio
    @type  Class
    @author 
    @since 
/*/
Class AbstractEntity 

	Data oDao
    Data cId
    Data hMap
    Data cJson
    Data cJSONProp
    Data nRecno
    Data nRecMap
    Data oHashFields
    Method setHashFields(oHashFields) 	
	
	Method New(oDao) Constructor
	
	// TODO - rever metodos da classe abstrata na refatoracao
	Method hasValue(cProperty,cType)
	Method getValue(cProperty)
	Method setValue(cProperty,xData)
	Method getId()
	Method setId(cId)
	Method fromJson(cJson)
	Method setJSon(cJson)
	Method ParseJSon()
	Method dateToUtc(dDate, cTime, utc)
	Method utcToDate(cUtcDate)
	
	Method getHMap()
	Method setHMap(hMap)

	Method setJSONProp(cProperty)
	Method getData(cProperty,cType)
	Method setData(cProperty,xData)
		
	Method getRecno()
	Method setRecno(nRecno)
	Method getRecMap()
	Method setRecMap(nRecMap)
	
	Method setDao(oDao)
	Method getDao()

	Method verificaPos()
	Method destroy()
	Method commit(nTpOpe)

EndClass

Method New(oDao) Class AbstractEntity
	self:oDao 		:= oDao
	self:hMap 		:= THashMap():New()
	self:cJSONProp	:= ""
	self:nRecno 	:= 1
	self:nRecMap 	:= 0
Return self

Method getId() Class AbstractEntity 
Return self:cId

Method setId(cId) Class AbstractEntity 
    self:cId := cId
Return

Method getHMap() Class AbstractEntity
Return self:hMap

Method setHMap(hMap) Class AbstractEntity
	self:hMap := hMap
Return

Method setJSONProp(cProperty) Class AbstractEntity 
	self:cJSONProp := cProperty
Return

Method getData(xKey, cType) Class AbstractEntity
    Local xValue := ""
	Local cDia := ""
	Local cMes := ""
	Local cAno := ""
    default cType := CARACTER
    self:hMap:get(self:cJSONProp + xKey,@xValue)
    
    if empty(xValue)

        DO CASE
            CASE cType == NUMBER
                xValue := 0
            CASE cType == BOOLEAN
                xValue := .F.
            CASE cType == DATE
                xValue := ""
            CASE cType == ARRAY
                xValue := {}
            CASE cType == OBJECT
                xValue := nil
	    END CASE
	
	else
		// TODO verificar se essa é a melhor tratativa para esse caso
		// por conta das barras estava gravando datas tipo 1912 e a validade estava ficando negativa

		if cType == DATE .and. "/" $ xValue 
			cDia := SubStr(xValue, 1, (at("/", xValue)-1))
			xValue :=  SubStr(xValue, (at("/", xValue)+1))
			cMes := SubStr(xValue, 1, (at("/", xValue)-1))
			xValue :=  SubStr(xValue, (at("/", xValue)+1))
			cAno := SubStr(xValue, (at("/", xValue)+1))
			xValue :=  cAno+cMes+cDia
		endIf
    endIf

Return xValue

Method setData(cProperty,xData) Class AbstractEntity 
Return self:hMap:set(self:cJSONProp + cProperty,xData)

Method getRecno() Class AbstractEntity
Return self:nRecno

Method setRecno(nRecno) Class AbstractEntity
	self:nRecno := nRecno
Return

Method getRecMap() Class AbstractEntity
Return self:nRecMap

Method setRecMap(nRecMap) Class AbstractEntity
	self:nRecMap 	:= nRecMap
	self:cJSONProp  += "[" + allTrim(str(self:nRecMap)) + "]."
Return

Method setDao(oDao) Class AbstractEntity
	self:oDao := oDao
Return

Method getDao() Class AbstractEntity
Return self:oDao

Method verificaPos() Class AbstractEntity
	self:oDao:verificaPos(self:getRecno())
return

Method destroy() Class AbstractEntity
	if !empty(self:oDao)
		FreeObj(self:oDao)
		self:oDao := Nil
	EndIf
return

Method commit(nTpOpe) Class AbstractEntity
	Local lGravou := .F.
	default nTpOpe := INSERT

	DO CASE
		CASE nTpOpe == INSERT
            lGravou := self:oDao:insert(self)
		CASE nTpOpe == DELETE
			lGravou := self:oDao:delete(self)
	END CASE
		
Return lGravou

Method hasValue(cProperty,cType) Class AbstractEntity
    Local anyValue := ""
    default cType := CARACTER

    lFound := self:hMap:get(self:cJSONProp + cProperty,@anyValue)
    lFound := !(empty(anyValue))
	
	if !lFound
        DO CASE
            CASE cType == CARACTER
                self:hMap:set(self:cJSONProp + cProperty,"")
            CASE cType == NUMBER
                self:hMap:set(self:cJSONProp + cProperty,0)
            CASE cType == BOOLEAN
                self:hMap:set(self:cJSONProp + cProperty,.F.)
            CASE cType == DATE
                self:hMap:set(self:cJSONProp + cProperty,StoD(""))
            CASE cType == ARRAY
                self:hMap:set(self:cJSONProp + cProperty,{})
            CASE cType == OBJECT
                self:hMap:set(self:cJSONProp + cProperty,nil)
	    END CASE
    endIf

	// Tratar formato data
	if cType == DATE
	endIf

Return lFound

Method getValue(cProperty) Class AbstractEntity
	Local anyValue := ""
	self:hMap:get(self:cJSONProp + cProperty,@anyValue)
Return anyValue

Method setValue(cProperty,anyValue) Class AbstractEntity
	if !empty(anyValue)
		self:hMap:set(self:cJSONProp + cProperty,@anyValue)
	endif
Return 

Method fromJson(cJson) Class AbstractEntity
    self:setJSon(cJson)
    self:setHMap(self:ParseJSon())
Return

Method setJSon(cJson) Class AbstractEntity
	self:cJson := cJson
Return

Method ParseJSon() Class AbstractEntity
	Local hMap := nil

	oJParser := JSonParser():New()
	oJParser:setJson(self:cJson)
	hMap := oJParser:parseJson()
Return hMap

Method dateToUtc(dDate, cTime, utc) Class AbstractEntity

	Local cUtcDate := ""
	Local dVoidDate := STOD("")

	If dDate == nil
		cUtcDate := dDate
	ElseIf dDate != dVoidDate
		If utc .and. dDate == nil
			cUtcDate := allTrim(FWTimeStamp(5, SdDate, cTime))  
		else
			cUtcDate := SubStr(allTrim(FWTimeStamp(5, dDate, cTime)), 1, 10)
		EndIF
	EndIf

Return cUtcDate

Method utcToDate(cUtcDate) Class AbstractEntity
	
	Local dDate := STOD("")

	If !Empty(cUtcDate)
		dDate := STOD(SubStr(allTrim(STRTRAN(cUtcDate, "-", "")), 1, 8))
	EndIF

Return dDate

Method setHashFields(oHashFields) Class AbstractEntity //Armazena os fields para serializar a saida Json do Objeto
    self:oHashFields := oHashFields
Return