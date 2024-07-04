#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA285.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA285()
Função de reaplicação de descontos em massa
@author  Jacomo Abenathar Fernandes Lisa
@since   27/06/17
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA285()
Local aArea     := GetArea()

If Pergunte('GTPA285',.T.)
    FwMsgRun(, {||RetQryGQW(),STR0003,STR0004}) //"Recalculo de descontos"  ##'Recalculando descontos...' 
Endif
RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} RetQryGQW()
description
@author  jacomo.fernandes
@since   29/06/17
@version P12
/*/
//-------------------------------------------------------------------
Static Function RetQryGQW()
Local cAliasGQW := GetNextAlias()
Local oModelGQW := FwLoadModel('GTPA283')
Local oModelGQY := NIL
Local aLotes    := {}    
Local cTxt      := ""
Local cMsgOk    := ""
Local cMsgErro  := ""
Local cLotErro  := ""
Local cLotOK    := ""
Local n1        := 0
Local nValor    := 0
Local nCont     := 0
oModelGQW:SetOperation(MODEL_OPERATION_UPDATE)
/*
MV_PAR01    --> GQW_CODCLI  --> Cliente de
MV_PAR02    --> GQW_CODLOJ  --> Loja de
MV_PAR03    --> GQW_CODCLI   --> Cliente até
MV_PAR04    --> GQW_CODLOJ   --> Loja até
MV_PAR05    --> GIC_CODIGO  --> Requisição de:
MV_PAR06    --> GIC_CODIGO  --> Requisição Até
MV_PAR07    --> GQW_DATEMI  --> Data de Emissão de:
MV_PAR08    --> GQW_DATEMI  --> Data de Emissão até:
*/
Pergunte('GTPA285',.F.)

BeginSql alias cAliasGQW
    Select
        R_E_C_N_O_ as RECNO
    From 
        %Table:GQW% GQW
    Where
        GQW.GQW_FILIAL = %xFilial:GQW%  AND
        GQW.GQW_CODCLI BETWEEN %Exp:MV_PAR01%	AND %Exp:MV_PAR03%	AND
        GQW.GQW_CODLOJ BETWEEN %Exp:MV_PAR02%	AND %Exp:MV_PAR04%	AND
        GQW.GQW_CODIGO BETWEEN %Exp:MV_PAR05%	AND %Exp:MV_PAR06%	AND 
        GQW.GQW_DATEMI BETWEEN %Exp:MV_PAR07%	AND %Exp:MV_PAR08%	AND 
        GQW.GQW_STATUS = '2' AND
        GQW.%NotDel%
EndSql

If (cAliasGQW)->(!EOF())

    While (cAliasGQW)->(!EOF())
        GQW->( DbGoTo( (cAliasGQW)->RECNO ) )
        If oModelGQW:Activate()
            nValor := GA285Recal(oModelGQW)
            IF !Empty(GQW->GQW_CODLOT) .and. (aScan(aLotes,GQW->GQW_CODLOT) == 0)
                If Len(aLotes) > 0
                    for nCont := 1 to Len(aLotes)
                        IF aScan(aLotes[nCont],GQW->GQW_CODLOT) == 0
                            aAdd(aLotes,{GQW->GQW_CODLOT,nValor})
                        EndIf
                    next
                Else
                    aAdd(aLotes,{GQW->GQW_CODLOT,nValor})
                EndIf
            Endif

            If !oModelGQW:VldData() .or. !oModelGQW:CommitData()
                cMsgErro+= GQW->GQW_CODIGO+ " ->"+Alltrim(oModelGQW:GetErrorMessage()[6]) +Chr(13)+Chr(10)
            Else
                cMsgOk  += GQW->GQW_CODIGO +Chr(13)+Chr(10)
            Endif
            oModelGQW:DeActivate()
        Endif
        (cAliasGQW)->(DbSkip())
    End


    If Len(aLotes) > 0
        If ValType( oModelGQY) == "U"
            oModelGQY := FwLoadModel('GTPA284')
            oModelGQY:SetOperation(MODEL_OPERATION_UPDATE)
        Endif
        For n1 := 1 to Len(aLotes)
            If GQY->(DbSeek(xFilial('GQY')+aLotes[N1,1]))
                IF (oModelGQY:Activate())
                    nValTot := Ga285RetTot(aLotes[N1,1])
                    oModelGQY:GetModel('FIELDGQY'):SetValue('GQY_TOTAL', nValTot )
                    oModelGQY:GetModel('FIELDGQY'):SetValue('GQY_TOTDES', nValTot - (nValTot * (1-(aLotes[N1,2]/100))) )
                    
                    If !oModelGQY:VldData() .or. !oModelGQY:CommitData()
                        cLotErro+= aLotes[N1,1] +" ->"+Alltrim(oModelGQY:GetErrorMessage()[6]) +Chr(13)+Chr(10)
                    Else
                        cLotOk  += aLotes[N1,1] +Chr(13)+Chr(10)
                    Endif
                    oModelGQY:DeActivate()
                ENDIF

            Endif
        Next
        oModelGQY:Destroy()
    Endif



    oModelGQW:Destroy()
    If !Empty(cMsgOk)
        cTxt +=STR0005+Chr(13)+Chr(10)+ cMsgOk +Chr(13)+Chr(10) //"Requisições recalculadas com sucesso:"
    Endif
    If !Empty(cMsgErro)
        cTxt += STR0006+Chr(13)+Chr(10) +cMsgErro    +Chr(13)+Chr(10)//"Requisições que apresentaram erros:"
    Endif
    If !Empty(cLotOk)
        cTxt += STR0007+Chr(13)+Chr(10) +cLotOk +Chr(13)+Chr(10) //"Lotes que foram alterados de acordo com a atualização das requisições:" 
    Endif
    If !Empty(cLotErro)
        cTxt +=STR0008  +Chr(13)+Chr(10) +cLotErro +Chr(13)+Chr(10)//"Lotes que apresentaram erros:"
    Endif
    Aviso(STR0003, cTxt,{"Ok"},3) //"Recalculo de Descontos"
ELSE
    FwAlertWarning(STR0009,STR0010)//"Não foram encontrados requisições com essas informações"##"Atenção!!!"
Endif

(cAliasGQW)->(dbCloseArea())
GTPDestroy(aLotes)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Ga285RetTot
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function Ga285RetTot(cLote)
Local nRet  := 0
Local cAliasGQW := GetNextAlias()
BeginSql Alias cAliasGQW
    Select
        Sum( GQW.GQW_TOTAL) as Total
    From 
        %Table:GQW% GQW
    Where
        GQW.GQW_FILIAL = %xFilial:GQW% And
        GQW.GQW_CODLOT = %Exp:cLote% And
        GQW.%NotDel%
EndSql

If (cAliasGQW)->(!Eof())
    nRet := (cAliasGQW)->Total
Endif
(cAliasGQW)->(dbCloseArea())
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GA285Recal()
Função de aplicação de descontos por requisição
@author  Jacomo Abenathar Fernandes Lisa
@since   27/06/17
@version P12
/*/
//-------------------------------------------------------------------
Function GA285Recal(oModel)
Local n1        := 0
Local nValor    := 0
Local oModelGQW := oModel:GetModel('FIELDGQW')
Local oModelGIC := oModel:GetModel('GRIDGIC')

For n1:= 1 to oModelGIC:Length()
    If !oModelGIC:IsDeleted(n1)
        oModelGIC:GoLine(n1)
        nValor := GA285Desc(oModelGIC)
    Endif
Next
oModelGIC:GoLine(1)

If Empty(oModelGQW:GetValue('GQW_CODLOT')) .and. oModelGQW:GetValue('GQW_CONFER') == '1'
    oModelGQW:SetValue('GQW_CONFER','2')
Endif

GTPReCalc(oModelGIC)

If FwIsInCall('GTPA283')
    FwAlertSuccess(STR0001,STR0002)//'Reaplicação de descontos aplicados com sucesso'##"Sucesso!!"
Endif

Return nValor
//-------------------------------------------------------------------
/*/{Protheus.doc} GA285Desc()
Função de aplicação de descontos por bilhetes
@author  Jacomo Abenathar Fernandes Lisa
@since   27/06/17
@version P12
/*/
//-------------------------------------------------------------------
Function GA285Desc(oModelGIC)
Local oModelGQW := oModelGIC:GetModel():GetModel('FIELDGQW')
Local aArea     := GetArea()
Local cAliasGQX := GetNextAlias()
Local cClient   := oModelGQW:GetValue("GQW_CODCLI")
Local cLoja     := oModelGQW:GetValue("GQW_CODLOJ")
Local nValor    := oModelGIC:GetValue("GIC_VALTOT")
Local nValPed   := oModelGIC:GetValue("GIC_PED")
Local cLinha    := oModelGIC:GetValue("GIC_LINHA")
Local cLocOri   := oModelGIC:GetValue("GIC_LOCORI")
Local cLocDes   := oModelGIC:GetValue("GIC_LOCDES")
Local nValDes   := 0

If !(oModelGIC:GetValue('GIC_STATUS') $ "C|D|I")
    BeginSql Alias cAliasGQX

        SELECT 
            GQV.GQV_COBPED,
            GQX.GQX_TPVAL,
            (CASE 
                WHEN GQX.GQX_TPVAL = '1' THEN GQX.GQX_DSCPER 
                ELSE GQX.GQX_DSCFIX 
            END) AS VALOR
            
        FROM %Table:GQV % GQV 
            LEFT JOIN %Table:GQX% GQX ON 
                GQX.GQX_FILIAL = %xFilial:GQX% AND 
                GQV.GQV_CODIGO = GQX.GQX_CODIGO AND 
                GQV.GQV_CODLOJ = GQX.GQX_CODLOJ AND 
                GQX.GQX_MSBLQL = '2'AND	
                (GQX.GQX_DTVFIN = '' OR (GQX.GQX_DTVINI <= %Exp:dDataBase% AND GQX.GQX_DTVFIN >= %Exp:dDataBase%)) AND
                ((GQX.GQX_DSCTIP = '1') OR	(GQX.GQX_LINHA = %Exp:cLinha%) OR (GQX.GQX_LOCORI = %Exp:cLocOri% AND GQX.GQX_LOCDES = %Exp:cLocDes%)	)	AND
                GQX.%NotDel%
        WHERE  
            GQV.GQV_FILIAL = %xFilial:GQV% AND
            GQV.GQV_CODIGO = %Exp:cClient% AND
            GQV.GQV_CODLOJ = %Exp:cLoja% AND
            GQV.%NotDel% 
        ORDER BY  GQX.GQX_DSCTIP||GQX.GQX_DTVINI||GQX.GQX_DTVFIN

    EndSql

    If (cAliasGQX)->(!Eof())
        nValDes := (cAliasGQX)->VALOR
        If (cAliasGQX)->GQV_COBPED == '2' //Se não cobra pedagio, remover o valor do pedagio
            nValor-=nValPed
        Endif
        IF (cAliasGQX)->GQX_TPVAL == '1' //Se Porcentagem
            nValor := nValor * (1-((cAliasGQX)->VALOR/100))
        ELSE
            nValor := nValor - (cAliasGQX)->VALOR
        Endif
        If nValor < 0
            nValor := 0
        Endif
        oModelGIC:SetValue("GIC_REQDSC",oModelGIC:GetValue("GIC_VALTOT") - nValor)
        oModelGIC:SetValue("GIC_REQTOT",oModelGIC:GetValue("GIC_VALTOT"))
    Else
        oModelGIC:SetValue("GIC_REQDSC",0)
        oModelGIC:SetValue("GIC_REQTOT",oModelGIC:GetValue("GIC_VALTOT"))
    Endif
    (cAliasGQX)->(dbCloseArea())
Endif
RestArea(aArea)
Return nValDes


