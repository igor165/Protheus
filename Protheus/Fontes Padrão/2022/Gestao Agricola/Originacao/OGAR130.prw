#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGAR130.ch'

/*/{Protheus.doc} OGAR130
//Relatório Análise Posição de Embarque
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
function OGAR130()
	Local oReport	:= Nil	
	Private _cPergunta := "OGAR130001"
    Private _cAliasQry := GetNextAlias()
	
    If !isBlind()
        If TRepInUse()            
            If Pergunte(_cPergunta,.T.)	                            
                If OGAR130PRD()
                   oReport := ReportDef()
                   oReport:PrintDialog()
                 EndIf  
            EndIf
        EndIf
    Else               
        oReport := ReportDef()
        oReport:PrintDialog()            
    EndIf
	
return .t.

/*/{Protheus.doc} ReportDef
//Função montagem colunas/ totalizadores relatório
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSDados		:= Nil	
    Local oBreakCtr     := nil
    Local oBreakFaz     := nil
    
    oReport 	:= TReport():New("OGAR130",STR0001,"",{|oReport| PrintReport(oReport)},STR0001)		//Análise Posição de Embarque
	oReport:SetLandScape()       	
	oReport:HideFooter() 
    oReport:SetTotalInLine(.F.)
    oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:oPage:nPapersize := 9     
	
    oSDados := TRSection():New( oReport, "DADOS", {"(_cAliasQry)"})                	        
    oSDados:SetHeaderPage(.T.)
    
    TRCell():New(oSDados,"(_cAliasQry)->NJR_CODENT", "(_cAliasQry)", /*"Cliente"*/      STR0002, PesqPict("NJ0","NJ0_NOME"),     20, /*lPixel*/, {|| ALLTRIM((_cAliasQry)->NJ0_NOME)})    //Cliente	 
    TRCell():New(oSDados,"(_cAliasQry)->NJR_CTREXT", "(_cAliasQry)", /*"Contrato"*/     STR0003, PesqPict("NJR","NJR_CTREXT"), TamSX3("NJR_CTREXT" )[1], /*lPixel*/, {|| (_cAliasQry)->NJR_CTREXT})    //Contrato   
    TRCell():New(oSDados,"(_cAliasQry)->NJR_STSASS", "(_cAliasQry)", /*"C. Assinado?"*/ STR0004, PesqPict("NJR","NJR_STSASS"), TamSX3("NJR_STSASS" )[1], /*lPixel*/, {|| getAssinado((_cAliasQry)->NJR_STSASS)}) 	//C. Assinado	    
    TRCell():New(oSDados,"(_cAliasQry)->NNY_MESEMB", "(_cAliasQry)", /*"Mês/Ano"*/      STR0005, PesqPict("NNY","NNY_MESEMB"), TamSX3("NNY_MESEMB" )[1], /*lPixel*/, {|| (_cAliasQry)->NNY_MESEMB}) 	//Mês/Ano
    If MV_PAR10 == 1
    	TRCell():New(oSDados,"(_cAliasQry)->N9A_SEQPRI", "(_cAliasQry)", /*"Regra Fiscal"*/ STR0006, PesqPict("N9A","N9A_SEQPRI"), TamSX3("N9A_SEQPRI")[1]+TamSX3("N9A_ITEM")[1]+1,  /*lPixel*/, {|| (_cAliasQry)->N9A_ITEM+"-"+(_cAliasQry)->N9A_SEQPRI})       //Regra Fiscal
    EndIf	    
    TRCell():New(oSDados,"TKP_CONTRAT",   , /*"Take-up Contratado"*/  STR0007,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT")[1],	/*lPixel*/, {|| (_cAliasQry)->QTD_CADENCIA}) 	//Take-up Contratado		
    TRCell():New(oSDados,"TKP_REALIZADA", , /*"Take-up Realizado"*/   STR0008,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT")[1],	/*lPixel*/, {|| (_cAliasQry)->TKP_REALIZADA}) 	//Take-up Realizado 
    TRCell():New(oSDados,"EMB_CONTRAT",   , /*"Embarque Contratado"*/ STR0009,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT")[1],  /*lPixel*/, {|| (_cAliasQry)->QTD_CADENCIA}) 	//Embarque Contratado	
    TRCell():New(oSDados,"EMB_FECHADO",   , /*"Embarque BL-Fechado/ Faturado"*/ STR0010, PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT")[1],  /*lPixel*/, {|| (_cAliasQry)->EMB_FECHADO}) //Embarque BL-Fechado/Faturado	        
    TRCell():New(oSDados,"INSTRUIDO",     , /*"Processo Instruído"*/  STR0011,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT")[1],	/*lPixel*/, {|| (_cAliasQry)->INSTRUIDO}) 	//Processo Instruído 	
    TRCell():New(oSDados,"REMETIDO",      , /*"Processo Remetido"*/   STR0012,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT")[1],	/*lPixel*/, {|| (_cAliasQry)->REMETIDO}) 	//Processo Remetido
    TRCell():New(oSDados,"SLD_EMBARCAR",  , /*"Saldo a Embarcar"*/    STR0013,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT" )[1],	/*lPixel*/, {|| (_cAliasQry)->QTD_CADENCIA - (_cAliasQry)->INSTRUIDO}) 	//Saldo a Embarcar
    TRCell():New(oSDados,"SLD_INSTRUIR",  , /*"Saldo a Instruir"*/    STR0014,   PesqPict("NNY","NNY_QTDINT"), TamSX3("NNY_QTDINT" )[1],	/*lPixel*/, {|| (_cAliasQry)->TKP_REALIZADA - (_cAliasQry)->INSTRUIDO}) 	//Saldo a Instruir

    oBreakCtr   := TRBreak():New(oSDados, { || (_cAliasQry)->NJR_CODENT + (_cAliasQry)->NJR_CTREXT} , STR0015, .F., 'NOMEBRKUN',  .F.)	//Total Contrato
    oBreakCtr:OnPrintTotal({|| oReport:skipLine(2)})

    TRFunction():New(oSDados:Cell("TKP_CONTRAT"),  , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)    		
    TRFunction():New(oSDados:Cell("TKP_REALIZADA"),, 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("EMB_CONTRAT"),  , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("EMB_FECHADO"),  , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("INSTRUIDO"),    , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("REMETIDO"),     , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("SLD_EMBARCAR"), , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("SLD_INSTRUIR"), , 'SUM',oBreakCtr,,,,.F.,.F.,.F.,   oSDados)
	    
    oBreakFaz   := TRBreak():New(oSDados, { || (_cAliasQry)->NJR_CODENT } , STR0016, .F., 'NOMEBRKCF',  .T.)	//Total Cliente
    oBreakFaz:OnPrintTotal({|| oReport:skipLine(2)})

    TRFunction():New(oSDados:Cell("TKP_CONTRAT"),  , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)    		
    TRFunction():New(oSDados:Cell("TKP_REALIZADA"),, 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("EMB_CONTRAT"),  , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("EMB_FECHADO"),  , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("INSTRUIDO"),    , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("REMETIDO"),     , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("SLD_EMBARCAR"), , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    TRFunction():New(oSDados:Cell("SLD_INSTRUIR"), , 'SUM',oBreakFaz,,,,.F.,.F.,.F.,   oSDados)
    
Return( oReport )

/*/{Protheus.doc} PrintReport
//Função montagem SQL e impressão do relatório
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport( oReport ) 	
    Local oSPrinc       := nil        
    Local cNomeEmp      := ""
	Local cNmFil        := ""
    Local cQuery        := ""
    Local cWhere        := ""
    Local cVis1         := ""
    Local cVis2         := ""   

    oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

   	oSPrinc   := oReport:Section( 1 )
    
    fWhereSQL(@cWhere)
    
	cQuery := "  SELECT NJR.NJR_CODENT, NJR.NJR_CTREXT, NJR.NJR_STSASS, "
	cQuery += "         NNY.NNY_MESEMB, N9A.N9A_ITEM, NJ0.NJ0_NOME, "
	If MV_PAR10 == 1
		cQuery += "         N9A.N9A_SEQPRI, "
	EndIf
	cQuery += "         SUM(NNY.NNY_QTDINT) AS QTD_CADENCIA, "
	cQuery += "         SUM(NNY.NNY_TKPQTD) AS TKP_REALIZADA, "
	cQuery += "         SUM(N9A.N9A_QTDNF)  AS EMB_FECHADO, "
	cQuery += "         SUM(N7S.N7S_QTDVIN) AS INSTRUIDO, "
	cQuery += "         SUM(N7S.N7S_QTDREM) AS REMETIDO "
	cQuery += "    FROM " + RetSqlName('NJR') + " NJR " 
	cQuery += "   INNER JOIN " + RetSqlName('NJ0') + " NJ0 "
	cQuery += "  	 ON NJ0.NJ0_FILIAL = '" + xFilial("NJ0") +"'"
	cQuery += "     AND NJ0.NJ0_CODENT = NJR.NJR_CODENT "
    cQuery += "     AND NJ0.NJ0_LOJENT = NJR.NJR_LOJENT "
    cQuery += "     AND NJ0.D_E_L_E_T_ = ' ' "
    cQuery += "   INNER JOIN " + RetSqlName('N9A') + " N9A "
	cQuery += "  	 ON N9A.N9A_FILIAL = NJR.NJR_FILIAL "
    cQuery += "  	AND N9A.N9A_CODCTR = NJR.NJR_CODCTR "
	cQuery += "     AND N9A.D_E_L_E_T_ = ' ' "
	cQuery += "   INNER JOIN " + RetSqlName('N7S') + " N7S " 
	cQuery += "  	 ON N7S.N7S_FILORG = N9A.N9A_FILORG "
	cQuery += "  	AND N7S.N7S_CODCTR = N9A.N9A_CODCTR "
	cQuery += " 	AND N7S.N7S_ITEM   = N9A.N9A_ITEM "
	cQuery += " 	AND N7S.N7S_SEQPRI = N9A.N9A_SEQPRI "
	cQuery += " 	AND N7S.D_E_L_E_T_ = ' ' "
	cQuery += "   INNER JOIN " + RetSqlName('NNY') + " NNY " 
	cQuery += "      ON NNY.NNY_FILORG = N9A.N9A_FILORG "
	cQuery += "     AND NNY.NNY_CODCTR = N9A.N9A_CODCTR "
	cQuery += "     AND NNY.NNY_ITEM   = N9A.N9A_ITEM "
	cQuery += " 	AND NNY.D_E_L_E_T_ = ' ' "
	cQuery += "   WHERE NJR.D_E_L_E_T_ = ' ' "
	
	If !Empty(cWhere)
		cQuery += cWhere
	EndIf	 	

	If MV_PAR10 == 1
		cVis1 := "N9A.N9A_SEQPRI, "
	Else
		cVis2 := ", N9A.N9A_SEQPRI "
	EndIf
	
	cQuery += "   GROUP BY " + cVis1 + "NJR.NJR_CODENT, NJR.NJR_STSASS, NJR.NJR_CTREXT, "
	cQuery += "            NNY.NNY_MESEMB, N9A.N9A_ITEM, NJ0.NJ0_NOME " + cVis2
    cQuery += "   ORDER BY " + cVis1 + "NJR.NJR_CODENT, NJR.NJR_CTREXT, NNY.NNY_MESEMB, "
    cQuery += "            N9A.N9A_ITEM " + cVis2         
          
	_cAliasQry := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cAliasQry,.T.,.T.)
	DbSelectArea( _cAliasQry ) 	
	
	If .Not. (_cAliasQry)->(Eof())
	    While (_cAliasQry)->(!Eof())        
			
			If oReport:Cancel()
			    Return( Nil )
		    EndIf                     
		    
	        oSPrinc:Init()
	        oSPrinc:PrintLine()                  
	        oReport:IncMeter()
	        (_cAliasQry)->(dbSkip())                    
	        
	    EndDo        	                            
	EndIf
    
    oSPrinc:Finish()                                  
    
    (_cAliasQry)->(dbCloseArea())	
		
Return .t.
	
/*/{Protheus.doc} AGRARCabec
//Função impressão cabeçalho customizado
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@param cNmEmp, characters, descricao
@param cNmFilial, characters, descricao
@type function
/*/
Static Function AGRARCabec(oReport, cNmEmp , cNmFilial)
	Local aCabec := {}
	Local cChar	 := CHR(160)  // caracter dummy para alinhamento do cabeçalho

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

	// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

	// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

	// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + "Dt.Ref:" +":" + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0017 + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

Return aCabec

/*/{Protheus.doc} fWhereSQL
//Função montagem dos filtros com os perguntes
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cWhere, characters, descricao
@type function
/*/
Static Function fWhereSQL(cWhere) 

 If !Empty(MV_PAR01) .or. !Empty(MV_PAR02) //filial
    cWhere += "AND N9A.N9A_FILORG BETWEEN '" + alltrim(MV_PAR01) + "' AND '" +  alltrim(MV_PAR02) + "'"
 EndIf

 If !Empty(MV_PAR03) .or. !Empty(MV_PAR05) //entidade
    cWhere += "AND NJR.NJR_CODENT BETWEEN '" + alltrim(MV_PAR03) + "' AND '" +  alltrim(MV_PAR05) + "'"
 EndIf

 If !Empty(MV_PAR04) .or. !Empty(MV_PAR06) //loja
    cWhere += "AND NJR.NJR_LOJENT BETWEEN '" + alltrim(MV_PAR04) + "' AND '" +  alltrim(MV_PAR06) + "'"
 EndIf

 If !Empty(MV_PAR07) .or. !Empty(MV_PAR08) //contrato externo    
    cWhere += "AND NJR.NJR_CTREXT BETWEEN '" + alltrim(MV_PAR07) + "' AND '" +  alltrim(MV_PAR08) + "'"
 EndIf

 If !Empty(MV_PAR09) //produto
    cWhere += "AND NJR.NJR_CODPRO = '" + alltrim(MV_PAR09) + "' "
 EndIf

Return 

/*/{Protheus.doc} getAssinado
//Função busca status assinatura do contrato
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cStatus, characters, descricao
@type function
/*/
Static Function getAssinado(cStatus)
	Local cRet     := ""
	
	If !Empty(cStatus)
		If cStatus == "A"
		    cRet := STR0018  //"Aberto" 
		ElseIf cStatus == "F"
			cRet := STR0019  //"Finalizado"
		EndIf 
	EndIf	
	
Return cRet

/*/{Protheus.doc} OGAR130PRD
//Função valida se produto foi informado
@author marina.muller
@since 18/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGAR130PRD()
	Local lRet := .T.
	
	If Empty(MV_PAR09)
		lRet := .F.
		MsgAlert(STR0020) //"Produto deve ser informado."
	EndIf
	
Return lRet
