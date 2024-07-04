#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGAR110.ch'
 
/*/{Protheus.doc} OGAR110
//Relatório Contratos Pendentes de Embarque
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
function OGAR110()
	Local oReport	:= Nil	
	Private _cPergunta := "OGAR110001"
    Private _cAliasQry := GetNextAlias()
    Private oBreakCli, oBreakPrd, oBreakFaz
    	
    If !isBlind()
        If TRepInUse()            
            If Pergunte(_cPergunta,.T.)	                            
                oReport := ReportDef()
                oReport:PrintDialog()
            EndIf
        EndIf
    Else               
        oReport := ReportDef()
        oReport:PrintDialog()            
    EndIf
	
return .t.

/*/{Protheus.doc} ReportDef
//Função monta as colunas/ totalizadores do relatório
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSHeader		:= Nil
	Local oSDados		:= Nil
        
    oReport 	:= TReport():New("OGAR110",STR0001,"",{|oReport| PrintReport(oReport)},STR0001)		//Contratos Pendentes de Embarque
	oReport:SetLandScape()       	
	oReport:HideFooter() 
    oReport:SetTotalInLine(.F.)
    oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:oPage:nPapersize := 9   
	
	oSHeader := TRSection():New(oReport, "HEADER", {"(_cAliasQry)"})
	oSHeader:SetLineStyle(.T.)	
	
	TRCell():New(oSHeader,"NJR_CODENT", "(_cAliasQry)", /*"Cliente"*/ STR0003, PesqPict("SA1","A1_NOME"), TamSX3("A1_NOME")[1],  /*lPixel*/, {|| getCliente((_cAliasQry)->NJR_CODENT, (_cAliasQry)->NJR_LOJENT)},  "LEFT", ,"LEFT", .T., , , , , .T.)    //Cliente
	
	oSProd  := TRSection():New(oSHeader, "PRODUTO", {"(_cAliasQry)"})
	oSProd:SetLineStyle(.T.)
	
	TRCell():New(oSProd, "NJR_CODPRO", "(_cAliasQry)", /*"Produto"*/ STR0004, PesqPict("NJR","NJR_CODPRO"), TamSX3("B1_DESC")[1], /*lPixel*/, {|| getProduto((_cAliasQry)->NJR_CODPRO)}) //Produto
	
    oSDados := TRSection():New(oSProd, "DADOS", {"(_cAliasQry)"})                	        
    oSDados:SetHeaderBreak(.T.)
    
    TRCell():New(oSDados, "N9A_FILORG", "(_cAliasQry)", /*"Fazenda"*/ STR0002, PesqPict("N9A","N9A_FILORG"), 20, /*lPixel*/, {|| FWFilialName(,(_cAliasQry)->N9A_FILORG ,1 )}) //Fazenda    	   
           
    //exibe colunas contrato/ regra fiscal relatório não consolidado
    If MV_PAR13 == 1
		TRCell():New(oSDados, "NJR_CTREXT", "(_cAliasQry)", /*"Contrato"*/ STR0005,     PesqPict("NJR","NJR_CTREXT"), TamSX3("NJR_CTREXT" )[1], /*lPixel*/, {|| (_cAliasQry)->NJR_CTREXT})    //Contrato
		TRCell():New(oSDados, "N9A_SEQPRI", "(_cAliasQry)", /*"Regra Fiscal"*/ STR0006, PesqPict("N9A","N9A_SEQPRI"), TamSX3("N9A_SEQPRI")[1]+TamSX3("N9A_ITEM")[1]+1,  /*lPixel*/, {|| (_cAliasQry)->N9A_ITEM+"-"+(_cAliasQry)->N9A_SEQPRI})       //Regra Fiscal
	EndIf
	    
    TRCell():New(oSDados, "PESOCONT", , /*"Peso Contrato"*/ STR0007,     PesqPict("NJR","NJR_VLRTOT"), TamSX3("NJR_VLRTOT")[1],	/*lPixel*/, {|| (_cAliasQry)->PESOCONT}) 	//Peso Contrato		
    TRCell():New(oSDados, "PESONF",   , /*"Peso NF"*/ STR0008,           PesqPict("NJR","NJR_VLRTOT"), TamSX3("NJR_VLRTOT")[1],	/*lPixel*/, {|| (_cAliasQry)->PESONF}) 		//Peso NF 
    TRCell():New(oSDados, "PESODEV",  , /*"Peso Devolução"*/ STR0009,    PesqPict("NJR","NJR_VLRTOT"), TamSX3("NJR_VLRTOT")[1],  /*lPixel*/, {|| (_cAliasQry)->PESODEV}) 	//Peso Devolução	
    TRCell():New(oSDados, "PESOFAT",  , /*"Peso Faturado"*/ STR0010,     PesqPict("NJR","NJR_VLRTOT"), TamSX3("NJR_VLRTOT")[1],  /*lPixel*/, {|| (_cAliasQry)->PESONF - (_cAliasQry)->PESODEV}) 	//Peso Faturado	        
    TRCell():New(oSDados, "SLDEMB",   , /*"Saldo Embarcar"*/ STR0011,    PesqPict("NJR","NJR_VLRTOT"), TamSX3("NJR_VLRTOT")[1],	/*lPixel*/, {|| getSldEmb((_cAliasQry)->PESOCONT, (_cAliasQry)->PESONF,(_cAliasQry)->PESODEV)}) 	//Saldo Embarcar 	
    TRCell():New(oSDados, "PERCEMB",  , /*"% Embarcado"*/ STR0012,       "@E 999.99",                                        5,	/*lPixel*/, {|| getPerEmb((_cAliasQry)->PESONF, (_cAliasQry)->PESODEV, (_cAliasQry)->PESOCONT)}) 	//% Embarcado
    TRCell():New(oSDados, "PRECOFAT", , /*"Preço Faturamento"*/ STR0013, PesqPict("N9A","N9A_VLTFPR"), TamSX3("N9A_VLTFPR" )[1],	/*lPixel*/, {|| (_cAliasQry)->PRECOFAT}) 	//Preço Faturamento
    	
    // Total por Cliente
	oBreakCli := TRBreak():New(oSHeader, { || (_cAliasQry)->NJR_CODENT+(_cAliasQry)->NJR_LOJENT }, STR0017, .F., 'NOMEBRKCF',  .T.) // Total Cliente
	oBreakCli:OnPrintTotal({|| oReport:skipLine(2)})

	TRFunction():New(oSDados:Cell("PESOCONT"),"TOTCLI1", 'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)    		
	TRFunction():New(oSDados:Cell("PESONF"),"TOTCLI2",   'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PESODEV"),"TOTCLI3",  'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PESOFAT"),"TOTCLI4",  'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("SLDEMB"),"TOTCLI5",   'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PERCEMB"),"TOTCLI6",  'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PRECOFAT"),"TOTCLI7", 'SUM', oBreakCli,,,,.F.,.F.,.F., oSDados)
	
	// Total por Produto
	oBreakPrd := TRBreak():New(oSProd, { || (_cAliasQry)->NJR_CODENT+(_cAliasQry)->NJR_LOJENT+(_cAliasQry)->NJR_CODPRO }, STR0018, .F., 'NOMEBRKCF',  .F.)	//Total Produto
	oBreakPrd:OnPrintTotal({|| oReport:skipLine(2)})

	TRFunction():New(oSDados:Cell("PESOCONT"),"TOTPRD1", 'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)    		
	TRFunction():New(oSDados:Cell("PESONF"),"TOTPRD2",   'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PESODEV"),"TOTPRD3",  'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PESOFAT"),"TOTPRD4",  'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("SLDEMB"),"TOTPRD5",   'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PERCEMB"),"TOTPRD6",  'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)
	TRFunction():New(oSDados:Cell("PRECOFAT"),"TOTPRD7", 'SUM', oBreakPrd,,,,.F.,.F.,.F., oSDados)
	
	// Total por Fazenda
	If MV_PAR13 == 1
		oBreakFaz := TRBreak():New(oSDados, { || (_cAliasQry)->NJR_CODENT+(_cAliasQry)->NJR_LOJENT+(_cAliasQry)->NJR_CODPRO+(_cAliasQry)->N9A_FILORG }, STR0015, .F., 'NOMEBRKCF',  .F.)	//Total Fazenda
		oBreakFaz:OnPrintTotal({|| oReport:skipLine(2)})
	
		TRFunction():New(oSDados:Cell("PESOCONT"),"TOTFAZ1", 'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)    		
		TRFunction():New(oSDados:Cell("PESONF"),"TOTFAZ2",   'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)
		TRFunction():New(oSDados:Cell("PESODEV"),"TOTFAZ3",  'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)
		TRFunction():New(oSDados:Cell("PESOFAT"),"TOTFAZ4",  'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)
		TRFunction():New(oSDados:Cell("SLDEMB"),"TOTFAZ5",   'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)
		TRFunction():New(oSDados:Cell("PERCEMB"),"TOTFAZ6",  'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)
		TRFunction():New(oSDados:Cell("PRECOFAT"),"TOTFAZ7", 'SUM', oBreakFaz,,,,.F.,.F.,.F., oSDados)
	EndIf
    
Return( oReport )

/*/{Protheus.doc} PrintReport
//Função montagem do SQL do relatório e impressão das colunas
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport( oReport ) 	
    Local oSPrinc       := nil  
    Local oProd			:= nil
    Local oDados        := nil  
    Local nTamEmp       := 0
    Local nTamUnNeg     := 0    
    Local cNomeEmp      := ""
	Local cNmFil        := ""
    Local cQuery        := ""
    Local cWhere        := ""  
    Local cKey			:= "" 
    Local cKeyProd		:= ""

    nTamEmp   := Len(FWSM0LayOut(,1))
    nTamUnNeg := Len(FWSM0LayOut(,2))

    oReport:SetCustomText( {|| AGRARCabec(oReport, @cNomeEmp, @cNmFil) } ) // Cabeçalho customizado

   	oSPrinc := oReport:Section(1)
   	oProd	:= oSPrinc:Section(1)
   	oDados  := oProd:Section(1)
    
    fWhereSQL(@cWhere)
    
    cQuery := "	SELECT N9A.N9A_FILORG, NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CODPRO, "
    
    //se não for relatório consolidado busca contrato/ regra fiscal 
    If MV_PAR13 == 1
    	cQuery += "NJR.NJR_CTREXT, N9A.N9A_ITEM, N9A.N9A_SEQPRI," 
    EndIf
    
    cQuery += " SUM(NJR.NJR_VLRTOT) AS PESOCONT, SUM(N9A.N9A_VTOTNF) AS PESONF, "
    cQuery += " SUM(N9A_VLTFPR) AS PRECOFAT, SUM(N9K_QTDEVL) AS PESODEV "
	cQuery += "  FROM " + RetSqlName('NJR') + " NJR "
	cQuery += " INNER JOIN " + RetSqlName('N9A') + " N9A " 
	cQuery += "    ON N9A.N9A_CODCTR = NJR.NJR_CODCTR "
	cQuery += "   AND N9A.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN " + RetSqlName('N9K') + " N9K "
	cQuery += "    ON N9K.N9K_FILORI = N9A.N9A_FILORG "
	cQuery += "   AND N9K.N9K_CODCTR = N9A.N9A_CODCTR "
	cQuery += "   AND N9K.N9K_ITEMPE = N9A.N9A_ITEM "
	cQuery += "   AND N9K.N9K_ITEMRF = N9A.N9A_SEQPRI "
	cQuery += "   AND N9K.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NJR.D_E_L_E_T_ = ' ' "
	
	If !Empty(cWhere)
		cQuery += cWhere
	EndIf	 	

    //se não for relatório consolidado agrupa/ordena contrato/ regra fiscal 
    If MV_PAR13 == 1
	    cQuery += " GROUP BY NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CODPRO, N9A.N9A_FILORG, NJR.NJR_CTREXT, N9A.N9A_ITEM, N9A.N9A_SEQPRI"
		cQuery += " ORDER BY NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CODPRO, N9A.N9A_FILORG, NJR.NJR_CTREXT, N9A.N9A_ITEM, N9A.N9A_SEQPRI"
	Else
	    cQuery += " GROUP BY NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CODPRO, N9A.N9A_FILORG "
		cQuery += " ORDER BY NJR.NJR_CODENT, NJR.NJR_LOJENT, NJR.NJR_CODPRO, N9A.N9A_FILORG "
	EndIf
		
    //oReport:SetMeter((_cAliasQry)->(RecSize()))	

	_cAliasQry := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cAliasQry,.T.,.T.)
	DbSelectArea( _cAliasQry ) 	
	
	If .Not. (_cAliasQry)->(Eof())
	    While (_cAliasQry)->(!Eof())        
			
			If oReport:Cancel()
			    Return( Nil )
		    EndIf
		    
		    oReport:IncMeter()
		    		    		       		  
		    If cKey != (_cAliasQry)->NJR_CODENT+(_cAliasQry)->NJR_LOJENT
		    		    			   
		     	If !Empty(cKey)	
		     		oDados:Finish()
		     		oProd:Finish()		     		
		     		oSPrinc:Finish()
		     		
		     		cKeyProd := ""		     				     	
		     	EndIf
		    
		        cKey := (_cAliasQry)->NJR_CODENT+(_cAliasQry)->NJR_LOJENT
		        
		        oSPrinc:Init()		    
		        oSPrinc:PrintLine()	
		        
		        oBreakCli:SetTitle(STR0017 + ": " + getCliente((_cAliasQry)->NJR_CODENT, (_cAliasQry)->NJR_LOJENT))        
		               	        
		    ElseIf cKeyProd != (_cAliasQry)->NJR_CODPRO
		    		    			    	    		     	
		     	oDados:Finish()
		     	oProd:Finish()
		    		        		       
		    EndIf
		    
		    If cKeyProd != (_cAliasQry)->NJR_CODPRO
		    		    			    
		    	cKeyProd := (_cAliasQry)->NJR_CODPRO
		        
		        oProd:Init()		    
		        oProd:PrintLine()
		        
		        oBreakPrd:SetTitle(STR0018 + ": " + getProduto((_cAliasQry)->NJR_CODPRO))
		    	
		    EndIf	
		    		    
		    oDados:Init()		  
		    oDados:PrintLine()	        	                                                    	       
	        	        
	        (_cAliasQry)->(dbSkip())                   
	        
	    EndDo        	                            
	EndIf    
	
	oDados:Finish()
	oProd:Finish()	
	oSPrinc:Finish()                                    
    
    (_cAliasQry)->(dbCloseArea())	
		
Return .t.
	
/*/{Protheus.doc} AGRARCabec
//Função montagem do cabeçalho do relatório
@author marina.muller
@since 17/12/2018
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
	AADD(aCabec, STR0016 + ":" + cNmEmp) //Esquerda //"Empresa"
	aCabec[5] += Space(9) // Meio

Return aCabec

/*/{Protheus.doc} fWhereSQL
//Função montagem do filtro do relatório utilizando os perguntes
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cWhere, characters, descricao
@type function
/*/
Static Function fWhereSQL(cWhere) 

 If !Empty(MV_PAR01) .or. !Empty(MV_PAR02) //filial
    cWhere += "AND N9A.N9A_FILORG BETWEEN '" + alltrim(MV_PAR01) + "' AND '" +  alltrim(MV_PAR02) + "'"
 EndIf

 If !Empty(MV_PAR03) .or. !Empty(MV_PAR04) //contrato externo    
    cWhere += "AND NJR.NJR_CTREXT BETWEEN '" + alltrim(MV_PAR03) + "' AND '" +  alltrim(MV_PAR04) + "'"
 EndIf

 If !Empty(MV_PAR05) .or. !Empty(MV_PAR06) //safra
    cWhere += "AND NJR.NJR_CODSAF BETWEEN '" + alltrim(MV_PAR05) + "' AND '" +  alltrim(MV_PAR06) + "'"
 EndIf

 If !Empty(MV_PAR07) .or. !Empty(MV_PAR09) //entidade
    cWhere += "AND NJR.NJR_CODENT BETWEEN '" + alltrim(MV_PAR07) + "' AND '" +  alltrim(MV_PAR09) + "'"
 EndIf

 If !Empty(MV_PAR08) .or. !Empty(MV_PAR10) //loja
    cWhere += "AND NJR.NJR_LOJENT BETWEEN '" + alltrim(MV_PAR08) + "' AND '" +  alltrim(MV_PAR10) + "'"
 EndIf

 If !Empty(MV_PAR11) .or. !Empty(MV_PAR12) //produto
    cWhere += "AND NJR.NJR_CODPRO BETWEEN '" + alltrim(MV_PAR11) + "' AND '" +  alltrim(MV_PAR12) + "'"
 EndIf

Return 

/*/{Protheus.doc} getCliente
//Função buscar nome do cliente
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cEntidade, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getCliente(cEntidade, cLoja)
	Local cRet     := ""
	Local cCliente := ""
	Local cLojCli    := ""
	
	If !Empty(cEntidade)
		cCliente := Posicione("NJ0",1,FWxFilial("NJ0")+cEntidade+cLoja,"NJ0_CODCLI")
		cLojCli  := Posicione("NJ0",1,FWxFilial("NJ0")+cEntidade+cLoja,"NJ0_LOJCLI")
		cRet     := Posicione("SA1",1,FWxFilial("SA1")+cCliente+cLojCli,"A1_NOME")
	EndIf	
	
Return cRet

/*/{Protheus.doc} getProduto
//Função para buscar descrição do produto
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cProduto, characters, descricao
@type function
/*/
Static Function getProduto(cProduto)
	Local cRet := ""
	
	If !Empty(cProduto)
		cRet := Posicione("SB1",1,FWxFilial("SB1")+cProduto,"B1_DESC")
	EndIf	
	
Return cRet

/*/{Protheus.doc} getSldEmb
//Função para calular o saldo a embarcar
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param nPesoCont, numeric, descricao
@param nPesoNF, numeric, descricao
@param nPesoDev, numeric, descricao
@type function
/*/
Static Function getSldEmb(nPesoCont, nPesoNF, nPesoDev)
	Local nSldEmb := 0
	
	nSldEmb  := (nPesoCont - (nPesoNF - nPesoDev))
	
Return nSldEmb

/*/{Protheus.doc} getPerEmb
//Função para calcular percentual embarcado
@author marina.muller
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@param nPesoNF, numeric, descricao
@param nPesoDev, numeric, descricao
@param nPesoCont, numeric, descricao
@type function
/*/
Static Function getPerEmb(nPesoNF, nPesoDev, nPesoCont)
	Local nPercEmb := 0
	
	nPercEmb := (((nPesoNF - nPesoDev) / nPesoCont) * 100)

Return nPercEmb
	
