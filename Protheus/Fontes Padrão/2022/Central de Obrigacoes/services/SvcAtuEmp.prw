#INCLUDE "TOTVS.CH"
#include "protheus.ch"

/*/{Protheus.doc} 
    @type  Function
    @author lima.everton
    @since 09/12/2019
/*/
Main Function SvcAtuEmp()
    Local cEmp := cEmpAnt
    Local cFil := cFilAnt
    StartJob("EXEATUEMP", GetEnvServer(), .F., cEmp, cFil)
return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

Function EXEATUEMP(cEmp, cFil, lJob)
    Local oSvcAtuEmp := SvcAtuEmp():New()
    Default lJob := .T.

    If lJob
        rpcSetType(3)
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    oSvcAtuEmp:prcAtuEmp()  
    FreeObj(oSvcAtuEmp)
    oSvcAtuEmp := nil
return

Class SvcAtuEmp

    Data cUrl
    Data cHeaderRet
    Data cGetPar
    Data aHeaderStr
    Data nTimeOut
    Data oDao
    Data oBuscador
    Data oJsonCenBenefi
    Data oCenLogger   
    Data oMprCenBenefi
    Data oCenBenefi
    Data oJson
    
    Method New()
    Method AtuReg(oCenBenefi, cNameEmp)
    Method prcAtuEmp()
    Method destroy()

EndClass

Method New() Class SvcAtuEmp
    self:cUrl := "https://www.receitaws.com.br/v1/cnpj/"
    self:cHeaderRet := ""
    self:cGetPar := ""
    self:aHeaderStr:= {}
    self:nTimeOut := 2
    self:oDao := DaoCenBenefi():New()
    self:oBuscador := BscCenBenefi():New(self:oDao)
    self:oJsonCenBenefi := JsonObject():New()
    self:oMprCenBenefi := MprCenBenefi():New()
    self:oCenBenefi := CenBenefi():New()
    self:oJson := JsonObject():New()
Return self

Method destroy() Class SvcAtuEmp

    if self:oDao <> nil
        FreeObj(self:oDao)
        self:oDao := nil
    endif
    if self:oBuscador <> nil
        FreeObj(self:oBuscador)
        self:oBuscador := nil
    endif
    if self:oJsonCenBenefi <> nil
        FreeObj(self:oJsonCenBenefi)
        self:oJsonCenBenefi := nil
    endif
    if self:oMprCenBenefi <> nil
        FreeObj(self:oMprCenBenefi)
        self:oMprCenBenefi := nil
    endif
    if self:oCenBenefi <> nil
        FreeObj(self:oCenBenefi)
        self:oCenBenefi := nil
    endif
    if self:oJson <> nil
        FreeObj(self:oJson)
        self:oJson := nil
    endif

return

Method prcAtuEmp() Class SvcAtuEmp
    Local nI := 1
    Local cResponse := ""
    Local ret := nil
    For nI:= 1 to 3
        self:oBuscador:BscAtuEmp()
        If self:oBuscador:found()
            If self:oBuscador:hasNext()
                oCenBenefi := self:oBuscador:getNext(self:oCenBenefi, self:oMprCenBenefi)
                cResponse := Httpget(self:cUrl+oCenBenefi:getCnpjCO(),self:cGetPar,self:nTimeOut, self:aHeaderStr, @self:cHeaderRet)
                ret := self:oJson:fromJson(cResponse)
                self:AtuReg(oCenBenefi,ret)
                oCenBenefi:getDao():fechaQuery()
           EndIf
        EndIf
    Next
    self:destroy()
Return 

Method AtuReg(oCenBenefi, ret) Class SvcAtuEmp
	
    Local cSql := ""
    Local nRet := 0
    
    If Empty(ret) .AND. self:oJson['status'] != "ERROR"
        cSql := " UPDATE " + RetSqlName('B3K') + " SET "
        cSql += " B3K_DTUPEM = '" + DTOS(DATE()) + "', "
        If !Empty(self:oJson['fantasia'])
            cSql += " B3K_NOMECO = '" + self:oJson['fantasia'] + "' "    
        Else
            cSql += " B3K_NOMECO = '" + self:oJson['nome'] + "' "    
        EndIf
        cSql += " WHERE "
        cSql += " B3K_CNPJCO = '" + oCenBenefi:getCnpjCO() + "' "
    Else
        cSql := " UPDATE " + RetSqlName('B3K') + " SET "
        cSql += " B3K_DTUPEM = '" + DTOS(DATE()) + "' "
        cSql += " WHERE "
        cSql += " B3K_CNPJCO = '" + oCenBenefi:getCnpjCO() + "' "
    EndIf

    nRet := TCSQLEXEC(cSql)
	If nRet >= 0 
		if SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		endif
	EndIf

Return