#INCLUDE 'TOTVS.CH'

Function GxDtHr2Str(dDt,nHr)
Local cRet  := ""
Default dDt := dDataBase
Default nHr := 0

cRet := DtoS(dDt)+StrTran(IntToHora(nHr,4),':','')

Return cRet

Function GxElapseTime(dDtIni,nHrIni,dDtFim,nHrFim)
Local nRet      := 0
Local nQtdDias  := 0
Local nHoras    := 0
Local lViraDia  := .F.

Default dDtIni  := dDataBase
Default nHrIni  := 0
Default dDtFim  := dDataBase
Default nHrFim  := 0

lViraDia  := nHrFIm < nHrIni

nHoras := If(lViraDia, nHrFIm+24 ,nHrFIm )- nHrIni
nQtdDias := ( dDtFim - dDtIni ) + If(lViraDia, -1,0)

nRet    := (nQtdDias*24)+nHoras

Return nRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} GxVldDtHr

@type Function
@author jacomo.fernandes
@since 07/12/2019
@version 1.0
@param dDtIni, date, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxVldData(dDtIni,dDtFim,cErro)
Local lRet := .T.

Default dDtIni  := StoD('')
Default dDtFim  := StoD('')
Default cErro   := ""


If !Empty(dDtIni) .and. !Empty(dDtFim)

    If dDtIni > dDtFim
        lRet    := .F.
        cErro   := "Data inicial maior que a data final"
    Endif
    
Endif

Return lRet 