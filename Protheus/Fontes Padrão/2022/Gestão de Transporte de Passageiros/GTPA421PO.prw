#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static Function ModelDef()
Local oModel
Local oStruG6X   := FWFormStruct( 1,"G6X")  // Ficha de Remessa
Local oStruGZG   := FWFormStruct( 1,"GZG" ) // Receitas e Despesas
Local oStruGZE   := FWFormStruct( 1,"GZE" ) // Depósitos
Local oStruGZF   := FWFormStruct( 1,"GZF" ) // Depósitos
//Local bPosValid	:= {|oModel|PosValid(oModel)}
//Local bLinePre	:= {|oModel|LinePreVld(oModel)}
//Local bLinePos	:= {|oModel|LinePosVld(oModel)}
Local bCommit    := { |oModel| G421POCommit(oModel)}

oModel := MPFormModel():New('GTPA421PO', /*bPre*/, /*FwPos*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G6XMASTER',/*cPai*/,oStruG6X)
	
oModel:AddGrid('GZGDETAIL', 'G6XMASTER', oStruGZG, /*bPreLinR*/) //Receitas e Despesas
oModel:GetModel('GZGDETAIL'):SetOptional( .T. )
//oModel:GetModel('GZGDETAIL'):SetUniqueLine({"GZG_COD"})
//
oModel:AddGrid('GZEDETAIL', 'G6XMASTER', oStruGZE, /*bPreLinR*/) //Depositos
oModel:GetModel('GZEDETAIL'):SetOptional( .T. )

oModel:AddGrid('GZFDETAIL', 'G6XMASTER', oStruGZF)
oModel:GetModel('GZFDETAIL'):SetOptional( .T. )
//  
oModel:SetRelation('GZGDETAIL', { { 'GZG_FILIAL', 'xFilial( "GZG" )' }, { 'GZG_AGENCI', 'G6X_AGENCI' } ,{ 'GZG_NUMFCH', 'G6X_NUMFCH' } }, GZG->(IndexKey(1)))
oModel:SetRelation('GZEDETAIL', { { 'GZE_FILIAL', 'xFilial( "GZE" )' }, { 'GZE_AGENCI', 'G6X_AGENCI' } ,{ 'GZE_NUMFCH', 'G6X_NUMFCH' } }, GZE->(IndexKey(1)))
oModel:SetRelation('GZFDETAIL', { { 'GZF_FILIAL', 'xFilial( "GZF" )' }, { 'GZF_AGENCI', 'G6X_AGENCI' } ,{ 'GZF_NUMFCH', 'G6X_NUMFCH' } }, GZF->(IndexKey(1)))

oModel:SetPrimaryKey({"G6X_FILIAL","G6X_AGENCI","G6X_NUMFCH"})

oModel:SetDescription('Ficha de Remessa')

oModel:SetCommit(bCommit)

oStruG6X:SetProperty('*', MODEL_FIELD_WHEN, {||.T.})
oStruG6X:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
		
Return oModel

/*Static Function PosValid(oModel)
Local lRet := .T.

If oModel:VldData()
    lRet := .T.
Else
    lRet := .F.
Endif

Return lRet*/

Static Function G421POCommit(oModel)
Local lRet      := .T.
Local cQuery    := ""
Local lOnlyCalc := .F.

Begin Transaction
        
    G421SumGZF(oModel)
    
    If oModel:GetModel('GZGDETAIL'):SeekLine({{'GZG_COD', '028'}}, , .T.) // Existe comissão

        If oModel:GetOperation() == MODEL_OPERATION_INSERT

            nVlrCom := G421CalcCom(oModel, lOnlyCalc)

            If nVlrCom != oModel:GetValue('GZGDETAIL', 'GZG_VALOR')
                lRet := .F.
                oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,'GTPA421', "Divergencia no calculo da comissao", "Favor reprocessar a ficha de remessa")
             Endif

        Endif

    Endif
    
    If lRet .And. oModel:VldData()
        FWFormCommit(oModel)

        cQuery := " UPDATE " + RetSqlName('GIC') "
        cQuery += " SET GIC_NUMFCH = '" + oModel:GetModel('G6XMASTER'):GetValue('G6X_NUMFCH') + "' "
        cQuery += " WHERE GIC_FILIAL = '" + xFilial('GIC') + "'"
        cQuery += "     AND GIC_AGENCI = '" + oModel:GetModel('G6XMASTER'):GetValue('G6X_AGENCI') + "' "
        cQuery += "     AND GIC_DTVEND BETWEEN '" + DTOS(oModel:GetModel('G6XMASTER'):GetValue('G6X_DTINI')) + "' "
        cQuery += "         AND '" + DTOS(oModel:GetModel('G6XMASTER'):GetValue('G6X_DTFIN')) + "' "
        cQuery += "     AND GIC_NUMFCH = '' "
        cQuery += "     AND D_E_L_E_T_ = ' ' "

        TcSqlExec(cQuery)

    Else
        DisarmTransaction()
    Endif
   
End Transaction

Return lRet

Static Function G421SumGZF(oModel)

Local oMdlGZF 	:= oModel:GetModel('GZFDETAIL')
Local cAliasTmp	:= GetNextAlias()

	oMdlGZF:DeActivate()
	oMdlGZF:SetNoInsertLine(.F.)
	oMdlGZF:SetNoDeleteLine(.F.)
	oMdlGZF:SetDelAllLine(.T.)

	oMdlGZF:Activate()
	oMdlGZF:DelAllLine()

    BeginSql Alias cAliasTmp

		SELECT GIC_TIPO
            , GIC_ORIGEM
            , GIC_LOCORI
            , GIC_STATUS
            , GIC_TAR
            , GIC_PED
            , GIC_TAX
            , GIC_SGFACU
            , GIC_OUTTOT
            , GIC_VALTOT
		FROM %Table:GIC%
         WHERE GIC_FILIAL = %xFilial:GIC%
            AND GIC_AGENCI = %Exp:oModel:GetModel('G6XMASTER'):GetValue('G6X_AGENCI')%
            AND GIC_DTVEND BETWEEN %Exp:DTOS(oModel:GetModel('G6XMASTER'):GetValue('G6X_DTINI'))%
            AND %Exp:DTOS(oModel:GetModel('G6XMASTER'):GetValue('G6X_DTFIN'))%
            AND GIC_NUMFCH = '' 
            AND %NotDel%

	EndSql

    While (cAliasTmp)->(!(EOF()))

        If !((cAliasTmp)->GIC_STATUS $ 'C|D')
            If  (oMdlGZF:SeekLine({{"GZF_TPPASS" , (cAliasTmp)->GIC_TIPO},;
                                    {"GZF_ORIGEM", (cAliasTmp)->GIC_ORIGEM},;
                                    {"GZF_LOCORI", (cAliasTmp)->GIC_LOCORI}}, .F., .T.))

                oMdlGZF:SetValue('GZF_QUANT',	oMdlGZF:GetValue('GZF_QUANT') + 1)
                oMdlGZF:SetValue('GZF_TARIFA', 	oMdlGZF:GetValue('GZF_TARIFA')  + (cAliasTmp)->GIC_TAR)
                oMdlGZF:SetValue('GZF_PEDAGI', 	oMdlGZF:GetValue('GZF_PEDAGI')  + (cAliasTmp)->GIC_PED)
                oMdlGZF:SetValue('GZF_TXEMB', 	oMdlGZF:GetValue('GZF_TXEMB')	+ (cAliasTmp)->GIC_TAX)
                oMdlGZF:SetValue('GZF_SEGURO', 	oMdlGZF:GetValue('GZF_SEGURO')	+ (cAliasTmp)->GIC_SGFACU)
                oMdlGZF:SetValue('GZF_OUTROS', 	oMdlGZF:GetValue('GZF_OUTROS')	+ (cAliasTmp)->GIC_OUTTOT)
                oMdlGZF:SetValue('GZF_TOTAL', 	oMdlGZF:GetValue('GZF_TOTAL')	+ (cAliasTmp)->GIC_VALTOT)
            
            Else

                If !(oMdlGZF:IsEmpty())
                    oMdlGZF:AddLine()
                Endif

                oMdlGZF:SetValue('GZF_TPPASS', 	(cAliasTmp)->GIC_TIPO)
                oMdlGZF:SetValue('GZF_ORIGEM', 	(cAliasTmp)->GIC_ORIGEM)
                oMdlGZF:SetValue('GZF_LOCORI', 	(cAliasTmp)->GIC_LOCORI)
                oMdlGZF:SetValue('GZF_QUANT',	1)
                oMdlGZF:SetValue('GZF_TARIFA', 	(cAliasTmp)->GIC_TAR)
                oMdlGZF:SetValue('GZF_PEDAGI', 	(cAliasTmp)->GIC_PED)
                oMdlGZF:SetValue('GZF_TXEMB', 	(cAliasTmp)->GIC_TAX)
                oMdlGZF:SetValue('GZF_SEGURO', 	(cAliasTmp)->GIC_SGFACU)
                oMdlGZF:SetValue('GZF_OUTROS', 	(cAliasTmp)->GIC_OUTTOT)
                oMdlGZF:SetValue('GZF_TOTAL', 	(cAliasTmp)->GIC_VALTOT)
                
            Endif
        Endif
        (cAliasTmp)->(dbSkip())
    End
    (cAliasTmp)->(dbCloseArea())

    oMdlGZF:SetNoInsertLine(.T.)
    oMdlGZF:SetNoDeleteLine(.T.)

Return
