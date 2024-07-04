#include "TOTVS.ch"

/*/{Protheus.doc}
    @type  Class
    @author lima.everton
    @since 10/08/2018
/*/

Class CenOpe from AbstractEntity

    Data cCodOpe
    Data cCnpjOp
    Data cRazSoc
    Data cNomFan
    Data cNatJur
    Data cModali
    Data cSegmen

    Method New(oDao) Constructor

    Method getCodOpe()
    Method getCnpjOp()
    Method getRazSoc()
    Method getNomFan()
    Method getNatJur()
    Method getModali()
    Method getSegmen()

    Method setCodOpe(cCodOpe)
    Method setCnpjOp(cCnpjOp)
    Method setRazSoc(cRazSoc)
    Method setNomFan(cNomFan)
    Method setNatJur(cNatJur)
    Method setModali(cModali)
    Method setSegmen(cSegmen)

EndClass

Method New(oDao) Class CenOpe
    _Super:New(oDao)
Return self

Method getCodOpe() Class CenOpe
Return self:cCodOpe

Method getCnpjOp() Class CenOpe
Return self:cCnpjOp

Method getRazSoc() Class CenOpe
Return self:cRazSoc

Method getNomFan() Class CenOpe
Return self:cNomFan

Method getNatJur() Class CenOpe
Return self:cNatJur

Method getModali() Class CenOpe
Return self:cModali

Method getSegmen() Class CenOpe
Return self:cSegmen

Method setCodOpe(cCodOpe) Class CenOpe
    self:cCodOpe := cCodOpe
Return

Method setCnpjOp(cCnpjOp) Class CenOpe
    self:cCnpjOp := cCnpjOp
Return

Method setRazSoc(cRazSoc) Class CenOpe
    self:cRazSoc := cRazSoc
Return

Method setNomFan(cNomFan) Class CenOpe
    self:cNomFan := cNomFan
Return

Method setNatJur(cNatJur) Class CenOpe
    self:cNatJur := cNatJur
Return

Method setModali(cModali) Class CenOpe
    self:cModali := cModali
Return

Method setSegmen(cSegmen) Class CenOpe
    self:cSegmen := cSegmen
Return
