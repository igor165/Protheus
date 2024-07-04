#include "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

/*/{Protheus.doc} 
    Classe abstrata de um CenMapper
    @type  Class
    @author victor.silva
    @since 20180718
/*/
Class CenMapper

    Data oEntity
    Data nType
    Data aFields
    Data aExpand    

    Method New() Constructor
    Method getEntity()
    Method getAFields()
    Method setEntity(oEntity)
    Method mapFromDao(oDao) 
    Method mapFromJson(oJson)
    Method getFields()
    Method setFields(aFields)

EndClass

Method New(oEntity) Class CenMapper
    self:oEntity := oEntity
    self:aFields := {}
    self:aExpand := {}    
Return self

Method getAFields() Class CenMapper
Return self:aFields

Method getEntity() Class CenMapper
Return self:oEntity

Method setEntity(oEntity) Class CenMapper
    self:oEntity := oEntity
Return

Method mapFromDao(oDao) Class CenMapper
    Local nField := 0
    Local nLen   := Len(self:getAFields())
    Local xValue := ""

    For nField := 1 to nLen
        xValue := (oDao:cAliasTemp)->&(self:getAFields()[nField][DBFIELD])
        If ValType( xValue ) == "C"
            xValue := AllTrim(xValue)
        EndIf
        self:oEntity:setValue(self:getAFields()[nField][JSONFIELD],xValue )
    Next nField
    self:oEntity:setFields(self:getAFields())
Return

Method mapFromJson(oJson) Class CenMapper
    Local nField := 0
    Local nLen   := Len(self:getAFields())

    For nField := 1 to nLen
        cField := self:getAFields()[nField][JSONFIELD]
        self:oEntity:setValue(cField,oJson[cField])
    Next nField
    
Return self:getEntity()

Method getFields() Class CenMapper
Return self:aFields

Method setFields(aFields) Class CenMapper
    self:aFields := aFields
Return