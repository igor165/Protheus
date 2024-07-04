#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} IPAGEN01

Rotina responsável pelo retorno dos bens

@type 	 function
@author  Ectore Cecato - Totvs IP Jundiaí
@since 	 27/12/2018
@version Protheus 12 - Genérico

/*/

User Function IPAGEN03(cCPF, cFilter)
	
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
		cQuery += "		ST9.T9_CODBEM, ST9.T9_NOME, SI3.I3_CUSTO, SI3.I3_DESC "+ CRLF
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
		
		If !Empty(cFilter)
			
			cQuery += " AND ((ST9.T9_CODBEM LIKE '%" + cFilter + "%') OR "+ CRLF
			cQuery += "      (ST9.T9_NOME LIKE '%" + cFilter + "%')) "+ CRLF
			
		EndIf
		
		cQuery += "GROUP BY "+ CRLF
		cQuery += "		ST9.T9_CODBEM, ST9.T9_NOME,	SI3.I3_CUSTO, SI3.I3_DESC "+ CRLF
		cQuery += "		"+ CRLF
		cQuery += "UNION "+ CRLF
		cQuery += "		"+ CRLF
		cQuery += "SELECT "+ CRLF
		cQuery += "		ST9.T9_CODBEM, ST9.T9_NOME, SI3.I3_CUSTO, SI3.I3_DESC "+ CRLF
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
		
		If !Empty(cFilter)
			
			cQuery += " AND ((ST9.T9_CODBEM LIKE '%"+ cFilter +"%') OR "+ CRLF
			cQuery += "      (ST9.T9_NOME LIKE '%"+ cFilter +"%')) "+ CRLF
			
		EndIf
		
		cQuery += "GROUP BY "+ CRLF
		cQuery += "		ST9.T9_CODBEM, ST9.T9_NOME, SI3.I3_CUSTO, SI3.I3_DESC "+ CRLF
		cQuery += "ORDER BY "+ CRLF
		cQuery += "		T9_CODBEM "
		
		ConOut(cQuery)
		
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .F., .T.)
		
		While !(cAliasQry)->(Eof())
			
			cResult := '{'
			cResult += '"T9_CODBEM":"'+ AllTrim((cAliasQry)->T9_CODBEM) +'", '
			cResult += '"T9_NOME":"'+ AllTrim((cAliasQry)->T9_NOME) +'", '
			cResult += '"I3_CUSTO":"'+ AllTrim((cAliasQry)->I3_CUSTO) +'",'
			cResult += '"I3_DESC":"'+ AllTrim((cAliasQry)->I3_DESC) +'"'
			cResult += '}'
			
			ConOut(cResult)
			
			aAdd(aBens, cResult)
						
			(cAliasQry)->(DbSkip())
			
		EndDo
		
	EndIf
	
	(cAliasQry)->(DbCloseArea())
	
Return aBens