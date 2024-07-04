#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB5Q - Error Log Of Oblig Central
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB5Q from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB5Q
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB5Q

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"errorDescription",self:getValue("errorDescription")) /* Column B5Q_DESCRI */ 
    oJsonControl:setProp(oJson,"errorDate",self:getValue("errorDate")) /* Column B5Q_DATA   */ 
    oJsonControl:setProp(oJson,"errorTime",self:getValue("errorTime")) /* Column B5Q_HORA   */ 
    oJsonControl:setProp(oJson,"idRequest",self:getValue("idRequest")) /* Column B5Q_IDREQU */ 
    oJsonControl:setProp(oJson,"path",self:getValue("path")) /* Column B5Q_PATH   */ 
    oJsonControl:setProp(oJson,"entradaJson",self:getValue("entradaJson")) /* Column B5Q_JSONIN */ 
    oJsonControl:setProp(oJson,"saidaJson",self:getValue("saidaJson")) /* Column B5Q_JSONOU */ 
    oJsonControl:setProp(oJson,"verboRequisicao",self:getValue("verboRequisicao")) /* Column B5Q_VERBO  */ 

Return oJson

Method destroy() Class CenB5Q
	_Super:destroy()
	DelClassIntF()
return