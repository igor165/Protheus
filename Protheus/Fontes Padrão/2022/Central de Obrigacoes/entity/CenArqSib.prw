#include "TOTVS.ch"

/*/{Protheus.doc} 
    @type  Class
    @author lima.everton
    @since 30/08/2018
/*/
Class CenArqSib from AbstractEntity

    Data cCodOpe
    Data cCdObri
    Data cAno   
    Data cCdComp
    Data cArquiv
    Data cSeqArq

    Method New(oDao) Constructor

    Method getCodOpe() 
    Method getCdObri() 
    Method getAno() 
    Method getCdComp() 
    Method getArquiv() 
    Method getSeqArq() 

    Method setCodOpe(cCodOpe)
    Method setCdObri(cCdObri)
    Method setAno(cAno)
    Method setCdComp(cCdComp)
    Method setArquiv(cArquiv)
    Method setSeqArq(cSeqArq)

    Method serialize(oJsonControl) 

EndClass

Method New(oDao) Class CenArqSib
    _Super:New(oDao)
Return self

Method serialize(oJsonControl) Class CenArqSib

    Local oJson 	   := JsonObject():New()
	Local aExpandables := {}

	Default oJsonControl := AutJsonControl():New()

	if oJsonControl:notFiltered()
        aExpandables := oJsonControl:getExpandables(aExpandables)
        if Len(aExpandables) > 0
    		oJson["_expandables"] := aExpandables
        EndIf
	Endif

	oJsonControl:setProp(oJson,"fileName", self:getArquiv())

    
    aExpandables := Nil

Return oJson

Method getCodOpe() Class CenArqSib 
Return self:cCodOpe

Method getCdObri() Class CenArqSib 
Return self:cCdObri

Method getAno() Class CenArqSib 
Return self:cAno   

Method getCdComp() Class CenArqSib 
Return self:cCdComp

Method getArquiv() Class CenArqSib 
Return self:cArquiv

Method getSeqArq() Class CenArqSib 
Return self:cSeqArq

Method setCodOpe(cCodOpe) Class CenArqSib
    self:cCodOpe := cCodOpe
Return

Method setCdObri(cCdObri) Class CenArqSib
    self:cCdObri := cCdObri
Return

Method setAno(cAno) Class CenArqSib
    self:cAno := cAno
Return

Method setCdComp(cCdComp) Class CenArqSib
    self:cCdComp := cCdComp
Return

Method setArquiv(cArquiv) Class CenArqSib
    self:cArquiv := cArquiv
Return

Method setSeqArq(cSeqArq) Class CenArqSib
    self:cSeqArq := cSeqArq
Return
