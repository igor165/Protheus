#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE STR0001 'XML Mal formatado.'
#DEFINE STR0002 'Empresa e Filial não encontradas no De/Para de Empresas e Filiais EAI.'
#DEFINE STR0003 ''

/*/{Protheus.doc} GPEYGIF
(long_description)
@author philipe.pompeu
@since 29/05/2015
@version P11
@param cXML, character, (Descrição do parâmetro)
@param nTypeTrans, numérico, (Descrição do parâmetro)
@param cTypeMessage, character, (Descrição do parâmetro)
@param cVersao, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Function GPEYGIF( cXML, nTypeTrans, cTypeMessage, cVersao )
	Local cXMLRet := ''
	Local cXmlTmp	:= ''
	Local lRet		:= .F.
	Local oXml		:= Nil
	Local cErrorMsg	:= ''
	Local cWarnMsg	:= ''
	Local aEmpPorCtt	:= {}
	Local cEmpPorCtt	:= ''
	Local cPeriodo	:= ''
	Local cMyAlias	:= GetNextAlias()	
	Local cConsulta := ''	
	Local aVerbas := {}
	Local cTipo	:= ''
	Local cCompanyID	:= ''
	Local cBranchId	:= ''
	Local cProduct	:= 'LOGIX'
	Local aTemp		:= {}	
	Local cVersoes	:= "1.000"
	Local nI := 0
	Default cVersao	:= "1.000"	

	Do Case
		Case (nTypeTrans == TRANS_RECEIVE)			
			Do Case
				Case (cTypeMessage == EAI_MESSAGE_WHOIS)
					cXMLRet+= cVersoes
					lRet := .T.				
				Case (cTypeMessage == EAI_MESSAGE_RESPONSE)
					//NADA					
				Case (cTypeMessage == EAI_MESSAGE_BUSINESS)					
					
					cXmlTmp := SubStr(cXML,At('<RequestApportionmentPayroll>',cXML))
					cXmlTmp := SubStr(cXmlTmp,1,At('</RequestApportionmentPayroll>',cXmlTmp) + 29)
					
					oXml :=  XmlParser(cXmlTmp, '_', @cErrorMsg, @cWarnMsg)
					
					if((oXML <> Nil) .And. (Empty(cErrorMsg)) .And. (Empty(cWarnMsg)))
						
						cPeriodo	:= oXML:_RequestApportionmentPayroll:_PeriodPayRoll:Text
						
						cTipo		:= oXML:_RequestApportionmentPayroll:_FundType:Text					
						
						if NodeExist(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll,'_FUNDCODEINTERNALID')
							
							If ValType(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCodeInternalId) <> "A"
								XmlNode2Arr(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCodeInternalId, "_FUNDCODEINTERNALID")
							EndIf						
							
							for nI:= 1 to Len(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCodeInternalId)								
								aAdd(aVerbas,GetCodVerba(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCodeInternalId[nI]:Text, cProduct))
							next
//							aEval(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCodeInternalId,{|x|aAdd(aVerbas,GetCodVerba(x:Text,cProduct))})
							
						ElseIf NodeExist(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll,'_FUNDCODE')
							If ValType(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCode) <> "A"
								XmlNode2Arr(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCode, "_FUNDCODE")
							EndIf					
							aEval(oXML:_RequestApportionmentPayroll:_ListOfFundPayRoll:_FundCode,{|x|aAdd(aVerbas,x:Text)})						
						endIf
												
						aSort(aVerbas)
												
						aTemp := SEPARA (oXML:_RequestApportionmentPayroll:_CompanyInternalId:Text,'|'/*,lEmpty*/)						
						
						cCompanyID	:= aTemp[1]
						cBranchId 	:= PADR(aTemp[2],FWSizeFilial(FWGrpCompany()))					
						
						aTemp := FwEAIEmpFil(cCompanyID,cBranchId,cProduct) 
						
						if(Len(aTemp) < 2)							
							Return({.F.,STR0002})
						endIf
						
						cConsulta := PegaConsulta(ConvPeriod(cPeriodo), cTipo, aVerbas,aTemp[2])
						
						dbUseArea( .T., 'TOPCONN', TCGenQry( ,,cConsulta ), (cMyAlias), .T., .T.)
												
						while ( (cMyAlias)->(!Eof()) )							
							cEmpPorCtt:= '	<EmployeeByCostCenter>'
							
							cEmpPorCtt+= GetTagClosed('CostCenter'			,(cMyAlias)->CC)							
							cEmpPorCtt+= GetTagClosed('CostCenterId'		,IntCusExt(,FWxFilial("CTT",(cMyAlias)->FILIAL), (cMyAlias)->CC, '2.000')[2])							
							cEmpPorCtt+= GetTagClosed('PeriodPayroll'		,cPeriodo)
														
							cEmpPorCtt+= GetTagClosed('FundCode'				,(cMyAlias)->PD)							
							cEmpPorCtt+= GetTagClosed('FundCodeInternalId'	,GPEI040Snd({cEmpAnt, FWxFilial("SRV",(cMyAlias)->FILIAL), (cMyAlias)->PD } ))
														
							cEmpPorCtt+= GetTagClosed('AmountOfEmployee'	,cValToChar((cMyAlias)->TOTAL))
														
							cEmpPorCtt+= '	</EmployeeByCostCenter>'							
							aAdd(aEmpPorCtt,cEmpPorCtt)
							
							(cMyAlias)->(dbSkip())
						End
												
						cXMLRet+="<ReturnApportionmentPayroll>"						
						if(Len(aEmpPorCtt) > 0)
							cXMLRet+='<ListOfEmployeeByCostCenter>'							
							
							aEval(aEmpPorCtt,{ |x|cXMLRet += x })	
							
							cXMLRet+='</ListOfEmployeeByCostCenter>'	
						Else
							cXMLRet+='<ListOfEmployeeByCostCenter/>'
						endIf
												
						cXMLRet+="</ReturnApportionmentPayroll>"
						
						lRet := .T.
					Else
						cXMLRet += STR0001
						cXMLRet += IIF(Empty(cErrorMsg)	,'.',cErrorMsg)
						cXMLRet += IIF(Empty(cWarnMsg)	,'.',cWarnMsg)																		
					EndIf								
			EndCase		
		Case (nTypeTrans == TRANS_SEND)
			//NADA		
	EndCase
	
Return ({lRet,cXMLRet})


/*/{Protheus.doc} GetTagClosed
(long_description)
@author philipe.pompeu
@since 29/05/2015
@version P11
@param cTagName, character, (Descrição do parâmetro)
@param xValue, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetTagClosed(cTagName,xValue)
	Local cResult := ''
	Default cTagName := 'TAG'
	
	cResult+='<'+ AllTrim(cTagName) + '>'
	cResult+= xValue
	cResult+='</'+ AllTrim(cTagName) + '>'
Return cResult 


/*/{Protheus.doc} PegaConsulta
(long_description)
@author philipe.pompeu
@since 29/05/2015
@version P11
@param cCompetencia, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param aVerbas, array, (Descrição do parâmetro)
@param cFil, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function PegaConsulta(cCompetencia,cTipo,aVerbas,cFil)
Local cConsulta		:= ''	
Local cDe	:= ''
Local cAte	:= ''
Local cAno	:= ''
Local cMes	:= ''
Local lHaVerbas := (Len(aVerbas) > 0)	
Local cIn		:= IIF(lHaVerbas,PegarIn(aVerbas,.T.),'') 
Local cRotFol 	:= "'" + fGetCalcRot('1') + "','" + fGetCalcRot('9') + "'"
Local cRot13 	:= "'" +  fGetCalcRot('5') + "','" + fGetCalcRot('6') + "'"

Default cCompetencia := ''
Default cTipo := '0'
Default aVerbas:= {}
	
	cDe 	:= cCompetencia + '01'						
	cAte 	:= SToD(cDe)
	cAte 	:= LastDate(cAte)
	cAte 	:= DtoS(cAte)
	
	cTipo := IIF(cTipo == 'O','0',cTipo)
	
	if(Len(cCompetencia) == 6)		
		cAno := SubStr(cCompetencia,1,4)
		cMes := SubStr(cCompetencia,5)
	Else		
		cAno := Year(Date())
		cMes := Day(Date())
	endIf
	
	cConsulta :="SELECT FILIAL, CC, PD, SUM(TOTAL) AS TOTAL FROM("
			
	cConsulta += "SELECT RC_FILIAL AS FILIAL,RC_CC AS CC,RC_PD AS PD,COUNT(DISTINCT RC_MAT) AS TOTAL "
	cConsulta += " FROM "+ RetSqlName('SRC') +" SRC "
	cConsulta += " INNER JOIN "+ RetSqlName('SRA') +" SRA ON(RA_FILIAL = RC_FILIAL AND RA_MAT = RC_MAT AND SRA.D_E_L_E_T_ = '') "
	cConsulta += " WHERE "
	cConsulta += " SRC.D_E_L_E_T_ = '' AND RC_FILIAL='"+ xFilial('SRC',cFil)+"'"
	if(lHaVerbas)
		cConsulta += " AND  RC_PD IN ("+ cIn +")"
	endif
	cConsulta += " AND RC_PERIODO = '" + cCompetencia + "'" 
	if cTipo == '1' // folha
		cConsulta += " AND RC_ROTEIR IN("+ cRotFol + ") "
	ElseIf cTipo == '2' // 13
		cConsulta += " AND RC_ROTEIR IN("+ cRot13 + ") "
	Else
		cConsulta += " AND RC_ROTEIR IN("+ cRotFol + "," + cRot13 +  ") "
	EndIf
	cConsulta += " AND ((RA_SITFOLH = '')OR(RA_DEMISSA <= '"+ cAte +"')) "
	cConsulta += " GROUP BY RC_FILIAL,RC_CC,RC_PD "

	cConsulta += " UNION "
		
	cConsulta += "SELECT RD_FILIAL AS FILIAL,RD_CC AS CC,RD_PD AS PD,COUNT(DISTINCT RD_MAT) AS TOTAL "
	cConsulta += " FROM "+ RetSqlName('SRD') +" SRD "
	cConsulta += " INNER JOIN "+ RetSqlName('SRA') +" SRA ON(RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT AND SRA.D_E_L_E_T_ = '') "
	cConsulta += " WHERE "
	cConsulta += " SRD.D_E_L_E_T_ = '' AND RD_FILIAL = '"+ xFilial('SRD',cFil) +"'" 
	
	if(lHaVerbas)
		cConsulta += " AND RD_PD IN ("+ cIn +")"
	endif		
	
	cConsulta += " AND RD_PERIODO = '" + cCompetencia + "'" 
	if cTipo == '1' // folha
		cConsulta += " AND RD_ROTEIR IN("+ cRotFol +  ") "
	ElseIf cTipo == '2' // 13
		cConsulta += " AND RD_ROTEIR IN("+ cRot13 + ") "
	Else
		cConsulta += " AND RD_ROTEIR IN("+ cRotFol + "," + cRot13 +  ") "
	EndIf
	
	 
	cConsulta += " AND ((RA_SITFOLH = '') OR (RA_DEMISSA <= '"+ cAte +"')) "
	cConsulta += "GROUP BY RD_FILIAL,RD_CC,RD_PD "		
	
	
	cConsulta += ") RESULTADO "
	cConsulta += "GROUP BY FILIAL,CC,PD "
	cConsulta += "ORDER BY FILIAL,CC,PD "
	
	cConsulta:= ChangeQuery(cConsulta)		
Return cConsulta

/*/{Protheus.doc} PegarIn
(long_description)
@author philipe.pompeu
@since 29/05/2015
@version P11
@param aItens, array, (Descrição do parâmetro)
@param lAsStr, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function PegarIn(aItens,lAsStr,bLogico)
	Local cIn	:= ''
	Local cItem:= ''
	Local nI := 0
	Local cTipo := ''
	Default aItens := {}
	Default lAsStr := .T.
	Default bLogico:={|lValor|IIF(lValor,'0','1')}	
	
	for nI:= 1 to Len(aItens)	
		cTipo := ValType(aItens[nI])
		Do Case
			Case (cTipo == 'C')
				cItem := aItens[nI]
			Case (cTipo == 'N')			
				cItem := cValToChar(aItens[nI])	
			Case (cTipo == 'L')					
				cItem := eVal(bLogico,aItens[nI])
			Case (cTipo == 'A')				
				cItem := PegarIn(aItens[nI],lAsStr)
			Case (cTipo == 'B')
				cItem := eVal(aItens[nI])
			Case (cTipo == 'U')
				cItem := 'NULL' 
		EndCase
		
		cIn += IIF(lAsStr,"'"+ cItem +"'",cItem)
		
		if(nI < Len(aItens))
			cIn+=','
		endIf
	Next nI
	
Return cIn

/*/{Protheus.doc} IntegDef
(long_description)
@author philipe.pompeu
@since 29/05/2015
@version P11
@param cXML, character, (Descrição do parâmetro)
@param nTypeTrans, numérico, (Descrição do parâmetro)
@param cTypeMessage, character, (Descrição do parâmetro)
@param cVerMsg, character, (Descrição do parâmetro)
@return aRet, Mensagem de Retorno
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage,cVerMsg)
	Local aRet := {}
	Default cVerMsg := "1.000"
	aRet:= GPEYGIF( cXML, nTypeTrans, cTypeMessage, cVerMsg)
Return aRet

/*/{Protheus.doc} ConvPeriod
@author philipe.pompeu
@since 24/08/2015
@version P11
@param cPeriod, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function ConvPeriod(cPeriod)	
	Local cAno	:= ''
	Local cMes	:= ''
	Default cPeriod := (Month(Date()) + Year(Date()))	
	cMes := SubStr(cPeriod,1,2)
	cAno := SubStr(cPeriod,3)
Return (cAno+cMes)

/*/{Protheus.doc} GetCodVerba
@author philipe.pompeu
@since 24/08/2015
@version P11
@param cExternal, character, (Descrição do parâmetro)
@param cProduto, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function GetCodVerba(cExternal,cProduto)
	Local cInternal := ''
	Default cProduto := 'LOGIX'
	if!(FindFunction("CFGA070INT") .And. FindFunction("GPEI040Rcv"))
		Return cExternal
	endIf
	
	cInternal := CFGA070INT(cProduto ,'SRV','RV_COD',cExternal) 
	cInternal := GPEI040Rcv(cInternal, { "RV_FILIAL", "RV_COD" })
	cInternal := SubStr(cInternal,TamSX3('RV_FILIAL')[1] + 1)		
Return cInternal

/*/{Protheus.doc} NodeExist
@author philipe.pompeu
@since 24/08/2015
@version P11
@param oObj, objeto, (Descrição do parâmetro)
@param cNode, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
Static Function NodeExist(oObj,cNode)	
Return (XmlChildEx(oObj, cNode) <> Nil)