#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#DEFINE DESCRICAO "DESCRICAO"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenTissTer
    Classe para controle de Terminologias TISS

    @type  Class
    @author lima.everton
    @since 20200303
/*/
//------------------------------------------------------------------------------------------
Class CenTissTer 
    
    Data oCenCltB2R
    Data oHmTissTerm 
    
    Method New() Constructor
    Method getTermDesc(cTable,cTermCode)
    Method destroy()

EndClass

Method New() Class CenTissTer
    self:oCenCltB2R := CenCltB2R():New()
    self:oHmTissTerm := THashMap():New()
Return self

Method destroy() Class CenTissTer
Return

Method getTermDesc(cTable,cTermCode) Class CenTissTer
    Local cDescricao := ""
    Local oCenB2R := nil
    self:oHmTissTerm:get(cTable+cTermCode,@cDescricao)
    If Empty(cDescricao)
        self:oCenCltB2R:setValue("tableCode", cTable)
        self:oCenCltB2R:setValue("termCode", cTermCode)
        if (self:oCenCltB2R:bscChaPrim())
            oCenB2R := self:oCenCltB2R:getNext()
            cDescricao := oCenB2R:getValue("termDescription")
            self:oHmTissTerm:set(cTable+cTermCode,cDescricao)
            oCenB2R:Destroy()
            FreeObj(oCenB2R)
            oCenB2R := nil
        EndIf
    EndIf
Return cDescricao


