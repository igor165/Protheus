#include 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} fAnalyticsJson
Funcao para obter o Json das views do analyhtics.
@author  Alessandro Afonso 
@version	1.0
@since	09/04/2021 
@type function
/*/
//-------------------------------------------------------------------
Function fAnalyticsJson(nPage, nSize, nPageSize, oWS, cBanco, cView, lforceInitialDate, lOffSet)
      Local nRec      := 0
      Local lSeek     := .F.
      Local cJson     := ''
      Local cDateTime := ''
      Private lErro   := .F.
      Default lforceInitialDate := .F.
      Default lOffSet           := .T.
      
      If cView == 'FINANCIALSECURITY'
            fGetJsonFin(nPage, nSize, oWS, cBanco, @nRec, @lSeek, @cJson, lforceInitialDate, lOffSet) 
      ElseIf cView == 'INVOICE'
            fJsonInvoice(nPage, nSize, oWS, cBanco, @nRec, @lSeek, @cJson, lforceInitialDate, lOffSet) 
      ElseIf cView == 'INVOICEITEM'
            fJsonItemInvoice(nPage, nSize, oWS, cBanco, @nRec, @lSeek, @cJson, lforceInitialDate, lOffSet) 
      ElseIf cView == 'ORDERS'
            fJsonPed(nPage, nSize, oWS, cBanco, @nRec, @lSeek, @cJson, lforceInitialDate, lOffSet) 
      ElseIf cView == 'ORDERSITEM'
            fJsonItemPed(nPage, nSize, oWS, cBanco, @nRec, @lSeek, @cJson, lforceInitialDate, lOffSet) 
      ElseIf cView == 'TES'
            fJsonTES(nPage, nSize, oWS, cBanco, @nRec, @lSeek, @cJson) 
      Else
            cJson := '{ "items": ["view":"nome de view invalido!, possiveis: FINANCIALSECURITY, INVOICEITEM, ORDERSITEM"'
      Endif
      
      If lErro
           cJson := '{ "items": ["view":"ConnectAdapterProc, parametro invalidao view, a api necessita do parametro view, exemplo: view = financialSecurity|19000101|"'
           lSeek := .F.
      Endif

      cDateTime := SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + ' ' +  Time()
      If lSeek
            cJson := Left(cJson,Len(cJson)-1)
            If nRec < nPageSize
                  cJson += '],  "hasNext": false, "Data": "' + cDateTime + '" }'
            Else
                  cJson += '],  "hasNext": true, "Data": "' + cDateTime + '" }'
            Endif
      Else
            cJson += '],  "hasNext": false, "Data": "' + cDateTime + '" }'
      Endif
      
Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} fGetJsonFin
Funcao para obter o Json do financeiro.
@author  Alessandro Afonso 
@version	1.0
@since	09/04/2021 
@type function
/*/
//-------------------------------------------------------------------
Static Function fGetJsonFin(nPage, nSize, oWS, cBanco, nRec, lSeek, cJson, lforceInitialDate, lOffSet) 
      Local cQuery  := ""
      Local cxAlias := ""
      Local cFilName:= ''
      Local cFiltroFil:= fFiltroFilial(oWs,"SE1")
      Local lCarga  := .F.
      Local aFilter   := fFilter(oWs, cBanco, @lCarga, "SE1.", "E1_EMISSAO", lforceInitialDate)
      Local ni        := 0 
      Local cxEmp     := Alltrim(cEmpAnt)
      Local cSubs     := Iif(cBanco == 'MSSQL', 'SUBSTRING', 'SUBSTR')
      Local cConcat   := Iif(cBanco == 'MSSQL', '+', '||')
      Local cIssueData:= ''
      Local cDataErp  := ''
      Local nTamEmp   := Len(FWCodEmp())
      Local lAnalytics:= oWS:isAnalytics
      Private nTamSA1 := Len(RTRIM(fwxFilial("SA1")))
      Private nTamCC2 := Len(RTRIM(fwxFilial("CC2")))
      Private nTamSX5 := Len(RTRIM(fwxFilial("SX5")))      
      Private nTamSA3 := Len(RTRIM(fwxFilial("SA3")))  
      

      cQuery := "SELECT * FROM ( "
      cQuery += "SELECT ROW_NUMBER() OVER (  ORDER BY  SE1.S_T_A_M_P_  ) ITEM_ORDER "
      cQuery += ",SE1.S_T_A_M_P_ "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " RTRIM(SE1.E1_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_PREFIXO) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_NUM) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_PARCELA) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_TIPO) AS id "
      cQuery += ",'" + cxEmp + "' as company_id "
      cQuery += ",'" + cxEmp + "' as company_code "
      cQuery += ",CASE  "
      cQuery += " 	WHEN SE1.E1_FILIAL IS NULL "
      cQuery += " 		THEN '' "
      cQuery += " 	ELSE  CAST(SE1.E1_FILIAL AS CHAR(" +cValToChar(Len(SE1->E1_FILIAL))+ ")) "
      cQuery += " 	END AS branch_id "
      cQuery += ",CASE  "
      cQuery += " 	WHEN SE1.E1_FILIAL IS NULL "
      cQuery += " 		THEN '' "
      cQuery += " 	ELSE  CAST(SE1.E1_FILIAL AS CHAR(" +cValToChar(Len(SE1->E1_FILIAL))+ ")) "
      cQuery += " 	END as branch_code	 "
      cQuery += ",' ' as branch_description	 "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SA1.A1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SE1.E1_CLIENTE, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SE1.E1_LOJA, ' ')), ' '), '|') " + cConcat + " '|C' AS customer_id "
      cQuery += ",RTRIM(COALESCE(SA1.A1_CGC, ' ')) as customer_document "
      cQuery += ",RTRIM(COALESCE(SA1.A1_NOME, ' ')) as customer_name "
      cQuery += ",' ' as customer_group "
      cQuery += ",RTRIM(COALESCE(CC2.CC2_CODMUN, ' ')) as cus_city_id 	 "
      cQuery += ",RTRIM(COALESCE(CC2.CC2_MUN, ' ')) as customer_city_description "
      cQuery += ",RTRIM(COALESCE(X5EST.X5_DESCRI, ' ')) as customer_state_description "
      cQuery += ",RTRIM(COALESCE(SA31.A3_COD, ' '))  as seller "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SA31.A3_FILIAL,' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SA31.A3_COD, ' '))  as seller_id "
      cQuery += ",RTRIM(COALESCE(SA31.A3_NOME,' '))  as seller_name "
      cQuery += ",'' as responsible_customer_crm_id "
      cQuery += ",'' as responsible_customer_crm_name "
      cQuery += ",RTRIM(SE1.E1_PORTADO) as bearer "
      cQuery += ",RTRIM(SE1.E1_TIPO) as fi_code "
      cQuery += ",RTRIM(COALESCE(TPTIT.X5_DESCRI,' ')) as fi_description "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " RTRIM(SE1.E1_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_PREFIXO) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_NUM) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_PARCELA) " + cConcat + " '|' " + cConcat + " RTRIM(SE1.E1_TIPO) as fi_identification "
      cQuery += ",RTRIM(SE1.E1_NUM) as source_document "
      cQuery += ", CASE  "
      If cBanco == 'ORACLE'
            cQuery += " 	WHEN ( SE1.E1_BAIXA = '' AND SE1.E1_VENCREA >= to_char(CURRENT_DATE, 'YYYYMMDD') ) "
            cQuery += " 		THEN 'Aberto' "
            cQuery += " 	WHEN ( SE1.E1_BAIXA  = '' AND SE1.E1_VENCREA < to_char(CURRENT_DATE, 'YYYYMMDD') ) "
            cQuery += " 		THEN 'Vencido' "
      Else
            cQuery += " 	WHEN ( SE1.E1_BAIXA = '' AND SE1.E1_VENCREA >= CONVERT(VARCHAR(10), GETDATE(), 112) ) "
            cQuery += " 		THEN 'Aberto' "
            cQuery += " 	WHEN ( SE1.E1_BAIXA  = '' AND SE1.E1_VENCREA < CONVERT(VARCHAR(10), GETDATE(), 112) ) "
            cQuery += " 		THEN 'Vencido' "
      Endif      
      cQuery += "	WHEN ( SE1.E1_BAIXA  <> '' AND SE1.E1_SALDO > 0 ) "
      cQuery += "		THEN 'Pago Parcial' "
      cQuery += "	WHEN ( SE1.E1_BAIXA  <> '' AND SE1.E1_SALDO = 0 ) "
      cQuery += "		THEN 'Pago Total' "
      cQuery += "	END as fi_status "

      cQuery += ",SE1.E1_EMISSAO as issue_date "
      cQuery += ",SE1.E1_VENCREA as maturity_date  "
      cQuery += ",SE1.E1_BAIXA as paymant_date  "
      cQuery += ",SE1.E1_VALOR as original_value "
      //jUROS e MULTA
      cQuery += ",(select SUM(SE5.E5_VALOR) AS increased_value FROM " + RetSqlName("SE5") + " SE5  "
      cQuery += "  where SE5.E5_FILIAL = SE1.E1_FILIAL  "
      cQuery += "  	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO  "
      cQuery += " 	AND SE5.E5_NUMERO = SE1.E1_NUM  "
      cQuery += " 	AND SE5.E5_PARCELA = SE1.E1_PARCELA "
      cQuery += " 	AND SE5.E5_TIPO = SE1.E1_TIPO "
      cQuery += " 	AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
      cQuery += " 	AND SE5.E5_LOJA =  SE1.E1_LOJA "
      cQuery += " 	AND ( SE5.E5_TIPODOC = 'JR' or SE5.E5_TIPODOC = 'MT') "
      cQuery += " 	AND SE5.E5_SITUACA = ' ' "
      cQuery += " 	AND  SE5.D_E_L_E_T_ = ' ' ) as increased_value

      //cQuery += ",SE1.E1_VALOR - E1_SALDO as value_paid "
      // Valor Pago
      cQuery += ",(select SUM(SE5.E5_VALOR) AS value_paid FROM " + RetSqlName("SE5") + " SE5  "
      cQuery += "  where    SE5.E5_FILIAL = SE1.E1_FILIAL  "
      cQuery += "  	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO  "
      cQuery += " 	AND SE5.E5_NUMERO = SE1.E1_NUM  "
      cQuery += " 	AND SE5.E5_PARCELA = SE1.E1_PARCELA "
      cQuery += " 	AND SE5.E5_TIPO = SE1.E1_TIPO "
      cQuery += " 	AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
      cQuery += " 	AND SE5.E5_LOJA =  SE1.E1_LOJA "
      cQuery += " 	AND ( SE5.E5_TIPODOC = 'VL' OR SE5.E5_TIPODOC = 'CP' OR SE5.E5_TIPODOC = 'BA'  ) "
      cQuery += " 	AND SE5.E5_DTCANBX = ' ' "
      cQuery += " 	AND  SE5.D_E_L_E_T_ = ' ' 
      cQuery += " 	AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName("SE5") + " SE5CQ  "
      cQuery += " 				WHERE SE5CQ.E5_FILIAL = SE5.E5_FILIAL "
      cQuery += " 				AND SE5CQ.E5_TIPODOC = 'ES' "
      cQuery += " 				AND SE5CQ.E5_DOCUMEN = SE5.E5_DOCUMEN "
      cQuery += " 				AND SE5CQ.D_E_L_E_T_ = ' ' "
      cQuery += " 				AND SE5CQ.E5_DOCUMEN <> ' ' ) "
      cQuery += " 	      ) as value_paid "

      //Desconto
      cQuery += ",(select SUM(SE5.E5_VALOR) AS discount_value FROM " + RetSqlName("SE5") + " SE5  "
      cQuery += "  where SE5.E5_FILIAL = SE1.E1_FILIAL  "
      cQuery += "  	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO  "
      cQuery += " 	AND SE5.E5_NUMERO = SE1.E1_NUM  "
      cQuery += " 	AND SE5.E5_PARCELA = SE1.E1_PARCELA "
      cQuery += " 	AND SE5.E5_TIPO = SE1.E1_TIPO "
      cQuery += " 	AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
      cQuery += " 	AND SE5.E5_LOJA =  SE1.E1_LOJA "
      cQuery += " 	AND ( SE5.E5_TIPODOC = 'DC') "
      cQuery += " 	AND SE5.E5_SITUACA = ' ' "
      cQuery += " 	AND  SE5.D_E_L_E_T_ = ' ' ) as discount_value

      //cQuery += ",SE1.E1_VALOR + SE1.E1_ACRESC - SE1.E1_DECRESC - SE1.E1_DESCONT + SE1.E1_MULTA  as total_value "
      cQuery += ",SE1.S_T_A_M_P_ as insert_erp "
      cQuery += ",SE1.E1_FILIAL "
      cQuery += ",SE1.D_E_L_E_T_  as CANCELED "
      if !lAnalytics
           cQuery += ", TPTIT.X5_DESCRI as descriptionType "
      Endif
      cQuery += "FROM " + RetSqlName('SE1') + " SE1 "
      cQuery += "LEFT JOIN " + RetSqlName('SA1') + " SA1 ON " + fFilial('SA1','SE1', cSubs) 
      cQuery += "      AND SA1.A1_COD  = SE1.E1_CLIENTE "
      cQuery += "      AND SA1.A1_LOJA = SE1.E1_LOJA "
      cQuery += "      AND SA1.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('CC2') + " CC2 ON " + fFilial('CC2','SE1', cSubs) 
      cQuery += "      AND CC2.CC2_CODMUN  = SA1.A1_COD_MUN "
      cQuery += "      AND CC2.CC2_EST = SA1.A1_EST "
      cQuery += "      AND CC2.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SX5') + " X5EST ON " + fFilial('X5EST','SE1', cSubs) 
      cQuery += "      AND X5EST.X5_TABELA = '12' "
      cQuery += "      AND X5EST.X5_CHAVE = SA1.A1_EST "
      cQuery += "      AND X5EST.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SA3') + " SA31 ON " + fFilial('SA31','SE1', cSubs)  
      cQuery += "      AND SA31.A3_COD = SE1.E1_VEND1 "
      cQuery += "      AND SA31.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SX5') + " TPTIT ON " + fFilial('TPTIT','SE1', cSubs)
      cQuery += "      AND TPTIT.X5_TABELA = '05' "
      cQuery += "      AND TPTIT.X5_CHAVE = SE1.E1_TIPO "
      cQuery += "      AND TPTIT.D_E_L_E_T_ = ' ' "
      If !Empty(cFiltroFil)
            cQuery += " WHERE " + cFiltroFil
      Else
            cQuery += " WHERE SE1.E1_FILIAL >= ' ' " //+ cSubs + "(SE1.E1_FILIAL, 1,"  + cValToChar(Len(cEmpAnt)) + ") = '" + SubStr(fwxFilial("SE1"),1,Len(cEmpAnt)) + "' "   
      Endif
            
      For ni := 1 to Len(aFilter)
            cQuery += aFilter[ni]
      Next ni
      
      if !lAnalytics
            cQuery += " AND SE1.D_E_L_E_T_  = ' ' "
      Endif

      cQuery += "      ) " // AND SE1.D_E_L_E_T_ = ' ' sera enviado todos os registros para analytics, deletados ou nao, mas marcaremos os deletados com: "canceled" : "*"
      cQuery += " TRB   "
      cQuery += fAddOffSet(cBanco, nPage, nSize, lOffSet)

      cQuery := ChangeQuery(cQuery)
      cxAlias := GetNextAlias()
      If oWS:isQuery
            lSeek := .F.
            cJson := '{ "items": [ { "query":"' + cQuery + '"} '
            Return Nil
      Endif

	MPSysOpenQuery(cQuery,cxAlias )	
	
      cJson := '{ "items": [ '

      nRec := 0
	While (cxAlias)->(!(EoF()))
            
            nRec := nRec + 1

            lSeek := .T.
            
            cFilName := StrxTran(NoAcento(Alltrim(FWFilialName(cEmpAnt, (cxAlias)->E1_FILIAL, 1))))

            cEmpName := StrxTran(FWCompanyName(cEmpAnt,(cxAlias)->branch_id))
            cCompanyid:= SubStr((cxAlias)->branch_id, 1, nTamEmp)

            cIssueData:= SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2)
            cDataErp  := Iif(!Empty(SubStr(dtos((cxAlias)->insert_erp),1,4)), SubStr(dtos((cxAlias)->insert_erp),1,4) + '-' + SubStr(DtoS((cxAlias)->insert_erp),5,2) + '-' + SubStr(DtoS((cxAlias)->insert_erp),7,2),cIssueData)

            cJson += '{'
            cJson += '    "financial_security_id":"' + Alltrim((cxAlias)->id) + '", '
            cJson += '    "company_id":"' + cCompanyid + '", '
            cJson += '    "company_code":"' + cCompanyid + '", '
            cJson += '    "company_description":"' + Alltrim(cEmpName) + '", '
            cJson += '    "branch_id":"' + Alltrim((cxAlias)->branch_id) + '", '
            cJson += '    "branch_code":"' + Alltrim((cxAlias)->branch_code) + '", '
            cJson += '    "branch_description":"' + Alltrim(cFilName) + '", '
            cJson += '    "customer_id":"' + Alltrim((cxAlias)->customer_id) + '", '
            cJson += '    "customer_document":"' + StrxTran(Alltrim((cxAlias)->customer_document)) + '", '
            cJson += '    "customer_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_name))) + '", '
            cJson += '    "customer_group":"' + Alltrim((cxAlias)->customer_group) + '", '
            cJson += '    "customer_city_id":"' + Alltrim((cxAlias)->cus_city_id) + '", '
            cJson += '    "customer_city_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_city_description))) + '", '
            cJson += '    "customer_state_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_state_description))) + '", '
            cJson += '    "seller_id":"' + IIF(!Empty((cxAlias)->seller), Alltrim((cxAlias)->seller_id), '' ) + '", '
            cJson += '    "seller_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->seller_name))) + '", '
            cJson += '    "responsible_customer_crm_id":"' + Alltrim((cxAlias)->responsible_customer_crm_id) + '", '
            cJson += '    "responsible_customer_crm_name":"' + StrxTran(Alltrim((cxAlias)->responsible_customer_crm_name)) + '", '
            cJson += '    "bearer":"' + Alltrim((cxAlias)->bearer) + '", '
            cJson += '    "financial_security_type_code":"' + Alltrim((cxAlias)->fi_code) + '", '
            cJson += '    "financial_security_type_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->fi_description))) + '", '
            cJson += '    "financial_security_identification":"' + Alltrim((cxAlias)->fi_identification) + '", '
            cJson += '    "source_document":"' + Alltrim((cxAlias)->source_document) + '", '
            cJson += '    "financial_security_status":"' + Alltrim((cxAlias)->fi_status) + '", '
            
            If !Empty((cxAlias)->issue_date)
                  cJson += '    "issue_date":"' + SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2) + '", '
            Endif 

            If  !Empty((cxAlias)->maturity_date)    
                  cJson += '    "maturity_date":"' + SubStr( (cxAlias)->maturity_date,1,4) + '-' + SubStr( (cxAlias)->maturity_date,5,2) + '-' + SubStr( (cxAlias)->maturity_date,7,2) + '", '
            Endif

            If !Empty((cxAlias)->paymant_date)
               cJson += '    "paymant_date":"' + IIF(!Empty((cxAlias)->paymant_date), SubStr( (cxAlias)->paymant_date,1,4) + '-' + SubStr( (cxAlias)->paymant_date,5,2) + '-' + SubStr( (cxAlias)->paymant_date,7,2), '') + '", '
            Endif
            cJson += '    "original_value":' + cValToChar((cxAlias)->original_value) + ', '
            cJson += '    "increased_value":' + cValToChar((cxAlias)->increased_value) + ', '
            cJson += '    "discount_value":' + cValToChar((cxAlias)->discount_value) + ', '            
            cJson += '    "value_paid":' + cValToChar((cxAlias)->value_paid) + ', '            
            cJson += '    "total_value":' + cValToChar((cxAlias)->original_value + (cxAlias)->increased_value - (cxAlias)->discount_value ) + ', '
            cJson += '    "insert_update_erp":"' + cDataErp +' 00:00:00", '            
            cJson += '    "insert_update_crm":"' + SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + ' ' + Time() + '", '                                    
            if !lAnalytics
              cJson += '    "descriptionType":"' + Alltrim((cxAlias)->descriptionType) + '", '
            Endif
            cJson += '    "canceled" :"' + (cxAlias)->CANCELED + '" ' 

            cJson += '},'
            (cxAlias)->(dbSkip())
      Enddo
     
      (cxAlias)->( dbCloseArea() ) 

Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} fJsonInvoice
Funcao para obter o Json da nota.
@author  Alessandro Afonso 
@version	1.0
@since	09/04/2021 
@type function
/*/
//-------------------------------------------------------------------

Static Function fJsonInvoice(nPage, nSize, oWS, cBanco, nRec, lSeek, cJson, lforceInitialDate, lOffSet) 
      Local cQuery    := ""
      Local cxAlias   := ""
      Local cFilName  := ''
      Local cFiltroFil:= fFiltroFilial(oWs,"SF2")
      Local lCarga    := .F.
      Local aFilter   := fFilter(oWs, cBanco, @lCarga, "SF2.", "F2_EMISSAO", lforceInitialDate)
      Local ni        := 0 
      Local cxEmp     := Alltrim(cEmpAnt)
      Local cSubs     := Iif(cBanco == 'MSSQL', 'SUBSTRING', 'SUBSTR')
      Local cConcat   := Iif(cBanco == 'MSSQL', '+', '||')
      Local cIssueData:= ''
      Local cDataErp  := ''
      Local nTamEmp   := Len(FWCodEmp())
      Private nTamSA1 := Len(RTRIM(fwxFilial("SA1")))
      Private nTamCC2 := Len(RTRIM(fwxFilial("CC2")))
      Private nTamSX5 := Len(RTRIM(fwxFilial("SX5")))      
      Private nTamSA3 := Len(RTRIM(fwxFilial("SA3")))  

      cQuery := " SELECT * "
      cQuery += " FROM ( "
      cQuery += " 	SELECT SF2.R_E_C_N_O_ "
      cQuery += " 		,ROW_NUMBER() OVER ( "
      cQuery += " 			ORDER BY SF2.S_T_A_M_P_ "
      cQuery += " 			) ITEM_ORDER "
      cQuery += " 		,SF2.S_T_A_M_P_ "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(SF2.F2_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SF2.F2_DOC) " + cConcat + " '|' " + cConcat + " RTRIM(SF2.F2_SERIE) " + cConcat + " '|' " + cConcat + " RTRIM(SF2.F2_CLIENTE) " + cConcat + " '|' " + cConcat + " RTRIM(SF2.F2_LOJA) AS inv_id "
      cQuery += " 		,'" + cxEmp + "' AS COMPANY_ID "
      cQuery += " 		,'" + cxEmp + "' AS COMPANY_CODE "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SF2.F2_FILIAL IS NULL "
      cQuery += " 				THEN ' ' "
      cQuery += " 			ELSE CAST(SF2.F2_FILIAL AS CHAR(" +cValToChar(Len(SF2->F2_FILIAL))+ ")) "
      cQuery += " 			END AS BRANCH_ID "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SF2.F2_FILIAL IS NULL "
      cQuery += " 				THEN ' ' "
      cQuery += " 			ELSE CAST(SF2.F2_FILIAL AS CHAR(" +cValToChar(Len(SF2->F2_FILIAL))+ ")) "
      cQuery += " 			END AS BRANCH_CODE "
      cQuery += " 		,' ' AS BRANCH_DESCRIPTION "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SA1.A1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SF2.F2_CLIENTE, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SF2.F2_LOJA, ' ')), ' '), '|') " + cConcat + " '|C' AS CUSTOMER_ID "
      cQuery += " 		,RTRIM(COALESCE(SA1.A1_CGC, ' ')) AS customer_document "
      cQuery += " 		,RTRIM(COALESCE(SA1.A1_NOME, ' ')) AS customer_name "
      cQuery += " 		,' ' AS customer_group "
      cQuery += " 		,RTRIM(COALESCE(CC2.CC2_CODMUN, ' ')) AS cus_city_id "
      cQuery += " 		,RTRIM(COALESCE(CC2.CC2_MUN, ' ')) AS customer_city_description "
      cQuery += " 		,RTRIM(COALESCE(X5EST.X5_DESCRI, ' ')) AS customer_state_description "
      cQuery += " 		,RTRIM(COALESCE(SA31.A3_COD, ' ')) AS seller "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SA31.A3_FILIAL,' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SA31.A3_COD, ' '))  as seller_id "
      cQuery += " 		,RTRIM(COALESCE(SA31.A3_NOME, ' ')) AS seller_name "
      cQuery += " 		,' ' AS responsible_customer_crm_id "
      cQuery += " 		,' ' AS responsible_customer_crm_name "
      cQuery += " 		,SF2.F2_DOC AS inv_number "
      cQuery += " 		,SF2.F2_TIPO AS inv_type "
      cQuery += " 		,SF2.F2_EMISSAO AS issue_date "

      cQuery += " 		,SF2.F2_VALICM as valicms "
      cQuery += " 		,SF2.F2_VALIMP6 as valpis "
      cQuery += " 		,SF2.F2_VALIMP5 as valcofins "
      cQuery += " 		,SF2.F2_VALIPI as valipi "

      cQuery += " 		,(select  sum(SD2.D2_QUANT) quantity FROM " + RetSqlName('SD2') + " SD2  "
      cQuery += " 		where SD2.D2_FILIAL = SF2.F2_FILIAL  "
      cQuery += " 		AND SD2.D2_DOC = SF2.F2_DOC  "
      cQuery += " 		AND SD2.D2_SERIE = SF2.F2_SERIE  "
      cQuery += " 		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
      cQuery += " 		AND SD2.D2_LOJA =SF2.F2_LOJA "
      cQuery += " 		AND SD2.D_E_L_E_T_ = '') as quantity "
      cQuery += "  "
      cQuery += " 		,(select sum(SD2.D2_TOTAL) total_value FROM " + RetSqlName('SD2') + " SD2  "
      cQuery += " 		where SD2.D2_FILIAL = SF2.F2_FILIAL  "
      cQuery += " 		AND SD2.D2_DOC = SF2.F2_DOC  "
      cQuery += " 		AND SD2.D2_SERIE = SF2.F2_SERIE  "
      cQuery += " 		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
      cQuery += " 		AND SD2.D2_LOJA = SF2.F2_LOJA "
      cQuery += " 		AND SD2.D_E_L_E_T_ = '') as total_value "
      cQuery += " 	 "
      cQuery += " 		,SF2.S_T_A_M_P_ AS INSERT_ERP "
      cQuery += " 		,SF2.F2_FILIAL "
      cQuery += " 		,SF2.D_E_L_E_T_  as CANCELED "

      cQuery += "FROM " + RetSqlName('SF2') + " SF2 "

      cQuery += "LEFT JOIN " + RetSqlName('SA1') + " SA1 ON " + fFilial('SA1','SF2', cSubs) 
      cQuery += "		AND SA1.A1_COD = SF2.F2_CLIENTE "
      cQuery += "		AND SA1.A1_LOJA = SF2.F2_LOJA "
      cQuery += "		AND SA1.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('CC2') + " CC2 ON " + fFilial('CC2','SF2', cSubs) 
      cQuery += "		AND CC2.CC2_CODMUN = SA1.A1_COD_MUN "
      cQuery += "		AND CC2.CC2_EST = SA1.A1_EST "
      cQuery += "		AND CC2.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SA3') + " SA31 ON " + fFilial('SA31','SF2', cSubs) 
      cQuery += "		AND SA31.A3_COD = SF2.F2_VEND1 "
      cQuery += "		AND SA31.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SX5') + " X5EST ON " + fFilial('X5EST','SF2', cSubs) 
      cQuery += "		AND X5EST.X5_TABELA = '12' "
      cQuery += "		AND X5EST.X5_CHAVE = SA1.A1_EST "
      cQuery += "		AND X5EST.D_E_L_E_T_ = ' ' "
      
      If !Empty(cFiltroFil)
            cQuery += " WHERE " + cFiltroFil
      Else
            cQuery += " WHERE SF2.F2_FILIAL >= ' ' " // + cSubs + "(SF2.F2_FILIAL, 1,"  + cValToChar(Len(cEmpAnt)) + ") = '" + SubStr(fwxFilial("SF2"),1,Len(cEmpAnt)) + "' "   
      Endif
            
      For ni := 1 to Len(aFilter)
            cQuery += aFilter[ni]
      Next ni
      // AND SF2.D_E_L_E_T_ = ' ' serï¿½ enviado todos os registros para analytics, deletados ou nï¿½o, mas marcaremos os deletados com: "canceled" : "*"
      cQuery += "      ) " // AND SF2.D_E_L_E_T_ = ' '
      cQuery += " TRB   "
      cQuery += fAddOffSet(cBanco, nPage, nSize, lOffSet)

      cQuery := ChangeQuery(cQuery)
      cxAlias := GetNextAlias()
      If oWS:isQuery
            lSeek := .F.
            cJson := '{ "items": [ { "query":"' + cQuery + '"} '
            Return Nil
      Endif
	MPSysOpenQuery(cQuery,cxAlias )	
	
      cJson := '{ "items": ['
      If (cxAlias)->(!(EoF()))
            lSeek := .T.
      Endif      
      nRec := 0
	While (cxAlias)->(!(EoF()))
            nRec := nRec + 1
            
            cFilName := StrxTran(NoAcento(Alltrim(FWFilialName(cEmpAnt, (cxAlias)->F2_FILIAL, 1))))
            
            cEmpName := StrxTran(FWCompanyName(cEmpAnt,(cxAlias)->branch_id))
            cCompanyid:= SubStr((cxAlias)->branch_id, 1, nTamEmp)
            
            cIssueData:= SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2)
            cDataErp := Iif(!Empty(SubStr(dtos((cxAlias)->insert_erp),1,4)), SubStr(dtos((cxAlias)->insert_erp),1,4) + '-' + SubStr(DtoS((cxAlias)->insert_erp),5,2) + '-' + SubStr(DtoS((cxAlias)->insert_erp),7,2),cIssueData)

            cJson += '{'
            cJson += '    "invoice_id":"' + Alltrim((cxAlias)->inv_id) + '", '
            cJson += '    "company_id":"' + cCompanyid + '", '
            cJson += '    "company_code":"' + cCompanyid + '", '
            cJson += '    "company_description":"' + Alltrim(cEmpName) + '", '
            cJson += '    "branch_id":"' + Alltrim((cxAlias)->branch_id) + '", '
            cJson += '    "branch_code":"' + Alltrim((cxAlias)->branch_code) + '", '
            cJson += '    "branch_description":"' + Alltrim(cFilName) + '", '
            cJson += '    "customer_id":"' + Alltrim((cxAlias)->customer_id) + '", '
            cJson += '    "customer_document":"' + Alltrim((cxAlias)->customer_document) + '", '
            cJson += '    "customer_name":"' + NoAcento(Alltrim((cxAlias)->customer_name)) + '", '
            cJson += '    "customer_group":"' + Alltrim((cxAlias)->customer_group) + '", '
            cJson += '    "customer_city_id":"' + Alltrim((cxAlias)->cus_city_id) + '", '
            cJson += '    "customer_city_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_city_description))) + '", '
            cJson += '    "customer_state_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_state_description))) + '", '
            cJson += '    "seller_id":"' + IIF(!Empty((cxAlias)->seller), Alltrim((cxAlias)->seller_id), '' ) + '", '
            cJson += '    "seller_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->seller_name))) + '", '
            cJson += '    "responsible_customer_crm_id":"' + Alltrim((cxAlias)->responsible_customer_crm_id) + '", '
            cJson += '    "responsible_customer_crm_name":"' + StrxTran(Alltrim((cxAlias)->responsible_customer_crm_name)) + '", '
            cJson += '    "sales_order_number":"", '
            cJson += '    "invoice_number":"' + Alltrim((cxAlias)->inv_number ) + '", '
            cJson += '    "invoice_type":"' + Alltrim((cxAlias)->inv_type ) + '", '
            cJson += '    "issue_date":"' + cIssueData +'", '  

            cJson += '    "valicms":"' + cValToChar((cxAlias)->valicms) + '", '
            cJson += '    "valpis":"' + cValToChar((cxAlias)->valpis) + '", '                        
            cJson += '    "valcofins":"' + cValToChar((cxAlias)->valcofins) + '", '                        
            cJson += '    "valipi":"' + cValToChar((cxAlias)->valipi) + '", '                        

            cJson += '    "total_quantity":"' + cValToChar((cxAlias)->quantity) + '", '
            cJson += '    "total_value":"' + cValToChar((cxAlias)->total_value) + '", '                        

            cJson += '    "insert_update_erp":"' + cDataErp +' 00:00:00", '         
            cJson += '    "insert_update_crm":"' + SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + ' ' + Time() + '", '                                    
            cJson += '    "canceled" :"' + (cxAlias)->CANCELED + '" '
            cJson += '},'
            (cxAlias)->(dbSkip())
      Enddo
     
      (cxAlias)->( dbCloseArea() ) 

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} fJsonItemInvoice
Funcao para obter o Json de itens da nota.
@author  Alessandro Afonso 
@version	1.0
@since	09/04/2021 
@type function
/*/
//-------------------------------------------------------------------

Static Function fJsonItemInvoice(nPage, nSize, oWS, cBanco, nRec, lSeek, cJson, lforceInitialDate, lOffSet) 
      Local cQuery    := ""
      Local cxAlias   := ""
      Local cFilName  := ''
      Local cFiltroFil:= fFiltroFilial(oWs,"SD2")
      Local lCarga    := .F.
      Local aFilter   := fFilter(oWs, cBanco, @lCarga, "SD2.", "D2_EMISSAO", lforceInitialDate)
      Local ni        := 0 
      Local cxEmp     := Alltrim(cEmpAnt)
      Local cSubs     := Iif(cBanco == 'MSSQL', 'SUBSTRING', 'SUBSTR')
      Local cConcat   := Iif(cBanco == 'MSSQL', '+', '||')
      Local cIssueData:= ''
      Local cDataErp  := ''
      Local nTamEmp   := Len(FWCodEmp())
      Private nTamSA1 := Len(RTRIM(fwxFilial("SA1")))
      Private nTamCC2 := Len(RTRIM(fwxFilial("CC2")))
      Private nTamSX5 := Len(RTRIM(fwxFilial("SX5")))      
      Private nTamSA3 := Len(RTRIM(fwxFilial("SA3")))  
      Private nTamSBM := Len(RTRIM(fwxFilial("SBM")))
      Private nTamSAH := Len(RTRIM(fwxFilial("SAH")))
      Private nTamSB1 := Len(RTRIM(fwxFilial("SB1")))

      cQuery := "SELECT * "
      cQuery += "FROM ( "
      cQuery += "	SELECT SD2.R_E_C_N_O_,  ROW_NUMBER() OVER ( "
      cQuery += "	ORDER BY SD2.S_T_A_M_P_ "
      cQuery += "	) ITEM_ORDER "
      cQuery += ",SD2.S_T_A_M_P_ "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " RTRIM(SD2.D2_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_DOC) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_SERIE) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_CLIENTE) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_LOJA) AS inv_id "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " RTRIM(SD2.D2_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_DOC) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_SERIE) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_CLIENTE) " + cConcat + " '|' " + cConcat + " RTRIM(SD2.D2_LOJA) " + cConcat + " '|' " + cConcat + " SD2.D2_ITEM AS inv_item_id "
      cQuery += ",'" + cxEmp + "' AS COMPANY_ID "
      cQuery += ",'" + cxEmp + "' AS COMPANY_CODE "
      cQuery += ",CASE  "
      cQuery += "WHEN SD2.D2_FILIAL IS NULL "
      cQuery += "   THEN ' ' "
      cQuery += "   ELSE CAST(SD2.D2_FILIAL AS CHAR(" +cValToChar(Len(SD2->D2_FILIAL))+ ")) "
      cQuery += "   END AS BRANCH_ID "
      cQuery += "	,CASE  "
      cQuery += "   WHEN SD2.D2_FILIAL IS NULL "
      cQuery += "   THEN ' ' "
      cQuery += "   ELSE CAST(SD2.D2_FILIAL AS CHAR(" +cValToChar(Len(SD2->D2_FILIAL))+ ")) "
      cQuery += "   END AS BRANCH_CODE "
      cQuery += ",' ' AS BRANCH_DESCRIPTION "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SA1.A1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SD2.D2_CLIENTE, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SD2.D2_LOJA, ' ')), ' '), '|') " + cConcat + " '|C' AS CUSTOMER_ID "
      cQuery += ",RTRIM(COALESCE(SA1.A1_CGC, ' ')) as customer_document "
      cQuery += ",RTRIM(COALESCE(SA1.A1_NOME, ' ')) as customer_name "
      cQuery += ",' ' as customer_group "
      cQuery += ",RTRIM(COALESCE(CC2.CC2_CODMUN, ' ')) as cus_city_id  "
      cQuery += ",RTRIM(COALESCE(CC2.CC2_MUN, ' ')) as customer_city_description "
      cQuery += ",RTRIM(COALESCE(X5EST.X5_DESCRI, ' '))  as customer_state_description "
      cQuery += ",RTRIM(COALESCE(SA31.A3_COD, ' ')) as seller "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SA31.A3_FILIAL,' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SA31.A3_COD, ' '))  as seller_id "      
      cQuery += ",RTRIM(COALESCE(SA31.A3_NOME, ' '))as seller_name "
      cQuery += ",' ' sales_sf2_order_number "
      cQuery += ",SD2.D2_DOC as inv_number "
      cQuery += ",SF2.F2_TIPO as inv_type "
      cQuery += ",SF2.F2_EMISSAO as issue_date "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SB1.B1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SD2.D2_COD, ' ')), ' '), '') AS product_id "
      cQuery += ",SB1.B1_COD as product_code "
      cQuery += ",SB1.B1_DESC as product_description "
      cQuery += ",'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SBM.BM_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SBM.BM_GRUPO, ' ')), ' '), '')  as p_group_id "
      cQuery += ",RTRIM(COALESCE(SBM.BM_GRUPO, ' ')) as p_group_code "
      cQuery += ",RTRIM(COALESCE(SBM.BM_DESC, ' ')) as p_group_description "
      cQuery += ",RTRIM(COALESCE(SD2.D2_PEDIDO, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SD2.D2_ITEMPV, ' ')) as sales_order_number "
      cQuery += ",RTRIM(COALESCE(SD2.D2_CF, ' ')) as fiscal_nature "
      cQuery += ",RTRIM(COALESCE(SAH.AH_UNIMED, ' ')) as unit_measure "
      cQuery += ",SD2.D2_QUANT as quantity "
      cQuery += ",SD2.D2_PRCVEN as unit_value "
      cQuery += ",SD2.D2_TOTAL as total_value "
      
      cQuery += ",SD2.D2_VALICM as valicms "
      cQuery += ",SD2.D2_VALIMP6 as valpis "
      cQuery += ",SD2.D2_VALIMP5 as valcofins "
      cQuery += ",SD2.D2_VALIPI as valipi "

      cQuery += ",SD2.S_T_A_M_P_ AS INSERT_ERP "
      cQuery += ",SD2.D2_FILIAL "
      cQuery += ",' ' as responsible_customer_crm_id "
      cQuery += ",' ' as responsible_customer_crm_name "
      cQuery += ",SD2.D_E_L_E_T_  as CANCELED "

      cQuery += "FROM " + RetSqlName('SD2') + " SD2 "
      cQuery += "LEFT JOIN " + RetSqlName('SA1') + " SA1 ON " + fFilial('SA1','SD2', cSubs) 
      cQuery += "		AND SA1.A1_COD = SD2.D2_CLIENTE "
      cQuery += "		AND SA1.A1_LOJA = SD2.D2_LOJA "
      cQuery += "		AND SA1.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('CC2') + " CC2 ON " + fFilial('CC2','SD2', cSubs) 
      cQuery += "		AND CC2.CC2_CODMUN = SA1.A1_COD_MUN "
      cQuery += "		AND CC2.CC2_EST = SA1.A1_EST "
      cQuery += "		AND CC2.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SF2') + " SF2 ON SF2.F2_FILIAL = SD2.D2_FILIAL " 
      cQuery += "		AND SF2.F2_DOC = SD2.D2_DOC "
      cQuery += "		AND SF2.F2_SERIE = SD2.D2_SERIE "
      cQuery += "		AND SF2.F2_CLIENTE = SD2.D2_CLIENTE  "
      cQuery += "		AND SF2.F2_LOJA = SD2.D2_LOJA "
      cQuery += "		AND SF2.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SA3') + " SA31 ON " + fFilial('SA31','SD2', cSubs) 
      cQuery += "		AND SA31.A3_COD = SF2.F2_VEND1 "
      cQuery += "		AND SA31.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SB1') + " SB1 ON " + fFilial('SB1','SD2', cSubs) 
      cQuery += "		AND SB1.B1_COD = SD2.D2_COD "
      cQuery += "		AND SB1.D_E_L_E_T_ = ' '  "
      cQuery += "LEFT JOIN " + RetSqlName('SX5') + " X5EST ON " + fFilial('X5EST','SD2', cSubs) 
      cQuery += "		AND X5EST.X5_TABELA = '12' "
      cQuery += "		AND X5EST.X5_CHAVE = SA1.A1_EST "
      cQuery += "		AND X5EST.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SBM') + " SBM ON " + fFilial('SBM','SD2', cSubs) 
      cQuery += "		AND SBM.BM_GRUPO = SB1.B1_GRUPO "
      cQuery += "		AND SBM.D_E_L_E_T_ = ' ' "
      cQuery += "LEFT JOIN " + RetSqlName('SAH') + " SAH ON " + fFilial('SAH','SD2', cSubs) 
      cQuery += "		AND SAH.AH_UNIMED = SB1.B1_UM "
      cQuery += "		AND SAH.D_E_L_E_T_ = ' ' "
      
      If !Empty(cFiltroFil)
            cQuery += " WHERE " + cFiltroFil
      Else
            cQuery += " WHERE SD2.D2_FILIAL >= ' ' "// + cSubs + "(SD2.D2_FILIAL, 1,"  + cValToChar(Len(cEmpAnt)) + ") = '" + SubStr(fwxFilial("SD2"),1,Len(cEmpAnt)) + "' "   
      Endif
            
      For ni := 1 to Len(aFilter)
            cQuery += aFilter[ni]
      Next ni
      // AND SD2.D_E_L_E_T_ = ' ' serï¿½ enviado todos os registros para analytics, deletados ou nï¿½o, mas marcaremos os deletados com: "canceled" : "*"
      cQuery += "      ) " // AND SD2.D_E_L_E_T_ = ' '
      cQuery += " TRB   "
      cQuery += fAddOffSet(cBanco, nPage, nSize, lOffSet)

      cQuery := ChangeQuery(cQuery)
      cxAlias := GetNextAlias()
      If oWS:isQuery
            lSeek := .F.
            cJson := '{ "items": [ { "query":"' + cQuery + '"} '
            Return Nil
      Endif
	MPSysOpenQuery(cQuery,cxAlias )	
	
      cJson := '{ "items": ['
      If (cxAlias)->(!(EoF()))
            lSeek := .T.
      Endif      
      nRec := 0
	While (cxAlias)->(!(EoF()))
            nRec := nRec + 1
            
            cFilName := StrxTran(NoAcento(Alltrim(FWFilialName(cEmpAnt, (cxAlias)->D2_FILIAL, 1))))
            
            cEmpName := StrxTran(FWCompanyName(cEmpAnt,(cxAlias)->branch_id))
            cCompanyid:= SubStr((cxAlias)->branch_id, 1, nTamEmp)

            cIssueData:= SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2)
            cDataErp  := Iif(!Empty(SubStr(dtos((cxAlias)->insert_erp),1,4)), SubStr(dtos((cxAlias)->insert_erp),1,4) + '-' + SubStr(DtoS((cxAlias)->insert_erp),5,2) + '-' + SubStr(DtoS((cxAlias)->insert_erp),7,2),cIssueData)

            cJson += '{'
            cJson += '    "invoice_id":"' + Alltrim((cxAlias)->inv_id) + '", '
            cJson += '    "invoice_item_id":"' + Alltrim((cxAlias)->inv_item_id) + '", '
            cJson += '    "company_id":"' + cCompanyid + '", '
            cJson += '    "company_code":"' + cCompanyid + '", '
            cJson += '    "company_description":"' + StrxTran(Alltrim(cEmpName)) + '", '
            cJson += '    "branch_id":"' + Alltrim((cxAlias)->branch_id) + '", '
            cJson += '    "branch_code":"' + Alltrim((cxAlias)->branch_code) + '", '
            cJson += '    "branch_description":"' + Alltrim(cFilName) + '", '
            cJson += '    "customer_id":"' + Alltrim((cxAlias)->customer_id) + '", '
            cJson += '    "customer_document":"' + Alltrim((cxAlias)->customer_document) + '", '
            cJson += '    "customer_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_name))) + '", '
            cJson += '    "customer_group":"' + Alltrim((cxAlias)->customer_group) + '", '
            cJson += '    "customer_city_id":"' + Alltrim((cxAlias)->cus_city_id) + '", '
            cJson += '    "customer_city_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_city_description))) + '", '
            cJson += '    "customer_state_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_state_description))) + '", '
            cJson += '    "seller_id":"' + IIF(!Empty((cxAlias)->seller), Alltrim((cxAlias)->seller_id), '' ) + '", '
            cJson += '    "seller_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->seller_name))) + '", '
            cJson += '    "responsible_customer_crm_id":"' + Alltrim((cxAlias)->responsible_customer_crm_id) + '", '
            cJson += '    "responsible_customer_crm_name":"' + StrxTran(Alltrim((cxAlias)->responsible_customer_crm_name)) + '", '
            cJson += '    "invoice_number":"' + Alltrim((cxAlias)->inv_number ) + '", '
            cJson += '    "invoice_type":"' + Alltrim((cxAlias)->inv_type) + '", '
            cJson += '    "issue_date":"' + SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2) +'", '  
            cJson += '    "product_id":"' + Alltrim((cxAlias)->product_id) + '", '
            cJson += '    "product_code":"' + Alltrim((cxAlias)->product_code) + '", '
            cJson += '    "product_description":"' +StrxTran(NoAcento(Alltrim((cxAlias)->product_description))) + '", '            
            cJson += '    "product_group_id":"' + IIF(!Empty((cxAlias)->p_group_code),Alltrim((cxAlias)->p_group_id),"") + '", '                  
            cJson += '    "product_group_code":"' + Alltrim((cxAlias)->p_group_code) + '", '                  
            cJson += '    "product_group_description":"' +  StrxTran(NoAcento(Alltrim((cxAlias)->p_group_description))) + '", '                  
            cJson += '    "sales_order_number":"' + Alltrim((cxAlias)->sales_order_number) + '", '                  
            cJson += '    "fiscal_nature":"' + Alltrim((cxAlias)->fiscal_nature) + '", '                  
            cJson += '    "unit_measure":"' + Alltrim((cxAlias)->unit_measure) + '", '                  
            cJson += '    "quantity":"' + cValToChar((cxAlias)->quantity) + '", '
            cJson += '    "unit_value":"' + cValToChar((cxAlias)->unit_value) + '", '            
            cJson += '    "total_value":"' + cValToChar((cxAlias)->total_value) + '", '                        

            cJson += '    "valicms":"' + cValToChar((cxAlias)->valicms) + '", '
            cJson += '    "valpis":"' + cValToChar((cxAlias)->valpis) + '", '                        
            cJson += '    "valcofins":"' + cValToChar((cxAlias)->valcofins) + '", '                        
            cJson += '    "valipi":"' + cValToChar((cxAlias)->valipi) + '", '                        

            cJson += '    "insert_update_erp":"' + cDataErp + ' 00:00:00", '            
            cJson += '    "insert_update_crm":"' + SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + ' ' + Time() + '", '
            cJson += '    "canceled" :"' + (cxAlias)->CANCELED + '" '            

            cJson += '},'
            (cxAlias)->(dbSkip())
      Enddo
     
      (cxAlias)->( dbCloseArea() ) 

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} fJsonPed
Funcao para obter o Json do pedido.
@author  Alessandro Afonso 
@version	1.0
@since	09/04/2021 
@type function
/*/
//-------------------------------------------------------------------

Static Function fJsonPed(nPage, nSize, oWS, cBanco, nRec, lSeek, cJson, lforceInitialDate, lOffSet)
      Local cQuery    := ""
      Local cxAlias   := ""
      Local cFilName  := ''
      Local cFiltroFil:= fFiltroFilial(oWs,"SC5")
      Local lCarga    := .F.
      Local aFilter   := fFilter(oWs, cBanco, @lCarga, "SC5.", "C5_EMISSAO", lforceInitialDate)
      Local ni        := 0 
      Local cxEmp     := Alltrim(cEmpAnt)
      Local cSubs     := Iif(cBanco == 'MSSQL', 'SUBSTRING', 'SUBSTR')
      Local cConcat   := Iif(cBanco == 'MSSQL', '+', '||')
      Local cIssueData:= ''
      Local cDataErp  := ''
      Local nTamEmp   := Len(FWCodEmp())
      Local lMadpFwJ1 := ExistBlock("MadpFwJ1")
      Local lMadpFwJ2 := ExistBlock("MadpFwJ2")
      Local cRet      := ""
      Private nTamSA1 := Len(RTRIM(fwxFilial("SA1")))
      Private nTamCC2 := Len(RTRIM(fwxFilial("CC2")))
      Private nTamSX5 := Len(RTRIM(fwxFilial("SX5")))      
      Private nTamSA3 := Len(RTRIM(fwxFilial("SA3")))  
      Private nTamSE4 := Len(RTRIM(fwxFilial("SE4")))

      cQuery := " SELECT * "
      cQuery += " FROM ( "
      cQuery += " 	SELECT SC5.R_E_C_N_O_,  ROW_NUMBER() OVER ( "
      cQuery += " 			ORDER BY SC5.S_T_A_M_P_ "
      cQuery += " 			) ITEM_ORDER "
      cQuery += " 		, SC5.C5_NUM "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(SC5.C5_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SC5.C5_NUM) as order_id "
      cQuery += " 		,'" + cxEmp + "' as COMPANY_ID "
      cQuery += " 		,'" + cxEmp + "' as COMPANY_CODE "
      cQuery += " 		,' '  as company_description "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC5.C5_FILIAL IS NULL "
      cQuery += " 				THEN ' ' "
      cQuery += " 			ELSE CAST(SC5.C5_FILIAL AS CHAR(" +cValToChar(Len(SC5->C5_FILIAL))+ ")) "
      cQuery += " 			END AS BRANCH_ID "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC5.C5_FILIAL IS NULL "
      cQuery += " 				THEN ' ' "
      cQuery += " 			ELSE CAST(SC5.C5_FILIAL AS CHAR(" +cValToChar(Len(SC5->C5_FILIAL))+ ")) "
      cQuery += " 			END AS BRANCH_CODE "
      cQuery += " 		,' ' as BRANCH_DESCRIPTION "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SA1.A1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SC5.C5_CLIENTE, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SC5.C5_LOJACLI, ' ')), ' '), '|') " + cConcat + " '|C' as CUSTOMER_ID "
      cQuery += " 		,RTRIM(COALESCE(SA1.A1_CGC, ' ')) as CUSTOMER_DOCUMENT "
      cQuery += " 		,RTRIM(COALESCE(SA1.A1_NOME, ' ')) as CUSTOMER_NAME "
      cQuery += " 		,' ' as CUSTOMER_GROUP "
      cQuery += " 		,RTRIM(COALESCE(CC2.CC2_CODMUN, ' ')) as CUS_CITY_ID "
      cQuery += " 		,RTRIM(COALESCE(CC2.CC2_MUN, ' ')) as CUSTOMER_CITY_DESCRIPTION "
      cQuery += " 		,RTRIM(COALESCE(X5EST.X5_DESCRI, ' ')) as CUSTOMER_STATE_DESCRIPTION "
      cQuery += " 		,RTRIM(COALESCE(SA31.A3_COD, ' ')) as SELLER "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SA31.A3_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SA31.A3_COD, ' ')) as SELLER_ID "
      cQuery += " 		,RTRIM(COALESCE(SA31.A3_NOME, ' ')) as SELLER_NAME "
      cQuery += " 		,' ' as RESPONSIBLE_CUSTOMER_CRM_ID "
      cQuery += " 		,' ' as RESPONSIBLE_CUSTOMER_CRM_NAME "
      cQuery += " 		,RTRIM(SC5.C5_NUM) as order_number "
      cQuery += " 		,' ' as status_id "
      
      cQuery += " 		,CASE "
	cQuery += " 		      WHEN SC5.C5_LIBEROK = ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ' " 
	cQuery += " 		      THEN 'Pedidos Abertos' "
	cQuery += " 		      WHEN (SC5.C5_NOTA <> ' ' OR SC5.C5_LIBEROK = 'E') AND SC5.C5_BLQ = ' ' "
	cQuery += " 		      THEN 'Pedidos Encerrados' "
	cQuery += " 		      WHEN SC5.C5_LIBEROK <> ' ' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = ' ' "
	cQuery += " 		      THEN 'Pedidos Liberados' "
	cQuery += " 		      WHEN SC5.C5_BLQ = '1' "
	cQuery += " 		      THEN 'Pedidos Bloqueados Por Regra' "
	cQuery += " 		      WHEN SC5.C5_BLQ = '1' "
	cQuery += " 		      THEN 'Pedidos Bloqueados Por Verba' "
	cQuery += " 		      ELSE ' ' "
	cQuery += " 		      END AS STATUS_DESCRIPTION "

      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SE4.E4_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SE4.E4_CODIGO, ' ')) as pay_term_id "
      cQuery += " 		,RTRIM(SE4.E4_DESCRI) as pay_term_description "

      cQuery += " 		,RTRIM(SC5.C5_TIPO) as order_type_id "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC5.C5_TIPO = 'N' "
      cQuery += " 				THEN 'Normal' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'C' "
      cQuery += " 				THEN 'Compl.Preco/Quantidade' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'I' "
      cQuery += " 				THEN 'Compl.ICMS' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'P' "
      cQuery += " 				THEN 'Compl.IPI' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'D' "
      cQuery += " 				THEN 'Devol.Compras' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'B' "
      cQuery += " 				THEN 'Utiliza Fornecedor' "
      cQuery += " 			Else ' ' "
      cQuery += " 			END as sales_order_type_description "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC5.C5_ORIGEM = 'MSGEAI' "
      cQuery += " 				THEN 'EXTERNO' "
      cQuery += " 			WHEN SC5.C5_ORIGEM <> 'MSGEAI' "
      cQuery += " 				THEN 'PROTHEUS' "
      cQuery += " 			END as order_origin_description "
      cQuery += " 		,' ' as origin_order_number	 "
      cQuery += " 		,SC5.C5_EMISSAO as issue_date "
      cQuery += " 		,(select SUM(SC6.C6_QTDVEN) quantity FROM " + RetSqlName('SC6') + " SC6 where SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = '')  as quantity "

      cQuery += " 		,(select SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) total_value from " + RetSqlName('SC6') + " SC6 where SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = '') as total_value "

      cQuery += " 		,(select SUM(SC6.C6_VALDESC) as total_discount_value from " + RetSqlName('SC6') + " SC6 where SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = '')  as total_discount_value "

      cQuery += " 		,( "
      cQuery += " 		         SELECT SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT)  "
      cQuery += " 		         FROM " + RetSqlName('SC6') + " SC6 "
      cQuery += " 		         WHERE SC6.C6_FILIAL = SC5.C5_FILIAL
      cQuery += " 		         AND SC6.C6_NUM = SC5.C5_NUM
      cQuery += " 		         AND SC6.C6_BLQ = 'R'
      cQuery += " 		         AND SC6.D_E_L_E_T_ = ' '
      cQuery += " 		  ) AS  total_quantity_canceled

      cQuery += " 		,( "
      cQuery += " 		         SELECT SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT)  "
      cQuery += " 		         FROM " + RetSqlName('SC6') + " SC6 "
      cQuery += " 		         WHERE SC6.C6_FILIAL = SC5.C5_FILIAL
      cQuery += " 		         AND SC6.C6_NUM = SC5.C5_NUM
      cQuery += " 		         AND SC6.C6_BLQ <> 'R'
      cQuery += " 		         AND SC6.D_E_L_E_T_ = ' '
      cQuery += " 		  ) AS  pending_quantity
      
      cQuery += " 		,(select sum(SC6.C6_QTDENT) from " + RetSqlName('SC6') + " SC6 where SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = '' ) as billed_total_quantity "

      cQuery += " 		,( "
      cQuery += " 		         SELECT SUM((SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN)  "
      cQuery += " 		         FROM " + RetSqlName('SC6') + " SC6 "
      cQuery += " 		         WHERE SC6.C6_FILIAL = SC5.C5_FILIAL
      cQuery += " 		         AND SC6.C6_NUM = SC5.C5_NUM
      cQuery += " 		         AND SC6.C6_BLQ = 'R'
      cQuery += " 		         AND SC6.D_E_L_E_T_ = ' '
      cQuery += " 		  ) AS  total_canceled_value

      cQuery += " 		,( "
      cQuery += " 		         SELECT SUM((SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN)  "
      cQuery += " 		         FROM " + RetSqlName('SC6') + " SC6 "
      cQuery += " 		         WHERE SC6.C6_FILIAL = SC5.C5_FILIAL
      cQuery += " 		         AND SC6.C6_NUM = SC5.C5_NUM
      cQuery += " 		         AND SC6.C6_BLQ <> 'R'
      cQuery += " 		         AND SC6.D_E_L_E_T_ = ' '
      cQuery += " 		  ) AS  total_pending_value

      cQuery += " 		,(select sum(SC6.C6_QTDENT * SC6.C6_PRCVEN) from " + RetSqlName('SC6') + " SC6 where SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = '' ) as total_billed_value		 "
      cQuery += " 		,SC5.S_T_A_M_P_ as INSERT_ERP "
      cQuery += " 		,SC5.C5_FILIAL "
      // ponto de entrada inserido para controlar dados especificos do cliente
      If lMadpFwJ1
            cRet := ExecBlock("MadpFwJ1",.F.,.F.) 
		If ValType(cRet) == "C"
			cQuery += cRet
		EndIf
      Endif
      cQuery += "             ,SC5.D_E_L_E_T_  as CANCELED "

      cQuery += " 		FROM " + RetSqlName('SC5') + " SC5 "

      cQuery += " 		LEFT JOIN " + RetSqlName('SA1') + " SA1 ON " + fFilial('SA1','SC5', cSubs) 
      cQuery += " 			AND SA1.A1_COD = SC5.C5_CLIENTE "
      cQuery += " 			AND SA1.A1_LOJA = SC5.C5_LOJACLI "
      cQuery += " 			AND SA1.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('CC2') + " CC2 ON " + fFilial('CC2','SC5', cSubs) 
      cQuery += " 			AND CC2.CC2_CODMUN = SA1.A1_COD_MUN "
      cQuery += " 			AND CC2.CC2_EST    = SA1.A1_EST "
      cQuery += " 			AND CC2.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SX5') + " X5EST ON " + fFilial('X5EST','SC5', cSubs) 
      cQuery += " 			AND X5EST.X5_TABELA = '12' "
      cQuery += " 			AND X5EST.X5_CHAVE = SA1.A1_EST "
      cQuery += " 			AND X5EST.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SA3') + " SA31 ON " + fFilial('SA31','SC5', cSubs) 
      cQuery += " 			AND SA31.A3_COD = SC5.C5_VEND1 "
      cQuery += " 			AND SA31.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SE4') + " SE4 ON " + fFilial('SE4','SC5', cSubs)
      cQuery += " 			AND SE4.E4_CODIGO = SC5.C5_CONDPAG "
      cQuery += " 			AND SE4.D_E_L_E_T_ = ' ' "

      If !Empty(cFiltroFil)
            cQuery += " WHERE " + cFiltroFil
      Else
            cQuery += " WHERE SC5.C5_FILIAL >= ' ' " // + cSubs + "(SC5.C5_FILIAL, 1,"  + cValToChar(Len(cEmpAnt)) + ") = '" + SubStr(fwxFilial("SC5"),1,Len(cEmpAnt)) + "' "   
      Endif
            
      For ni := 1 to Len(aFilter)
            cQuery += aFilter[ni]
      Next ni
      // AND SC5.D_E_L_E_T_ = ' ' serï¿½ enviado todos os registros para analytics, deletados ou nï¿½o, mas marcaremos os deletados com: "canceled" : "*"
      cQuery += "  ) "      
      cQuery += " TRB   "
      cQuery += fAddOffSet(cBanco, nPage, nSize, lOffSet)
      

      cQuery := ChangeQuery(cQuery)
      cxAlias := GetNextAlias()
      If oWS:isQuery
            lSeek := .F.
            cJson := '{ "items": [ { "query":"' + cQuery + '"} '
            Return Nil
      Endif
	MPSysOpenQuery(cQuery,cxAlias)	
	
      cJson := '{ "items": ['
      If (cxAlias)->(!(EoF()))
            lSeek := .T.
      Endif      
      nRec := 0
	While (cxAlias)->(!(EoF()))
            nRec := nRec + 1
            
            cFilName := StrxTran(NoAcento(Alltrim(FWFilialName(cEmpAnt, (cxAlias)->C5_FILIAL, 1))))
            cEmpName := StrxTran(FWCompanyName(cEmpAnt,(cxAlias)->branch_id))
            cCompanyid:= SubStr((cxAlias)->branch_id, 1, nTamEmp)

            cIssueData:= SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2)
            cDataErp  := Iif(!Empty(SubStr(dtos((cxAlias)->insert_erp),1,4)), SubStr(dtos((cxAlias)->insert_erp),1,4) + '-' + SubStr(DtoS((cxAlias)->insert_erp),5,2) + '-' + SubStr(DtoS((cxAlias)->insert_erp),7,2),cIssueData)

            cJson += '{'
            cJson += '    "sales_order_id":"' + Alltrim((cxAlias)->order_id) + '", '
            cJson += '    "company_id":"' + cCompanyid + '", '
            cJson += '    "company_code":"' + cCompanyid + '", '
            cJson += '    "company_description":"' + Alltrim(cEmpName) + '", '
            cJson += '    "branch_id":"' + Alltrim((cxAlias)->branch_id) + '", '
            cJson += '    "branch_code":"' + Alltrim((cxAlias)->branch_code) + '", '
            cJson += '    "branch_description":"' + Alltrim(cFilName) + '", '
            cJson += '    "customer_id":"' + Alltrim((cxAlias)->customer_id) + '", '
            cJson += '    "customer_document":"' + Alltrim((cxAlias)->customer_document) + '", '
            cJson += '    "customer_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_name))) + '", '
            cJson += '    "customer_group":"' + Alltrim((cxAlias)->customer_group) + '", '
            cJson += '    "customer_city_id":"' + Alltrim((cxAlias)->cus_city_id) + '", '
            cJson += '    "customer_city_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_city_description))) + '", '
            cJson += '    "customer_state_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_state_description))) + '", '
            cJson += '    "seller_id":"' + IIF(!Empty((cxAlias)->seller), Alltrim((cxAlias)->seller_id), '' ) + '", '
            cJson += '    "seller_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->seller_name))) + '", '
            cJson += '    "responsible_customer_crm_id":"", '
            cJson += '    "responsible_customer_crm_name":"", '
            cJson += '    "sales_order_number":"' + Alltrim((cxAlias)->order_number) + '", '
            cJson += '    "status_id":"", '
            cJson += '    "status_description":"' + StrxTran(Alltrim((cxAlias)->STATUS_DESCRIPTION)) + '", '
            cJson += '    "payment_term_id":"' + Alltrim((cxAlias)->pay_term_id) + '", '
            cJson += '    "payment_term_description":"' + StrxTran(Alltrim((cxAlias)->pay_term_description)) + '", '
            cJson += '    "sales_order_type_id":"' + Alltrim((cxAlias)->order_type_id) + '", '
            cJson += '    "sales_order_type_description":"' + Alltrim((cxAlias)->sales_order_type_description) + '", '
            cJson += '    "sales_order_origin_number":"' + Alltrim((cxAlias)->origin_order_number) + '", '
            cJson += '    "sales_order_origin_description":"' + Alltrim((cxAlias)->order_origin_description) + '", '
            cJson += '    "issue_date":"' + SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2) +'", '  

            cJson += '    "total_quantity":"' + cValToChar((cxAlias)->quantity) + '", '
            cJson += '    "total_quantity_canceled":"' + cValToChar((cxAlias)->total_quantity_canceled) + '", '
            cJson += '    "total_quantity_pending":"' + cValToChar((cxAlias)->pending_quantity) + '", '            
            cJson += '    "total_quantity_billed":"' + cValToChar((cxAlias)->billed_total_quantity) + '", '

            cJson += '    "total_value":"' + cValToChar((cxAlias)->total_value) + '", '                  
            cJson += '    "total_discount_value":"' +  cValToChar((cxAlias)->total_discount_value) + '", '    
            cJson += '    "total_canceled_value":"' +  cValToChar((cxAlias)->total_canceled_value) + '", '                  
            cJson += '    "total_pending_value":"' +  cValToChar((cxAlias)->total_pending_value) + '", '                  
            cJson += '    "total_billed_value":"' +  cValToChar((cxAlias)->total_billed_value) + '", '                  
            // ponto de entrada inserido para controlar dados especificos do cliente
            If lMadpFwJ2
                  cRet := ExecBlock("MadpFwJ2",.F.,.F., {cxAlias}) 
                  If ValType(cRet) == "C"
                        cJson += cRet
                  EndIf
            Endif
            cJson += '    "insert_update_erp":"' + cDataErp + ' 00:00:00", '            
            cJson += '    "insert_update_crm":"' + SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + ' ' + Time() + '", '
            cJson += '    "canceled" :"' + (cxAlias)->CANCELED + '" '   

            cJson += '},'
            (cxAlias)->(dbSkip())
      Enddo
     
      (cxAlias)->( dbCloseArea() ) 

Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} fJsonItemPed
Funcao para obter o Json de itens do pedido.
@author  Alessandro Afonso 
@version	1.0
@since	09/04/2021 
@type function
/*/
//-------------------------------------------------------------------

Static Function fJsonItemPed(nPage, nSize, oWS, cBanco, nRec, lSeek, cJson, lforceInitialDate, lOffSet)
      Local cQuery    := ""
      Local cxAlias   := ""
      Local cFilName  := ''
      Local cFiltroFil:= fFiltroFilial(oWs,"SC6")
      Local lCarga    := .F.
      Local aFilter   := fFilter(oWs, cBanco, @lCarga, "SC5.", "C5_EMISSAO", lforceInitialDate)
      Local ni        := 0 
      Local cxEmp     := Alltrim(cEmpAnt)
      Local cSubs     := Iif(cBanco == 'MSSQL', 'SUBSTRING', 'SUBSTR')
      Local cConcat   := Iif(cBanco == 'MSSQL', '+', '||')
      Local cIssueData:= ''
      Local cDataErp  := ''
      Local nTamEmp   := Len(FWCodEmp())
      Local cRet      := ""
      Local lMadpFwJ3 := ExistBlock("MadpFwJ3")
      Local lMadpFwJ4 := ExistBlock("MadpFwJ4") 
      Private nTamSA1 := Len(RTRIM(fwxFilial("SA1")))
      Private nTamCC2 := Len(RTRIM(fwxFilial("CC2")))
      Private nTamSX5 := Len(RTRIM(fwxFilial("SX5")))      
      Private nTamSA3 := Len(RTRIM(fwxFilial("SA3")))  
      Private nTamSBM := Len(RTRIM(fwxFilial("SBM")))
      Private nTamSAH := Len(RTRIM(fwxFilial("SAH")))
      Private nTamSB1 := Len(RTRIM(fwxFilial("SB1")))
      Private nTamSE4 := Len(RTRIM(fwxFilial("SE4")))

      cQuery := " SELECT * "
      cQuery += " FROM ( "
      cQuery += " SELECT SC6.R_E_C_N_O_,  ROW_NUMBER() OVER ( "
      cQuery += " 			ORDER BY SC6.S_T_A_M_P_ "
      cQuery += " 			) ITEM_ORDER "
      cQuery += " 		 "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(SC5.C5_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SC5.C5_NUM) as order_id "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(SC5.C5_FILIAL) " + cConcat + " '|' " + cConcat + " RTRIM(SC5.C5_NUM)  " + cConcat + " '|' " + cConcat + " RTRIM(SC6.C6_ITEM)  " + cConcat + " '|' " + cConcat + " RTRIM(SC6.C6_PRODUTO) as order_item_id "
      cQuery += " 		,'" + cxEmp + "' as COMPANY_ID "
      cQuery += " 		,'" + cxEmp + "' as COMPANY_CODE "
      cQuery += " 		,' '  as company_description "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC6.C6_FILIAL IS NULL "
      cQuery += " 				THEN ' ' "
      cQuery += " 			ELSE CAST(SC6.C6_FILIAL AS CHAR(" +cValToChar(Len(SC6->C6_FILIAL))+ ")) "
      cQuery += " 			END AS BRANCH_ID "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC6.C6_FILIAL IS NULL "
      cQuery += " 				THEN ' ' "
      cQuery += " 			ELSE CAST(SC6.C6_FILIAL AS CHAR(" +cValToChar(Len(SC6->C6_FILIAL))+ ")) "
      cQuery += " 			END AS BRANCH_CODE "
      cQuery += " 		,' ' as BRANCH_DESCRIPTION "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SA1.A1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SC5.C5_CLIENTE, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SC5.C5_LOJACLI, ' ')), ' '), '|') " + cConcat + " '|C' as CUSTOMER_ID "
      cQuery += " 		,RTRIM(COALESCE(SA1.A1_CGC, ' ')) as CUSTOMER_DOCUMENT "
      cQuery += " 		,RTRIM(COALESCE(SA1.A1_NOME, ' ')) as CUSTOMER_NAME "
      cQuery += " 		,' ' as CUSTOMER_GROUP "
      cQuery += " 		,RTRIM(COALESCE(CC2.CC2_CODMUN, ' ')) as CUS_CITY_ID "
      cQuery += " 		,RTRIM(COALESCE(CC2.CC2_MUN, ' ')) as CUSTOMER_CITY_DESCRIPTION "
      cQuery += " 		,RTRIM(COALESCE(X5EST.X5_DESCRI, ' ')) as CUSTOMER_STATE_DESCRIPTION "
      cQuery += " 		,RTRIM(COALESCE(SA31.A3_COD, ' ')) as SELLER "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SA31.A3_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SA31.A3_COD, ' ')) as SELLER_ID "
      cQuery += " 		,RTRIM(COALESCE(SA31.A3_NOME, ' ')) as SELLER_NAME "
      cQuery += " 		,' ' as RESPONSIBLE_CUSTOMER_CRM_ID "
      cQuery += " 		,' ' as RESPONSIBLE_CUSTOMER_CRM_NAME "
      cQuery += " 		,RTRIM(SC5.C5_NUM) as order_number "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " RTRIM(COALESCE(SE4.E4_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SE4.E4_CODIGO, ' ')) as pay_term_id "
      cQuery += " 		,RTRIM(SE4.E4_DESCRI) as pay_term_description "
      cQuery += " 		,RTRIM(SC5.C5_TIPO) as order_type_id "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC5.C5_TIPO = 'N' "
      cQuery += " 				THEN 'Normal' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'C' "
      cQuery += " 				THEN 'Compl.Preco/Quantidade' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'I' "
      cQuery += " 				THEN 'Compl.ICMS' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'P' "
      cQuery += " 				THEN 'Compl.IPI' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'D' "
      cQuery += " 				THEN 'Devol.Compras' "
      cQuery += " 			WHEN SC5.C5_TIPO = 'B' "
      cQuery += " 				THEN 'Utiliza Fornecedor' "
      cQuery += " 			Else ' ' "
      cQuery += " 			END as sales_order_type_description "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC5.C5_ORIGEM = 'MSGEAI' "
      cQuery += " 				THEN 'EXTERNO' "
      cQuery += " 			WHEN SC5.C5_ORIGEM <> 'MSGEAI' "
      cQuery += " 				THEN 'PROTHEUS' "
      cQuery += " 			END as order_origin_description "
      cQuery += " 		,' ' as origin_order_number	 "
      cQuery += " 		,SC5.C5_EMISSAO as issue_date "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SB1.B1_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SB1.B1_COD, ' ')), ' '), '') as product_id "
      cQuery += " 		,RTRIM(COALESCE(SC6.C6_PRODUTO, ' ')) as product_code "
      cQuery += " 		,RTRIM(COALESCE(SB1.B1_DESC, ' '))  as product_description  "
      cQuery += " 		,'" + cxEmp + "|' " + cConcat + " COALESCE(NULLIF(RTRIM(COALESCE(SBM.BM_FILIAL, ' ')) " + cConcat + " '|' " + cConcat + " RTRIM(COALESCE(SBM.BM_GRUPO, ' ')), ' '), '') as p_group_id "
      cQuery += " 		,RTRIM(COALESCE(SBM.BM_GRUPO, ' ')) as p_group_code "
      cQuery += " 		,RTRIM(COALESCE(SBM.BM_DESC, ' ')) as p_group_description "
      cQuery += " 		,' ' as status_id "
      
      cQuery += " 		,CASE "
	cQuery += " 		      WHEN SC5.C5_LIBEROK = ' ' AND SC5.C5_NOTA = ' ' AND SC5.C5_BLQ = ' ' " 
	cQuery += " 		      THEN 'Pedidos Abertos' "
	cQuery += " 		      WHEN (SC5.C5_NOTA <> ' ' OR SC5.C5_LIBEROK = 'E') AND SC5.C5_BLQ = ' ' "
	cQuery += " 		      THEN 'Pedidos Encerrados' "
	cQuery += " 		      WHEN SC5.C5_LIBEROK <> ' ' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = ' ' "
	cQuery += " 		      THEN 'Pedidos Liberados' "
	cQuery += " 		      WHEN SC5.C5_BLQ = '1' "
	cQuery += " 		      THEN 'Pedidos Bloqueados Por Regra' "
	cQuery += " 		      WHEN SC5.C5_BLQ = '1' "
	cQuery += " 		      THEN 'Pedidos Bloqueados Por Verba' "
	cQuery += " 		      ELSE ' ' "
	cQuery += " 		      END AS STATUS_DESCRIPTION "

      cQuery += " 		,RTRIM(COALESCE(SAH.AH_UNIMED, ' ')) as unit_measure "
      cQuery += " 		,SC6.C6_QTDVEN as quantity "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC6.C6_BLQ = 'R' "
      cQuery += " 				THEN SC6.C6_QTDVEN - SC6.C6_QTDENT "
      cQuery += " 			WHEN SC5.C5_ORIGEM <> 'R' "
      cQuery += " 				THEN 0 "
      cQuery += " 			END as canc_quantity "
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC6.C6_BLQ = 'R' "
      cQuery += " 				THEN 0 "
      cQuery += " 			WHEN SC5.C5_ORIGEM <> 'R' "
      cQuery += " 				THEN SC6.C6_QTDVEN - SC6.C6_QTDENT  "
      cQuery += " 			END as pending_quantity "
      cQuery += " 		,SC6.C6_QTDENT as billed_quantity "
      cQuery += " 		,SC6.C6_PRCVEN as unit_value "
      cQuery += " 		,SC6.C6_VALDESC as discount_value "
      
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC6.C6_BLQ = 'R' "
      cQuery += " 				THEN (SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN "
      cQuery += " 			WHEN SC5.C5_ORIGEM <> 'R' "
      cQuery += " 				THEN 0 "
      cQuery += " 			END as canceled_value "
      
      cQuery += " 		,CASE  "
      cQuery += " 			WHEN SC6.C6_BLQ = 'R' "
      cQuery += " 				THEN 0 "
      cQuery += " 			WHEN SC6.C6_BLQ <> 'R' "
      cQuery += " 				THEN ( (SC6.C6_QTDVEN - SC6.C6_QTDENT) * SC6.C6_PRCVEN)"
      cQuery += " 			END as pending_value "

      cQuery += " 		,(SC6.C6_QTDVEN * SC6.C6_PRCVEN) as total_value "

      cQuery += " 		,CASE 
      cQuery += " 		     WHEN (SC6.C6_BLQ = 'R' AND SC6.C6_QTDENT = 0)
      cQuery += " 		            THEN  0
      cQuery += " 		     WHEN (SC6.C6_BLQ <> 'R' AND SC6.C6_QTDENT > 0 )
      cQuery += " 		            THEN (SC6.C6_QTDENT * SC6.C6_PRCVEN) 
      cQuery += " 		     ELSE     0
      cQuery += " 		     END as total_billed_value "
      // ponto de entrada inserido para controlar dados especificos do cliente
      If lMadpFwJ3
            cRet := ExecBlock("MadpFwJ3",.F.,.F.) 
            If ValType(cRet) == "C"
                  cQuery += cRet
            EndIf
      Endif
      cQuery += " 		,SC5.S_T_A_M_P_ as INSERT_ERP "
      cQuery += "             ,SC6.C6_FILIAL "
      cQuery += "             ,SC6.D_E_L_E_T_  as CANCELED "

      cQuery += " 		FROM " + RetSqlName('SC6') + " SC6 "
      cQuery += " 		INNER JOIN " + RetSqlName('SC5') + " SC5 ON SC5.C5_FILIAL = SC6.C6_FILIAL "
      cQuery += " 			AND SC5.C5_NUM  = SC6.C6_NUM "
      //cQuery += " 			AND SC5.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SA1') + " SA1 ON " + fFilial('SA1','SC6', cSubs) 
      cQuery += " 			AND SA1.A1_COD = SC5.C5_CLIENTE "
      cQuery += " 			AND SA1.A1_LOJA = SC5.C5_LOJACLI "
      cQuery += " 			AND SA1.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('CC2') + " CC2 ON " + fFilial('CC2','SC6', cSubs) 
      cQuery += " 			AND CC2.CC2_CODMUN = SA1.A1_COD_MUN "
      cQuery += " 			AND CC2.CC2_EST    = SA1.A1_EST "
      cQuery += " 			AND CC2.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SX5') + " X5EST ON " + fFilial('X5EST','SC6', cSubs) 
      cQuery += " 			AND X5EST.X5_TABELA = '12' "
      cQuery += " 			AND X5EST.X5_CHAVE = SA1.A1_EST "
      cQuery += " 			AND X5EST.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SA3') + " SA31 ON " + fFilial('SA31','SC6', cSubs) 
      cQuery += " 			AND SA31.A3_COD = SC5.C5_VEND1 "
      cQuery += " 			AND SA31.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SE4') + " SE4 ON " + fFilial('SE4','SC6', cSubs)
      cQuery += " 			AND SE4.E4_CODIGO = SC5.C5_CONDPAG "
      cQuery += " 			AND SE4.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SB1') + " SB1 ON " + fFilial('SB1','SC6', cSubs)
      cQuery += " 			AND SB1.B1_COD = SC6.C6_PRODUTO "
      cQuery += " 			AND SB1.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SBM') + " SBM ON " + fFilial('SBM','SC6', cSubs)
      cQuery += " 			AND SBM.BM_GRUPO = SB1.B1_GRUPO "
      cQuery += " 			AND SBM.D_E_L_E_T_ = ' ' "
      cQuery += " 		LEFT JOIN " + RetSqlName('SAH') + " SAH ON " + fFilial('SAH','SC6', cSubs)
      cQuery += " 			AND SAH.AH_UNIMED = SB1.B1_UM "
      cQuery += " 			AND SAH.D_E_L_E_T_ = ' ' " 

      If !Empty(cFiltroFil)
            cQuery += " WHERE " + cFiltroFil
      Else
            cQuery += " WHERE SC6.C6_FILIAL >= ' ' " // + cSubs + "(SC6.C6_FILIAL, 1,"  + cValToChar(Len(cEmpAnt)) + ") = '" + SubStr(fwxFilial("SC6"),1,Len(cEmpAnt)) + "' "   
      Endif
            
      For ni := 1 to Len(aFilter)
            cQuery += aFilter[ni]
      Next ni

      cQuery += "  ) "      
      
      cQuery += " TRB   "
      cQuery += fAddOffSet(cBanco, nPage, nSize, lOffSet)

      cQuery := ChangeQuery(cQuery)
      cxAlias := GetNextAlias()
      If oWS:isQuery
            lSeek := .F.
            cJson := '{ "items": [ { "query":"' + cQuery + '"} '
            Return Nil
      Endif                  
      
	MPSysOpenQuery(cQuery,cxAlias )	
	Conout("Linha 1215 after exec query orderitem---------------" + DtoS(dDatabase) + " - " + Time() )
      
      cJson := '{ "items": ['
      If (cxAlias)->(!(EoF()))
            lSeek := .T.
      Endif      
      nRec := 0
	While (cxAlias)->(!(EoF()))
            nRec := nRec + 1
           
            cFilName := StrxTran(NoAcento(Alltrim(FWFilialName(cEmpAnt, (cxAlias)->C6_FILIAL, 1))))
            
            cEmpName := StrxTran(FWCompanyName(cEmpAnt,(cxAlias)->branch_id))
            cCompanyid:= SubStr((cxAlias)->branch_id, 1, nTamEmp)

            cIssueData:= SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2)
            cDataErp  := Iif(!Empty(SubStr(dtos((cxAlias)->insert_erp),1,4)), SubStr(dtos((cxAlias)->insert_erp),1,4) + '-' + SubStr(DtoS((cxAlias)->insert_erp),5,2) + '-' + SubStr(DtoS((cxAlias)->insert_erp),7,2),cIssueData)

            cJson += '{'
            cJson += '    "sales_order_id":"' + Alltrim((cxAlias)->order_id) + '", '
            cJson += '    "sales_order_item_id":"' + Alltrim((cxAlias)->order_item_id) + '", '
            cJson += '    "company_id":"' + cCompanyid + '", '
            cJson += '    "company_code":"' + cCompanyid + '", '
            cJson += '    "company_description":"' + Alltrim(cEmpName) + '", '
            cJson += '    "branch_id":"' + Alltrim((cxAlias)->branch_id) + '", '
            cJson += '    "branch_code":"' + Alltrim((cxAlias)->branch_code) + '", '
            cJson += '    "branch_description":"' + Alltrim(cFilName) + '", '
            cJson += '    "customer_id":"' + Alltrim((cxAlias)->customer_id) + '", '
            cJson += '    "customer_document":"' + Alltrim((cxAlias)->customer_document) + '", '
            cJson += '    "customer_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_name))) + '", '
            cJson += '    "customer_group":"' + Alltrim((cxAlias)->customer_group) + '", '
            cJson += '    "customer_city_id":"' + Alltrim((cxAlias)->cus_city_id) + '", '
            cJson += '    "customer_city_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_city_description))) + '", '
            cJson += '    "customer_state_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->customer_state_description))) + '", '
            cJson += '    "seller_id":"' + IIF(!Empty((cxAlias)->seller), Alltrim((cxAlias)->seller_id), '' ) + '", '
            cJson += '    "seller_name":"' + StrxTran(NoAcento(Alltrim((cxAlias)->seller_name))) + '", '
            cJson += '    "responsible_customer_crm_id":"", '
            cJson += '    "responsible_customer_crm_name":"", '
            cJson += '    "sales_order_number":"' + Alltrim((cxAlias)->order_number) + '", '
            cJson += '    "payment_term_id":"' + Alltrim((cxAlias)->pay_term_id) + '", '
            cJson += '    "payment_term_description":"' + StrxTran(Alltrim((cxAlias)->pay_term_description)) + '", '
            cJson += '    "sales_order_type_id":"' + Alltrim((cxAlias)->order_type_id) + '", '
            cJson += '    "sales_order_type_description":"' + Alltrim((cxAlias)->sales_order_type_description) + '", '
            cJson += '    "sales_order_origin_number":"' + Alltrim((cxAlias)->origin_order_number) + '", '
            cJson += '    "sales_order_origin_description":"' + Alltrim((cxAlias)->order_origin_description) + '", '
            cJson += '    "issue_date":"' + SubStr((cxAlias)->issue_date,1,4) + '-' + SubStr((cxAlias)->issue_date,5,2) + '-' + SubStr((cxAlias)->issue_date,7,2) +'", '  
            cJson += '    "product_id":"' + Alltrim((cxAlias)->product_id) + '", '
            cJson += '    "product_code":"' + Alltrim((cxAlias)->product_code) + '", '
            cJson += '    "product_description":"' + StrxTran(NoAcento(Alltrim((cxAlias)->product_description))) + '", '            
            cJson += '    "product_group_id":"' + IIF(!Empty((cxAlias)->p_group_code),Alltrim((cxAlias)->p_group_id),"") + '", '                  
            cJson += '    "product_group_code":"' + Alltrim((cxAlias)->p_group_code) + '", '                  
            cJson += '    "product_group_description":"' +  StrxTran(NoAcento(Alltrim((cxAlias)->p_group_description))) + '", '     
            cJson += '    "status_id":"", '                  
            cJson += '    "status_description":"' + Alltrim((cxAlias)->STATUS_DESCRIPTION) + '", '                
            cJson += '    "unit_measure":"' + Alltrim((cxAlias)->unit_measure) + '", '                  

            cJson += '    "quantity":"' + cValToChar((cxAlias)->quantity) + '", '
            cJson += '    "canceled_quantity":"' + cValToChar((cxAlias)->canc_quantity) + '", '                        
            cJson += '    "pending_quantity":"' + cValToChar((cxAlias)->pending_quantity) + '", '                        
            cJson += '    "billed_quantity":"' + cValToChar((cxAlias)->billed_quantity) + '", '                        

            cJson += '    "unit_value":"' + cValToChar((cxAlias)->unit_value) + '", '            
            cJson += '    "discount_value":"' + cValToChar((cxAlias)->discount_value) + '", '            
            cJson += '    "canceled_value":"' + cValToChar((cxAlias)->canceled_value) + '", '            
            cJson += '    "pending_value":"' + cValToChar((cxAlias)->pending_value) + '", '            
            cJson += '    "total_value":"' + cValToChar((cxAlias)->total_value) + '", '                        
            cJson += '    "total_billed_value":"' + cValToChar((cxAlias)->total_billed_value) + '", '            
            // ponto de entrada inserido para controlar dados especificos do cliente
            If lMadpFwJ4
                  cRet := ExecBlock("MadpFwJ4",.F.,.F., {cxAlias}) 
                  If ValType(cRet) == "C"
                        cJson += cRet
                  EndIf
            Endif
            cJson += '    "insert_update_erp":"' + cDataErp + ' 00:00:00", '            
            cJson += '    "insert_update_crm":"' + SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + ' ' + Time() + '", '
            cJson += '    "canceled" :"' + (cxAlias)->CANCELED + '" '                          
            cJson += '},'
            (cxAlias)->(dbSkip())
      Enddo
     
      (cxAlias)->( dbCloseArea() ) 

Return cJson
//-------------------------------------------------------------------
/*/{Protheus.doc} fJsonTES
Funcao para obter o Json de TES.
@author  Alessandro Afonso 
@version	1.0
@since	08/10/2021 
@type function
/*/
//-------------------------------------------------------------------


Static Function fJsonTES(nPage, nSize, oWS, cBanco, nRec, lSeek, cJson)
      Local cQuery := ''
      Local cxAlias   := ""
      Local cFiltroFil:= fFiltroFilial(oWs,"SF4")
      Local cxEmp     := Alltrim(cEmpAnt)
      Private nTamSF4 := Len(RTRIM(fwxFilial("SF4")))

      cQuery += " SELECT F4_CODIGO, F4_FINALID, F4_TEXTO
      cQuery += ",CASE  "
      cQuery += " 	WHEN SF4.F4_FILIAL IS NULL "
      cQuery += " 		THEN '' "
      cQuery += " 	ELSE  CAST(SF4.F4_FILIAL AS CHAR(" + cValToChar(Len(SF4->F4_FILIAL)) + ")) "
      cQuery += " 	END AS branch_id "
      cQuery += " 	FROM " + RetSqlName("SF4") + " SF4 "
      If !Empty(cFiltroFil)
            cQuery += " WHERE " + cFiltroFil
      Else
            cQuery += " WHERE SF4.F4_FILIAL = '" + fwxFilial("SF4") + "' " 
      Endif
      cQuery += " AND SF4.D_E_L_E_T_ = '' "

      cQuery := ChangeQuery(cQuery)
      cxAlias := GetNextAlias()
      If oWS:isQuery
            lSeek := .F.
            cJson := '{ "items": [ { "query":"' + cQuery + '"} '
            Return Nil
      Endif                  
	MPSysOpenQuery(cQuery,cxAlias )	
	
      cJson := '{ "items": ['
      If (cxAlias)->(!(EoF()))
            lSeek := .T.
      Endif      
      nRec := 0
	While (cxAlias)->(!(EoF()))
            nRec := nRec + 1
            cJson += '{'
            cJson += '    "tabela":"SF4", '
            cJson += '    "data":"' + SubStr(DtoS(dDatabase),1,4) + '-' + SubStr(DtoS(dDatabase),5,2) + '-' + SubStr(DtoS(dDatabase),7,2) + 'T' + Time() + 'Z", '
            cJson += '    "company_id":"' + cxEmp + '", '
            cJson += '    "branchid":"' + cFilAnt + '", '
            cJson += '    "code":"' + Alltrim((cxAlias)->F4_CODIGO) + '", '
            cJson += '    "description":"' + Alltrim((cxAlias)->F4_FINALID) + '", '
            cJson += '    "description1":"' + Alltrim((cxAlias)->F4_TEXTO) + '", '
            cJson += '    "internalid":"' + cEmpAnt + '|' + Alltrim(fwxFilial("SF4")) + '|' + Alltrim((cxAlias)->F4_CODIGO) + '" '
            cJson += '},'
            (cxAlias)->(dbSkip())
      Enddo      

      (cxAlias)->( dbCloseArea() ) 

Return cJson


Static Function fFilial(cAlias, cTab, cSubs, cField)
      Local cRet := ''
      
      If cTab == 'SE1'
            cField := "SE1.E1_FILIAL"
      ElseIf cTab == 'SF2'
            cField := "SF2.F2_FILIAL"
      ElseIf cTab == 'SD2'
            cField := "SD2.D2_FILIAL"
      ElseIf cTab == 'SC5'
            cField := "SC5.C5_FILIAL"
      ElseIf cTab == 'SC6'
            cField := "SC6.C6_FILIAL"
      ElseIf cTab == 'SF4'
            cField := "SF4.F4_FILIAL"            
      Endif

      If cTab == 'SE1' .OR. cTab = 'SD2' .OR. cTab == 'SC6' .OR. cTab == 'SF2' .OR. cTab == 'SC5'
            If cAlias == 'SA1'
                  If Empty(fwXFilial("SA1"))
                        cRet := " SA1.A1_FILIAL = '" + fwXFilial("SA1") + "' "
                  Else
                        cRet := " RTRIM(SA1.A1_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSA1) + ") "        
                  Endif
            Endif
            iF cAlias == 'CC2'
                  If Empty(fwXFilial("CC2"))
                        cRet := " CC2.CC2_FILIAL = '" + fwXFilial("CC2") + "' "
                  Else
                        cRet := " RTRIM(CC2.CC2_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamCC2) + ") "        
                  Endif
            Endif
            iF cAlias == 'X5EST'
                  If Empty(fwXFilial("SX5"))
                        cRet := " X5EST.X5_FILIAL = '" + fwXFilial("SX5") + "' "
                  Else
                        cRet := " RTRIM(X5EST.X5_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSX5) + ") "        
                  Endif
            Endif
            iF cAlias == 'SA31'
                  If Empty(fwXFilial("SA3"))
                        cRet := " SA31.A3_FILIAL = '" + fwXFilial("SA3") + "' "
                  Else
                        cRet := " RTRIM(SA31.A3_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSA3) + ") "        
                  Endif
            Endif
            iF cAlias == 'TPTIT'
                  If Empty(fwXFilial("SX5"))
                        cRet := " TPTIT.X5_FILIAL = '" + fwXFilial("SX5") + "' "
                  Else
                        cRet := " RTRIM(TPTIT.X5_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSX5) + ") "        
                  Endif
            Endif            
            iF cAlias == 'SBM'
                  If Empty(fwXFilial("SBM"))
                        cRet := " SBM.BM_FILIAL = '" + fwXFilial("SBM") + "' "
                  Else
                        cRet := " RTRIM(SBM.BM_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSBM) + ") "        
                  Endif
            Endif            
            iF cAlias == 'SAH'
                  If Empty(fwXFilial("SAH"))
                        cRet := " SAH.AH_FILIAL = '" + fwXFilial("SAH") + "' "
                  Else
                        cRet := " RTRIM(SAH.AH_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSAH) + ") "        
                  Endif
            Endif  
            iF cAlias == 'SB1'
                  If Empty(fwXFilial("SB1"))
                        cRet := " SB1.B1_FILIAL = '" + fwXFilial("SB1") + "' "
                  Else
                        cRet := " RTRIM(SB1.B1_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSB1) + ") "        
                  Endif
            Endif                        
            iF cAlias == 'SE4'
                  If Empty(fwXFilial("SE4"))
                        cRet := " SE4.E4_FILIAL = '" + fwXFilial("SE4") + "' "
                  Else
                        cRet := " RTRIM(SE4.E4_FILIAL) =  " + cSubs + "(" + cField + ", 1," + cValToChar(nTamSE4) + ") "        
                  Endif
            Endif                        
      Endif

Return cRet

Static Function fFiltroFilial(oWs,cAlias)
      Local cRet    := ''
      Local cxParam := ''
      Local aXFil   :={}
      Local lFil    := .F.
      Local ni      := 0
      If Empty(oWS:Filial)
            Return ''
      Endif
      
      If cAlias == 'SE1'
            cField := "E1_FILIAL"
      ElseIf cAlias = 'SF2'
            cField := "F2_FILIAL"
      ElseIf cAlias = 'SD2'
            cField := "D2_FILIAL"
      ElseIf cAlias = 'SC6'
            cField := "C6_FILIAL"
      ElseIf cAlias = 'SC5'
            cField := "C5_FILIAL"
      ElseIf cAlias = 'SF4'      
            cField := "F4_FILIAL"
      Endif

      aXFil := Separa(oWS:Filial, "|")

      If !Empty(axFil)
            cxParam := "'"
            For ni := 1 to Len(axFil)
                  If FWFilExist(cEmpAnt, axFil[ni])
                        lFil := .T.
                        cxParam += Alltrim(axFil[ni]) + "','"
                  Endif      
            Next ni
            // Se conter uma filial dentro do parametro oWS:Filial valida, retorna o filtro por filial
            If lFil
                  cxParam := SubStr(cxParam, 1, Len(cxParam)-2)
                  cRet    := " ( " + cField + " IN (" + cxParam + "))"
            Endif
      ElseIf FWFilExist(cEmpAnt, oWS:Filial)
            cRet := " ( " + cField + " = '" + PadR(Alltrim(oWS:Filial), TamSX3(cField)[1]) + "' ) "
      Endif
Return cRet

Static Function fFilter(oWs, cBanco, lCarga, cAlias, cField, lforceInitialDate)
      Local aFilter          := StrToKarr(Upper(SubStr(oWS:View,At("|",oWS:View))), "|")
      Local aRet             := {}
      Local ni               := 0
      Local cConvInitialDate := ''
      Local cInitialDate     := ''
      Default lforceInitialDate := .F.

      If Len(aFilter) <= 0
            Conout("ConnectAdapterProc, erro da api " + DtoS(dDatabase) + '-' + Time() + ", para utilização da api listview, devera ser passado o View, como filtro, exemplo: financialSecurity|19000101|")
            lErro := .T.
            Return aRet
      Endif

      cInitialDate     := aFilter[1]
      cConvInitialDate := SubStr(aFilter[1],1,4) + '-' + SubStr(aFilter[1],5,2) + '-' + SubStr(aFilter[1],7,2)

      if !lforceInitialDate
          cInitialDate   :=  cValToChar(Year(dDatabase) - 2) + "0101"
      Endif      

      For ni := 1 to Len(aFilter)
            If ni == 1 .and. STOD(aFilter[ni]) < dDatabase - 30
                  lCarga := .T.
            Endif

            If cBanco = 'MSSQL'
                  If ni == 1
                        If lCarga .OR. lforceInitialDate
                              aAdd(aRet, " AND (    ( " + cAlias + cField + " >= '" + cInitialDate +  "' AND " + cAlias + "S_T_A_M_P_ IS NULL )  "+;
                                                "OR (" + cAlias + "S_T_A_M_P_ IS NOT NULL" +  " and convert(varchar(23), " + cAlias + "S_T_A_M_P_ , 21 ) >= '" + cConvInitialDate + ' 00:00:00.001'  + "')) ")
                        Else
                              aAdd(aRet, " AND ( " + cAlias + cField + " >= '" + cInitialDate +  "' and convert(varchar(23), " + cAlias + "S_T_A_M_P_ , 21 ) >= '" + cConvInitialDate + ' 00:00:00.001'  + "') ")
                        Endif
                  Endif    
            ElseIf cBanco = 'ORACLE' .OR. cBanco = 'POSTGRE'
                  If ni == 1
                        If lCarga .OR. lforceInitialDate
                              aAdd(aRet," AND (( " + cAlias + cField + " >= '" + cInitialDate +  "' AND " + cAlias + "S_T_A_M_P_ IS NULL) OR (" + cAlias + "S_T_A_M_P_ IS NOT NULL" +  " and " + cAlias + "S_T_A_M_P_  >= TO_DATE('" + cConvInitialDate + "', 'YYYY-MM-DD') ))")
                        Else
                              aAdd(aRet, " AND ( " + cAlias + cField + " >= '" + cInitialDate +  "' and " + cAlias + "S_T_A_M_P_  >= TO_DATE('" + cConvInitialDate + "', 'YYYY-MM-DD'))")
                        Endif      
                  Endif
            Endif     
      Next ni

Return aRet

Static Function StrxTran(cStr)
Default cStr := ""
cStr := StrTran(cStr, '"', '')
cStr := StrTran(cStr, ',', '')
Return cStr

Static Function  fAddOffSet(cBanco, nPage, nSize, lOffSet)
      Local cQuery := ""

      If !lOffSet
            cQuery += " WHERE ITEM_ORDER BETWEEN " + cValToChar(nPage) + " AND " + cValToChar(nSize) 
            cQuery += " ORDER BY ITEM_ORDER "
      Else      
            cQuery += " ORDER BY ITEM_ORDER "
            cQuery += " OFFSET " + cValToChar(nPage) + " ROWS "
            cQuery += " FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
      Endif
      
Return cQuery
