#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPXGCT()
	Função para verificar se o contrato foi gerado por gestão de Transporte de Passageiros
@author GTP
@since 22/06/2021
/*/
Function GTPXGCT(lUsaCND as Logical) as Logical
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local oModel	:= FwModelActive()	
	Local lMdlAtivo	:= (ValType(oModel) == 'O' .And. oModel:lActivate .And. oModel:GetId() $ 'CNTA300|CNTA301')
	Local cContra	:= ""
	Local cRevisa	:= ""
	Local cAliasTmp	:= ""
	Local cWhere	:= "%%"
	Default lUsaCND	:= .F.
	
	If (AliasInDic("GY0") .And. GY0->(FieldPos("GY0_CODCN9")) > 0 .And. ChkFile("GY0"))
		cAliasTmp	:= GetNextAlias()

		If (lMdlAtivo)
			cContra := oModel:GetValue("CN9MASTER","CN9_NUMERO")			
			cRevisa := oModel:GetValue("CN9MASTER","CN9_REVISA")
		ElseIf lUsaCND
			cContra := CND->CND_CONTRA
			cRevisa := CND->CND_REVISA
		Else
			cContra := CN9->CN9_NUMERO
			cRevisa := CN9->CN9_REVISA
		EndIf

		If GY0->(FieldPos("GY0_REVISA")) > 0 
			cWhere := "% GY0.GY0_REVISA = '" + cRevisa + "' AND %"
		EndIf
	
		BeginSql Alias cAliasTmp
			SELECT 
				GY0.R_E_C_N_O_ RECGY0
			FROM 
				%Table:GY0% GY0
			WHERE 
				GY0.GY0_FILIAL = %xFilial:GY0% AND
				GY0.GY0_CODCN9 = %Exp:cContra% AND
				%Exp:cWhere%
				GY0.%NotDel%
		EndSql
		
		lRet := (cAliasTmp)->(!EoF())
		(cAliasTmp)->(dbCloseArea())	 
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return lRet
