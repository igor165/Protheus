#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fila Banco de Dados
Classe da engine de fila do processamento em uma tabela de entidade que será usada como fila

@author    everton.mateus
@version   V12
@since     06/12/2019
/*/
class CenFilaBD
    
    Data cError
	Data cProcId
	Data oCollection
	Data cCodOpe

    Method New(oCollection) Constructor
    Method setProcId(cProcId)
    Method setCodOpe(cCodOpe)
    Method checkQueue()
    Method setupQueue()
    Method lock(lBloq)
    Method getMsg()
    Method getNext()
    Method setEndProc()
    Method setExpired()

EndClass

Method New(oCollection) class CenFilaBD
    self:oCollection := oCollection
    self:cError		:= ""
return self

Method setProcId(cProcId) Class CenFilaBD
    self:cProcId := cProcId
Return 

Method setCodOpe(cCodOpe) Class CenFilaBD
    self:cCodOpe := cCodOpe
Return

Method checkQueue() Class CenFilaBD
Return ChkFile(self:oCollection:getAlias())

Method setupQueue() Class CenFilaBD
Return ChkFile(self:oCollection:getAlias())

Method lock(lBloq) Class CenFilaBD
    Local lOk   := .T.

    If lBloq
        while lOk 
            If LockByName(self:oCollection:getAlias(), .T., .T.)
                lOk := .F.
            EndIf
        enddo
    Else
        UnlockByName(self:oCollection:getAlias(), .T., .T.)
    EndIf

return lOk

Method getMsg() Class CenFilaBD
    Local lRet := .F.
    
    self:setExpired()
    self:lock(.T.)
    self:oCollection:setValue("processId", self:cProcId)
    If self:oCollection:setProcessing()
        lRet := self:oCollection:getMessage()
    EndIf
    self:lock(.F.)
Return lRet

Method getNext() Class CenFilaBD
    Local oEntity := nil
    If self:oCollection:hasNext()
        oEntity := self:oCollection:getNext()
    EndIf
Return oEntity

Method setEndProc() Class CenFilaBD
Return self:oCollection:setEndProc(self:oCollection:getDbRecno())

Method setExpired() Class CenFilaBD
Return self:oCollection:setExpired()

