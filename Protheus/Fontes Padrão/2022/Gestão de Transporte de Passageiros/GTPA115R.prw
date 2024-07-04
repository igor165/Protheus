#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include 'PARMTYPE.CH'
#Include 'TBICONN.CH'
#Include 'FWBROWSE.CH'
#Include 'GTPA115R.CH'

/*/{Protheus.doc} GTPA115R()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Function GTPA115R()
Local oBrowse	:= Nil
//Private aRotina	:= MenuDef()
Local aCampos := {'GIC_STAPRO', 'GIC_MOTIVO','GIC_BILHET','GIC_CODIGO','GIC_TIPO','GIC_STATUS','GIC_ORIGEM','GIC_AGENCI'}

	oBrowse:=FwMBrowse():New()
	oBrowse:SetAlias("GIC")
	oBrowse:DisableDetails()
    oBrowse:SetOnlyFields(aCampos)
    oBrowse:SetDescription(STR0001) //"Inconsistências no faturamento de bilhetes"
    oBrowse:SetFilterDefault ("GIC_STAPRO <> '0' .AND. GIC_STAPRO <> '1'")

	oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} MenuDef()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function MenuDef()
	
Local aRotina := {}
	
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA115R' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION "G115Reproc()"     OPERATION 2 ACCESS 0 //"Reprocessar"
	
Return aRotina	

/*/{Protheus.doc} ModelDef()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStrGIC	:= FWFormStruct(1, "GIC",,.F. )

oModel := MPFormModel():New("GTPA115R")

oModel:AddFields("GICMASTER", /*cOwner*/, oStrGIC, /*bValid*/)

oModel:SetDescription(STR0001) //"Inconsistências no faturamento de bilhetes" 

Return(oModel)

/*/{Protheus.doc} ViewDef()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function ViewDef()
Local oView		 := nil
Local oModel	 := FwLoadModel("GTPA115")
Local oStrGIC	 := FWFormStruct(2, "GIC",,.F. )	//Bilhetes

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField("VIEW_GIC", oStrGIC, "GICMASTER" )

Return (oView)

/*/{Protheus.doc} G115Reproc()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Function G115Reproc()
Local lRet := .T.

If Pergunte('GTPA115R',.T.)

    FwMsgRun( ,{|| lRet := AtuStatus()},, STR0004) //"Atualizando bilhetes..."

        If lRet .And. FwAlertYesNo(STR0005, STR0006) //"Deseja gerar o faturamento agora ?", "Bilhetes atualizados"
            FwMsgRun( ,{|| lRet := CallJob()},, STR0007) //"Gerando faturamento, aguarde..."
        Endif
Endif

Return lRet

/*/{Protheus.doc} AtuStatus()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function AtuStatus()
Local lRet    := .T.
Local cQuery  := ""
Local nStatus := 0

cQuery := " UPDATE " + RetSqlName("GIC")
cQuery += " SET GIC_STAPRO = '0',"
cQuery += " GIC_DTERRO = '',"
cQuery += " GIC_MOTIVO = CAST('' AS VARBINARY(MAX))"
cQuery += " WHERE"
cQuery += " GIC_FILIAL = '" + xFilial("GIC") + "'"
cQuery += " AND GIC_AGENCI BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + " ' "
cQuery += " AND GIC_DTVEND BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + Dtos(MV_PAR04) + " ' "
cQuery += " AND GIC_STAPRO NOT IN ('0','1')"
cQuery += " AND D_E_L_E_T_ = ' '"

nStatus := TcSqlExec(cQuery)

If nStatus < 0
    lRet := .F.
    FwAlertWarning(TcSqlError(), STR0008) //"Erro na atualização"
Endif

Return lRet

/*/{Protheus.doc} CallJob()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 16/08/2021
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function CallJob()
Local cAliasTmp := GetNextAlias()
Local lJob      := .T.
Local lManual   := .F.
Local lConf     := .T.
Local cTpStatus := '0'
Local cDtIni    := DtoS(MV_PAR03)
Local cDtFim    := DtoS(MV_PAR04)
Local cAgeIni   := MV_PAR01
Local cAgeFim   := MV_PAR02
Local cAgencia  := ''

BeginSql alias cAliasTmp

    SELECT GI6_CODIGO
    FROM %Table:GI6%
    WHERE GI6_FILIAL = %xFilial:GI6%
      AND GI6_CODIGO BETWEEN %Exp:cAgeIni% AND %Exp:cAgeFim%
      AND %NotDel%
    ORDER BY GI6_CODIGO
EndSql

While (cAliasTmp)->(!Eof())

    cAgencia := (cAliasTmp)->GI6_CODIGO

    GTPJ001(lJob, cTpStatus, cDtini, cDtFim, lConf, lManual, cAgencia)

    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

Return

