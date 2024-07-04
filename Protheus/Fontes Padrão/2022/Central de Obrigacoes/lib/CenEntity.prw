#include "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

/*/{Protheus.doc} 
    Classe abstrata de uma entidade de negócio
    @type  Class
    @author 
    @since 
/*/
Class CenEntity 

    Data hMap
    Data aFields
    Data cJson
    Data nRecno
    Data oHashFields
	
	Method New() Constructor
	
	Method getAFields()
	Method setFields(aFields)
	Method getHMap()
	Method setHMap(hMap)
	Method setValue(cProperty,xData)
	Method destroy()
	Method getValue(cProperty)
	Method dateToUtc(dDate, cTime, utc)
	Method utcToDate(cUtcDate)
	Method setHashFields(oHashFields)

EndClass

Method New() Class CenEntity
	self:hMap 		:= THashMap():New()
	self:nRecno 	:= 1
	self:aFields	:= {}
Return self

Method getAFields() Class CenEntity
Return self:aFields

Method setFields(aFields) Class CenEntity
	self:aFields := aFields
Return 

Method getHMap() Class CenEntity
Return self:hMap

Method setHMap(hMap) Class CenEntity
	self:hMap := hMap
Return

Method setValue(cProperty,xData) Class CenEntity
	Local nPos := 0
    nPos := aScan(self:getAFields(),{ |aFields| aFields[DBFIELD] == cProperty })
    If nPos > 0
        cProperty := self:getAFields()[nPos][JSONFIELD]
    EndIf
Return self:hMap:set(cProperty,xData)

Method destroy() Class CenEntity
	if !empty(self:hMap)
        self:hMap:clean()
        FreeObj(self:hMap)
        self:hMap := nil
    endif
	if !empty(self:oHashFields)
        self:oHashFields:clean()
        FreeObj(self:oHashFields)
        self:oHashFields := nil
    endif
return

Method getValue(cProperty) Class CenEntity
	Local anyValue := ""
	Local anyDbValue := ""
	self:hMap:get(cProperty,@anyValue)
	If Empty(anyValue)
		nPos := aScan(self:getAFields(),{ |aFields| aFields[DBFIELD] == cProperty })
		If nPos > 0
			anyDbValue := self:getValue(self:getAFields()[nPos][JSONFIELD])
			If !Empty(anyDbValue)
				anyValue := anyDbValue
			EndIf
		EndIf
	EndIf
Return anyValue

Method dateToUtc(dDate, cTime, utc) Class CenEntity

	Local cUtcDate := ""
	Local dVoidDate := STOD("")

	If dDate != dVoidDate
		If utc 
			cUtcDate := allTrim(FWTimeStamp(5, dDate, cTime))  
		else
			cUtcDate := SubStr(allTrim(FWTimeStamp(5, dDate, cTime)), 1, 10)
		EndIF
	EndIf

Return cUtcDate

Method utcToDate(cUtcDate) Class CenEntity
	
	Local dDate := STOD("")

	If !Empty(cUtcDate)
		dDate := STOD(SubStr(allTrim(STRTRAN(cUtcDate, "-", "")), 1, 8))
	EndIF

Return dDate

//Armazena os fields para serializar a saida Json do Objeto
Method setHashFields(oHashFields) Class CenEntity
    self:oHashFields := oHashFields
Return