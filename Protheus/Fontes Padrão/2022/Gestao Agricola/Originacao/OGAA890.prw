#INCLUDE "OGAA890.CH"
#INCLUDE "PROTHEUS.CH"

Static __cTabTmp  := ""
Static __cNamTmp  := ""
Static __aIteCont := {}
Static __oBrwAPep := NIL

/*/{Protheus.doc} OGAA890()
Função de acompanhamento do Aviso PEPRO
@type  Function
@author rafael.kleestadt / vanilda.moggio
@since 27/08/2018
@version 1.0
@param param, param_type, param_descr
@return lRet, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGAA890()
	
    CriaBrowse()
		
Return .T.

/*/{Protheus.doc} CriaBrowse()
Função de criação da estrutura das tabs temporarias e da tela
@type Static Function
@author rafael.kleestadt / vanilda.moggio
@since 27/08/2018
@version 1.0
@param param, param_type, param_descr
@return lRet, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaBrowse()
	Local aStrcTmp   := {{"", "T_OK", "C", 1,, "@!"}}
    Local aIndTmp    := {}
	Local oDlg	     := Nil
	Local oSize      := Nil
	Local aFilBrwTmp := {}
	Local nCont		 := 1	
	Local nOpcX	     := 1
	Local aHeader	 := {}
	Local aSeek    	 := {}

    //-------------------------------Estrutura da Tabela-----------------------------------//
	AAdd(aStrcTmp, {RetTitle("N9W_STATUS"), "T_STATUS", TamSX3("N9W_STATUS")[3], TamSX3("N9W_STATUS")[1], TamSX3("N9W_STATUS")[2], PesqPict("N9W","N9W_STATUS")})
	AAdd(aStrcTmp, {RetTitle("N9U_FILIAL"), "T_FILIAL", TamSX3("N9U_FILIAL")[3], TamSX3("N9U_FILIAL")[1], TamSX3("N9U_FILIAL")[2], PesqPict("N9U","N9U_FILIAL")})
	AAdd(aStrcTmp, {RetTitle("N9U_FILORI"), "T_FILORI", TamSX3("N9U_FILORI")[3], TamSX3("N9U_FILORI")[1], TamSX3("N9U_FILORI")[2], PesqPict("N9U","N9U_FILORI")})
	AAdd(aStrcTmp, {RetTitle("N9U_NUMAVI"), "T_NUMAVI", TamSX3("N9U_NUMAVI")[3], TamSX3("N9U_NUMAVI")[1], TamSX3("N9U_NUMAVI")[2], PesqPict("N9U","N9U_NUMAVI")})
	AAdd(aStrcTmp, {RetTitle("N9U_NUMDCO"), "T_NUMDCO", TamSX3("N9U_NUMDCO")[3], TamSX3("N9U_NUMDCO")[1], TamSX3("N9U_NUMDCO")[2], PesqPict("N9U","N9U_NUMDCO")})
	AAdd(aStrcTmp, {RetTitle("N9W_SEQEST"), "T_VERSAO", TamSX3("N9W_SEQEST")[3], TamSX3("N9W_SEQEST")[1], TamSX3("N9W_SEQEST")[2], PesqPict("N9W","N9W_SEQEST")})
	AAdd(aStrcTmp, {RetTitle("N9W_QUANT") , "T_QUANT",  TamSX3("N9W_QUANT") [3], TamSX3("N9W_QUANT")[1],  TamSX3("N9W_QUANT")[2],  PesqPict("N9W","N9W_QUANT")})
	AAdd(aStrcTmp, {RetTitle("N9U_UMDQTD"), "T_UMDQTD", TamSX3("N9U_UMDQTD")[3], TamSX3("N9U_UMDQTD")[1], TamSX3("N9U_UMDQTD")[2], PesqPict("N9W","N9U_UMDQTD")})
	AAdd(aStrcTmp, {STR0012               , "T_QTDIE",  TamSX3("N7Q_TOTLIQ")[3], TamSX3("N7Q_TOTLIQ")[1], TamSX3("N7Q_TOTLIQ")[2], PesqPict("N7Q","N7Q_TOTLIQ")})
	AAdd(aStrcTmp, {STR0013               , "T_SIEVIM", TamSX3("N7Q_TOTLIQ")[3], TamSX3("N7Q_TOTLIQ")[1], TamSX3("N7Q_TOTLIQ")[2], PesqPict("N7Q","N7Q_TOTLIQ")})
	AAdd(aStrcTmp, {STR0014               , "T_QTDVIN", TamSX3("N9W_QTDVIN")[3], TamSX3("N9W_QTDVIN")[1], TamSX3("N9W_QTDVIN")[2], PesqPict("N9W","N9W_QTDVIN")})
	AAdd(aStrcTmp, {STR0015               , "T_SNFCOM", TamSX3("N9U_QTDVIN")[3], TamSX3("N9U_QTDVIN")[1], TamSX3("N9U_QTDVIN")[2], PesqPict("N9U","N9U_QTDVIN")})
	AAdd(aStrcTmp, {STR0017               , "T_VALOR",  TamSX3("N9X_VALOR") [3], TamSX3("N9X_VALOR")[1],  TamSX3("N9X_VALOR")[2],  PesqPict("N9X","N9X_VALOR")})
	AAdd(aStrcTmp, {STR0016               , "T_DTPREV", TamSX3("N9X_DTPREV")[3], TamSX3("N9X_DTPREV")[1], TamSX3("N9X_DTPREV")[2], PesqPict("N9X","N9X_DTPREV")})
	AAdd(aStrcTmp, {RetTitle("NJ0_CODCLI"), "T_CODCLI", TamSX3("NJ0_CODCLI")[3], TamSX3("NJ0_CODCLI")[1], TamSX3("NJ0_CODCLI")[2], PesqPict("NJ0","NJ0_CODCLI")})
	AAdd(aStrcTmp, {RetTitle("NJ0_LOJCLI"), "T_LOJCLI", TamSX3("NJ0_LOJCLI")[3], TamSX3("NJ0_LOJCLI")[1], TamSX3("NJ0_LOJCLI")[2], PesqPict("NJ0","NJ0_LOJCLI")})
	AAdd(aStrcTmp, {RetTitle("NJ0_NOMCLI"), "T_NOMCLI", TamSX3("NJ0_NOMCLI")[3], TamSX3("NJ0_NOMCLI")[1], TamSX3("NJ0_NOMCLI")[2], PesqPict("NJ0","NJ0_NOMCLI")})
	AAdd(aStrcTmp, {RetTitle("N9X_DTPREV"), "T_DTPGTO", TamSX3("N9X_DTPREV")[3], TamSX3("N9X_DTPREV")[1], TamSX3("N9X_DTPREV")[2], PesqPict("N9X","N9X_DTPREV")})
	AAdd(aStrcTmp, {RetTitle("N9U_STAFIN"), "T_STAFIN", TamSX3("N9U_STAFIN")[3], TamSX3("N9U_STAFIN")[1], TamSX3("N9U_STAFIN")[2], PesqPict("N9U","N9U_STAFIN")})
	
	SetKey(VK_F5,{|| F5Tela()})
	
	//Campos dinâmicos com base nos itens de controle cadastrados.
	DbSelectArea("NBZ")
	DbSetOrder(1)
	While NBZ->(!EOF())

		cNmIte := "T_ITE" + AllTrim(Str(nCont))
		cItem  := Posicione("NBY",1,xFilial("NBY")+NBZ->NBZ_CODITE,'NBY_DESITE') 

 		If aScan(aStrcTmp,{|x| x[1]==cItem}) == 0 

			cNmDtIt := "T_DTITE" + AllTrim(Str(nCont))

			AAdd(aStrcTmp, {cItem, cNmIte, TamSX3("NCL_STATUS")[3], TamSX3("NCL_STATUS")[1], TamSX3("NCL_STATUS")[2], PesqPict("NCL","NCL_STATUS")})
			AAdd(aStrcTmp, {RetTitle("NBZ_DTLIMT"), cNmDtIt, TamSX3("NBZ_DTLIMT")[3], TamSX3("NBZ_DTLIMT")[1], TamSX3("NBZ_DTLIMT")[2], PesqPict("NBZ","NBZ_DTLIMT")})
			
			AAdd(__aIteCont, {NBZ->NBZ_CODITE, cItem})

			// Definição dos índices da tabela
			AAdd(aIndTmp, {"CHAVE"+AllTrim(Str(nCont)), "T_FILIAL,T_NUMAVI,T_NUMDCO,T_VERSAO,"+cNmIte+""})

			nCont ++

		EndIf

		NBZ->( DbSkip() )
	EndDo
	NBZ->(DbcloseArea())

	//Se não tivem nenhum item de controle vinculado ao aviso cria um índice simples.
	If Empty(aIndTmp)
		AAdd(aIndTmp, {"CHAVE", "T_FILIAL,T_NUMAVI,T_NUMDCO,T_VERSAO"})
	EndIf

	//Limpa a Variavel
	aHeader := {}
	
	For nCont := 2  to Len(aStrcTmp)

		//Cria o array com as colunas que devem ser exibidas no Browse
		If !aStrcTmp[nCont][2] $ "T_FILIAL | T_STATUS | T_CODCLI | T_LOJCLI | T_STAFIN"
			Aadd(aHeader, {aStrcTmp[nCont][1], &("{||"+aStrcTmp[nCont][2]+"}"), aStrcTmp[nCont][3], aStrcTmp[nCont][6], 22, aStrcTmp[nCont][4], aStrcTmp[nCont][5], .F.})												
		EndIf

		//Cria o array com as colunas que devem ser exibidas na opção Filtrar
		Aadd(aFilBrwTmp, {aStrcTmp[nCont][2], aStrcTmp[nCont][1], aStrcTmp[nCont][3], aStrcTmp[nCont][4], aStrcTmp[nCont][5], aStrcTmp[nCont][6]})

	Next nCont
	
	//Cria a tabela temporária
    Processa({|| OG710ACTMP(@__cTabTmp, @__cNamTmp, aStrcTmp, aIndTmp)}, STR0002) //"Aguarde. Criando a Tabela..."

	// Carrega os registros das tabelas temporárias.
	Processa({|| InsRegDoc()}, STR0003) //Aguarde. "Selecionando as Dados Disponíveis..."

	/************* TELA PRINCIPAL ************************/
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Painel de Acomapanhamento Pepro"

 	//Criação e instância do browse
	__oBrwAPep := FWFormBrowse():New(oDlg)
	__oBrwAPep:SetOwner(oDlg)
	__oBrwAPep:SetDataTable(.T.)
    __oBrwAPep:SetAlias(__cTabTmp)
    __oBrwAPep:SetProfileID("DOC")    
    __oBrwAPep:Acolumns := {}        
    //__oBrwAPep:DisableReport(.T.)
	__oBrwAPep:AddStatusColumns( { || OGAA890CLR((__cTabTmp)->T_STATUS) }, { || OGAA890LEG() } )
	__oBrwAPep:AddLegend( "T_STAFIN=='1'", "BR_AZUL"	, X3CboxDesc( "N9U_STAFIN", "1" ),, .T.) //"Pendente"
	__oBrwAPep:AddLegend( "T_STAFIN=='2'", "BR_AMARELO"	, X3CboxDesc( "N9U_STAFIN", "2" ),, .T.) //"Aberto"
	__oBrwAPep:AddLegend( "T_STAFIN=='3'", "BR_VERDE"	, X3CboxDesc( "N9U_STAFIN", "3" ),, .T.) //"Finalizado"
	__oBrwAPep:SetColumns(aHeader) 
	__oBrwAPep:SetDescription(STR0001)

	// Filtro
    __oBrwAPep:SetUseFilter(.T.)
	__oBrwAPep:SetUseCaseFilter(.T.)                         
    __oBrwAPep:SetFieldFilter(aFilBrwTmp)   
    __oBrwAPep:SetDBFFilter(.T.)

	//Aadd(aSeek,{ "Aviso", {{"", 'C' , 10 , 0 , "@!" }}, 1, .T. }) //STR0003 - 'Campo'

	__oBrwAPep:SetSeek( , aSeek )
	
	__oBrwAPep:AddButton(STR0004, {|| OGA800((__cTabTmp)->T_NUMAVI, (__cTabTmp)->T_NUMAVI ) },,,,.F.,1)//"Aviso"
	__oBrwAPep:AddButton(STR0005, {|| OGA810((__cTabTmp)->T_NUMAVI, (__cTabTmp)->T_NUMDCO ) },,,,.F.,1)//"DCO"
	__oBrwAPep:AddButton(STR0006, {|| OGAA890CTR() },,,,.F.,1)//"Contrato"
	__oBrwAPep:AddButton(STR0007, {|| OGAA890FIE() },,,,.F.,1)//"Instrução de Embarque"
	__oBrwAPep:AddButton(STR0008, {|| OGAA890HIS() },,,,.F.,1)//"Histórico"
	__oBrwAPep:AddButton(STR0019, {|| OGAA890FIN() },,,,.F.,1)//"Finalizar"
	__oBrwAPep:AddButton(STR0018, {|| OGAA890CAN() },,,,.F.,1)//"Cancelar"
	__oBrwAPep:AddButton(STR0027, {|| OGAA890LGF() },,,,.F.,1)//"Leg. Sta. Fina."
	__oBrwAPep:AddButton(STR0009, {|| oDlg:End() },,,,.F.,1)//"Sair"

	__oBrwAPep:acolumns[1]:cTitle := RetTitle("N9W_STATUS")
	__oBrwAPep:acolumns[2]:cTitle := RetTitle("N9U_STAFIN")

	__oBrwAPep:SetDoubleClick({|| OGAA890NCL((__cTabTmp)->T_FILIAL, (__cTabTmp)->T_NUMAVI, (__cTabTmp)->T_NUMDCO, (__cTabTmp)->T_VERSAO, __oBrwAPep:GetColumn():cTitle), __oBrwAPep:Refresh() })			
	__oBrwAPep:Activate()
	//__oBrwAPep:SetEditCell(.T.) 						//indica que o grid e editavel
	//__oBrwAPep:acolumns[nColEdit]:ledit := .t.
	//__oBrwAPep:acolumns[nColEdit]:bValid := {|| IIF(ValidRes(_cNJKTEMP,(_cNJKTEMP)->NJK_ITEM, (_cNJKTEMP)->NJK_CODDES, (_cNJKTEMP)->NJK_PERDES) ,__oBrwAPep:Refresh(),.F.)}

	oDlg:Activate( , , , .t., { || .t. }, , { || .T. })

    If nOpcX = 1
        //GrvN9V()
    EndIf

Return .T.

/*/{Protheus.doc} InsRegDoc()
Função de carga inicial nas tabelas temporarias
@type  Static Function
@author rafael.kleestadt / vanilda.moggio
@since 27/08/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logical, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function InsRegDoc()
	Local nX        := 0
	Local cAliasQry := GetNextAlias()
	Local cStatus   := ""

	// Limpa a tabela temporária
	DbSelectArea(__cTabTmp)
	(__cTabTmp)->(DbSetorder(1))
	ZAP

	cQryN9W := " SELECT N9W_FILIAL, N9U_FILORI, N9W_NUMAVI, N9W_NUMDCO, N9W_SEQEST, "
	cQryN9W += "     N9W_EST, N9W_STATUS, N9W_QUANT,  N9W_VLPREV, N9W_QTDVIN, "
	cQryN9W += "     N9W_VLPREV, SUM(N9X_VALOR) AS VALREC, MAX(N9X_DTPREV) AS DATREC, "
	cQryN9W += "     SUM(N9X_QTDNFS) AS QTDNFS, 
	cQryN9W += "     N9U_CODREG, N9U_UMDQTD, N9U_STAFIN "	
	cQryN9W += " FROM " + RetSqlName("N9W") + " N9W "
	cQryN9W += " INNER JOIN " + RetSqlName("N9U") + " N9U ON N9U.D_E_L_E_T_ = '' "
	cQryN9W += "     AND N9U.N9U_FILIAL = N9W.N9W_FILIAL "
	cQryN9W += "     AND N9U.N9U_NUMAVI = N9W.N9W_NUMAVI "
	cQryN9W += "     AND N9U.N9U_NUMDCO = N9W.N9W_NUMDCO "
	cQryN9W += " INNER JOIN " + RetSqlName("N9X") + " N9X ON N9X.D_E_L_E_T_ = '' " 
	cQryN9W += "     AND N9X.N9X_FILIAL = N9W.N9W_FILIAL " 
	cQryN9W += "     AND N9X.N9X_NUMAVI = N9W.N9W_NUMAVI "
	cQryN9W += "     AND N9X.N9X_NUMDCO = N9W.N9W_NUMDCO "
	cQryN9W += " WHERE N9W.D_E_L_E_T_ = '' " 
	cQryN9W += " GROUP BY N9W_FILIAL, N9U_FILORI, N9W_NUMAVI, N9W_NUMDCO, N9W_SEQEST, "
	cQryN9W += "     N9W_EST, N9W_STATUS, N9W_QUANT,  N9W_VLPREV, N9W_QTDVIN, N9W_VLPREV, N9U_CODREG, N9U_UMDQTD, N9U_STAFIN "

	cQryN9W := ChangeQuery(cQryN9W)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryN9W),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->( !Eof() )
		While (cAliasQry)->( !Eof() )

			cCodEnt := Posicione("N9A", 3, FwxFilial("N9A") + (cAliasQry)->N9W_NUMAVI + (cAliasQry)->N9W_NUMDCO + (cAliasQry)->N9W_SEQEST, "N9A_CODENT")
			cLojEnt := Posicione("N9A", 3, FwxFilial("N9A") + (cAliasQry)->N9W_NUMAVI + (cAliasQry)->N9W_NUMDCO + (cAliasQry)->N9W_SEQEST, "N9A_LOJENT")
			cCodCli := Posicione("NJ0", 1, FwxFilial("NJ0") + cCodEnt + cLojEnt, "NJ0_CODCLI")
			cLojCli := Posicione("NJ0", 1, FwxFilial("NJ0") + cCodEnt + cLojEnt, "NJ0_LOJCLI")
			cNomCli := Posicione("SA1", 1, FwxFilial("SA1") + cCodCli + cLojCli, "A1_NOME")
			cStatus := STR0010//"N.A."

			RecLock(__cTabTmp, .T.)
				(__cTabTmp)->T_STATUS  := (cAliasQry)->N9W_STATUS
				(__cTabTmp)->T_FILIAL  := (cAliasQry)->N9W_FILIAL
				(__cTabTmp)->T_FILORI  := (cAliasQry)->N9U_FILORI
				(__cTabTmp)->T_NUMAVI  := (cAliasQry)->N9W_NUMAVI
				(__cTabTmp)->T_NUMDCO  := (cAliasQry)->N9W_NUMDCO
				(__cTabTmp)->T_VERSAO  := (cAliasQry)->N9W_SEQEST
				(__cTabTmp)->T_QUANT   := (cAliasQry)->N9W_QUANT
				(__cTabTmp)->T_QTDVIN  := (cAliasQry)->QTDNFS
				(__cTabTmp)->T_QTDIE   := (cAliasQry)->N9W_qtdvin 
				(__cTabTmp)->T_SNFCOM  := (cAliasQry)->N9W_QUANT - (__cTabTmp)->T_QTDVIN
				(__cTabTmp)->T_SIEVIM  := (cAliasQry)->N9W_QUANT - (__cTabTmp)->T_QTDIE 
				(__cTabTmp)->T_VALOR   := (cAliasQry)->VALREC
				(__cTabTmp)->T_DTPREV  := STOD((cAliasQry)->DATREC)
				(__cTabTmp)->T_CODCLI  := cCodCli
				(__cTabTmp)->T_LOJCLI  := cLojCli
				(__cTabTmp)->T_NOMCLI  := cNomCli
				(__cTabTmp)->T_UMDQTD  := (cAliasQry)->N9U_UMDQTD
				(__cTabTmp)->T_STAFIN  := (cAliasQry)->N9U_STAFIN

				For nX := 1 To Len(__aIteCont)

					cStatus := STR0010//"N.A."

					//Verifica se o item de controle pertence ao Aviso selecionado
					DbSelectArea("NBZ")
					DbSetOrder(1)
					If NBZ->(DBSeek(FwxFilial("NBZ")+(cAliasQry)->N9W_NUMAVI+__aIteCont[nX,1]))
						cStatus := Posicione("NCL",1,FwxFilial("NCL")+(cAliasQry)->N9W_NUMAVI+(cAliasQry)->N9W_NUMDCO+(cAliasQry)->N9W_SEQEST+__aIteCont[nX,1], "NCL_STATUS")
						(__cTabTmp)->&("T_DTITE" + AllTrim(Str(nX))) := Posicione("NBZ",1,FwxFilial("NBZ")+(cAliasQry)->N9W_NUMAVI+__aIteCont[nX,1],"NBZ_DTLIMT")
					EndIf
					NBZ->(DbCloseArea())
					
					(__cTabTmp)->&("T_ITE" + AllTrim(Str(nX))) := cStatus
				Next nX

			(__cTabTmp)->(MsUnlock())

			(cAliasQry)->( DbSkip() )
		EndDo
	EndIf
	(cAliasQry)->(DbcloseArea())

Return .T.

/*/{Protheus.doc} OGAA890CLR
Retorna a cor da legenda do browse
@type Function
@author rafael.kleestadt / vanilda.moggio
@since 27/08/2018
@version 1.0
@param cStatus, Caractere, conteúdo do campo T_STATUS
@return cColor, Caractere, Cor da legenda a ser apresentada no browse
@example
(examples)
@see (links_or_references)
/*/
Function OGAA890CLR(cStatus)
	Local cColor := "BR_CINZA"
	Local aArea  := GetArea()

	Do Case
		Case cStatus = "1" //"Pendente"
			cColor := "BR_AMARELO"
		Case cStatus = "2" //"Em processo"
			cColor := "BR_LARANJA"
		Case cStatus = "3" //"Encerrado"
			cColor := "BR_VERMELHO"
		Case cStatus = "4" //"Nao Utilizado"
			cColor := "BR_CANCEL"
	EndCase

	RestArea(aArea)

Return cColor

/*/{Protheus.doc} OGAA890LEG
Retorna a legenda e suas descrições
@type Static Function
@author rafael.kleestadt / vanilda.moggio
@since 27/08/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_desc
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAA890LEG()
    Local oLegenda := FWLegend():New()
    
    oLegenda:Add( '', 'BR_AMARELO',  X3CboxDesc( "N9W_STATUS", "1" ) ) //"Pendente"
    oLegenda:Add( '', 'BR_LARANJA',  X3CboxDesc( "N9W_STATUS", "2" ) ) //"Em Processo"
    oLegenda:Add( '', 'BR_VERMELHO', X3CboxDesc( "N9W_STATUS", "3" ) ) //"Encerrado"
    oLegenda:Add( '', 'BR_CANCEL',   X3CboxDesc( "N9W_STATUS", "4" ) ) //"Cancelado"
    
    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()

Return Nil


/*/{Protheus.doc} OGAA890NCL()
Exibe o dialog de alteração do status do item e atualiza a tabela temporaria e a tabela de Status Item de Controle do DCO
@type  Static Function
@author rafael.kleestadt
@since 30/08/2018
@version 1.0
@param cFilTmp, caractere, Filial do registro posicionado na tabela temporaria
@param cNumAvi, caractere, Numero do Aviso Pepro posicionado na tabela temporaria
@param cNumDco, caractere, Numero do DCO Pepro posicionado na tabela temporaria
@param cVersao, caractere, Sequencial do DCO Pepro posicionado na tabela temporaria
@param cItem, caractere, Código do itemd e controle do Pepro posicionado na tabela temporaria
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAA890NCL(cFilTmp, cNumAvi, cNumDco, cVersao, cItem )
	Local lOK       := .F.
	Local cMsgMemo  := TamSX3("NK9_MSGMEM")
	Local aAreaTmp  := (__cTabTmp)->(GetArea())
	Local dDataPrev := (__cTabTmp)->(T_DTPREV)
	Private cText   := TamSX3("NCL_STATUS")
	Private cDesc 	:= TamSX3("NLK_DESTAT")
	Private oDlg	:= NIL

	If cItem == STR0016 //"Dt Prev Rec"
		
		//Chamar nova tela de alteração da N9X, salvar N9X, ajustar SE1, N8L e tempTable do painel.
		dDataPrev := OGAA920(cFilTmp, cNumAvi, cNumDco, cVersao, (__cTabTmp)->(T_DTPREV))

		DbSelectArea(__cTabTmp)
		(__cTabTmp)->(DbSetOrder(1))
		If (__cTabTmp)->(DbSeek(cFilTmp+cNumAvi+cNumDco))
			While (__cTabTmp)->(!EOF()) .And. (__cTabTmp)->(T_FILIAL+T_NUMAVI+T_NUMDCO) == cFilTmp+cNumAvi+cNumDco

				RecLock(__cTabTmp, .F.)
						
					(__cTabTmp)->(T_DTPREV) := dDataPrev
					
					//Atualiza o Status da previsão financeira
					(__cTabTmp)->(T_STAFIN) := Posicione("N9U", 1, cFilTmp+cNumAvi+cNumDco+cVersao, "N9U_STAFIN") 

				(__cTabTmp)->(MsUnlock())

				(__cTabTmp)->( DbSkip() )
			EndDo
		EndIf

		RestArea(aAreaTmp)
		Return .T.

	EndIf

	nPos := aScan(__aIteCont,{|x| x[2]==cItem})

	If Empty(nPos)
		Return .T.
	EndIf

	cItem :=  __aIteCont[nPos, 1]

	cItem := PADR( cItem, TamSx3("NBZ_CODITE")[1])

	//Verifica se o item de controle pertence ao Aviso selecionado
	DbSelectArea("NBZ")
	DbSetOrder(1)
	If !NBZ->(DBSeek(FwxFilial("NBZ")+cNumAvi+cItem))
		Return .T.
	EndIf
	NBZ->(DbCloseArea())

	If __oBrwAPep:GetColumn():nOrder > Len(__oBrwAPep:aColumns) - (Len(__aIteCont) * 2) .And. __oBrwAPep:GetColumn():cType <> TamSX3("NBZ_DTLIMT")[3]

		cText    := Posicione("NCL",1,FwxFilial("NCL")+cNumAvi+cNumDco+cVersao+cItem, "NCL_STATUS")
		cMsgMemo := Posicione("NCL",1,FwxFilial("NCL")+cNumAvi+cNumDco+cVersao+cItem, "NCL_OBSERV")
		cDesc	 := Posicione("NLK",1,FwxFilial("NLK")+cText, "NLK_DESTAT")

		/*Exibe Dialog para alteração do status do item*/
		oDlg := TDialog():New(350,405,685,795,STR0011+AllTrim(cItem),,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Atualizar Status do Item "
		oDlg:lEscClose := .f.

 		@ 035,008 SAY " " PIXEL
		@ 035,008 SAY RetTitle("NCL_STATUS") PIXEL
		TGet():New(045, 008, {|u| If(PCount()>0,cText:=u,cText) }, oDlg, 096, 009, PesqPict("NCL", "NCL_STATUS"),{|| fVldStatus()},,,,.F.,,.T.,,,{|| .T., .T.},,,{|| .T.},,,"NLK","cText")

		@ 060,008 SAY " " PIXEL
		@ 060,008 SAY RetTitle("NLK_DESTAT") PIXEL
		@ 070,008 MSGET cDesc OF oDlg Size 100,010 PIXEL
		
		@ 085,008 SAY " " PIXEL
		@ 085,008 SAY RetTitle("NCL_OBSERV") PIXEL
		@ 095,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 175,055 PIXEL

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lOK := .T., oDlg:End() },{|| lOK := .F., oDlg:End() }) CENTERED

		/*Botão OK - Atualiza as informações*/
		If lOK

			//Grava tabela Status Item de Controle d DCO
			DbSelectArea("NCL")
			DbSetOrder(1) //NCL_FILIAL+NCL_NUMAVI+NCL_NUMDCO+NCL_SEQDCO+NCL_CODITE
			If NCL->(DBSeek(FwxFilial("NCL")+cNumAvi+cNumDco+cVersao+cItem))
				RecLock("NCL", .F.)
				cTipo := '4'
			Else
				RecLock("NCL", .T.)
				NCL->NCL_NUMAVI := cNumAvi
				NCL->NCL_NUMDCO := cNumDco
				NCL->NCL_SEQDCO := cVersao
				NCL->NCL_CODITE := cItem
				cTipo := '3'
			EndIf

			NCL->NCL_STATUS := cText
			NCL->NCL_OBSERV := cMsgMemo

			NCL->(MsUnlock())
			NCL->(DbcloseArea())

			//Busca Indice da tabela temporária
			nInd := aScan(__aIteCont,{|x| x[1]==cItem})

			//Define a chave que deve ser usada para busca na tabela temporária
			cChave := cFilTmp+cNumAvi+cNumDco+cVersao+(__cTabTmp)->&("T_ITE" + AllTrim(Str(nInd)))

			//Grava na tabela temporária
			dbSelectArea(__cTabTmp)
			DbSetOrder(nInd)
			If (__cTabTmp)->(DBSeek(cChave))

				RecLock(__cTabTmp, .F.)
						
					(__cTabTmp)->&("T_ITE" + AllTrim(Str(nInd))) := cText 					

				(__cTabTmp)->(MsUnlock())

			EndIf

			//Grava histórico 
			AGRGRAVAHIS(,,,,{"N9W",cFilTmp+cNumAvi+cNumDco+cVersao,cTipo,cItem+" : "+cText+Chr(10)+cMsgMemo}) 

		EndIf

	EndIf
	__oBrwAPep:Refresh()
Return .T.

/*/{Protheus.doc} OGAA890HIS()
Função para exibir o histórico de alterações do status do item do DCO
@type Function
@author rafael.kleestadt
@since 30/08/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGAA890HIS()
	Local cChaveI := "N9W->("+Alltrim(AGRSEEKDIC("SIX","N9W1",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("N9W",cChaveA)
Return


/*/{Protheus.doc} OGAA890CTR()
Função para exibir os contratos que possuem o Aviso/DCO/Sequencial vinculado as regras fiscais
@type Function
@author rafael.kleestadt
@since 03/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGAA890CTR()
	Local cFiltro := ""
		
	cQry := " SELECT DISTINCT N9A_CODCTR "		
	cQry += "  FROM " + RetSqlName("N9A") + " N9A "
	cQry += " INNER JOIN " + RetSqlName("NLN") + " NLN ON NLN.NLN_FILIAL = N9A.N9A_FILIAL AND NLN.NLN_CODCTR = N9A.N9A_CODCTR "
	cQry += "   AND NLN.NLN_CODINE = '' AND NLN.D_E_L_E_T_ = '' "
	cQry += " WHERE N9A.D_E_L_E_T_ = '' "	
	cQry += "   AND NLN.NLN_NUMAVI = '"+(__cTabTmp)->T_NUMAVI+"' "
	cQry += "   AND NLN.NLN_NUMDCO = '"+(__cTabTmp)->T_NUMDCO+"' " 
	cQry += "   AND NLN.NLN_SEQDCO = '"+(__cTabTmp)->T_VERSAO+"' "

	cQry := ChangeQuery(cQry)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAliasQry,.F.,.T.)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->( !Eof() )

		If !Empty(cFiltro)
			cFiltro += " .OR. "
		Else
			cFiltro += " NJR_TIPO = '2' .AND. ( "
		EndIf

		cFiltro += "NJR_CODCTR = '"+(cAliasQry)->N9A_CODCTR+"'"

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If !Empty(cFiltro)
		cFiltro += " ) "
	EndIf

	OGA290(,,cFiltro)

Return .T.

/*/{Protheus.doc} OGAA890FIE()
Função para exibir as IE`s que possuem o Aviso/DCO/Sequencial vinculado as regras fiscais
@type Function
@author rafael.kleestadt
@since 03/09/2018
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Function OGAA890FIE()
	Local cFiltro := ""
		
	cQry := " SELECT DISTINCT N7S_CODINE "
	cQry += "   FROM " + RetSqlName("N7S") + " N7S "	
	cQry += " INNER JOIN " + RetSqlName("NLN") + " NLN ON NLN.NLN_FILIAL = N7S.N7S_FILIAL AND NLN.NLN_CODINE = N7S.N7S_CODINE "
	cQry += "   AND NLN.D_E_L_E_T_ = '' "	
	cQry += "  WHERE N7S.D_E_L_E_T_ = '' "
	cQry += "    AND NLN.NLN_NUMAVI = '"+(__cTabTmp)->T_NUMAVI+"' "
	cQry += "    AND NLN.NLN_NUMDCO = '"+(__cTabTmp)->T_NUMDCO+"' " 
	cQry += "    AND NLN.NLN_SEQDCO = '"+(__cTabTmp)->T_VERSAO+"' "

	cQry := ChangeQuery(cQry)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAliasQry,.F.,.T.)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->( !Eof() )

		If !Empty(cFiltro)
			cFiltro += " .OR. "
		EndIf

		cFiltro += "N7Q_CODINE = '"+(cAliasQry)->N7S_CODINE+"'"

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	OGA710(cFiltro)

Return .T.

/*/{Protheus.doc} OGAA890FIN()
Função para exibir finalizar o DCO
@type Function
@author Christopher.miranda
@since 06/09/2018
@version 1.0
/*/
Function OGAA890FIN()

	If (__cTabTmp)->T_STATUS == '1' .or.(__cTabTmp)->T_STATUS == '2'
		If AGRGRAVAHIS(STR0025,"N9W",N9W->N9W_FILIAL+N9W->N9W_NUMAVI+N9W->N9W_NUMDCO+N9W->N9W_SEQEST,"F",) = 1//"Deseja realmente Cancelar a Amostra?"

			If RecLock( __cTabTmp, .f. )
				(__cTabTmp)->T_STATUS := "3" //"Finalizada"
				(__cTabTmp)->( MsUnLock() )
			EndIf

			DbSelectArea("N9W")
			DbSetOrder(1) //N9W_FILIAL+N9W_NUMAVI+N9W_NUMDCO+N9W_SEQEST
			If N9W->(DBSeek((__cTabTmp)->T_FILIAL+(__cTabTmp)->T_NUMAVI+(__cTabTmp)->T_NUMDCO+(__cTabTmp)->T_VERSAO))

				If RecLock( "N9W", .f. )
					N9W->N9W_STATUS := "3"
					N9W->( MsUnLock() )
				EndIf

			EndIf
			N9W->(DbCloseArea())

			__oBrwAPep:Refresh()
			
		EndIf 
	Else
		Help( , , STR0020, , STR0021, 1, 0 )
	EndIf

return()
		
/*/{Protheus.doc} OGAA890CAN()
Função para exibir cancelar o DCO
@type Function
@author Christopher.miranda
@since 06/09/2018
@version 1.0
/*/
Function OGAA890CAN()

	If (__cTabTmp)->T_STATUS == '1' .or.(__cTabTmp)->T_STATUS == '2'
		If AGRGRAVAHIS(STR0024,"N9W",N9W->N9W_FILIAL+N9W->N9W_NUMAVI+N9W->N9W_NUMDCO+N9W->N9W_SEQEST,"C",) = 1//"Deseja realmente Cancelar a Amostra?"

			If RecLock( __cTabTmp, .f. )
				(__cTabTmp)->T_STATUS := "4" //"Cancelada"
				(__cTabTmp)->( MsUnLock() )
			EndIf
			DbSelectArea("N9W")
			DbSetOrder(1) //N9W_FILIAL+N9W_NUMAVI+N9W_NUMDCO+N9W_SEQEST
			If N9W->(DBSeek((__cTabTmp)->T_FILIAL+(__cTabTmp)->T_NUMAVI+(__cTabTmp)->T_NUMDCO+(__cTabTmp)->T_VERSAO))

				If RecLock( "N9W", .f. )
					N9W->N9W_STATUS := "4"
					N9W->( MsUnLock() )
				EndIf

			EndIf
			N9W->(DbCloseArea())

			__oBrwAPep:Refresh()
			
		EndIf 
	Else
		Help( , , STR0020, , STR0021, 1, 0 )
	EndIf

return()	

/*/{Protheus.doc} F5Tela
@author vanilda.moggio
@since 24/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function F5Tela()
	InsRegDoc()
	__oBrwAPep:Refresh( .T. )

Return .T.


/*/{Protheus.doc} OGAA890LGF()
Exibe a legenda do status da previsão financeira
@type  Static Function
@author rafael.kleestadt
@since 03/11/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGAA890LGF()
	Local aLegenda := {}

	aAdd(aLegenda,{ "BR_AZUL"    , X3CboxDesc("N9U_STAFIN",'1') }) // "Pendente"
	aAdd(aLegenda,{ "BR_AMARELO" , X3CboxDesc("N9U_STAFIN",'2') }) // "Aberto"
	aAdd(aLegenda,{ "BR_VERDE"   , X3CboxDesc("N9U_STAFIN",'3') }) // "Finalizado"

	BrwLegenda( RetTitle("N9U_STAFIN"), "Legenda", aLegenda )

Return( Nil )

/*{Protheus.doc} 
Validação do Status
@sample   	fVldStatus()
@return   	lRetorno
@author   	Christopher.miranda
@since    	19/11/2018
@version  	P12
*/
Function fVldStatus()

	Local lRetorno  := .t.
	Local aOldArea  := GetArea() 

	If !Empty(cText)
		If ExistCpo('NLK',cText)
			cDesc := Posicione("NLK",1,xFilial("NLK")+cText,'NLK_DESTAT')
		Else
			cDesc := TamSX3("NLK_DESTAT")
			lRetorno := .f.
		EndIf
	Else
		lRetorno := .f.
	EndIf

	oDlg:Refresh()

	RestArea(aOldArea)

Return lRetorno
