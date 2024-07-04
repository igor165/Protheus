#include "TOTVS.ch"

/*/{Protheus.doc} 
    Classe responsavel por queries comuns a todos os atendimentos
    @type  Class
    @author lima.everton
    @since 25/07/2018
/*/
Class CenProd from AbstractEntity

    Data cCodOpe
    Data cCodigo
    Data cDescri
    Data cForCon
    Data cSegmen
    Data cStatus
    Data cDtiNvl
    Data cHriNvl
    Data cDttEvl
    Data cHrtEvl
    Data cAbrang

    Method New(oDao) Constructor
    Method getCodOpe()
    Method getCodigo()
    Method getDescri()
    Method getForCon()
    Method getSegmen()
    Method getStatus()
    Method getDtiNvl()
    Method getHriNvl()
    Method getDttEvl()
    Method getHrtEvl()
    Method getAbrang()

    Method setCodOpe(cCodOpe)
    Method setCodigo(cCodigo)
    Method setDescri(cDescri)
    Method setForCon(cForCon)
    Method setSegmen(cSegmen)
    Method setStatus(cStatus)
    Method setDtiNvl(cDtiNvl)
    Method setHriNvl(cHriNvl)
    Method setDttEvl(cDttEvl)
    Method setHrtEvl(cHrtEvl)
    Method setAbrang(cAbrang)

    Method serialize(oJsonControl) 

EndClass

Method New(oDao) Class CenProd
    _Super:New(oDao)
Return self

Method serialize(oJsonControl) Class CenProd

    Local oJson 	   := JsonObject():New()
	Local aExpandables := {}

	default oJsonControl := AutJsonControl():New()

	if oJsonControl:notFiltered()
        aExpandables :=  oJsonControl:getExpandables(aExpandables)
        if Len(aExpandables) > 0
    		oJson["_expandables"] := aExpandables
        EndIf
	Endif
    
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("healthInsurerCode")
        oJsonControl:setProp(oJson,"healthInsurerCode", self:getCodOpe())        
    EndIf
	If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("code")
        oJsonControl:setProp(oJson,"code", self:getCodigo())
    EndIf        
	If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("description")
        oJsonControl:setProp(oJson,"description", self:getDescri(),"cp1251")
    EndIf        
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("wayOfHiring")
        oJsonControl:setProp(oJson,"wayOfHiring", self:getForCon())
    EndIf        
	If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("marketSegmentation")
        oJsonControl:setProp(oJson,"marketSegmentation", self:getSegmen())
    EndIf        
	If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("coverageArea")
        oJsonControl:setProp(oJson,"coverageArea", self:getAbrang())
    EndIf        

    aExpandables := Nil

Return oJson

Method getCodOpe() Class CenProd
Return self:cCodOpe

Method getCodigo() Class CenProd
Return self:cCodigo

Method getDescri() Class CenProd
Return self:cDescri

Method getForCon() Class CenProd
Return self:cForCon

Method getSegmen() Class CenProd
Return self:cSegmen

Method getStatus() Class CenProd
Return self:cStatus

Method getDtiNvl() Class CenProd
Return self:cDtiNvl

Method getHriNvl() Class CenProd
Return self:cHriNvl

Method getDttEvl() Class CenProd
Return self:cDttEvl

Method getHrtEvl() Class CenProd
Return self:cHrtEvl

Method getAbrang() Class CenProd
Return self:cAbrang

Method setCodOpe(cCodOpe) Class CenProd
    self:cCodOpe := cCodOpe
Return

Method setCodigo(cCodigo) Class CenProd
    self:cCodigo := cCodigo
Return

Method setDescri(cDescri) Class CenProd
    self:cDescri := cDescri
Return

Method setForCon(cForCon) Class CenProd
    self:cForCon := cForCon
Return

Method setSegmen(cSegmen) Class CenProd
    self:cSegmen := cSegmen
Return

Method setStatus(cStatus) Class CenProd
    self:cStatus := cStatus
Return

Method setDtiNvl(cDtiNvl) Class CenProd
    self:cDtiNvl := cDtiNvl
Return

Method setHriNvl(cHriNvl) Class CenProd
    self:cHriNvl := cHriNvl
Return

Method setDttEvl(cDttEvl) Class CenProd
    self:cDttEvl := cDttEvl
Return

Method setHrtEvl(cHrtEvl) Class CenProd
    self:cHrtEvl := cHrtEvl
Return

Method setAbrang(cAbrang) Class CenProd
    self:cAbrang := cAbrang
Return

