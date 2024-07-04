#INCLUDE "TOTVS.CH"

#DEFINE POS_TPDIA   01
#DEFINE POS_DTINI   02
#DEFINE POS_cHRINI  03
#DEFINE POS_nHRINI  04
#DEFINE POS_CODORI  05
#DEFINE POS_DESORI  06
#DEFINE POS_DTFIM   07
#DEFINE POS_cHRFIM  08
#DEFINE POS_nHRFIM  09
#DEFINE POS_CODDES  10
#DEFINE POS_DESDES  11
#DEFINE POS_HRVOL   12
#DEFINE POS_lHRPAG  13
#DEFINE POS_CONF    14
#DEFINE POS_nHRPAG  15
#DEFINE POS_nHRFVO  16

Class GTPxCalcHrDia
    Data aTrechos   as Array
    
    Data dDtRef     as Date
    Data cTpDia     as Character
    Data nDayOfWeek as Numeric
    Data lFeriado	as Logical

    Data cSetor     as Character
    Data cColab     as Character
    
    Data cFilFunc   as Character
    Data cMatricula as Character
    Data cTurno     as Character
    Data cHrMaxInt	as Character
    Data nHrMaxInt	as Numeric

    Data nHrIniAdn  as Numeric
    Data nHrFimAdn  as Numeric
    Data nMinutAdn  as Numeric

    Data dData_1E   as Date
    Data cHora_1E   as Character
    Data nHora_1E   as Numeric
    Data cCodLoc_1E as Character
    Data cDesLoc_1E as Character

    Data dData_1S   as Date
    Data cHora_1S   as Character
    Data nHora_1S   as Numeric
    Data cCodLoc_1S as Character
    Data cDesLoc_1S as Character

    Data dData_2E   as Date
    Data cHora_2E   as Character
    Data nHora_2E   as Numeric
    Data cCodLoc_2E as Character
    Data cDesLoc_2E as Character

    Data dData_2S   as Date
    Data cHora_2S   as Character
    Data nHora_2S   as Numeric
    Data cCodLoc_2S as Character
    Data cDesLoc_2S as Character

    Data cHrVolante as Character
    Data nHrVolante as Numeric
    
    Data cHrForaVol as Character
    Data nHrForaVol as Numeric
    
    Data cHrPlantao	as Character
    Data nHrPlantao	as Numeric
    
    Data cHrIntTot  as Character
    Data nHrIntTot  as Numeric
    
    Data cHrIntPgt	as Character
    Data nHrIntPgt	as Numeric
    
    Data cHrPagas	as Character
    Data nHrPagas	as Numeric
    
    Data cHrJorn	as Character
    Data nHrJorn	as Numeric
    
    Data cHrAdnNot	as Character
    Data nHrAdnNot	as Numeric
    
    Data cHrsDia	as Character
    Data nHrsDia	as Numeric
    
    Data cHrExtra	as Character
    Data nHrExtra	as Numeric
    
    Data cHrNegat	as Character
    Data nHrNegat	as Numeric

    Data cHrConf	as Character
    Data nHrConf	as Numeric

    Data cHrNaoConf	as Character
    Data nHrNaoConf	as Numeric


    Method New(dDataRef,cSetor,cColab) CONSTRUCTOR
    Method Reset()
    Method Destroy()
    Method SetDadosRh()
    Method CheckFeriado()
    Method AddTrechos(cTpDia,dDtIni,cHrIni,cCodOri,cDesOri,dDtFim,cHrFim,cCodDes,cDesDes,;
                        lHrVol,lHrPagas,lConf,cHrIniSrv,cHrFimSrv)
    Method CalculaDia()
    Method SetApontamentos()
    Method CalcHorasPagas()
    Method CalcJornadaTrabalho()
    Method CalcAdicionalNoturno()
    Method CalculaSaldo()
    Method CalculaIntervaloPago()
    Method SetHrsToStr()
    Method ExistMarcacao(cTpMarc)
    Method GetValorMarcacao(cTpMarc,cValor)
    
EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} 

@type method
@author jacomo.fernandes
@since 26/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method New(dDataRef, cSetor, cColab) Class GTPxCalcHrDia
Default dDataRef    := dDataBase
Default cSetor      := ""
Default cColab      := ""

Self:aTrechos   := {}
Self:dDtRef     := dDataRef
Self:nDayOfWeek := Dow(dDataRef)
Self:cSetor     := cSetor
Self:cColab     := cColab

Self:cFilFunc   := xFilial('SRA')
Self:cMatricula := ""
Self:cHrMaxInt	:= "05:00"
Self:cTurno     := ""
Self:nHrMaxInt	:= HoraToInt("05:00")
Self:cHrsDia	:= "07:20"
Self:nHrsDia    := HoraToInt("07:20")
Self:nHrIniAdn  := SuperGetMV("MV_INIHNOT",,22.00)
Self:nHrFimAdn  := SuperGetMV("MV_FIMHNOT",,05.00)
Self:nMinutAdn  := 60
Self:lFeriado   := .F.

Self:Reset()
Self:SetDadosRh()
Self:CheckFeriado()

Return Self

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
Method Reset() Class GTPxCalcHrDia

Self:cTpDia     := ""

Self:dData_1E   := Stod('')
Self:cHora_1E   := ""
Self:nHora_1E   := 0
Self:cCodLoc_1E := ""
Self:cDesLoc_1E := ""

Self:dData_1S   := Stod('')
Self:cHora_1S   := ""
Self:nHora_1S   := 0
Self:cCodLoc_1S := ""
Self:cDesLoc_1S := ""

Self:dData_2E   := Stod('')
Self:cHora_2E   := ""
Self:nHora_2E   := 0
Self:cCodLoc_2E := ""
Self:cDesLoc_2E := ""

Self:dData_2S   := Stod('')
Self:cHora_2S   := ""
Self:nHora_2S   := 0
Self:cCodLoc_2S := ""
Self:cDesLoc_2S := ""

Self:cHrVolante := ""
Self:cHrForaVol := ""
Self:cHrPlantao	:= ""
Self:cHrIntTot  := ""
Self:cHrIntPgt	:= ""
Self:cHrPagas	:= ""
Self:cHrJorn	:= ""
Self:cHrAdnNot	:= ""
Self:cHrExtra	:= ""
Self:cHrNegat	:= ""
Self:cHrConf	:= ""
Self:cHrNaoConf	:= ""

Self:nHrVolante := 0
Self:nHrForaVol := 0
Self:nHrPlantao	:= 0
Self:nHrIntTot  := 0
Self:nHrIntPgt	:= 0
Self:nHrPagas	:= 0
Self:nHrJorn	:= 0
Self:nHrAdnNot	:= 0
Self:nHrExtra	:= 0
Self:nHrNegat	:= 0
Self:nHrConf	:= 0
Self:nHrNaoConf	:= 0


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
Method Destroy() Class GTPxCalcHrDia

GtpDestroy(Self:aTrechos)
GtpDestroy(Self)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetDadosRh

@type method
@author jacomo.fernandes
@since 29/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method SetDadosRh() Class GTPxCalcHrDia
Local cAliasTmp := GetNextAlias()


BeginSql Alias cAliasTmp
    Select 
        GYT.GYT_CODIGO,
        GYT.GYT_HRMINT,
        GYG_FILSRA,
        GYG_FUNCIO,
        RA_TNOTRAB,
        R6_INIHNOT,
        R6_FIMHNOT,
        R6_MINHNOT, 
        (Case (PJ_HRTOTAL - (PJ_HRSINT1 + PJ_HRSINT2 + PJ_HRSINT3))
            when 0 then RA_HRSDIA
            ELSE (PJ_HRTOTAL - (PJ_HRSINT1 + PJ_HRSINT2 + PJ_HRSINT3))
        End) AS HORASTRAB
    From %Table:GYT% GYT
        Inner Join %Table:GY2% GY2 on
            GY2.GY2_FILIAL = GYT.GYT_FILIAL
            AND GY2.GY2_SETOR = GYT.GYT_CODIGO
            AND GY2.GY2_CODCOL = %Exp:Self:cColab%
            AND GY2.%NotDel%
        INNER JOIN %Table:GYG% GYG ON
            GYG.GYG_FILIAL = %Exp:FWxFilial('GYG')%
            AND GYG.GYG_CODIGO = GY2.GY2_CODCOL
            AND GYG.%NotDel%
        INNER JOIN %Table:SRA% SRA ON
            SRA.RA_FILIAL = GYG.GYG_FILSRA
            AND SRA.RA_MAT = GYG.GYG_FUNCIO
            AND SRA.%NotDel%
        INNER JOIN %Table:SR6% SR6 ON
            SR6.R6_FILIAL = %Exp:FWxFilial('SR6')%
            AND SR6.R6_TURNO = SRA.RA_TNOTRAB
            AND SR6.%NotDel%
        INNER JOIN %Table:SPJ% SPJ ON
            SPJ.PJ_FILIAL = SR6.R6_FILIAL
            AND SPJ.PJ_TURNO = SR6.R6_TURNO
            AND SPJ.PJ_DIA = %Exp:cValToChar(Self:nDayOfWeek)%
            AND SPJ.%NotDel%
    Where
        GYT.GYT_FILIAL = %xFilial:GYT%
        AND GYT.GYT_CODIGO = %Exp:Self:cSetor%
        AND GYT.%NotDel%
EndSql

If (cAliasTmp)->(!EOF())
    Self:cFilFunc   := (cAliasTmp)->GYG_FILSRA
    Self:cMatricula := (cAliasTmp)->GYG_FUNCIO
    Self:cHrMaxInt  := Transform((cAliasTmp)->GYT_HRMINT,"@R 99:99")
    Self:nHrMaxInt  := HoraToInt(Self:cHrMaxInt)
    Self:nHrsDia    := __Hrs2Min((cAliasTmp)->HORASTRAB)/60
    Self:nHrIniAdn  := (cAliasTmp)->R6_INIHNOT
    Self:nHrFimAdn  := (cAliasTmp)->R6_FIMHNOT
    Self:nMinutAdn  := (cAliasTmp)->R6_MINHNOT
    Self:cTurno     := (cAliasTmp)->RA_TNOTRAB
Endif

(cAliasTmp)->(DbCloseArea())

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckFeriado

@type method
@author jacomo.fernandes
@since 28/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method CheckFeriado() Class GTPxCalcHrDia
Self:lFeriado   := GTPxGetFer(Self:dDtRef, Self:dDtRef, Self:cSetor, Self:cFilFunc,.T.)
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
Method AddTrechos(cTpDia,dDtIni,cHrIni,cCodOri,cDesOri,dDtFim,cHrFim,cCodDes,cDesDes,;
                    lHrVol,lHrPagas,lConf,cHrIniSrv,cHrFimSrv) Class GTPxCalcHrDia

Local nHrIni        := 0
Local nHrFim        := 0
Local nHrIniSrv     := 0
Local nHrFimSrv     := 0
Local nHrPagas      := 0
Local nHrForaVol    := 0

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

Default cHrIniSrv   := ""
Default cHrFimSrv   := ""

If DtoS(dDtIni)+cHrIni > DtoS(dDtFim)+cHrFim
    dDtFim++
Endif

cHrIni      := Transform(cHrIni, "@R 99:99")
cHrFim      := Transform(cHrFim, "@R 99:99")
nHrIni      := HoraToInt(cHrIni)
nHrFim      := HoraToInt(cHrFim)
nHrIniSrv   := HoraToInt(cHrIniSrv)
nHrFimSrv   := HoraToInt(cHrFimSrv)

If nHrIni > nHrIniSrv
    nHrForaVol := (24-nHrIni) + nHrIniSrv
Else
    nHrForaVol := (nHrIniSrv - nHrIni)
Endif

If nHrFim >= nHrFimSrv
    nHrForaVol += (nHrFim - nHrFimSrv)
Else
    nHrForaVol += (24-nHrFimSrv) + nHrFim //(nHrIniSrv)
Endif

If lHrPagas
    nHrPagas    := GxElapseTime(dDtIni,nHrIni,dDtFim,nHrFim)
    aAdd(Self:aTrechos, {   cTpDia,;
                            dDtIni,cHrIni,nHrIni,cCodOri,cDesOri,;
                            dDtFim,cHrFim,nHrFim,cCodDes,cDesDes,;
                            lHrVol,lHrPagas,lConf,nHrPagas,nHrForaVol;
                        } )
Endif
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
Method CalculaDia() Class GTPxCalcHrDia

//Reinicia as Propriedades do objeto
Self:Reset()

//Realizo a separação das horas em marcações (1E/1S/2E/2S) 
Self:SetApontamentos()

//Calcula Horas Pagas de acordo com as marcações
Self:CalcHorasPagas()

//Calcula Jornada de Trabalho de acordo com as marcações
Self:CalcJornadaTrabalho()

//Calcula Hora Adicional Noturno de acordo com as marcações
Self:CalcAdicionalNoturno()

//Calcula as horas Extras ou Negativas
Self:CalculaSaldo()

//Calcula as horas Extras ou Negativas
Self:CalculaIntervaloPago()

//Realiza a conversão das horas em string
Self:SetHrsToStr()

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} SetApontamentos

@type method
@author jacomo.fernandes
@since 26/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
/*/
//------------------------------------------------------------------------------
Method SetApontamentos() Class GTPxCalcHrDia
Local aApont        := {}
Local aApontInner   := {}
Local n1            := 0
Local n2            := 0

Local dDtIniAtu     := ""
Local nHrIniAtu     := ""
Local cCodOriAtu    := ""
Local cDesOriAtu    := ""

Local dDtFimAnt     := ""
Local nHrFimAnt     := ""
Local cCodDesAnt    := ""
Local cDesDesAnt    := ""

Local nIntervNew       := 0
Local nIntervOld       := 0
Local nDifHrInt     := 0
Local lIsGtpa302    := FWISINCALLSTACK("GTPA302")
Local cTPSdIA       := IIF(lIsGtpa302,'1/2/3','1/2')
Local cTPSdIA1      := IIF(lIsGtpa302,'3','2')

//Por garantia, ordeno os trechos informados por data+hora
aSort(Self:aTrechos,,,{|x,y| GxDtHr2Str(x[POS_DTINI],x[POS_nHRINI])  < GxDtHr2Str(y[POS_DTINI],y[POS_nHRINI]) })

For n1  := 1 To Len(Self:aTrechos)
    If Empty(Self:cTpDia)
        If !(Self:aTrechos[n1][POS_TPDIA] $ cTPSdIA)
            Self:cTpDia := Self:aTrechos[n1][POS_TPDIA]
            Loop
        Else
            Self:cTpDia := "1"
        Endif
    Endif
            
    //Se Horas Volantes, soma horas pagas no totalizador de horas volante
        
    Self:nHrForaVol +=  Self:aTrechos[n1][POS_nHRFVO]
    
    If Self:aTrechos[n1][POS_HRVOL] .AND. !(Self:aTrechos[n1][POS_TPDIA] $ cTPSdIA1)
        Self:nHrVolante += (Self:aTrechos[n1][POS_nHRPAG] - Self:aTrechos[n1][POS_nHRFVO])
    Else //Se não, soma no totalizador fora do volanta
        Self:nHrForaVol += Self:aTrechos[n1][POS_nHRPAG]
    Endif
    
    //Se plantão, soma no totalizador de plantão
    If Self:aTrechos[n1][POS_TPDIA] $ cTPSdIA1
        Self:nHrPlantao += Self:aTrechos[n1][POS_nHRPAG]
    Endif

    If Self:aTrechos[n1][POS_CONF]
        Self:nHrConf += Self:aTrechos[n1][POS_nHRPAG]
    Else
        Self:nHrNaoConf += Self:aTrechos[n1][POS_nHRPAG]
    Endif    

    //Se Primeira Linha, pega os dados de origem
    If n1 == 1 
        aAdd(aApont,{;
                        Self:aTrechos[n1][POS_DTINI],;
                        Self:aTrechos[n1][POS_nHRINI],;
                        Self:aTrechos[n1][POS_CODORI],;
                        Self:aTrechos[n1][POS_DESORI];
                    })
    Endif
    
    //Se não for primeira linha, verifica os intervalos entre trechos
    If n1 > 1
        dDtIniAtu     := Self:aTrechos[n1][POS_DTINI]
        nHrIniAtu     := Self:aTrechos[n1][POS_nHRINI]
        cCodOriAtu    := Self:aTrechos[n1][POS_CODORI]
        cDesOriAtu    := Self:aTrechos[n1][POS_DESORI]

        dDtFimAnt     := Self:aTrechos[n1-1][POS_DTFIM]
        nHrFimAnt     := Self:aTrechos[n1-1][POS_nHRFIM]
        cCodDesAnt    := Self:aTrechos[n1-1][POS_CODDES]
        cDesDesAnt    := Self:aTrechos[n1-1][POS_DESDES]
        
        nIntervNew := GxElapseTime(dDtFimAnt,nHrFimAnt,dDtIniAtu,nHrIniAtu)

        If nIntervNew > 0

            Self:nHrIntTot += nIntervNew

            If nIntervNew > nIntervOld
                nIntervOld		:= nIntervNew
                
                If nIntervNew > Self:nHrMaxInt
                    nDifHrInt := nIntervNew-Self:nHrMaxInt
                    
                    If (nDifHrInt + nHrFimAnt) > HoraToInt("23:59")
                        dDtFimAnt := dDtFimAnt+1
                        nHrFimAnt := (nDifHrInt + nHrFimAnt) - 24
                    Else
                        nHrFimAnt := (nDifHrInt + nHrFimAnt)
                    Endif
                    
                Endif
                            
                If Len(aApontInner) == 0
                    aAdd(aApontInner,{dDtFimAnt,nHrFimAnt,cCodDesAnt,cDesDesAnt})
                    aAdd(aApontInner,{dDtIniAtu,nHrIniAtu,cCodOriAtu,cDesOriAtu})
                Else
                    aApontInner[1][1] := dDtFimAnt  //Data de chegada do ultimo trecho
                    aApontInner[1][2] := nHrFimAnt  //Hora de chegada do ultimo trecho
                    aApontInner[1][3] := cCodDesAnt //Hora de chegada do ultimo trecho
                    aApontInner[1][4] := cDesDesAnt //Hora de chegada do ultimo trecho
                    
                    aApontInner[2][1] := dDtIniAtu  //Data de Saida do trecho atual
                    aApontInner[2][2] := nHrIniAtu  //Hora de Saida do trecho atual
                    aApontInner[2][3] := cCodOriAtu //Hora de Saida do trecho atual
                    aApontInner[2][4] := cDesOriAtu //Hora de chegada do ultimo trecho
                    
                Endif                    

            Endif

        Endif
        
    Endif
    
    //Se Ultima Linha, pega os dados de Destino
    If n1 == Len(Self:aTrechos) 
        aAdd(aApont,{;
                        Self:aTrechos[n1][POS_DTFIM],;
                        Self:aTrechos[n1][POS_nHRFIM],;
                        Self:aTrechos[n1][POS_CODDES],;
                        Self:aTrechos[n1][POS_DESDES];
                    })
    Endif


Next


//Caso possuir intervalo entre os trechos, adiciono na variavel aApont os trechos
For n2 := 1 to Len(aApontInner)
    aAdd(aApont,{aApontInner[n2][1],aApontInner[n2][2],aApontInner[n2][3],aApontInner[n2][4]})
Next

//Como é realizado a inclusão dos intervalos após a inclusão do inicio e fim
//Reordeno a variavel pela Data+Hora
ASORT(aApont,,, { |x, y| GxDtHr2Str(x[1],x[2]) < GxDtHr2Str(y[1],y[2])  } ) 


For n2 := 1 to Len(aApont)
    If n2 == 1      //Primeira Entrada
        Self:dData_1E   := aApont[n2,1]
        Self:cHora_1E   := IntToHora(aApont[n2,2])
        Self:nHora_1E   := aApont[n2,2]
        Self:cCodLoc_1E := aApont[n2,3]
        Self:cDesLoc_1E := aApont[n2,4]
    ElseIf n2 == 2  //Primeira Saida
        Self:dData_1S   := aApont[n2,1]
        Self:cHora_1S   := IntToHora(aApont[n2,2])
        Self:nHora_1S   := aApont[n2,2]
        Self:cCodLoc_1S := aApont[n2,3]
        Self:cDesLoc_1S := aApont[n2,4]
    ElseIf n2 == 3  //Segunda Entrada
        Self:dData_2E   := aApont[n2,1]
        Self:cHora_2E   := IntToHora(aApont[n2,2])
        Self:nHora_2E   := aApont[n2,2]
        Self:cCodLoc_2E := aApont[n2,3]
        Self:cDesLoc_2E := aApont[n2,4]
    Else            //Segunda Saida
        Self:dData_2S   := aApont[n2,1]
        Self:cHora_2S   := IntToHora(aApont[n2,2])
        Self:nHora_2S   := aApont[n2,2]
        Self:cCodLoc_2S := aApont[n2,3]
        Self:cDesLoc_2S := aApont[n2,4]
    Endif
Next
   
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
Method SetHrsToStr() Class GTPxCalcHrDia

Self:cHrVolante := IntToHora(Self:nHrVolante   )
Self:cHrForaVol := IntToHora(Self:nHrForaVol   )
Self:cHrPlantao	:= IntToHora(Self:nHrPlantao   )
Self:cHrIntTot  := IntToHora(Self:nHrIntTot    )
Self:cHrIntPgt	:= IntToHora(Self:nHrIntPgt    )
Self:cHrPagas	:= IntToHora(Self:nHrPagas	   )
Self:cHrJorn	:= IntToHora(Self:nHrJorn	   )
Self:cHrAdnNot	:= IntToHora(Self:nHrAdnNot    )
Self:cHrExtra	:= IntToHora(Self:nHrExtra	   )
Self:cHrNegat	:= IntToHora(Self:nHrNegat	   )
Self:cHrConf	:= IntToHora(Self:nHrConf	   )
Self:cHrNaoConf	:= IntToHora(Self:nHrNaoConf   )

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
Method CalcHorasPagas() Class GTPxCalcHrDia

If !Empty(Self:dData_1E) .and. !Empty(Self:cHora_1E) .and. !Empty(Self:dData_1S) .and. !Empty(Self:cHora_1S)
    Self:nHrPagas += GxElapseTime(Self:dData_1E,Self:nHora_1E,Self:dData_1S,Self:nHora_1S)
Endif

If !Empty(Self:dData_2E) .and. !Empty(Self:cHora_2E) .and. !Empty(Self:dData_2S) .and. !Empty(Self:cHora_2S)
    Self:nHrPagas += GxElapseTime(Self:dData_2E,Self:nHora_2E,Self:dData_2S,Self:nHora_2S)
Endif


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
Method CalcJornadaTrabalho() Class GTPxCalcHrDia
Local dDtFim    := Self:dData_1S
Local nHrFim    := Self:nHora_1S

If !Empty(Self:dData_2S) .and. !Empty(Self:cHora_2S)
    dDtFim    := Self:dData_2S
    nHrFim    := Self:nHora_2S
Endif

Self:nHrJorn := GxElapseTime(Self:dData_1E,Self:nHora_1E,dDtFim,nHrFim)

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
Method CalcAdicionalNoturno() Class GTPxCalcHrDia
Local nHrAdn    := 0
If !Empty(Self:dData_1E) .and. !Empty(Self:cHora_1E) .and. !Empty(Self:dData_1S) .and. !Empty(Self:cHora_1S)
    nHrAdn  :=  DataHora2Not(	Self:dData_1E		                ,;	//1a Data
                                Val(StrTran(Self:cHora_1E,':','.'))	,;	//1a Hora
                                Self:dData_1S                       ,;	//2a Data
                                Val(StrTran(Self:cHora_1S,':','.')) ,;	//2a Hora
                                Self:dData_1E 		                ,;	//Data Inicial do Adicional Noturno
                                Self:nHrIniAdn  	                ,;	//Inicio do Adicional Noturno
                                Self:nHrFimAdn                      ,;	//Final do Adicional Noturno
                                Self:nMinutAdn                      ;	//Minutos do Adicional Noturno
                            )[1]

    Self:nHrAdnNot	+= __Hrs2Min(nHrAdn)/60
Endif

If !Empty(Self:dData_2E) .and. !Empty(Self:cHora_2E) .and. !Empty(Self:dData_2S) .and. !Empty(Self:cHora_2S)
    nHrAdn	:= DataHora2Not(	Self:dData_2E		                ,;	//1a Data
                                Val(StrTran(Self:cHora_2E,':','.')) ,;	//1a Hora
                                Self:dData_2S                       ,;	//2a Data
                                Val(StrTran(Self:cHora_2S,':','.')) ,;	//2a Hora
                                Self:dData_2E                       ,;	//Data Inicial do Adicional Noturno
                                Self:nHrIniAdn                      ,;	//Inicio do Adicional Noturno
                                Self:nHrFimAdn                      ,;	//Final do Adicional Noturno
                                Self:nMinutAdn                      ;	//Minutos do Adicional Noturno
                            )[1]

    Self:nHrAdnNot	+= __Hrs2Min(nHrAdn)/60
Endif       

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CalculaSaldo

@type method
@author jacomo.fernandes
@since 26/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method CalculaSaldo() Class GTPxCalcHrDia
//Diferente de Indisponivel RH ou DSR
If !(Self:cTpDia $ "5/6") 
    If Self:nHrPagas > Self:nHrsDia
        Self:nHrExtra := Self:nHrPagas - Self:nHrsDia
    ElseIf Self:nHrPagas < Self:nHrsDia
        Self:nHrNegat := Self:nHrsDia - Self:nHrPagas
    Endif
Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CalculaIntervaloPago

@type method
@author jacomo.fernandes
@since 27/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method CalculaIntervaloPago() Class GTPxCalcHrDia
Local nIntDesc  := 0

If !Empty(Self:dData_2E) .And. !Empty(Self:cHora_2E)
    nIntDesc  := GxElapseTime(Self:dData_1S,Self:nHora_1S,Self:dData_2E,Self:nHora_2e)
Endif

Self:nHrIntPgt := Self:nHrIntTot - nIntDesc

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ExistMarcacao

@type method
@author jacomo.fernandes
@since 27/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method ExistMarcacao(cTpMarc) Class GTPxCalcHrDia
Local lRet      := .T.

Default cTpMarc := "1E"

Do Case
    Case cTpMarc == "1E"
        lRet := !Empty(Self:dData_1E)
    Case cTpMarc == "1S"
        lRet := !Empty(Self:dData_1S)
    Case cTpMarc == "2E"
        lRet := !Empty(Self:dData_2E)
    Case cTpMarc == "2S"
        lRet := !Empty(Self:dData_2E)
EndCase

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetValorMarcacao

@type method
@author jacomo.fernandes
@since 27/08/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Method GetValorMarcacao(cTpMarc,cValor) Class GTPxCalcHrDia
Local uVal  := NIL

Do Case
    Case cTpMarc == "1E"
        If cValor == "Data"
            uVal := Self:dData_1E
        ElseIf cValor == "nHora"
            uVal := Self:nHora_1E
        ElseIf cValor == "cHora"
            uVal := Self:cHora_1E
        Endif
    Case cTpMarc == "1S"
        If cValor == "Data"
            uVal := Self:dData_1S
        ElseIf cValor == "nHora"
            uVal := Self:nHora_1S
        ElseIf cValor == "cHora"
            uVal := Self:cHora_1S
        Endif
    Case cTpMarc == "2E"
        If cValor == "Data"
            uVal := Self:dData_2E
        ElseIf cValor == "nHora"
            uVal := Self:nHora_2E
        ElseIf cValor == "cHora"
            uVal := Self:cHora_2E
        Endif
    Case cTpMarc == "2S"
        If cValor == "Data"
            uVal := Self:dData_2S
        ElseIf cValor == "nHora"
            uVal := Self:nHora_2S
        ElseIf cValor == "cHora"
            uVal := Self:cHora_2S
        Endif
EndCase


Return uVal
