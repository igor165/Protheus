#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} IPAGEN04

Rotina responsável pelo retorno das ordens de serviço do bem

@type 	 function
@author  Ectore Cecato - Totvs IP Jundiaí
@since 	 27/12/2018
@version Protheus 12 - Genérico

/*/

User Function IPAGEN04(cCPF, cBem, cFilter)
	
	Local aBens		:= {}
	Local cLogin	:= ""
	Local cQuery	:= ""
	Local cResult	:= ""
	Local cAliasQry	:= GetNextAlias()
	
	cQuery := "SELECT "+ CRLF
	cQuery += "		ST1.T1_CODUSU "+ CRLF
	cQuery += "FROM "+ RetSqlTab("ST1") +" "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "		"+ RetSqlDel("ST1") +" "+ CRLF
	cQuery += "		AND "+ RetSqlFil("ST1") +" "+ CRLF
	cQuery += "		AND ST1.T1_ZZCPF = '"+ cCPF +"' "
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
	
	If !(cAliasQry)->(Eof())
		
		cLogin	:= UsrRetName((cAliasQry)->T1_CODUSU)
		
		(cAliasQry)->(DbCloseArea())
		
		cAliasQry := GetNextAlias()
		
		cQuery := "SELECT "+ CRLF
		cQuery += "		STJ.TJ_ORDEM, '' AS TL_NUMSA "+ CRLF
		cQuery += "FROM "+ RetSqlTab("STJ") +" "+ CRLF
		cQuery += "		INNER JOIN "+ RetSqlTab("ST9") +" "+ CRLF 
		cQuery += "			ON	"+ RetSqlDel("ST9") +" "+ CRLF 
		cQuery += "				AND "+ RetSqlFil("ST9") +" "+ CRLF 
		cQuery += "				AND ST9.T9_CODBEM = STJ.TJ_CODBEM "+ CRLF 
		cQuery += "		INNER JOIN "+ RetSqlTAb("SI3") +" "+ CRLF 
		cQuery += "			ON 	"+ RetSqlDel("SI3") +" "+ CRLF 
		cQuery += "				AND "+ RetSqlFil("SI3") +" "+ CRLF
		cQuery += "				AND SI3.I3_CUSTO = ST9.T9_CCUSTO "+ CRLF 
		cQuery += "WHERE "+ CRLF
		cQuery += "		"+ RetSqlDel("STJ") +" "+ CRLF
		cQuery += "		AND "+ RetSqlFil("STJ") +" "+ CRLF
		cQuery += "		AND STJ.TJ_USUAINI = '"+ cLogin +"' "+ CRLF
		cQuery += "		AND STJ.TJ_SEQRELA = '0' "+ CRLF
		cQuery += "		AND STJ.TJ_DTMRFIM = '' "+ CRLF 
		cQuery += "		AND STJ.TJ_CODBEM = '"+ cBem +"' "+ CRLF
		cQuery += "     AND STJ.TJ_SITUACA = 'L' "+ CRLF
		cQuery += "     AND STJ.TJ_TERMINO = 'N' "+ CRLF
		
		If !Empty(cFilter)
			cQuery += "		AND STJ.TJ_ORDEM LIKE '%" + cFilter + "%' "
		EndIf
		
		cQuery += "		"+ CRLF
		cQuery += "UNION "+ CRLF
		cQuery += "		"+ CRLF
		cQuery += "SELECT "+ CRLF
		cQuery += "		STJ.TJ_ORDEM, "+ CRLF
		cQuery += "		( "+ CRLF
		cQuery += "			SELECT TOP 1 "+ CRLF 
		cQuery += "				TL_NUMSA "+ CRLF
		cQuery += "			FROM "+ RetSqlName("STL") +" "+ CRLF 
		cQuery += "			WHERE "+ CRLF
		cQuery += "				STL010.D_E_L_E_T_ = '' "+ CRLF 
		cQuery += "				AND STL010.TL_FILIAL = STL.TL_FILIAL "+ CRLF 
		cQuery += "				AND STL010.TL_ORDEM = STL.TL_ORDEM "+ CRLF
		cQuery += "				AND STL010.TL_TIPOREG = 'P' "+ CRLF
		cQuery += "		) AS TL_NUMSA "+ CRLF
		cQuery += "FROM "+ RetSqlTab("STJ")+" "+ CRLF
		cQuery += "		INNER JOIN "+ RetSqlTab("STL") +" "+ CRLF 
		cQuery += "			ON	"+ RetSqlDel("STJ") +" "+ CRLF 
		cQuery += "				AND "+ RetSqlFil("STJ") +" "+ CRLF 
		cQuery += "				AND STL.TL_ORDEM = STJ.TJ_ORDEM "+ CRLF 
		cQuery += "				AND STL.TL_TIPOREG = 'M' "+ CRLF 
		cQuery += "		INNER JOIN "+ RetSqlTab("ST1") +" "+ CRLF 
		cQuery += "			ON 	"+ RetSqlDel("ST1") +" "+ CRLF 
		cQuery += "				AND "+ RetSqlFil("ST1") +" "+ CRLF 
		cQuery += "				AND ST1.T1_CODFUNC = STL.TL_CODIGO "+ CRLF
		cQuery += "				AND ST1.T1_ZZCPF = '"+ cCPF +"' "+ CRLF 
		cQuery += "		INNER JOIN "+ RetSqlTab("ST9") +" "+ CRLF 
		cQuery += "			ON 	"+ RetSqlDel("ST9") +" "+ CRLF 
		cQuery += "				AND "+ RetSqlFil("ST9") +" "+ CRLF 
		cQuery += "				AND ST9.T9_CODBEM = STJ.TJ_CODBEM "+ CRLF 
		cQuery += "		INNER JOIN "+ RetSqlTab("SI3") +" "+ CRLF 
		cQuery += "			ON 	"+ RetSqlDel("SI3") +" "+ CRLF
		cQuery += "				AND "+ RetSqlFil("SI3") +" "+ CRLF
		cQuery += "				AND SI3.I3_CUSTO = ST9.T9_CCUSTO "+ CRLF
		cQuery += "WHERE "+ CRLF 
		cQuery += "		"+ RetSqlDel("STJ") +" "+ CRLF
		cQuery += "		AND "+ RetSqlFil("STJ") +" "+ CRLF
		cQuery += "		AND STJ.TJ_DTMRFIM = '' "+ CRLF 
		cQuery += "		AND STJ.TJ_CODBEM = '"+ cBem +"' "+ CRLF
		
		If !Empty(cFilter)
			cQuery += "		AND STJ.TJ_ORDEM LIKE '%" + cFilter + "%' "
		EndIf
		
		cQuery += "ORDER BY "+ CRLF
		cQuery += "		TJ_ORDEM "
		
		ConOut(cQuery)
		
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
		
		While !(cAliasQry)->(Eof())
			
			cResult := '{'
			cResult += '"TJ_ORDEM":"'+ AllTrim((cAliasQry)->TJ_ORDEM) +'", '
			cResult += '"TL_NUMSA":"'+ AllTrim((cAliasQry)->TL_NUMSA) +'"'
			cResult += '}'
			
			ConOut(cResult)
			
			aAdd(aBens, cResult)
						
			(cAliasQry)->(DbSkip())
			
		EndDo
		
	EndIf
	
	(cAliasQry)->(DbCloseArea())
	
Return aBens