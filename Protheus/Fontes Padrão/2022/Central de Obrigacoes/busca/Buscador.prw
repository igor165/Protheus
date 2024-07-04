#include "TOTVS.CH"
/*/{Protheus.doc} 
    Classe abstrata de um buscador
    @type  Class
    @author 
    @since 
/*/
Class Buscador
	   
    Data oDaoBusca
    Data lFound
    Data nRecno

    Method New(oDaoBusca) Constructor
    Method found()
    Method getDao()
    Method setDao(oDaoBusca)
    Method getNext(oEntidade, oMapper)
    Method hasNext()
    Method buscar(nType)
    Method bscCcos(nType)
    Method goTop()
    Method goToNext() 
    Method destroy()
    Method BscAtuEmp()
        
EndClass

Method New(oDaoBusca) Class Buscador
    self:oDaoBusca := oDaoBusca
    self:lFound := .F.
Return self

Method destroy() Class Buscador
    if !empty(self:oDaoBusca)
        self:oDaoBusca:destroy()
        FreeObj(self:oDaoBusca)
        self:oDaoBusca := nil
    endif
Return 

Method found() Class Buscador
Return self:lFound

Method getDao() Class Buscador
Return self:oDaoBusca

Method setDao(oDaoBusca) Class Buscador
    self:oDaoBusca := oDaoBusca
Return

Method hasNext() Class Buscador
    Local lTemProx := .F.
    If Select(self:oDaoBusca:getAliasTemp()) > 0
        self:oDaoBusca:verificaPos(self:nRecno)
        lTemProx := !(self:oDaoBusca:getAliasTemp())->(Eof())
    EndIf
return lTemProx

Method getNext(oEntidade,oMapper) Class Buscador
    //self:oDaoBusca:posReg(self:nRecno)
    oMapper:mapFromDao(oEntidade,self:oDaoBusca)
    self:nRecno++
return oEntidade

Method goToNext() Class Buscador
    self:nRecno++
return

Method buscar(nType) Class Buscador
    self:lFound := self:getDao():buscar(nType)
    self:goTop()
Return self:found()

Method BscAtuEmp() Class Buscador
    self:lFound := self:getDao():BscAtuEmp()
    self:goTop()
Return self:found()

Method bscCcos(nType) Class Buscador
    self:lFound := self:getDao():bscCcos(nType)
    self:goTop()
Return self:found()

Method goTop() Class Buscador
    self:nRecno := 1
Return
