#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB3X - Changes History
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB3X from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB3X
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB3X

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"benefitedRecno",self:getValue("benefitedRecno")) /* Column B3X_BENEF  */ 
    oJsonControl:setProp(oJson,"changedField",self:getValue("changedField")) /* Column B3X_CAMPO  */ 
    oJsonControl:setProp(oJson,"changeDate",self:getValue("changeDate")) /* Column B3X_DATA   */ 
    oJsonControl:setProp(oJson,"fileName",self:getValue("fileName")) /* Column B3X_ARQUIV */ 
    oJsonControl:setProp(oJson,"sibOperation",self:getValue("sibOperation")) /* Column B3X_OPERA  */ 
    oJsonControl:setProp(oJson,"criticized",self:getValue("criticized")) /* Column B3X_CRITIC */ 
    oJsonControl:setProp(oJson,"modificationTime",self:getValue("modificationTime")) /* Column B3X_HORA   */ 
    oJsonControl:setProp(oJson,"originDescription",self:getValue("originDescription")) /* Column B3X_DESORI */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B3X_STATUS */ 
    oJsonControl:setProp(oJson,"previousValue",self:getValue("previousValue")) /* Column B3X_VLRANT */ 
    oJsonControl:setProp(oJson,"newValue",self:getValue("newValue")) /* Column B3X_VLRNOV */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column B3X_CODOPE */ 
    oJsonControl:setProp(oJson,"operationalControlCode",self:getValue("operationalControlCode")) /* Column B3X_CODCCO */ 
    oJsonControl:setProp(oJson,"validationStartDate",self:getValue("validationStartDate")) /* Column B3X_DTINVL */ 
    oJsonControl:setProp(oJson,"validationStartTime",self:getValue("validationStartTime")) /* Column B3X_HRINVL */ 
    oJsonControl:setProp(oJson,"validationEndDate",self:getValue("validationEndDate")) /* Column B3X_DTTEVL */ 
    oJsonControl:setProp(oJson,"validationEndTime",self:getValue("validationEndTime")) /* Column B3X_HRTEVL */ 

Return oJson

Method destroy() Class CenB3X
	_Super:destroy()
	DelClassIntF()
return