#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"

#define VIAWSDL "2"

// Fonte dedicado a realizar a integração com o faturamento no HAT
Function PLHATINTFAT(cCodOpe, cCodLdp, cCodPeg)
local lFound        := .t.     
local aArea         := BCI->(getArea("BCI"))

if BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG) <> cCodOpe + cCodLdp + cCodPeg
    
    BCI->( dbGotop() )
    BCI->( dbSetOrder(1) ) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
    lFound := BCI->( msSeek(xFilial("BCI") + cCodOpe + cCodLdp + cCodPeg) )

endIf    

if lFound

    BXX->( dbSetOrder(6) )
    If BXX->( msSeek(xFilial("BXX") + cCodOpe + cCodPeg)) .And.;
        (BXX->BXX_TPNFS == VIAWSDL .or. !empty(BXX->BXX_PLSHAT))

        Conout('[HAT - PLS][' + DTOS(Date()) + '-' + Time() + '] PROTOCOLO DE ORIGEM DO HAT (' + cCodPeg + ')')
        PLHATBCI(4, BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)

    endif

Endif

BCI->(restArea(aArea))

Return
