#INCLUDE "TOTVS.CH"

Class GTPxCalcHrPeriodo
    Data aDias      as Array
    
    Data cSetor     as Character
    Data cColab 	as Character
    
    //Totalizadores
    Data nHrVolante as Numeric
    Data nHrForaVol as Numeric
    Data nHrPlan	as Numeric
    Data nHrIntTot  as Numeric
    Data nHrIntPgt	as Numeric
    Data nHrPagas	as Numeric
    Data nHrJorn	as Numeric
    Data nHrAdnNot	as Numeric
    Data nHrExtra	as Numeric
    Data nHrNegat	as Numeric
    Data nHrConf	as Numeric
    Data nHrNaoConf	as Numeric
    Data nSaldoHora as Numeric
    Data nHrPeriodo as Numeric
    Data nHrsDia    as Numeric
    
    Data cHrVolante as Character
    Data cHrForaVol as Character
    Data cHrPlan	as Character
    Data cHrIntTot  as Character
    Data cHrIntPgt	as Character
    Data cHrPagas	as Character
    Data cHrJorn	as Character
    Data cHrAdnNot	as Character
    Data cHrExtra	as Character
    Data cHrNegat	as Character
    Data cHrConf	as Character
    Data cHrNaoConf	as Character
    Data cSaldoHora as Character
    Data cHrPeriodo as Character
    Data cHrsDia    as Character
    
    
    Data nQtdDias   as Numeric
    Data nQtdInd	as Numeric
    Data nQtdFaltas	as Numeric
    Data nDsrDisp	as Numeric
    Data nDsrUtil	as Numeric
    
    
    Method New(cSetor,cColab) CONSTRUCTOR
    Method Reset()
    Method Destroy()
    Method SetHrsToStr()
    Method AddTrechos(dDtRef,cTpDia,;
                        dDtIni,cHrIni,cCodOri,cDesOri,;
                        dDtFim,cHrFim,cCodDes,cDesDes,;
                        lHrVol,lHrPagas,lConf)
    //Method DelTrecho(dDtRef)
    Method Calcula()
    
EndClass


//------------------------------------------------------------------------------
/*/{Protheus.doc} New
Funï¿½ï¿½o responsavel pela definiï¿½ï¿½o basica do objeto
@type method
@author jacomo.fernandes
@since 15/08/2019
@version 1.0
@param , character, (Descriï¿½ï¿½o do parï¿½metro)
@return Self, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Method New(cSetor,cColab) Class GTPxCalcHrPeriodo
Default cSetor  := ""
Default cColab  := ""

Self:aDias      := {}

Self:cSetor     := cSetor
Self:cColab     := cColab

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} Reset

@type method
@author jacomo.fernandes
@since 26/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method Reset() Class GTPxCalcHrPeriodo

Self:nHrVolante := 0
Self:nHrForaVol := 0
Self:nHrPlan	:= 0
Self:nHrIntTot  := 0
Self:nHrIntPgt	:= 0
Self:nHrPagas	:= 0
Self:nHrJorn	:= 0
Self:nHrAdnNot	:= 0
Self:nHrExtra	:= 0
Self:nHrNegat	:= 0
Self:nHrConf    := 0
Self:nHrNaoConf := 0
Self:nSaldoHora := 0
Self:nHrPeriodo := 0
Self:nHrsDia    := 0

Self:cHrVolante := ""
Self:cHrForaVol := ""
Self:cHrPlan	:= ""
Self:cHrIntTot  := ""
Self:cHrIntPgt	:= ""
Self:cHrPagas	:= ""
Self:cHrJorn	:= ""
Self:cHrAdnNot	:= ""
Self:cHrExtra	:= ""
Self:cHrNegat	:= ""
Self:cHrConf    := ""
Self:cHrNaoConf := ""
Self:cSaldoHora := ""
Self:cHrPeriodo := ""
Self:cHrsDia    := ""

Self:nQtdDias   := 0
Self:nQtdInd	:= 0
Self:nQtdFaltas	:= 0
Self:nDsrDisp   := 0
Self:nDsrUtil   := 0

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Funï¿½ï¿½o responsavel pela destruiï¿½ï¿½o do objeto
@type method
@author jacomo.fernandes
@since 15/08/2019
@version 1.0
@param , character, (Descriï¿½ï¿½o do parï¿½metro)
@return Self, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Method Destroy() Class GTPxCalcHrPeriodo
Local n1    := 0
For n1  := 1 To Len(Self:aDias)
    Self:aDias[n1]:Destroy()
Next
GtpDestroy(Self:aDias)
GtpDestroy(Self)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} 

@type method
@author jacomo.fernandes
@since 26/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Method SetHrsToStr() Class GTPxCalcHrPeriodo
//Sim!!!! É totalmente desnecessario essa conversão,
// mas foi necessário pq tinha um bug no inttohora quando numeros inteiros
Self:cHrVolante := IntToHora(Val(cValToChar(Self:nHrVolante )),3)
Self:cHrForaVol := IntToHora(Val(cValToChar(Self:nHrForaVol )),3)
Self:cHrPlan	:= IntToHora(Val(cValToChar(Self:nHrPlan    )),3)
Self:cHrIntTot  := IntToHora(Val(cValToChar(Self:nHrIntTot  )),3)
Self:cHrIntPgt	:= IntToHora(Val(cValToChar(Self:nHrIntPgt  )),3)
Self:cHrPagas	:= IntToHora(Val(cValToChar(Self:nHrPagas   )),3)
Self:cHrJorn	:= IntToHora(Val(cValToChar(Self:nHrJorn    )),3)
Self:cHrAdnNot	:= IntToHora(Val(cValToChar(Self:nHrAdnNot  )),3)
Self:cHrExtra	:= IntToHora(Val(cValToChar(Self:nHrExtra   )),3)
Self:cHrNegat	:= IntToHora(Val(cValToChar(Self:nHrNegat   )),3)
Self:cHrConf    := IntToHora(Val(cValToChar(Self:nHrConf    )),3)
Self:cHrNaoConf := IntToHora(Val(cValToChar(Self:nHrNaoConf )),3)
Self:cSaldoHora := IntToHora(Val(cValToChar(Self:nSaldoHora )),3)
Self:cHrPeriodo := IntToHora(Val(cValToChar(Self:nHrPeriodo )),3)
Self:cHrsDia    := IntToHora(Val(cValToChar(Self:nHrsDia    )),3)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddTrecho
metodo responsavel para preencher a estrutura dos dias
@type method
@author jacomo.fernandes
@since 15/08/2019
@version 1.0
@param dDtRef, date, (Descriï¿½ï¿½o do parï¿½metro)
@param cTpDia, character, (Descriï¿½ï¿½o do parï¿½metro)
@param dDtIni, date, (Descriï¿½ï¿½o do parï¿½metro)
@param cHrIni, character, (Descriï¿½ï¿½o do parï¿½metro)
@param cCodOri, character, (Descriï¿½ï¿½o do parï¿½metro)
@param dDtFim, date, (Descriï¿½ï¿½o do parï¿½metro)
@param cHrFim, character, (Descriï¿½ï¿½o do parï¿½metro)
@param cCodDes, character, (Descriï¿½ï¿½o do parï¿½metro)
@param lHrVol, logical, (Descriï¿½ï¿½o do parï¿½metro)

@param lHrPagas, logical, (Descriï¿½ï¿½o do parï¿½metro)
@return nil, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Method AddTrechos(dDtRef,cTpDia,;
                dDtIni,cHrIni,cCodOri,cDesOri,;
                dDtFim,cHrFim,cCodDes,cDesDes,;
                lHrVol,lHrPagas,lConf) Class GTPxCalcHrPeriodo

Local oCalcHrDia    := Nil
Local nPos          := 0

Default dDtRef      := dDataBase
Default cTpDia      := "1"
Default dDtIni      := dDataBase
Default cHrIni      := ""
Default cCodOri     := ""
Default cDesOri     := ""
Default dDtFim      := dDataBase
Default cHrFim      := ""
Default cCodDes     := ""
Default cDesDes     := ""
Default lHrVol      := .T.

Default lHrPagas    := .T.
Default lConf       := .T.

If Len(Self:aDias) > 0 .and. (nPos := aScan(Self:aDias,{|x| x:dDtRef == dDtRef } ) ) > 0
    oCalcHrDia  := Self:aDias[nPos]
Else
    oCalcHrDia  := GTPxCalcHrDia():New(dDtRef,Self:cSetor,Self:cColab)
    aAdd(Self:aDias,oCalcHrDia)
Endif

oCalcHrDia:AddTrechos(cTpDia,;
                        dDtIni,cHrIni,cCodOri,cDesOri,;
                        dDtFim,cHrFim,cCodDes,cDesDes,;
                        lHrVol,lHrPagas,lConf)

Return nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} Calcula

@type method
@author jacomo.fernandes
@since 15/08/2019
@version 1.0
@param , character, (Descriï¿½ï¿½o do parï¿½metro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Method Calcula() Class GTPxCalcHrPeriodo
Local oCalcDia      := nil
Local cPosFalta		:= cValToChar(Len(GTPXCBox('GQK_TPDIA'))+1)
Local n1            := 0
	
Self:Reset()

For n1 := 1 to Len(Self:aDias)
    oCalcDia  := Self:aDias[n1]
    oCalcDia:CalculaDia()
    
    Self:nHrVolante += oCalcDia:nHrVolante
    Self:nHrForaVol += oCalcDia:nHrForaVol
    Self:nHrPlan	+= oCalcDia:nHrPlantao
    Self:nHrIntTot  += oCalcDia:nHrIntTot
    Self:nHrIntPgt	+= oCalcDia:nHrIntPgt
    Self:nHrPagas	+= oCalcDia:nHrPagas
    Self:nHrJorn	+= oCalcDia:nHrJorn
    Self:nHrAdnNot	+= oCalcDia:nHrAdnNot
    Self:nHrExtra	+= oCalcDia:nHrExtra
    Self:nHrNegat	+= oCalcDia:nHrNegat
    Self:nHrConf	+= oCalcDia:nHrConf
    Self:nHrNaoConf	+= oCalcDia:nHrNaoConf
    
    Self:nQtdDias++
    
    If Empty(Self:nHrsDia)
        Self:nHrsDia := oCalcDia:nHrsDia
    Endif

    If oCalcDia:cTpDia == cPosFalta
        Self:nQtdFaltas++
    Endif

    If oCalcDia:cTpDia <> '5' .and. (oCalcDia:nDayOfWeek == 1  .or. oCalcDia:lFeriado )
        Self:nDsrDisp++
    Endif

    If oCalcDia:cTpDia == "6" //DSR
        Self:nDsrUtil++
    Endif

    If oCalcDia:cTpDia == "5" //Indisponivel rh (Ferias/3=Afastado/4=Demitido)
        Self:nQtdInd++
    Endif

Next


Self:nHrPeriodo	:= Self:nHrsDia*(Self:nQtdDias - Self:nDsrDisp - Self:nQtdInd)
Self:nSaldoHora := Self:nHrExtra - Self:nHrNegat


Self:SetHrsToStr()

Return 
