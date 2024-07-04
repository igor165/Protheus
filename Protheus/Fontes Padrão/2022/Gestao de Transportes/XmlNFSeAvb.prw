#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} QryNFSe
description Busca NFSe
@author Gustavo Krug
@since 27/03/2018 
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function QryNFSe(cFilDoc, cDoc, cSerie, cAliasDT6)
Local cQuery := ''
Local lDT6SqeDes	:= DT6->(ColumnPos('DT6_SQEDES')) > 0
Local lRecebedor	:= DT6->(ColumnPos("DT6_CLIREC")) > 0
Local lExped 		:= DTC->(ColumnPos("DT6_CLIEXP")) > 0

    cQuery := " SELECT NFSe.DT6_FILDOC, " + CRLF
	cQuery += "        NFSe.DT6_FILORI, " + CRLF
	cQuery += "        NFSe.DT6_SERIE,  " + CRLF
	cQuery += "        NFSe.DT6_DOC,    " + CRLF
	cQuery += "        NFSe.DT6_DATEMI, " + CRLF
	cQuery += "        NFSe.DT6_HOREMI, " + CRLF
	cQuery += "        NFSe.DT6_DOCTMS, " + CRLF
	cQuery += "        NFSe.DT6_TIPTRA, " + CRLF
	cQuery += "        NFSe.DT6_FILIAL, " + CRLF
	cQuery += "        NFSe.DT6_CLIDEV, " + CRLF
	cQuery += "        NFSe.DT6_LOJDEV, " + CRLF
	cQuery += "        NFSe.DT6_CLIREM, " + CRLF
	cQuery += "        NFSe.DT6_LOJREM, " + CRLF
	cQuery += "        NFSe.DT6_CLIDES, " + CRLF
	cQuery += "        NFSe.DT6_LOJDES, " + CRLF
	cQuery += "        NFSe.DT6_CLICON, " + CRLF
	cQuery += "        NFSe.DT6_LOJCON, " + CRLF
	cQuery += "        NFSe.DT6_CLIDPC, " + CRLF
	cQuery += "        NFSe.DT6_LOJDPC, " + CRLF
	cQuery += "        NFSe.DT6_VALFRE, " + CRLF
	cQuery += "        NFSe.DT6_VALTOT, " + CRLF
	cQuery += "        NFSe.DT6_VALIMP, " + CRLF
	cQuery += "        NFSe.DT6_PRZENT, " + CRLF
	cQuery += "        NFSe.DT6_VOLORI, " + CRLF
	cQuery += "        NFSe.DT6_SERVIC, " + CRLF
	cQuery += "        NFSe.DT6_LOTNFC, " + CRLF
	cQuery += "        NFSe.DT6_VALMER, " + CRLF
	cQuery += "        NFSe.DT6_FILDCO, " + CRLF
	cQuery += "        NFSe.DT6_DOCDCO, " + CRLF
	cQuery += "        NFSe.DT6_SERDCO, " + CRLF
	cQuery += "        NFSe.DT6_CODMSG, " + CRLF
	cQuery += "        NFSe.DT6_CDRORI, " + CRLF
	cQuery += "        NFSe.DT6_PREFIX, " + CRLF
	cQuery += "        NFSe.DT6_NUM,    " + CRLF
	cQuery += "        NFSe.DT6_TIPO,   " + CRLF
	cQuery += "        NFSe.DT6_CODOBS, " + CRLF
	cQuery += "        NFSe.DT6_CHVCTE, " + CRLF
	cQuery += "        NFSe.DT6_SITCTE, " + CRLF
	cQuery += "        NFSe.DT6_DEVFRE, " + CRLF
	cQuery += "        NFSe.DT6_AMBIEN, " + CRLF
	If lRecebedor
		cQuery += "		NFSe.DT6_CLIREC, " + CRLF
		cQuery += "		NFSe.DT6_LOJREC, " + CRLF
		cQuery += "		CLIREC.A1_EST REC_UF, " + CRLF
		cQuery += "		CLIREC.A1_COD_MUN REC_COD_MUN, " + CRLF
	Else
		cQuery += "	 ''	DT6_CLIREC, " + CRLF
		cQuery += "	 ''	DT6_LOJREC, " + CRLF
		cQuery += "	 '' REC_UF, " + CRLF
		cQuery += "  '' REC_COD_MUN, " + CRLF
	EndIf
	
	If lExped
		cQuery += "	 NFSe.DT6_CLIEXP, " + CRLF
		cQuery += "	 NFSe.DT6_LOJEXP , " + CRLF
	Else
		cQuery += "	 ''	DT6_CLIEXP, " + CRLF
		cQuery += "	 ''	DT6_LOJEXP, " + CRLF
	EndIf
	
	If lDT6SqeDes 
		cQuery += "		NFSe.DT6_SQEDES, " + CRLF
	EndIf
	cQuery += "		   DTC.DTC_TIPNFC,  " + CRLF
	cQuery += "		   DTC.DTC_SELORI,  " + CRLF

	cQuery += "        CLIREM.A1_CGC REM_CNPJ,			" + CRLF
	cQuery += "        CLIREM.A1_INSCR REM_INSC,		" + CRLF
	cQuery += "        CLIREM.A1_CONTRIB REM_CONTRIB,	" + CRLF
	cQuery += "        CLIREM.A1_NOME REM_NOME,			" + CRLF
	cQuery += "        CLIREM.A1_NREDUZ REM_NMEFANT,	" + CRLF
	cQuery += "        CLIREM.A1_DDD REM_DDDTEL,		" + CRLF
	cQuery += "        CLIREM.A1_TEL REM_TEL,			" + CRLF
	cQuery += "        CLIREM.A1_END REM_END,			" + CRLF
	cQuery += "        CLIREM.A1_COMPLEM REM_CPL,		" + CRLF
	cQuery += "        CLIREM.A1_BAIRRO REM_BAIRRO,		" + CRLF
	cQuery += "        CLIREM.A1_MUN REM_MUNICI,		" + CRLF
	cQuery += "        CLIREM.A1_CEP REM_CEP,			" + CRLF
	cQuery += "        CLIREM.A1_EST REM_UF,			" + CRLF
	cQuery += "        CLIREM.A1_PAIS REM_PAIS,			" + CRLF
	cQuery += "        CLIREM.A1_CODPAIS REM_CBACEN,	" + CRLF
	cQuery += "        CLIREM.A1_PESSOA REM_TPPESSOA,	" + CRLF
	cQuery += "        CLIREM.A1_SUFRAMA REM_SUFRAMA,	" + CRLF
	cQuery += "        CLIREM.A1_COD_MUN REM_COD_MUN,	" + CRLF
	cQuery += "        CLIREM.A1_EMAIL   REM_EMAIL,		" + CRLF
	
	cQuery += "        CLIDES.A1_CGC DES_CNPJ,			" + CRLF
	cQuery += "        CLIDES.A1_INSCR DES_INSC,		" + CRLF
	cQuery += "        CLIDES.A1_CONTRIB DES_CONTRIB,	" + CRLF
	cQuery += "        CLIDES.A1_NOME DES_NOME,			" + CRLF
	cQuery += "        CLIDES.A1_DDD DES_DDDTEL,		" + CRLF
	cQuery += "        CLIDES.A1_TEL DES_TEL,			" + CRLF
	cQuery += "        CLIDES.A1_PESSOA DES_TPPESSOA, 	" + CRLF
	cQuery += "        CLIDES.A1_SUFRAMA	DES_SUFRAMA," + CRLF
	cQuery += "        CLIDES.A1_END DES_END,			" + CRLF
	cQuery += "        CLIDES.A1_COMPLEM DES_CPL,		" + CRLF
	cQuery += "        CLIDES.A1_BAIRRO DES_BAIRRO,		" + CRLF
	cQuery += "        CLIDES.A1_MUN DES_MUNICI,		" + CRLF
	cQuery += "        CLIDES.A1_CEP DES_CEP,			" + CRLF
	cQuery += "        CLIDES.A1_EST DES_UF,			" + CRLF
	cQuery += "        CLIDES.A1_PAIS DES_PAIS,			" + CRLF
	cQuery += "        CLIDES.A1_CODPAIS DES_CBACEN,	" + CRLF			
	cQuery += "        CLIDES.A1_COD_MUN DES_COD_MUN,	" + CRLF
	cQuery += "        CLIDES.A1_EMAIL   DES_EMAIL		" + CRLF
	cQuery += "   FROM " + RetSqlName('DT6') + " NFSe   " + CRLF
	cQuery += "   INNER JOIN " + RetSqlName('DTC') + " DTC ON (DTC.DTC_FILDOC = NFSe.DT6_FILDOC AND DTC.DTC_DOC = NFSe.DT6_DOC AND DTC.DTC_SERIE = NFSe.DT6_SERIE ) " + CRLF
	cQuery += "   INNER JOIN " + RetSqlName('SA1') + " CLIREM  ON (CLIREM.A1_COD = NFSe.DT6_CLIREM AND CLIREM.A1_LOJA = NFSe.DT6_LOJREM ) " + CRLF
	cQuery += "   INNER JOIN " + RetSqlName('SA1') + " CLIDES  ON (CLIDES.A1_COD = NFSe.DT6_CLIDES AND CLIDES.A1_LOJA = NFSe.DT6_LOJDES   ) " + CRLF

	If lRecebedor
		cQuery += "   LEFT JOIN " + RetSqlName('SA1') + " CLIREC  ON (CLIREC.A1_COD = NFSe.DT6_CLIREC AND CLIREC.A1_LOJA = NFSe.DT6_LOJREC  " + CRLF
		cQuery += "    AND CLIREC.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
		cQuery += "    AND CLIREC.D_E_L_E_T_ = ' ' ) " + CRLF
	EndIf
    
	cQuery += "  WHERE NFSe.DT6_FILIAL   = '" + xFilial('DT6') + "'" + CRLF
	cQuery += "    AND NFSe.DT6_FILDOC   = '" + cFilDoc + "'" + CRLF
	cQuery += "    AND NFSe.DT6_DOC      = '" + cDoc + "'" + CRLF
	cQuery += "    AND NFSe.DT6_SERIE    = '" + cSerie + "'" + CRLF
	cQuery += "    AND NFSe.D_E_L_E_T_   = ' '" + CRLF
	
	cQuery += "    AND DTC.D_E_L_E_T_   = ' '" + CRLF

	cQuery += "    AND CLIREM.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
	cQuery += "    AND CLIREM.D_E_L_E_T_ = ' '" + CRLF
	
	cQuery += "    AND CLIDES.A1_FILIAL  = '" + xFilial('SA1') + "'" + CRLF
	cQuery += "    AND CLIDES.D_E_L_E_T_ = ' '"
	
	cQuery += "  ORDER BY NFSe.DT6_FILDOC, " + CRLF
	cQuery += "           NFSe.DT6_DOC,    " + CRLF
	cQuery += "           NFSe.DT6_SERIE   "
    
    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDT6, .F., .T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlNFSe
description Gera e retorna XML averbação de NFS-e
@author  Gustavo Krug
@since   26/03/2018
@version 12.1.17
//-------------------------------------------------------------------
//@param 1  cFilDoc (Filial do Documento)////////////////////////////
//@param 2  cDoc    (N° do Documento)    ////////////////////////////
//@param 3  cSerie  (Série do Documento) ////////////////////////////
/*///////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------

User Function XmlNFSe(cFilDoc, cDoc, cSerie, cTpMov)
Local cXML      := ""
Local cAliasDT6	:= GetNextAlias()
Local cAliasAll := GetNextAlias()
Local cTimeZone := GetSM0(cFilDoc)[1]
Local cToma	    := ''
Local aRetMun 	:= {}
Local cSelOri := ''
Local cMod:= ''
Local cNumDoc:= ''

	QryNFSe(cFilDoc, cDoc, cSerie, cAliasDT6)
	GetSelOri(cFilDoc, cDoc, cSerie, cAliasDT6 ,cAliasAll)
	cSelOri:= (cAliasAll)->SELORI
	cToma := NFSeToma(cAliasDT6)

	SF3->(dbSetOrder(6))
	if SF3->(dbSeek(xFilial("SF3")+cDoc+cSerie))
		if !Empty(SF3->F3_NFELETR)
			cMod:= '98'
			cNumDoc:= SF3->F3_NFELETR
		else
			cMod:= '92'
			cNumDoc:= (cAliasDT6)->DT6_DOC
		endif 
	endif

    cXML := '<cteProc>'
    cXML += '<CTe>'
    cXML += '<infCte>'
    cXML += '<ide>'
    cXML += '<mod>' + cMod + '</mod>'
    if cMod == '92'
    	cXML += '<serie>' + NoAcentoCte( (cAliasDT6)->DT6_SERIE ) + '</serie>'
    endif
    cXML += '<nCT>' + cNumDoc + '</nCT>'
    cXML += '<dhEmi>'+ SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 1, 4) + "-";
					 + SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 5, 2) + "-";
					 + SubStr(AllTrim((cAliasDT6)->DT6_DATEMI), 7, 2) + "T";
					 + SubStr(AllTrim((cAliasDT6)->DT6_HOREMI), 1, 2) + ":";
					 + SubStr(AllTrim((cAliasDT6)->DT6_HOREMI), 3, 2) + ':00';
				     + cTimeZone
	cXML += '</dhEmi>'
    cXML += '<tpAmb>'+ Alltrim(cValToChar((cAliasDT6)->DT6_AMBIEN)) +'</tpAmb>'
    If ( AllTrim((cAliasDT6)->DT6_DOCTMS) $ "A/E/2/6/7/9" )
		cXML += '<tpCTe>0</tpCTe>'
	ElseIf ( AllTrim((cAliasDT6)->DT6_DOCTMS) $ "8" )
		cXML += '<tpCTe>1</tpCTe>'
	Else
		cXML += '<tpCTe>0</tpCTe>'
	EndIf	
	
    If (cAliasDT6)->DTC_TIPNFC $ '0,1,3,4,6,7'
		cXML   += '<tpServ>0</tpServ>'
	ElseIf (cAliasDT6)->DTC_TIPNFC == '2'
		cXML   += '<tpServ>1</tpServ>'
	ElseIf (cAliasDT6)->DTC_TIPNFC == '5'
		cXML   += '<tpServ>2</tpServ>'
	ElseIf (cAliasDT6)->DTC_TIPNFC == '9'
		cXML   += '<tpServ>3</tpServ>'
	EndIf	
	
	aRetMun:= GetMun(cSelOri,cAliasDT6,cAliasAll)
	
	cXML += '<cMunIni>'+aRetMun[1]+'</cMunIni>'
    cXML += '<UFIni>' +aRetMun[2]+ '</UFIni>'
    cXML += '<cMunFim>' + aRetMun[3] + '</cMunFim>'
    cXML += '<UFFim>' + aRetMun[4] + '</UFFim>'
	cXML += '<toma03>'
	cXML += '<toma>' + cToma + '</toma>'
	cXML += '</toma03>'
    cXML += '</ide>'
    cXML += '<emit>'
	cXML += '<CNPJ>' + StaticCall(CTESEFAZ3,NoPontos,GetSM0(cFilDoc)[4]) + '</CNPJ>'
    cXML += '<enderEmit>'
	cXML += '<cMun>' + NoAcentoCte( GetSM0(cFilDoc)[2] ) + '</cMun>'
    cXML += '<UF>' + NoAcentoCte( GetSM0(cFilDoc)[3] ) + '</UF>'
    cXML += '</enderEmit>'
    cXML += '</emit>'
    cXML += '<rem>'
	cXML += '<CNPJ>' + IIf((cAliasDT6)->REM_UF <> 'EX',NoAcentoCte( (cAliasDT6)->REM_CNPJ ),StrZero(0,14)) + '</CNPJ>'   
    cXML += '<enderReme>'
	cXML += '<cMun>' + NoAcentoCte( AllTrim(GetUF((cAliasDT6)->REM_UF)) + AllTrim((cAliasDT6)->REM_COD_MUN) ) + '</cMun>'
	cXML += '<UF>' + (cAliasDT6)->REM_UF + '</UF>'
    cXML += '<cPais>' + NoAcentoCte( RIGHT((cAliasDT6)->REM_CBACEN ,4 )) + '</cPais>'
    cXML += '</enderReme>'
    cXML += '</rem>'    
    cXML += '<dest>'
	cXML += '<CNPJ>' + Iif((cAliasDT6)->DES_UF <> 'EX', StaticCall(CTESEFAZ3,NoPontos,(cAliasDT6)->DES_CNPJ), '00000000000000') + '</CNPJ>'   
    cXML += '<enderDest>'
	cXML += '<cMun>'+ NoAcentoCte( AllTrim(GetUF((cAliasDT6)->DES_UF)) + AllTrim((cAliasDT6)->DES_COD_MUN) ) + '</cMun>'
	cXML += '<UF>' + NoAcentoCte( (cAliasDT6)->DES_UF ) +  '</UF>'	
	If !Empty(AllTrim((cAliasDT6)->DES_CBACEN))
		cXML += '<cPais>'+ NoAcentoCte( RIGHT((cAliasDT6)->DES_CBACEN ,4 )) + '</cPais>'
	Else
		If !Empty(AllTrim((cAliasDT6)->DES_PAIS))
			cXML += '<cPais>'+ NoAcentoCte( (cAliasDT6)->DES_PAIS ) + '</cPais>'
		EndIf
	EndIf
    cXML += '</enderDest>'
    cXML += '</dest>'
    cXML += '<infCTeNorm>'
    cXML += '<infCarga>'
    cXML += '<vCarga>' + StaticCall(CTESEFAZ3,ConvType,(cAliasDT6)->DT6_VALMER, 15, 2) + '</vCarga>'
    cXML += '</infCarga>'
    cXML += '<seg>'	
	If cTpMov == '1'
		cXML += '<respSeg>' + '4' + '</respSeg>'	
	ElseIf cTpMov == '4'
		cXML += '<respSeg>' + '5' + '</respSeg>'
	EndIf
    cXML += '<vCarga>' + StaticCall(CTESEFAZ3,ConvType,(cAliasDT6)->DT6_VALMER, 15, 2) + '</vCarga>'
    cXML += '</seg>'
    cXML += '</infCTeNorm>'
    cXML += '</infCte>'
    cXML += '</CTe>'
    cXML += '</cteProc>'
    
	(cAliasDT6)->(DbCloseArea())

Return cXML

/*/{Protheus.doc} QryNFSeC
description Carrega em cAliasDT6 os dados da NFSe a ser cancelada
@author Wander Horongoso
@since 27/03/2018 
@version 12.1.17
//-------------------------------------------------------------------
//@param 1  cFilDoc   (Filial do Documento)//////////////////////////
//@param 2  cDoc      (N° do Documento)    //////////////////////////
//@param 3  cSerie    (Série do Documento) //////////////////////////
//@param 4  cAliasDT6 (Alias contendo a seleção dos dados) //////////
/*///////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------
Static Function QryNFSeC(cFilDoc, cDoc, cSerie, cAliasDT6)
Local cQuery := ''

    cQuery := " SELECT NFSe.DT6_FILDOC, " + CRLF
	cQuery += "        NFSe.DT6_FILORI, " + CRLF
	cQuery += "        NFSe.DT6_SERIE,  " + CRLF
	cQuery += "        NFSe.DT6_DOC,    " + CRLF
	cQuery += "        NFSe.DT6_DATEMI, " + CRLF
	cQuery += "        NFSe.DT6_HOREMI, " + CRLF
	cQuery += "        NFSe.DT6_AMBIEN, " + CRLF
	cQuery += "        NFSe.DT6_CHVCTE, " + CRLF

	cQuery += "		   DL5.DL5_PROTOC  " + CRLF

	cQuery += "   FROM " + RetSqlName('DT6') + " NFSe   " + CRLF
	cQuery += "   INNER JOIN " + RetSqlName('DL5') + " DL5 ON (DL5.DL5_FILDOC = NFSe.DT6_FILDOC AND DL5.DL5_DOC = NFSe.DT6_DOC AND DL5.DL5_SERIE = NFSe.DT6_SERIE ) " + CRLF
        
    cQuery += "  WHERE NFSe.DT6_FILIAL   = '" + xFilial('DT6') + "'" + CRLF
	cQuery += "    AND NFSe.DT6_FILDOC   = '" + cFilDoc + "'" + CRLF
	cQuery += "    AND NFSe.DT6_DOC      = '" + cDoc + "'" + CRLF
	cQuery += "    AND NFSe.DT6_SERIE    = '" + cSerie + "'" + CRLF
	
	cQuery += "    AND DL5.D_E_L_E_T_   = ' '" + CRLF

	cQuery += "  ORDER BY NFSe.DT6_FILDOC, " + CRLF
	cQuery += "           NFSe.DT6_DOC,    " + CRLF
	cQuery += "           NFSe.DT6_SERIE   "
    
    cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDT6, .F., .T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlNFSeC
description  Gera e retorna XML de cancelamento de averbação de NFS-e  
@author  Wander Horongoso
@since   27/03/2018
@version 12.1.17
//@param 1  cFilDoc (Filial do Documento)////////////////////////////
//@param 2  cDoc    (N° do Documento)    ////////////////////////////
//@param 3  cSerie  (Série do Documento) ////////////////////////////
/*///////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------
User Function XmlNFSeC(cFilDoc, cDoc, cSerie)
Local cAliasDT6 := GetNextAlias()
Local cXML

	QryNFSeC(cFilDoc, cDoc, cSerie, cAliasDT6)
	
	If (cAliasDT6)->(!Eof())
		(cAliasDT6)->(dbGoTop())
		cXML := '<retCancCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="1.04">'
		cXML += 	'<infCanc>'
		cXML += 		'<tpAmb>' + Alltrim(cValToChar((cAliasDT6)->DT6_AMBIEN)) + '</tpAmb>'
		cXML += 		'<cUF/>'
		cXML += 		'<verAplic>98</verAplic>'
		cXML += 		'<cStat>101</cStat>'
		cXML += 		'<xMotivo>Cancelamento de NFS-e homologado</xMotivo>'
		cXML += 		'<chCTe>' + AllTrim((cAliasDT6)->DL5_PROTOC) + '</chCTe>'
		cXML += 		'<dhRecbto>' + AllTrim(XMLDtUTC((cAliasDT6)->DT6_DATEMI, (cAliasDT6)->DT6_HOREMI, (cAliasDT6)->DT6_FILDOC)) + '</dhRecbto>'
		cXML += 		'<dhEmi>' + AllTrim(XMLDtUTC((cAliasDT6)->DT6_DATEMI, (cAliasDT6)->DT6_HOREMI, (cAliasDT6)->DT6_FILDOC)) + '</dhEmi>'
		cXML += 		'<nProt>' + AllTrim((cAliasDT6)->DL5_PROTOC) + '</nProt>'
		cXML += 	'</infCanc>'
		cXML += '</retCancCTe>'
	EndIf
	
	(cAliasDT6)->(dbCloseArea())

return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSM0
description Retorna TimeZone UTC
@author  Gustavo Krug
@since   27/03/2018
@version 12.1.17 
/*/
//-------------------------------------------------------------------
Static Function GetSM0(cFilDoc)
Local aArea := SM0->(GetArea())
Local aRet	    := {}
Local cIdEnt    := ''
Local cMun		:= ''
Local cUF		:= ''
Local cCNPJ		:= ''

	
	SM0->(MsSeek(SM0->M0_CODIGO+cFilDoc))
	cIdEnt := RetIdEnti(.F.)
	cMun	:= SM0->M0_CODMUN
	cUF		:= SM0->M0_ESTENT
	cCNPJ	:= SM0->M0_CGC

	RestArea(aArea)
	aRet := {StaticCall(SPEDNFE,TZoneUTC,cIdEnt), cMun, cUF, cCNPJ}
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NFSeToma
description Tomador de Serviço NFS-e 
@author  Gustavo Krug	
@since   27/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function NFSeToma(cAliasDT6)

Local cTomador   	:= ""

If	( Empty((cAliasDT6)->DT6_CLICON) .And. Empty((cAliasDT6)->DT6_CLIDPC) ) .Or. ;
	(IIf(!Empty((cAliasDT6)->DT6_CLICON),((cAliasDT6)->DT6_CLICON+(cAliasDT6)->DT6_LOJCON <> (cAliasDT6)->DT6_CLIDEV+(cAliasDT6)->DT6_LOJDEV),.T.)) .And. ;
	(IIf(!Empty((cAliasDT6)->DT6_CLIDPC) ,((cAliasDT6)->DT6_CLIDPC+(cAliasDT6)->DT6_LOJDPC <> (cAliasDT6)->DT6_CLIDEV+(cAliasDT6)->DT6_LOJDEV),.T.))

	//+---------------------------------------------------------------------------
	//| Tomador = 0-Remetente
	//+---------------------------------------------------------------------------
	If (((cAliasDT6)->DT6_CLIREM = (cAliasDT6)->DT6_CLIDES) .And.;
		((cAliasDT6)->DT6_LOJREM = (cAliasDT6)->DT6_LOJDES)) .And. (cAliasDT6)->DT6_DEVFRE $ "1|2"
		If (cAliasDT6)->DT6_DEVFRE = '1' 
			cTomador   	:= '0'			
		ElseIf (cAliasDT6)->DT6_DEVFRE = '2'
			cTomador   	:= '3'			
		EndIf
	//+---------------------------------------------------------------------------
	//| Tomador = 0-Remetente
	//+---------------------------------------------------------------------------
	ElseIf (((cAliasDT6)->DT6_CLIREM = (cAliasDT6)->DT6_CLIDEV) .And.;
		((cAliasDT6)->DT6_LOJREM = (cAliasDT6)->DT6_LOJDEV))
		cTomador   	    := '0'

	//+---------------------------------------------------------------------------
	//| Tomador = 1-Expedidor
	//+---------------------------------------------------------------------------
	ElseIf ((cAliasDT6)->DT6_CLIEXP == (cAliasDT6)->DT6_CLIDEV) .And.;
			((cAliasDT6)->DT6_LOJEXP == (cAliasDT6)->DT6_LOJDEV)		
			
		cTomador      := '1'

	//+---------------------------------------------------------------------------
	//| Tomador = 2-Recebedor
	//+---------------------------------------------------------------------------
	ElseIf ((cAliasDT6)->DT6_CLIREC == (cAliasDT6)->DT6_CLIDEV) .And.;
			((cAliasDT6)->DT6_LOJREC == (cAliasDT6)->DT6_LOJDEV)
		cTomador      := '2'

	//+---------------------------------------------------------------------------
	//| Tomador = 3-Destinatario
	//+---------------------------------------------------------------------------
	ElseIf (((cAliasDT6)->DT6_CLIDES = (cAliasDT6)->DT6_CLIDEV) .And.;
		((cAliasDT6)->DT6_LOJDES = (cAliasDT6)->DT6_LOJDEV))
		cTomador		:= '3'
			
	Else
		cTomador   	:= '1'
	EndIf
EndIf

Return(cTomador)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMun()
description Função que retorna Município/UF inicio e fim da prestacao 
@author  Gustavo Krug
@since   27/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GetMun(cSelOri, cAliasDT6,cAliasAll)
	Local aRet:={"","","",""}
	Local lDT6SqeDes	:= DT6->(ColumnPos('DT6_SQEDES')) > 0
	Local cSeqEntr:=""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Municipio inicio e termino da prestacao                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cSelOri == StrZero(1,Len(DTC->DTC_SELORI)) .Or.  AllTrim((cAliasDT6)->DT6_DOCTMS) $ "6/7"  //Transportadora ou CT-e de Devolução e Reentrega
		DUY->(DbSetOrder(1))
		If DUY->(MsSeek(xFilial("DUY")+(cAliasDT6)->DT6_CDRORI))
			aRet[1]:= NoAcentoCte( AllTrim(DUY->DUY_EST ) +  Alltrim( DUY->DUY_CODMUN ) )
			aRet[2]:= NoAcentoCte( DUY->DUY_EST )
		EndIf
	ElseIf cSelOri == StrZero(2,Len(DTC->DTC_SELORI))   //Remetente

		aRet[1]:= NoAcentoCte(AllTrim(GetUF((cAliasDT6)->REM_UF)) +  Alltrim((cAliasDT6)->(REM_COD_MUN)))
		aRet[2]:= NoAcentoCte( (cAliasDT6)->(REM_UF))
	ElseIf cSelOri == StrZero(3,Len(DTC->DTC_SELORI))   //Coleta ou expedidor.

		If !Empty((cAliasDT6)->DT6_CLIEXP) //--Origem Expedidor?
			aRet[1]:= NoAcentoCte( GetUF((cAliasDT6)->(EXP_UF))) +  Alltrim((cAliasDT6)->(EXP_COD_MUN))
			aRet[2]:= NoAcentoCte( (cAliasDT6)->(EXP_UF))
		Else //-- ou Coleta
			cAliasDT5:= GetNextAlias()
			cQuery := " SELECT DUE_MUN, DUE_CODMUN, DUE_EST, DUL_MUN, DUL_CODMUN, DUL_EST "
			cQuery += "  FROM " + RetSQLName("DT5") + " DT5 "
			cQuery += "  JOIN " + RetSQLName("DUE") + " DUE "
			cQuery += "    ON DUE_FILIAL = '" + xFilial("DUE") + "' "
			cQuery += "    AND DUE_CODSOL = DT5_CODSOL "
			cQuery += "    AND DUE.D_E_L_E_T_ = ' ' "
			cQuery += "  LEFT JOIN " + RetSQLName("DUL") + " DUL "
			cQuery += "    ON DUL_FILIAL = '" + xFilial("DUL") + "' "
			cQuery += "    AND DUL_CODSOL = DT5_CODSOL "
			cQuery += "    AND DUL_SEQEND = DT5_SEQEND "
			cQuery += "    AND DUL.D_E_L_E_T_ = ' ' "
			cQuery += "  WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
			cQuery += "    AND DT5_FILORI = '" + (cAliasAll)->( DTC_FILORI ) + "' "
			cQuery += "    AND DT5_NUMSOL = '" + (cAliasAll)->( DTC_NUMSOL ) + "' "
			cQuery += "    AND DT5.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)

			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT5,.T.,.T.)
			If !(cAliasDT5)->(Eof())
				//-- Endereco do Solicitante
				If !Empty((cAliasDT5)->DUL_CODMUN)
					aRet[1]:=  NoAcentoCte( AllTrim(GetUF((cAliasDT5)->DUL_EST)) + Alltrim((cAliasDT5)->(DUL_CODMUN)) )
					aRet[2]:=  NoAcentoCte( (cAliasDT5)->(DUL_EST) )
				Else
					//-- Solicitante
					aRet[1]:= NoAcentoCte( AllTrim(GetUF((cAliasDT5)->DUE_EST)) +  Alltrim((cAliasDT5)->(DUE_CODMUN)) )
					aRet[2]:= NoAcentoCte( (cAliasDT5)->(DUE_EST) )
				EndIf
			EndIf
			(cAliasDT5)->(DbCloseArea())
		EndIf
	EndIf
	
	If lDT6SqeDes .And. (cAliasDT6)->DT6_DOCTMS $ '67' //Devolução ou Reentrega
		cSeqEntr := (cAliasDT6)->DT6_SQEDES
	EndIf
	
	If !Empty(cSeqEntr)
		cSeekDUL := xFilial('DUL')+(cAliasDT6)->DT6_CLIDES + (cAliasDT6)->DT6_LOJDES + cSeqEntr
		DUL->(DbSetOrder(2))
		If	DUL->(MsSeek(cSeekDUL))
	
			aRet[3]:= NoAcentoCte( AllTrim(Iif(!Empty((cAliasDT6)->DT6_CLIREC),GetUF((cAliasDT6)->REC_UF), GetUF(DUL->DUL_EST))) + Iif(!Empty((cAliasDT6)->DT6_CLIREC),AllTrim((cAliasDT6)->REC_COD_MUN), AllTrim(DUL->DUL_CODMUN)))// '</cMunFim>'
			aRet[4]:=  NoAcentoCte( Iif(!Empty((cAliasDT6)->DT6_CLIREC), (cAliasDT6)->REC_UF , DUL->DUL_EST ) )//  '</UFFim>'
		EndIf
	
	ElseIf Empty(cSeqEntr) .And. !Empty((cAliasDT6)->DT6_CLIREC)
			aRet[3]:= NoAcentoCte( AllTrim(Iif(!Empty((cAliasDT6)->DT6_CLIREC),GetUF((cAliasDT6)->REC_UF), GetUF(DUL->DUL_EST))) + AllTrim((cAliasDT6)->REC_COD_MUN)) //'</cMunFim>'
			aRet[4]:= NoAcentoCte( (cAliasDT6)->REC_UF ) // '</UFFim>'
	
	Else
		aRet[3]:= NoAcentoCte( AllTrim(GetUF((cAliasDT6)->DES_UF )) + AllTrim((cAliasDT6)->DES_COD_MUN ) ) //'</cMunFim>'
		aRet[4]:=  NoAcentoCte( (cAliasDT6)->DES_UF ) // '</UFFim>'
	
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XMLDtUTC
description Formatação da data/hora em padrão SEFAZ 
@author  Wander Horongoso
@since   27/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static function XMLDtUTC(cData, cHora, cFilDoc)
Local cRet

	cRet := SubStr(cData, 1, 4) + "-";
	  	  + SubStr(cData, 5, 2) + "-";
		  + SubStr(cData, 7, 2) + "T";
		  + SubStr(cHora, 1, 2) + ":";
		  + SubStr(cHora, 3, 2) + ':00';
		  + GetSM0(cFilDoc)[1]		
		
Return cRet		 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUF
description Função converse char do UF em código IBGE do estado
@author  Gustavo Krug
@since   29/03/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GetUF(cUF)
Local aUF := {}

	aAdd(aUF,{"RO","11"})
	aAdd(aUF,{"AC","12"})
	aAdd(aUF,{"AM","13"})
	aAdd(aUF,{"RR","14"})
	aAdd(aUF,{"PA","15"})
	aAdd(aUF,{"AP","16"})
	aAdd(aUF,{"TO","17"})
	aAdd(aUF,{"MA","21"})
	aAdd(aUF,{"PI","22"})
	aAdd(aUF,{"CE","23"})
	aAdd(aUF,{"RN","24"})
	aAdd(aUF,{"PB","25"})
	aAdd(aUF,{"PE","26"})
	aAdd(aUF,{"AL","27"})
	aAdd(aUF,{"MG","31"})
	aAdd(aUF,{"ES","32"})
	aAdd(aUF,{"RJ","33"})
	aAdd(aUF,{"SP","35"})
	aAdd(aUF,{"PR","41"})
	aAdd(aUF,{"SC","42"})
	aAdd(aUF,{"RS","43"})
	aAdd(aUF,{"MS","50"})
	aAdd(aUF,{"MT","51"})
	aAdd(aUF,{"GO","52"})
	aAdd(aUF,{"DF","53"})
	aAdd(aUF,{"SE","28"})
	aAdd(aUF,{"BA","29"})
	aAdd(aUF,{"EX","99"})

	If aScan(aUF,{|x| x[1] ==  cUF }) != 0
		cUF  := aUF[ aScan(aUF,{|x| x[1] == cUF }), 2]
	EndIf
Return cUF

Static Function GetSelOri(cFilDoc, cDoc, cSerie, cAliasDT6, cAliasAll)

	Local cQuery:= ""

	cQuery := " SELECT MAX(DTC.DTC_VALOR),	" + CRLF
	cQuery += " 		 DTC.DTC_TIPNFC,	" + CRLF
	cQuery += " 		 DTC.DTC_DEVFRE,	" + CRLF
	cQuery += " 		 DTC.DTC_CODOBS,	" + CRLF
	cQuery += " 		 DTC.DTC_CTRDPC,	" + CRLF
	cQuery += " 		 DTC.DTC_SERDPC,	" + CRLF
	cQuery += " 		 DTC.DTC_TIPANT,	" + CRLF
	cQuery += " 		 DTC.DTC_DPCEMI,	" + CRLF
	cQuery += " 		 DTC.DTC_CTEANT,	" + CRLF
	cQuery += " 		 DTC.DTC_SELORI SELORI,	" + CRLF
	cQuery += " 		 DTC.DTC_CLIDES,	" + CRLF
	cQuery += " 		 DTC.DTC_LOJDES,	" + CRLF				
	cQuery += " 		 DTC.DTC_SQEDES,	" + CRLF
	cQuery += " 		 DTC.DTC_FILORI,	" + CRLF
	cQuery += " 		 DTC.DTC_NUMSOL,	" + CRLF
	
	cQuery += " 		 DV3REM.DV3_INSCR REMDV3_INSCR ,	" + CRLF
	cQuery += " 		 DV3DES.DV3_INSCR DESDV3_INSCR,		" + CRLF
	cQuery += " 		 SB1.B1_DESC,						" + CRLF
	cQuery += " 		 SB1.B1_COD,						" + CRLF
	cQuery += " 		 SB1.B1_UM							" + CRLF
	cQuery += "   FROM " + RetSqlName("DTC") + " DTC 		" + CRLF

	cQuery += " 		INNER JOIN " + RetSqlName('SB1') + " SB1 "	+ CRLF
	cQuery += "					ON ( SB1.B1_COD = DTC.DTC_CODPRO ) "+ CRLF

	cQuery += " 		 LEFT JOIN " + RetSqlName('DV3') + " DV3REM " + CRLF
	cQuery += "					ON (DV3REM.DV3_FILIAL = '" + xFilial("DV3") + "'"  + CRLF
	cQuery += "					AND DV3REM.DV3_CODCLI = DTC.DTC_CLIREM " + CRLF
	cQuery += "					AND DV3REM.DV3_LOJCLI = DTC.DTC_LOJREM " + CRLF
	cQuery += "					AND DV3REM.DV3_SEQUEN = DTC.DTC_SQIREM " + CRLF
	cQuery += "					AND DV3REM.D_E_L_E_T_ = ' ') "

	cQuery += " 		 LEFT JOIN " + RetSqlName('DV3') + " DV3DES " + CRLF
	cQuery += "					ON (DV3DES.DV3_FILIAL = '" + xFilial("DV3") + "'"  + CRLF
	cQuery += "					AND DV3DES.DV3_CODCLI = DTC.DTC_CLIDES " + CRLF
	cQuery += "					AND DV3DES.DV3_LOJCLI = DTC.DTC_LOJDES " + CRLF
	cQuery += "					AND DV3DES.DV3_SEQUEN = DTC.DTC_SQIdES " + CRLF
	cQuery += "					AND DV3DES.D_E_L_E_T_ = ' ') "

	cQuery += "  WHERE DTC.DTC_FILIAL = '" + xFilial('DTC') + "'" + CRLF

	cQuery += "	 	AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'" + CRLF
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o tipo de Conhecimento for de Complemento, seleciona as      ³
	//³ informacoes do CTR principal, pois o complemento nao tem DTC    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cDoc)
		cQuery += " AND DTC.DTC_FILDOC   = '" + cFilDoc + "'" + CRLF
		cQuery += " AND (DTC.DTC_DOC     = '" + cDoc + "' OR DTC.DTC_DOCPER = '" + cDoc + "')" + CRLF
		cQuery += " AND DTC.DTC_SERIE    = '" + cSerie + "'" + CRLF
	Else
		cQuery += " AND DTC.DTC_FILDOC   = '" + (cAliasDT6)->DT6_FILDOC + "'" + CRLF
		cQuery += " AND (DTC.DTC_DOC     = '" + (cAliasDT6)->DT6_DOC    + "' OR DTC.DTC_DOCPER = '" + (cAliasDT6)->DT6_DOC + "')" + CRLF
		cQuery += " AND DTC.DTC_SERIE    = '" + (cAliasDT6)->DT6_SERIE  + "'" + CRLF
	EndIf
	cQuery += " AND DTC.D_E_L_E_T_   = ' '" + CRLF
	cQuery += " GROUP BY DV3REM.DV3_INSCR, DV3DES.DV3_INSCR, DTC.DTC_TIPNFC, DTC.DTC_DEVFRE, DTC.DTC_CODOBS, DTC.DTC_CTRDPC, DTC.DTC_SERDPC, DTC.DTC_TIPANT, "+ CRLF
	cQuery += "          DTC.DTC_DPCEMI, DTC.DTC_CTEANT, DTC.DTC_SELORI, DTC.DTC_CLIDES, DTC.DTC_LOJDES, DTC.DTC_SQEDES, DTC.DTC_FILORI, DTC.DTC_NUMSOL, "+ CRLF				
	cQuery += "          SB1.B1_DESC, SB1.B1_COD , SB1.B1_UM " + CRLF

	cQuery += " ORDER BY MAX(DTC.DTC_VALOR) DESC" + CRLF
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAll, .F., .T.)

Return 
