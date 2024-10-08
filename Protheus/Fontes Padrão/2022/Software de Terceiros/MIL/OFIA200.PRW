#Include "TOTVS.ch"
#Include "OFIA200.ch"

/*/
{Protheus.doc} OFIA200
Rotina que realiza a gera��o e envio do DEF (DFS D-In) Cont�bil da AGCO no formato JSON para consumo da API.
@type   Function
@author Ot�vio Favarelli
@since  28/10/2019
@param  nil
@return nil
/*/
Function OFIA200()

    Local oTProcess
    Local bProcess := { |oSelf| OA2000017_GeraDFSContabilJSON(oSelf) }
    Local lPainelAux := .t.
    Local lViewExecute := .t.
    Local lOneMeter := .f.
    Local cPerg := "OFIA200" // Pergunte

	//
	// Validacao de Licencas DMS
	//
	If !OFValLicenca():ValidaLicencaDMS()
		Return
	EndIf

    oTProcess := tNewProcess():New(;
                                    STR0001,;				// 01 - Nome da fun��o que est� chamando o objeto.	//OFIA200
                                    STR0002,;				// 02 - T�tulo da �rvore de op��es.	// Gera��o e Envio DEF Cont�bil AGCO
                                    bProcess,;				// 03 - Bloco de execu��o que ser� executado ao confirmar a tela.
                                    STR0003,;				// 04 - Descri��o da rotina.	// Esta rotina realiza a gera��o e a transmiss�o do DEF Cont�bil da AGCO.
                                    cPerg,;					// 05 - Nome do Pergunte (SX1) a ser utilizado na rotina.
                                    /* aInfoCustom */ ,;	// 06 - Informa��es adicionais carregada na �rvore de op��es.
                                    lPainelAux,;			// 07 - Se .T. cria uma novo painel auxiliar ao executar a rotina.
                                    /* nSizePanelAux */ ,;	// 08 - Tamanho do painel auxiliar, utilizado quando lPainelAux = .T.
                                    /* cDescriAux */ ,;		// 09 - Descri��o a ser exibida no painel auxiliar.
                                    lViewExecute,;			// 10 - Se .T. exibe o painel de execu��o. Se .f., apenas executa a fun��o sem exibir a r�gua de processamento.
                                    lOneMeter;				// 11 - Se .T. cria apenas uma regua de processamento.
                                    )

Return

/*/
{Protheus.doc} OA2000017_GeraDFSContabilJSON
Rotina que realiza a gera��o do DEF AGCO (DFS) Cont�bil no formato JSON.
@type   Static Function
@author Ot�vio Favarelli
@since  28/10/2019
@param  oTProcess,  Objeto, Objeto tNewProcess para controle e intera��o do processamento.
@return nil
/*/
Static Function OA2000017_GeraDFSContabilJSON(oTProcess)

    Local cAuxData			:= Dtoc(dDataBase)
    Local cAliasB 			:= GetNextAlias()
    Local cQuery  			:= ""
    Local cJsonFinal
    Local cTimeIni
    Local cArqCNPJ  
    Local cArqMesAno
    Local cArqTStamp
	Local cEndPoint
    //
    Local nPos
    Local nCntA
    Local nCntB
    Local nCntC
    //
    Local jChavePrimaria    := {}
    //
    Local aDFS              := {}
    //
    Local lGrvJSON
	//

	//
	Private aFilComp := {}
	//

	If !OA2000027_ValidacoesIniciais()
		Return
	EndIf
	
	cEndPoint := GetMV("MV_MIL0142")

	ConOut(Chr(13) + Chr(10))
    ConOut("---------------------------------------------------------------")
    ConOut(" #######  ######## ####    ###     #######    #####     #####  ")
    ConOut("##     ## ##        ##    ## ##   ##     ##  ##   ##   ##   ## ")
    ConOut("##     ## ##        ##   ##   ##         ## ##     ## ##     ##")
    ConOut("##     ## ######    ##  ##     ##  #######  ##     ## ##     ##")
    ConOut("##     ## ##        ##  ######### ##        ##     ## ##     ##")
    ConOut("##     ## ##        ##  ##     ## ##         ##   ##   ##   ## ")
    ConOut(" #######  ##       #### ##     ## #########   #####     #####  ")
    ConOut("---------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut( STR0004 + cAuxData + " - " + Time() )	// INICIO DA GERACAO DO AGCO DFS CONTABIL JSON - OFIA200:
    cTimeIni := Time() 

	cQuery := "SELECT "
    cQuery +=   " COUNT(*) "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VDC") + " VDC "
    cQuery += "INNER JOIN "
    cQuery +=   RetSQLName("VD9") + " VD9 ON "
    cQuery +=   " VD9.VD9_CODDEF = VDC.VDC_CODDEF "
    cQuery +=   " AND VD9.VD9_CODCON = VDC.VDC_CODCON "
    cQuery += "WHERE "
    cQuery +=   " VD9.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VDC.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VD9.VD9_FILIAL = '" + xFilial("VD9") + "' "
    cQuery +=   " AND VDC.VDC_DATA = '" + DTOS(MV_PAR02) + "' " // Data?
    cQuery +=   " AND VDC.VDC_CODDEF = '" + Alltrim(MV_PAR03) + "' " // C�digo DEF?
    cQuery +=   " AND VDC.VDC_FILIAL IN ("
	
	For nCntA := 1 to Len(aFilComp)
		cQuery +=  "'" + aFilComp[nCntA] + "',"
	Next
	cQuery := Stuff(cQuery,Len(cQuery),1,")")

    oTProcess:SetRegua1(FM_SQL(cQuery))
    
	cQuery := "SELECT "
    cQuery +=   " VDC_FILIAL "
    cQuery +=   " , VD9_CPODEF "
    cQuery +=   " , SUM(VDC_VALOR) VALOR "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VDC") + " VDC "
    cQuery += "INNER JOIN "
    cQuery +=   RetSQLName("VD9") + " VD9 ON "
    cQuery +=   " VD9_CODDEF = VDC_CODDEF "
    cQuery +=   " AND VD9_CODCON = VDC_CODCON "
    cQuery += "WHERE "
    cQuery +=   " VD9.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VDC.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VD9_FILIAL = '" + xFilial("VD9") + "' "
    cQuery +=   " AND VDC_DATA = '" + DTOS(MV_PAR02) + "' "
    cQuery +=   " AND VDC_CODDEF = '" + Alltrim(MV_PAR03) + "' "
	cQuery +=   " AND VDC.VDC_FILIAL IN ("
	
	For nCntB := 1 to Len(aFilComp)
		cQuery +=  "'" + aFilComp[nCntB] + "',"
	Next
	cQuery := Stuff(cQuery,Len(cQuery),1,")")

    cQuery += " GROUP BY VDC_FILIAL,VD9_CPODEF"
    cQuery += " ORDER BY VDC_FILIAL,VD9_CPODEF"
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasB, .f., .t.)
    
	While !(cAliasB)->(EoF())
        oTProcess:IncRegua1( STR0005 + (cAliasB)->VD9_CPODEF )	// Gerando JSON para o DFS
        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(MV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(MV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasB)->VDC_FILIAL)[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := Substr( (cAliasB)->VD9_CPODEF, 1,4 )
        jChavePrimaria['sectionCode'        ] := Substr( (cAliasB)->VD9_CPODEF, 5,4 )
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,MV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( (cAliasB)->VALOR )
        (cAliasB)->(dbSkip())
    End
    
	cJsonFinal := "["
    
	For nCntC := 1 to Len(aDFS)
        cJsonFinal += aDFS[nCntC]:toJson() + ","
    Next
    
	cJsonFinal := Stuff(cJsonFinal,Len(cJsonFinal),2,"]")
    
	FreeObj(jChavePrimaria)
    
	(cAliasB)->(DbCloseArea())
    
	lGrvJSON := .t.
    
	// Gravacao do arquivo JSON no diretorio
    If !Empty(MV_PAR04)
        cArqCNPJ    := FWArrFilAtu(,MV_PAR01)[18]
        cArqMesAno  := cValToChar( Month(MV_PAR02) ) + cValToChar( Year(MV_PAR02) )
        cArqTStamp  := StrTran(FWTimeStamp(3,Date()),":","-")
        lGrvJSON := OA200JSON( RTrim(MV_PAR04), RTrim(MV_PAR04) + "dfscontabil_dados_" + cArqCNPJ + "_" + cArqMesAno + "_" + cArqTStamp + ".json" , cJsonFinal , "OFIA200" )
    EndIf
    	
    If lGrvJSON 

        // Chamada de fun��o para transmiss�o do JSON via API
        Processa( {|| OA200API(cEndPoint,cJsonFinal,"OFIA200") }, STR0006, STR0007,.t.)	// Aguarde... Realizando Transmiss�o via API...

    EndIf
	        
    ConOut(Chr(13) + Chr(10))
    ConOut("---------------------------------------------------------------")
    ConOut(" #######  ######## ####    ###     #######    #####     #####  ")
    ConOut("##     ## ##        ##    ## ##   ##     ##  ##   ##   ##   ## ")
    ConOut("##     ## ##        ##   ##   ##         ## ##     ## ##     ##")
    ConOut("##     ## ######    ##  ##     ##  #######  ##     ## ##     ##")
    ConOut("##     ## ##        ##  ######### ##        ##     ## ##     ##")
    ConOut("##     ## ##        ##  ##     ## ##         ##   ##   ##   ## ")
    ConOut(" #######  ##       #### ##     ## #########   #####     #####  ")
    ConOut("---------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut( STR0008 + cAuxData + " - " + Time() )	// FIM DA GERACAO DO AGCO DFS CONTABIL JSON - OFIA200:
    ConOut( STR0009 + ElapTime( cTimeIni, Time() ) )	// TEMPO DECORRIDO:

Return

/*/
{Protheus.doc} OA2000027_ValidacoesIniciais
Funcao estatica que realiza as validacoes iniciais do processo de gera��o do DEF AGCO (DFS) Cont�bil no formato JSON.
@type   Static Function
@author otaviofavarelli
@since  17/03/2021
@param  nil
@return nil
/*/
Static Function OA2000027_ValidacoesIniciais()

	Local cAliasA	:= GetNextAlias()
    Local cQuery            
    Local cEndPoint
	Local cFilFalt
	//
	Local aUni
	Local aFil
	//
	Local nCntFor1
	Local nCntFor2
	Local nCntFor3
	Local nCntFor4
	//
	Local lFilFound
	//
	
	cEndPoint := GetMV("MV_MIL0142")
    If Empty(cEndPoint)
        Help(NIL, NIL, STR0010, NIL, STR0011, /* Par�metro Em Branco |  Par�metro MV_MIL0142 est� em branco. Imposs�vel continuar. */ ; 
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0012})	// Preencha o par�metro MV_MIL0142 para utilizar esta rotina.
        Return .f.
    EndIf

	// Levantamento de todas as filiais da empresa na qual a filial matriz faz parte (MV_PAR01)
	aUni := FWAllUnitBusiness(FWArrFilAtu(,MV_PAR01)[3],FWArrFilAtu(,MV_PAR01)[1])
	If Len(aUni) == 0
		aAdd(aUni, "")
	Endif
	For nCntFor1 := 1 to Len(aUni)  
		aFil := FWAllFilial(FWArrFilAtu(,MV_PAR01)[3],aUni[nCntFor1],FWArrFilAtu(,MV_PAR01)[1])
		For nCntFor2 := 1 to Len(aFil)
			AAdd(aFilComp,FWArrFilAtu(,MV_PAR01)[3]+aUni[nCntFor1]+aFil[nCntFor2])
		Next
	Next

	// Validacao de que os registros do DEF de todas as filiais da empresa est�o gerados
	cQuery := "SELECT "
    cQuery +=   " VDB.VDB_FILIAL "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VDB") + " VDB "
    cQuery += "WHERE "
    cQuery +=   " VDB.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VDB.VDB_FILIAL IN ("
	
	For nCntFor3 := 1 to Len(aFilComp)
		cQuery +=  "'" + aFilComp[nCntFor3] + "',"
	Next
	cQuery := Stuff(cQuery,Len(cQuery),1,")")

    cQuery +=   " AND VDB.VDB_DATA = '" + DTOS(MV_PAR02) + "' " // Data?
    cQuery +=   " AND VDB.VDB_CODDEF = '" + Alltrim(MV_PAR03) + "' " // C�digo DEF?
    cQuery += "GROUP BY "
    cQuery +=   " VDB.VDB_FILIAL "
	DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasA, .f., .t.)

	cFilFalt := ""

	For nCntFor4 := 1 to Len(aFilComp)
		lFilFound := .f.
		(cAliasA)->(DbGoTop())
		
		While !(cAliasA)->(EoF()) .and. !lFilFound
			If aFilComp[nCntFor4] == (cAliasA)->VDB_FILIAL
				lFilFound := .t.
			EndIf
			(cAliasA)->(dbSkip())
		End
		
		If !lFilFound
			cFilFalt += STR0013 + aFilComp[nCntFor4] + Chr(13) + Chr(10)	// C�digo da Filial:
		EndIf

	Next

	(cAliasA)->(DbCloseArea())

	If !Empty(cFilFalt)
		Help(NIL, NIL, STR0014, NIL, STR0015 + /* Registros N�o Encontrados | Os registros do D-In Cont�bil para as filiais listadas abaixo no per�odo */ ; 
			DtoC(MV_PAR02) + STR0016 + Chr(13) + Chr(10) + cFilFalt, /* n�o foram encontrados. Imposs�vel continuar: */ ; 
			1, 0, NIL, NIL, NIL, NIL, NIL,{STR0017}) // Realize a gera��o dos dados do D-In para as filiais listadas.
        Return .f.
	EndIf

Return .t.

/*/
{Protheus.doc} OA200API
Fun��o que realiza a transmiss�o via API do DEF AGCO (DFS) Cont�bil e Gerencial no formato JSON.
@type   Function
@author Ot�vio Favarelli
@since  04/01/2020
@param  cEndPoint,  Caractere,  EndPoint que ser� utilizado para transmiss�o.
@param  cJsonFinal, Caractere,  JSON que cont�m as informa��es a serem enviadas.
@param  cRotOrig,   Caractere,  Codigo da rotina que realizou a chamada.
@return nil
/*/
Function OA200API(cEndPoint,cJsonFinal,cRotOrig)
    Local aHeader   := {}
    Local aRetValAPI
    //
    Local oJSONRet
    //
    Local nCntB
    Local nCntC
    Local nCntD
    //
    Local cCNPJFiliais
    Local cArqCNPJ  
    Local cArqMesAno
    Local cArqTStamp
    Local cDireArq
    Local cHeaderRet    := ""
    Local cResult       := ""
    Local cStatusCode
    //
    Local lGrvRetJSON
    Local lComOK
    //
    Local oHttpResponse := FWHttpHeaderResponse():New()

    AAdd(aHeader, 'Content-Type: application/json')
    cResult := HttpPost(cEndPoint,,cJsonFinal,,aHeader,@cHeaderRet)
    
    If !Empty(cHeaderRet)
        oHttpResponse:Activate(cHeaderRet)
        
        cStatusCode := SubStr(cHeaderRet, At( Chr(13) + Chr(10), cHeaderRet ) -4, 3 )
        cResult := Stuff(cResult,2,0,'"statusCode":' + cStatusCode + ',')        
        cJSONRet := DecodeUTF8( cResult )
    
        oJSONRet := JSONObject():New()
        oJSONRet:FromJSON(cJSONRet)

        cArqCNPJ    := FWArrFilAtu(,MV_PAR01)[18]
        cArqMesAno  := cValToChar( Month(MV_PAR02) ) + cValToChar( Year(MV_PAR02) )
        cArqTStamp  := StrTran(FWTimeStamp(3,Date()),":","-")
        cDireArq    := RTrim(MV_PAR04) + "dfscontabil_retorno_" + cArqCNPJ + "_" + cArqMesAno + "_" + cArqTStamp + ".json"
        
        lComOK := .t.
    Else
        Help( NIL, NIL, STR0018, NIL, STR0019 /* Falha na Comunica��o | A comunica��o com a API da AGCO n�o pode ser realizada realizada com sucesso. */ ; 
        , 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0020 } )	// Verifique sua infraestrutura relacionada a internet e acesso ao endpoint da AGCO.
        lComOK := .f.
    EndIf
    
    If lComOK
        If ValType( oJSONRet:GetJsonObject("protocol") ) == "C" // A requisicao foi enviada e processada com sucesso

            lGrvRetJSON := OA200JSON( RTrim(MV_PAR04), cDireArq , cJSONRet , "OFIA200" )

            cCNPJFiliais := ""
            For nCntC := 1 to Len(oJSONRet:GetJsonObject("dealerBranchCodes"))
                cCNPJFiliais += oJSONRet:GetJsonObject("dealerBranchCodes")[nCntC] + CRLF
            Next

            Aviso(STR0021, STR0022 + Chr(13) + Chr(10) + /* Sucesso | A gera��o e transmiss�o das informa��es foram realizadas com sucesso! */ ; 
                STR0023	+ oJSONRet:GetJsonText("statusCode")            + Chr(13) + Chr(10) + /* Status Code: */ ;
                STR0024 + oJSONRet:GetJsonText("protocol")              + Chr(13) + Chr(10) + /* Protocolo: */ ;
                STR0025 + oJSONRet:GetJsonText("periodMonth")           + Chr(13) + Chr(10) + /* M�s: */ ;
                STR0026 + oJSONRet:GetJsonText("periodYear")            + Chr(13) + Chr(10) + /* Ano: */ ;
                STR0027 + oJSONRet:GetJsonText("dealerHeadOfficeCode")  + Chr(13) + Chr(10) + /* CNPJ Matriz: */ ;
                STR0028 + cCNPJFiliais                                  + Chr(13) + Chr(10) + /* CNPJs Enviados: */ ;
                STR0029 + oJSONRet:GetJsonText("totalValue")            + Chr(13) + Chr(10) , { STR0030 }, 3) // Valor Total: | Fechar

            ConOut(Chr(13) + Chr(10))
            ConOut("------------------------------------------------------------------------------")
            ConOut(cRotOrig)
            ConOut(STR0031)	// Sucesso na transmissao das informacoes via API. Verifique o retorno informado:
            ConOut(Chr(13) + Chr(10))
            ConOut(STR0023	+ oJSONRet:GetJsonText("statusCode")             + Chr(13) + Chr(10) )	// Status Code:
            ConOut(STR0024	+ oJSONRet:GetJsonText("protocol")               + Chr(13) + Chr(10) )	// Protocolo:
            ConOut(STR0025	+ oJSONRet:GetJsonText("periodMonth")            + Chr(13) + Chr(10) )	// M�s:
            ConOut(STR0026	+ oJSONRet:GetJsonText("periodYear")             + Chr(13) + Chr(10) )	// Ano:
            ConOut(STR0027	+ oJSONRet:GetJsonText("dealerHeadOfficeCode")   + Chr(13) + Chr(10) )	// CNPJ Matriz:
            ConOut(STR0028	+ cCNPJFiliais                                   + Chr(13) + Chr(10) )	// CNPJs Enviados:
            ConOut(STR0029	+ oJSONRet:GetJsonText("totalValue")             + Chr(13) + Chr(10) )	// Valor Total:
            ConOut(Chr(13) + Chr(10))
            If lGrvRetJSON
                ConOut(STR0032) // O arquivo JSON contendo o retorno informado foi gravado conforme diret�rio abaixo:
                ConOut(cDireArq)
            EndIf
            ConOut("------------------------------------------------------------------------------")
            ConOut(Chr(13) + Chr(10))

        ElseIf ValType( oJSONRet:GetJsonObject("status") ) == "N" // A requisicao encontrou problemas na validacao da API

            lGrvRetJSON := OA200JSON( RTrim(MV_PAR04), cDireArq , cJSONRet , "OFIA200" )

            Help( NIL, NIL, STR0033, NIL, STR0034 + Chr(13) + Chr(10) + /* Falha na Transmiss�o | A transmiss�o n�o foi realizada com sucesso. Verifique o retorno abaixo: */ ;	
                STR0023 + oJSONRet:GetJsonText("statusCode")	+ Chr(13) + Chr(10) + /* Status Code: */ ;
                STR0035 + oJSONRet:GetJsonText("status")        + Chr(13) + Chr(10) + /* Resposta: */ ;
                STR0036 + oJSONRet:GetJsonText("error")         + Chr(13) + Chr(10) + /* Retorno: */ ;
                STR0037 + oJSONRet:GetJsonText("message")       + Chr(13) + Chr(10) + /* Descri��o: */ ;
                STR0038 + oJSONRet:GetJsonText("path")          + Chr(13) + Chr(10) , 1, 0, NIL, NIL, NIL, NIL, NIL, { "" } )	// Endpoint:

            ConOut(Chr(13) + Chr(10))
            ConOut("---------------------------------------------------------------------------")
            ConOut(cRotOrig)
            ConOut(STR0039)	// Erro na transmissao das informacoes via API. Verifique o retorno informado:
            ConOut(Chr(13) + Chr(10))
            ConOut(STR0023 + oJSONRet:GetJsonText("statusCode")	+ Chr(13) + Chr(10) )	// Status Code:
            ConOut(STR0035 + oJSONRet:GetJsonText("status")     + Chr(13) + Chr(10) )	// Resposta:
            ConOut(STR0036 + oJSONRet:GetJsonText("error")      + Chr(13) + Chr(10) )	// Retorno:
            ConOut(STR0037 + oJSONRet:GetJsonText("message")    + Chr(13) + Chr(10) )	// Descri��o:
            ConOut(STR0038 + oJSONRet:GetJsonText("path")       + Chr(13) + Chr(10) )	// Endpoint:
            ConOut(Chr(13) + Chr(10))
            If lGrvRetJSON
                ConOut(STR0032)	// O arquivo JSON contendo o retorno informado foi gravado conforme diret�rio abaixo:
                ConOut(cDireArq)
            EndIf
            ConOut("---------------------------------------------------------------------------")
            ConOut(Chr(13) + Chr(10))

        Else // A requisicao foi enviada com sucesso, porem encontrou problemas de validacao na AGCO

            lGrvRetJSON := OA200JSON( RTrim(MV_PAR04), cDireArq , cJSONRet , "OFIA200" )

            aRetValAPI  := {}
            cErroValAPI := ""
            For nCntB := 1 to Len(oJSONRet:GetJsonObject("errors"))
                AAdd(aRetValAPI, StrTokArr2( oJSONRet:GetJsonObject("errors")[nCntB]:GetJsonObject("message"), "," ) )
                For nCntD := 1 to Len(aRetValAPI[nCntB])
                    cErroValAPI += aRetValAPI[nCntB][nCntD] + " "
                Next
                cErroValAPI += CRLF
            Next

            Help( NIL, NIL, STR0040, NIL, STR0041 + /* Falha na Valida��o | A transmiss�o foi realizada com sucesso, por�m problemas foram encontrados na valida��o dos dados. */ ;
                STR0042	+ Chr(13) + Chr(10) + /* Verifique o retorno abaixo: */ ;
                STR0023	+ oJSONRet:GetJsonText("statusCode")	+ Chr(13) + Chr(10) + /* Status Code: */ ;
                STR0043	+ oJSONRet:GetJsonText("data")      	+ Chr(13) + Chr(10) + /* Dados: */ ;
                STR0044	+ oJSONRet:GetJsonText("links")     	+ Chr(13) + Chr(10) + /* Links: */ ;
                STR0045	+ cErroValAPI                       	+ Chr(13) + Chr(10) , 1, 0, NIL, NIL, NIL, NIL, NIL, { "" } ) // Erros:

            ConOut(Chr(13) + Chr(10))
            ConOut("---------------------------------------------------------------------------")
            ConOut(cRotOrig)
            ConOut(STR0039)	// Erro na transmissao das informacoes via API. Verifique o retorno informado:
            ConOut(Chr(13) + Chr(10))
            ConOut(STR0023  + oJSONRet:GetJsonText("statusCode")    + Chr(13) + Chr(10) ) // Status Code:
            ConOut(STR0043	+ oJSONRet:GetJsonText("data")          + Chr(13) + Chr(10) ) // Dados:
            ConOut(STR0044	+ oJSONRet:GetJsonText("links")         + Chr(13) + Chr(10) ) // Links:
            ConOut(STR0045	+ cErroValAPI                           + Chr(13) + Chr(10) ) // Erros:
            ConOut(Chr(13) + Chr(10))
            If lGrvRetJSON
                ConOut(STR0032)	// O arquivo JSON contendo o retorno informado foi gravado conforme diret�rio abaixo:
                ConOut(cDireArq)
            EndIf
            ConOut("---------------------------------------------------------------------------")
            ConOut(Chr(13) + Chr(10))
        EndIf
    EndIf

Return

/*/
{Protheus.doc} OA200JSON
Fun��o que realiza a criacao e gravacao do arquivo JSON referente ao DEF AGCO (DFS) Cont�bil e Gerencial.
@type   Function
@author Ot�vio Favarelli
@since  04/01/2020
@param  cDirJSON,   Caractere,  Diretorio onde sera gravado o arquivo JSON.
@param  cArqJSON,   Caractere,  Nome do arquivo com path completo onde ser� gravado.
@param  cConteud,   Caractere,  Conteudo que sera gravado no arquivo.
@param  cRotOrig,   Caractere,  Codigo da rotina que realizou a chamada.
@return lRet,       Booleano,   Resultado da gravacao do arquivo.
/*/
Function OA200JSON(cDirJSON,cArqJSON,cConteud,cRotOrig)
    Local oJsonFile
    Local lRet
    
    oJsonFile := FwFileWriter():New(cArqJSON)
    If oJsonFile:Create()
        oJsonFile:Write(cConteud)
        oJsonFile:Close()
        lRet := .t.
    Else
        Help(NIL, NIL, STR0046, NIL, STR0047, /* Falha na Grava��o | A grava��o do arquivo JSON no diret�rio informado n�o foi realizado com sucesso. O envio das informa��es n�o ser� realizado. */ ;
        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0048,cDirJSON + Chr(13) + Chr(10) + Chr(13) + Chr(10),STR0049 + Chr(13) + Chr(10),oJsonFile:Error():Message}) // Verifique abaixo diret�rio informado: | Erro retornado:
        ConOut(Chr(13) + Chr(10))
        ConOut("---------------------------------------------------------------")
        ConOut(cRotOrig)
        ConOut(STR0050) // Erro na gravacao do arquivo JSON. Verifique o diretorio informado:
        ConOut(cDirJSON)
        ConOut(STR0049) // Erro retornado:
        ConOut(oJsonFile:Error():Message)
        ConOut("---------------------------------------------------------------")
        ConOut(Chr(13) + Chr(10))
        lRet := .f.
    EndIf

Return lRet
