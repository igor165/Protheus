#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#include 'OGA710B.ch'

Static __cTabRem := ""
Static __cNamRem := ""
Static __cTabFil := ""
Static __cNamFil := ""
Static __oBrwFil := Nil
Static __oBrwRem := Nil

/*{Protheus.doc} OG710BRREM
Retorno da remessa formação de lote

@author francisco.nunes
@since 30/04/2018
@version 1.0
@type function
*/
Function OG710BRREM()
	
	If N7Q->N7Q_QTDREM = 0
		MsgAlert(STR0002, STR0001) // Instrução de Embarque não possui quantidade remetida para retorno das remessas. ## Alerta
		Return .T.
	EndIf
	
	CriaBrowse()
		
Return .T.

/*{Protheus.doc} CriaBrowse
Cria browse das notas fiscais de remessas para retorno

@author francisco.nunes
@since 09/05/2018
@version 1.0
@type function
*/
Static Function CriaBrowse()	
	Local aStrcRem   := {{"", "T_OK", "C", 1,, "@!"}}
	Local aIndRem    := {}	
	Local aStrcFil   := {{"", "T_OK", "C", 1,, "@!"}}
	Local aIndFil    := {}
	Local aCoors     := FWGetDialogSize(oMainWnd)
	Local oDlg	     := Nil
	Local oFWL		 := Nil
	Local aSize		 := Nil
	Local oSize1     := Nil
	Local oSize2     := Nil
	Local oSize3     := Nil
	Local oPnl1      := Nil
	Local oPnlWnd1	 := Nil
	Local oPnlWnd2	 := Nil
	Local aFilBrwFil := {}
	Local aFilBrwRem := {}		
	Local nCont		 := 0	
	Local nOpcX	     := 1
	Local aHeader	 := {}
		
	// Estrutura da tabela temporária de notas fiscais de remessa
	AAdd(aStrcRem, {RetTitle("N9I_FILIAL"), "T_FILIAL", TamSX3("N9I_FILIAL")[3], TamSX3("N9I_FILIAL")[1], TamSX3("N9I_FILIAL")[2], PesqPict("N9I","N9I_FILIAL")})
	AAdd(aStrcRem, {RetTitle("N9I_DOC"),    "T_DOC",    TamSX3("N9I_DOC")[3],    TamSX3("N9I_DOC") [1],   TamSX3("N9I_DOC") [2],   PesqPict("N9I","N9I_DOC")})
	AAdd(aStrcRem, {RetTitle("N9I_SERIE"),  "T_SERIE",  TamSX3("N9I_SERIE")[3],  TamSX3("N9I_SERIE")[1],  TamSX3("N9I_SERIE")[2],  PesqPict("N9I","N9I_SERIE")})	
	AAdd(aStrcRem, {RetTitle("N9I_ITEDOC"), "T_ITEDOC", TamSX3("N9I_ITEDOC")[3], TamSX3("N9I_ITEDOC")[1], TamSX3("N9I_ITEDOC")[2], PesqPict("N9I","N9I_ITEDOC")})
	AAdd(aStrcRem, {RetTitle("N9I_DOCEMI"), "T_DOCEMI", TamSX3("N9I_DOCEMI")[3], TamSX3("N9I_DOCEMI")[1], TamSX3("N9I_DOCEMI")[2], PesqPict("N9I","N9I_DOCEMI")})
	AAdd(aStrcRem, {RetTitle("N9I_QTDSLR"), "T_QTDRET", TamSX3("N9I_QTDSLR")[3], TamSX3("N9I_QTDSLR")[1], TamSX3("N9I_QTDSLR")[2], PesqPict("N9I","N9I_QTDSLR")})		
	AAdd(aStrcRem, {RetTitle("N9I_CLIFOR"), "T_CLIFOR", TamSX3("N9I_CLIFOR")[3], TamSX3("N9I_CLIFOR")[1], TamSX3("N9I_CLIFOR")[2], PesqPict("N9I","N9I_CLIFOR")})
	AAdd(aStrcRem, {RetTitle("N9I_LOJA"),   "T_LOJA",   TamSX3("N9I_LOJA")[3],   TamSX3("N9I_LOJA")[1],   TamSX3("N9I_LOJA")[2],   PesqPict("N9I","N9I_LOJA")})	
	AAdd(aStrcRem, {RetTitle("N9I_QTDANT"), "T_QTDANT", TamSX3("N9I_QTDANT")[3], TamSX3("N9I_QTDANT")[1], TamSX3("N9I_QTDANT")[2], PesqPict("N9I","N9I_QTDANT")})
	
	// Definição dos índices da tabela
	aIndRem := {{"ORDER", "T_FILIAL,T_DOCEMI"}, {"CHAVE","T_FILIAL,T_DOC,T_SERIE,T_CLIFOR,T_LOJA,T_ITEDOC"}, {"SELEC", "T_OK"}}	

	// Estrutura da tabela temporária das filiais	
	AAdd(aStrcFil, {RetTitle("N9I_FILIAL"), "T_FILIAL", TamSX3("N9I_FILIAL")[3], TamSX3("N9I_FILIAL")[1], TamSX3("N9I_FILIAL")[2], PesqPict("N9I","N9I_FILIAL")})
	AAdd(aStrcFil, {STR0003, "T_TOTFIS", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Tot. Ret.			
	AAdd(aStrcFil, {STR0004, "T_QTDVINC", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Qtd. Vinc.	
	AAdd(aStrcFil, {STR0005, "T_SLDVINC", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Saldo a vinc.		

	aIndFil := {{"","T_FILIAL"}, {"SELEC", "T_OK"}}

	Processa({|| OG710ACTMP(@__cTabRem, @__cNamRem, aStrcRem, aIndRem)}, STR0006) // Aguarde. Carregando a tela
	Processa({|| OG710ACTMP(@__cTabFil, @__cNamFil, aStrcFil, aIndFil)}, STR0006) // Aguarde. Carregando a tela
	
	// Carrega os registros das tabelas temporárias de Filiais e Remessas	
	Processa({|| InsRegRem()}, STR0007) // Aguarde. Selecionando notas fiscais de remessa disponíveis para retorno

	/************* TELA PRINCIPAL ************************/
	aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0008, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // Retornar NFs de Remessa

	// Desabilita o fechamento da tela através da tela ESC.
	oDlg:lEscClose := .F.

	oPnl1:= tPanel():New(oSize1:aPosObj[1,1], oSize1:aPosObj[1,2],, oDlg,,,,,, oSize1:aPosObj[1,4], oSize1:aPosObj[1,3] - 30)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine('MASTER', 100, .F.)
	oFWL:addCollumn('LEFT', 40, .F., 'MASTER')
	oFWL:addCollumn('RIGHT', 60, .F., 'MASTER')

	//cria as janelas
	oFWL:addWindow('LEFT', 'Wnd1', STR0009, 100/*tamanho*/, .F., .T.,, 'MASTER') //"Filiais"
	oFWL:addWindow('RIGHT','Wnd2', STR0010, 100/*tamanho*/, .F., .T.,, 'MASTER') //"Remessas"
	
	oFWL:setColSplit('LEFT', 0, 'MASTER')

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1 := oFWL:getWinPanel('LEFT', 'Wnd1', 'MASTER')
	oPnlWnd2 := oFWL:getWinPanel('RIGHT','Wnd2', 'MASTER')
	
	/****************** FILIAIS ********************************/
	
	aHeader := {}
	
	For nCont := 2  to Len(aStrcFil)	
		Aadd(aHeader, {aStrcFil[nCont][1], &("{||"+aStrcFil[nCont][2]+"}"), aStrcFil[nCont][3], aStrcFil[nCont][6], 1, aStrcFil[nCont][4], aStrcFil[nCont][5], .F.})												
		Aadd(aFilBrwFil, {aStrcFil[nCont][2], aStrcFil[nCont][1], aStrcFil[nCont][3], aStrcFil[nCont][4], aStrcFil[nCont][5], aStrcFil[nCont][6]})		
	Next nCont

	//- Recupera coordenadas
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject(STR0009,100,100,.T.,.T.) //"Filiais"
	oSize2:SetWindowSize({0, 0, oPnlWnd1:NHEIGHT, oPnlWnd1:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()
	
	__oBrwFil := FWBrowse():New()
	__oBrwFil:SetOwner(oPnlWnd1)
	__oBrwFil:SetDataTable(.T.)
	__oBrwFil:SetAlias(__cTabFil)
	__oBrwFil:SetProfileID("FIL")
	__oBrwFil:Acolumns := {}	
	__oBrwFil:AddMarkColumns({||IIf((__cTabFil)->T_OK == "1", "LBOK", "LBNO")}, {|| MarkBrw(__oBrwFil, "F")}, {|| MarkAllBrw(__oBrwFil, "F")})	
	__oBrwFil:SetColumns(aHeader)	
	__oBrwFil:DisableReport(.T.)
	__oBrwFil:SetFieldFilter(aFilBrwFil)
	__oBrwFil:SetUseFilter() // Ativa filtro
						
	__oBrwFil:Activate()		
	__oBrwFil:Enable()
	__oBrwFil:Refresh(.T.)
	
	/****************** REMESSAS ********************************/
	
	aHeader := {}
	
	For nCont := 2 to Len(aStrcRem)    
	 	If !aStrcRem[nCont][2] $ 'T_QTDANT'
	 		Aadd(aHeader, {aStrcRem[nCont][1], &("{||"+aStrcRem[nCont][2]+"}"), aStrcRem[nCont][3], aStrcRem[nCont][6], 1, aStrcRem[nCont][4], aStrcRem[nCont][5], .F.})
	 		Aadd(aFilBrwRem, {aStrcRem[nCont][2], aStrcRem[nCont][1], aStrcRem[nCont][3], aStrcRem[nCont][4], aStrcRem[nCont][5], aStrcRem[nCont][6]})
	 	EndIf	    
    Next nCont
	
	//- Recupera coordenadas 
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject(STR0010,100,100,.T.,.T.) //"Remessas"
	oSize3:SetWindowSize({0, 0, oPnlWnd2:NHEIGHT, oPnlWnd2:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {0,0,0,0}
	oSize3:Process()
                       
	__oBrwRem := FWBrowse():New()
	__oBrwRem:SetOwner(oPnlWnd2)
	__oBrwRem:SetDataTable(.T.)
    __oBrwRem:SetAlias(__cTabRem)
    __oBrwRem:SetProfileID("REM")    
    __oBrwRem:Acolumns := {}
    __oBrwRem:AddMarkColumns({||IIf((__cTabRem)->T_OK == "1", "LBOK", "LBNO")}, {|| MarkBrw(__oBrwRem, "R")}, {|| MarkAllBrw(__oBrwRem, "R")})
    __oBrwRem:SetColumns(aHeader)         
    __oBrwRem:DisableReport(.T.)                              
    __oBrwRem:SetFieldFilter(aFilBrwRem)
    __oBrwRem:SetUseFilter() // Ativa filtro
            
    __oBrwRem:Activate()
    __oBrwRem:Enable()
	__oBrwRem:Refresh(.T.)
        
	__oBrwFil:SetFocus()  // Focus no browser de Filiais - Principal
	__oBrwFil:GoColumn(1) // Posiciona o Browse 2 na primeira coluna depois da ativação
	
	oDlg:Activate(,,, .T.,,, EnchoiceBar(oDlg, {|| nOpcX := 1, ODlg:End()} /*OK*/, {|| nOpcX := 0, oDlg:End()} /*Cancel*/ ) )
	
	If nOpcX = 1
		If !GeraRom()
			Return .F.
		EndIf		
	EndIf
		
Return .T.

/*{Protheus.doc} MarkBrw
Seleção individual Filiais / Remessas

@author francisco.nunes
@since  09/05/2018
@version 1.0
@param oBrwObj, object, Objeto do browser marcado
@param cBrwName, characters, Nome do browser ("F"=Filiais;"R"=Remessas)
@type function
*/
Static Function MarkBrw(oBrwObj, cBrwName)
	Local lMarcar := .F.
	
	If Empty((oBrwObj:Alias())->(T_OK))
		lMarcar := .T.				
	EndIf
	
	/* Atualiza a grid de Remessas */
	AtualizRem(oBrwObj:Alias(), cBrwName, lMarcar)
	
	/* Atualiza a grid de Filiais */
	AtualizFil()
		
	If cBrwName == "F" // Filiais
		__oBrwRem:Refresh(.T.)
	EndIf
	
	If cBrwName == "R" // Remessas
		__oBrwFil:Refresh(.T.)
	EndIf
		
	oBrwObj:SetFocus() 
	oBrwObj:GoColumn(1)

Return .T.

/*{Protheus.doc} MarkAllBrw
Seleção de todos os itens do browse [Filiais / Remessas]

@author francisco.nunes
@since  09/05/2018
@version 1.0
@param oBrwObj, object, Objeto do browser marcado
@param cBrwName, characters, Nome do browser ("F"=Filiais;"R"=Remessas)
@type function
*/
Static function MarkAllBrw(oBrwObj, cBrwName)
	Local lMarcar := .F.
	
	(oBrwObj:Alias())->(DbGoTop())
	(oBrwObj:Alias())->(DbSetOrder(1))
	If (oBrwObj:Alias())->(DbSeek((oBrwObj:Alias())->T_FILIAL))
		lMarcar := IIf((oBrwObj:Alias())->T_OK == "1", .F., .T.)
		
		While !(oBrwObj:Alias())->(Eof())		
			/* Atualiza a grid de Remessas */
			AtualizRem(oBrwObj:Alias(), cBrwName, lMarcar)
		
			(oBrwObj:Alias())->(DbSkip())
		EndDo
	EndIf
	
	/* Atualiza a grid de Filiais */
	AtualizFil()
		
	__oBrwFil:Refresh(.T.)
	__oBrwRem:Refresh(.T.)
		
	oBrwObj:SetFocus()

Return .T.

/*{Protheus.doc} AtualizRem
Atualiza a grid de Remessas

@author francisco.nunes
@since  09/05/2018
@version 1.0
@param cAliasBrw, character, Alias do objeto do browser marcado
@param cBrwName, characters, Nome do browser ("F"=Filiais;"R"=Remessas)
@param lMarcar, logical, .T. - Marcar; .F. - Desmarcar
@type function
*/
Static Function AtualizRem(cAliasBrw, cBrwName, lMarcar)
	Local aAreaRem := (__cTabRem)->(GetArea())
			
	If cBrwName == "R" // Browser Remessas
		
		If RecLock(cAliasBrw, .F.)
			(cAliasBrw)->T_OK := IIf(lMarcar, "1", "")							
			(cAliasBrw)->(MsUnlock())
		EndIf		
	EndIf
	
	If cBrwName == "F" // Browser Filiais		
						
		DbSelectArea(__cTabRem)
		(__cTabRem)->(DbSetOrder(1))
		If (__cTabRem)->(DbSeek((cAliasBrw)->T_FILIAL))
			While (__cTabRem)->(!Eof()) .AND. (__cTabRem)->T_FILIAL == (cAliasBrw)->T_FILIAL
													
				If RecLock(__cTabRem, .F.)
					(__cTabRem)->T_OK     := IIf(lMarcar, "1", "")										
					(__cTabRem)->(MsUnlock())
				EndIf
				
				(__cTabRem)->(DbSkip())
			EndDo
		EndIf					
	EndIf
	
	RestArea(aAreaRem)

Return .T.

/*{Protheus.doc} AtualizFil
Atualiza a grid de Filiais

@author francisco.nunes
@since  09/05/2018
@version 1.0
@type function
*/
Static Function AtualizFil()	
	Local aAreaFil := (__cTabFil)->(GetArea())
	Local cQuery   := ""	
	Local cFilRem  := ""
	Local nQtdVinc := 0
	
	// Busca a quantidade das remessas marcadas para retorno por filial
	cQuery := " SELECT T_FILIAL, " 
	cQuery += "        SUM(T_QTDRET) AS QTREMSEL "
	cQuery += " FROM "+ __cNamRem + " REM "
	cQuery += " WHERE REM.T_OK = '1' "
	cQuery += " GROUP BY T_FILIAL "	

	MPSysOpenQuery(cQuery, 'QRYQREM')
		
	DbSelectArea('QRYQREM')
	
	If ('QRYQREM')->(!Eof())	
		While ('QRYQREM')->(!Eof())
		
			cFilRem  := ('QRYQREM')->(FieldGet(1))
			nQtdVinc := ('QRYQREM')->(FieldGet(2))
			
			DbSelectArea(__cTabFil)
			(__cTabFil)->(DbSetorder(1))
			If (__cTabFil)->(DbSeek(cFilRem))
					
				If RecLock(__cTabFil, .F.)
					(__cTabFil)->T_QTDVINC := nQtdVinc
					(__cTabFil)->T_SLDVINC := (__cTabFil)->T_TOTFIS - nQtdVinc 											
					(__cTabFil)->T_OK 	   := IIf((__cTabFil)->T_QTDVINC > 0, "1","")				
					(__cTabFil)->(MsUnlock())
				EndIf
			EndIf
		
			('QRYQREM')->(DbSkip())
		EndDo	
	Else
		DbSelectArea(__cTabFil)
		(__cTabFil)->(DbGoTop())
		While (__cTabFil)->(!Eof())
		
			If RecLock(__cTabFil, .F.)
				(__cTabFil)->T_QTDVINC := 0
				(__cTabFil)->T_SLDVINC := (__cTabFil)->T_TOTFIS										
				(__cTabFil)->T_OK 	   := ""
				(__cTabFil)->(MsUnlock())
			EndIf
			
			(__cTabFil)->(DbSkip())
		EndDo
	EndIf				
	('QRYQREM')->(DbCloseArea())
		
	RestArea(aAreaFil)
	
Return .T.

/*{Protheus.doc} InsRegRem
Seleção das notas fiscais de remessa para retorno

@author francisco.nunes
@since  09/05/2018
@version 1.0
@type function
*/
Static Function InsRegRem()
	Local cQuery     := ""
	Local cAliasN9I  := GetNextAlias()
	Local cQryInsert := ""
	Local nQtdRet 	 := 0
						
	// Limpa a tabela temporária
	DbSelectArea(__cTabRem)
	(__cTabRem)->(DbSetorder(1))
	ZAP
	
	// Limpa a tabela temporária
	dbSelectArea(__cTabFil)
	(__cTabFil)->(DbSetorder(1))
	ZAP
	    
    // Monta a query de busca
    cQuery := "SELECT N9I.N9I_FILIAL AS FILIAL, "
	cQuery += " 	  N9I.N9I_DOC    AS DOC, "
	cQuery += " 	  N9I.N9I_SERIE  AS SERIE, "
	cQuery += " 	  N9I.N9I_CLIFOR AS CLIFOR, "
	cQuery += " 	  N9I.N9I_LOJA   AS LOJA, "
	cQuery += " 	  N9I.N9I_ITEDOC AS ITEDOC, "	
	cQuery += " 	  N9I.N9I_DOCEMI AS DOCEMI, "
	cQuery += "       SUM(CASE WHEN N9I.N9I_INDSLD = '1' THEN N9I.N9I_QTDSLR ELSE 0 END) AS QTDRETIE, "
	cQuery += "       SUM(CASE WHEN N9I.N9I_INDSLD = '2' THEN N9I.N9I_QTDSLR ELSE 0 END) AS QTDRETCT, "
	cQuery += "       SUM(CASE WHEN N9I.N9I_INDSLD = '1' THEN N9I.N9I_QTDANT ELSE 0 END) AS QTDANT "
	cQuery += " FROM " + RetSqlName("N9I") + " N9I "				
	cQuery += " WHERE N9I.D_E_L_E_T_ = ' ' "
	cQuery += "   AND N9I.N9I_FILORG = '"+N7Q->(N7Q_FILIAL)+"' "
	cQuery += "   AND N9I.N9I_CODINE = '"+N7Q->(N7Q_CODINE)+"' "
	
	If N7Q->N7Q_TPMERC == "1" // Mercado Interno
		cQuery += "   AND N9I.N9I_INDSLD = '1' "// Vinculado a IE
	Else
		cQuery += "   AND N9I.N9I_INDSLD IN ('1','2') "// Vinculado a container
	EndIf
	
	cQuery += "   AND N9I.N9I_QTDSLR > 0 "
	cQuery += "   AND N9I.N9I_DEPALF = '1' " // Apenas considera as remessas DAC			
	cQuery += "	GROUP BY N9I.N9I_FILIAL, N9I.N9I_DOC, N9I.N9I_SERIE, N9I.N9I_CLIFOR, N9I.N9I_LOJA, N9I.N9I_ITEDOC, N9I.N9I_DOCEMI "
    cQuery += " ORDER BY N9I.N9I_DOCEMI "
    					         		        
	cQuery := ChangeQuery(cQuery)
	cAliasN9I := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasN9I,.F.,.T.)
		
	If (cAliasN9I)->(!EoF())
		While (cAliasN9I)->(!EoF())
		
			If N7Q->N7Q_TPMERC == "1"		
				nQtdRet := (cAliasN9I)->QTDRETIE
			Else
				nQtdRet := (cAliasN9I)->QTDRETCT + IIf((cAliasN9I)->QTDANT > 0, (cAliasN9I)->QTDRETIE, 0)
			EndIf
			
			If nQtdRet = 0
				(cAliasN9I)->(DbSkip())
				LOOP
			EndIf
																					
			cQryInsert := "('"+(cAliasN9I)->FILIAL+"', '"+(cAliasN9I)->DOC+"', '"+(cAliasN9I)->SERIE+"', '"+(cAliasN9I)->CLIFOR+"', '"+(cAliasN9I)->LOJA+"', '"+(cAliasN9I)->ITEDOC+"', '"+(cAliasN9I)->DOCEMI+"', '"+AllTrim(STR(nQtdRet))+"', '"+AllTrim(STR((cAliasN9I)->QTDANT))+"', ' ') "
			TCSqlExec("INSERT INTO "+__cNamRem+" (T_FILIAL, T_DOC, T_SERIE, T_CLIFOR, T_LOJA, T_ITEDOC, T_DOCEMI, T_QTDRET, T_QTDANT, T_OK) VALUES " + cQryInsert)
			
			// ****** INSERE NA TABELA TEMPORÁRIA DE FILIAIS ******					
			If !(__cTabFil)->(DbSeek((cAliasN9I)->FILIAL))
							
				RecLock(__cTabFil, .T.)					
				(__cTabFil)->T_FILIAL := (cAliasN9I)->FILIAL												
			Else
				RecLock(__cTabFil, .F.)
			EndIf
			
			(__cTabFil)->T_TOTFIS  += nQtdRet 
			(__cTabFil)->T_QTDVINC := 0
			(__cTabFil)->T_SLDVINC := (__cTabFil)->T_TOTFIS
			(__cTabFil)->T_OK	   := ""			
			(__cTabFil)->(MsUnlock())
							
			(cAliasN9I)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasN9I)->(dbCloseArea())	
		
	// Refresh nos browsers
	TCRefresh(__cNamRem)
	TCRefresh(__cNamFil)
				
Return .T.

/*{Protheus.doc} GeraRom
Gera o romaneio de retorno da Formação de Lote

@author francisco.nunes
@since  09/05/2018
@type function
*/
Static Function GeraRom()
	Local aAreaFil  := (__cTabFil)->(GetArea())
	Local cQuery    := ""	
	Local lRet		:= .T.
	
	Private _cFilRem := ""
	Private _nQtdSel := 0
	
	BEGIN TRANSACTION

		// Busca a quantidade das remessas marcadas para retorno por filial
		cQuery := " SELECT T_FILIAL, " 
		cQuery += "        SUM(T_QTDVINC) AS QTREMSEL "
		cQuery += " FROM "+ __cNamFil + " FIL "
		cQuery += " WHERE FIL.T_QTDVINC > 0 "
		cQuery += " GROUP BY T_FILIAL "	
	
		MPSysOpenQuery(cQuery, 'QRYQFIL')
		
		DbSelectArea('QRYQFIL')	
		While ('QRYQFIL')->(!Eof())
						
			_cFilRem := ('QRYQFIL')->(FieldGet(1))
			_nQtdSel := ('QRYQFIL')->(FieldGet(2))
								
			MsgRun("Gerando romaneio para filial "+_cFilRem+"...", "Aguarde", {|| lRet := InsRoman()}) //"Gerando romaneio para filial " # "Aguarde"
			
			If !lRet
				DisarmTransaction()
			EndIf
		
			('QRYQFIL')->(DbSkip())
		EndDo	
		('QRYQFIL')->(DbCloseArea())
	
	END TRANSACTION
		
	RestArea(aAreaFil)		
		
Return lRet

/*{Protheus.doc} CarrRomArr
CarRega o array de dados para geração do romaneio

@author francisco.nunes
@since  09/05/2018
@param  aFldNJJ, array campos NJJ
@param  aFldNJM, array campos NJM
@param  aFldN9E, array campos N9E
@type function
*/
Static Function CarrRomArr(aFldNJJ, aFldNJM, aFldN9E)

	Local cUnidade := Posicione("SB1",1,Fwxfilial('SB1')+N7Q->N7Q_CODPRO,"B1_UM")
	Local aAux	   := {}
	Local cDoc     := ""
	Local cSerie   := ""
	Local cCliFor  := ""
	Local cLoja    := ""
	Local cItDoc   := ""
	Local nQtdRet  := 0
	Local cIndSld  := ""
	Local nQtdAnt  := 0
	
	/*Dados Tipo Romaneio*/
	aAdd(aFldNJJ, {'NJJ_FILIAL', _cFilRem})
	aAdd(aFldNJJ, {'NJJ_TIPO'  , "7" }) // (E) DEVOLUCAO REMESSA
	aAdd(aFldNJJ, {'NJJ_TPFORM', "1" }) 
	aAdd(aFldNJJ, {'NJJ_TIPENT', "2" }) 
	/*Dados do Contrato*/
	aAdd(aFldNJJ, {'NJJ_FILORG', ""})
	aAdd(aFldNJJ, {'NJJ_CODCTR', ""})
	aAdd(aFldNJJ, {'NJJ_CODSAF', N7Q->N7Q_CODSAF})
	aAdd(aFldNJJ, {'NJJ_TES'   , ''	         })
	aAdd(aFldNJJ, {'NJJ_CODPRO', N7Q->N7Q_CODPRO})
	aAdd(aFldNJJ, {'NJJ_UM1PRO', cUnidade})
	aAdd(aFldNJJ, {'NJJ_LOCAL' , N7Q->N7Q_LOCAL })
	/*Dados da Entidade*/
	aAdd(aFldNJJ, {'NJJ_CODENT', N7Q->N7Q_ENTENT})
	aAdd(aFldNJJ, {'NJJ_LOJENT', N7Q->N7Q_LOJENT})
	aAdd(aFldNJJ, {'NJJ_ENTENT', N7Q->N7Q_ENTENT})
	aAdd(aFldNJJ, {'NJJ_ENTLOJ', N7Q->N7Q_LOJENT})
	/*Dados Quantidade*/
	aAdd(aFldNJJ, {'NJJ_PSSUBT', _nQtdSel})
	aAdd(aFldNJJ, {'NJJ_PSBASE', _nQtdSel})
	aAdd(aFldNJJ, {'NJJ_PSLIQU', _nQtdSel})
	aAdd(aFldNJJ, {'NJJ_PESO3' , _nQtdSel})
	aAdd(aFldNJJ, {'NJJ_QTDFIS', _nQtdSel})
	/*Dados Pesagem*/
	aAdd(aFldNJJ, {'NJJ_DATA'  , dDataBase})
	aAdd(aFldNJJ, {'NJJ_DATPS1', dDataBase})
	aAdd(aFldNJJ, {'NJJ_HORPS1', Substr(Time(),1,5)})
	aAdd(aFldNJJ, {'NJJ_PESO1' , _nQtdSel})
	aAdd(aFldNJJ, {'NJJ_DATPS2', dDataBase})
	aAdd(aFldNJJ, {'NJJ_HORPS2', Substr(Time(),1,5)})
	/*Dados Fixos*/
	aAdd(aFldNJJ, {'NJJ_TRSERV', "0"})
	aAdd(aFldNJJ, {'NJJ_STSPES', "1"})
	aAdd(aFldNJJ, {'NJJ_STATUS', "1"})
	aAdd(aFldNJJ, {'NJJ_STSCLA', "1"})
	aAdd(aFldNJJ, {'NJJ_STAFIS', "1"})
	aAdd(aFldNJJ, {'NJJ_STACTR', "1"})
	aAdd(aFldNJJ, {'NJJ_TPFRET', "C"})
	
	/* Comercialização */
	aAdd(aAux, {'NJM_ITEROM', StrZero(1,2)})
	aAdd(aAux, {'NJM_CODENT', N7Q->N7Q_ENTENT})
	aAdd(aAux, {'NJM_LOJENT', N7Q->N7Q_LOJENT})
	aAdd(aAux, {'NJM_CODSAF', N7Q->N7Q_CODSAF})	
	aAdd(aAux, {'NJM_CODPRO', N7Q->N7Q_CODPRO})
	aAdd(aAux, {'NJM_UM1PRO', cUnidade})		
	aAdd(aAux, {'NJM_VLRUNI', 0})	
	aAdd(aAux, {'NJM_PERDIV', 100})	
	aAdd(aAux, {'NJM_STAFIS', "1"})
	aAdd(aAux, {'NJM_TPFORM', "1"})
	aAdd(aAux, {'NJM_NFPSER', ""})
	aAdd(aAux, {'NJM_NFPNUM', ""})
	aAdd(aAux, {'NJM_QTDFIS', _nQtdSel})
	aAdd(aAux, {'NJM_QTDFCO', _nQtdSel})
	aAdd(aAux, {'NJM_TRSERV', "0"})  // Não		
	aAdd(aAux, {'NJM_LOCAL ', N7Q->N7Q_LOCAL})
	aAdd(aAux, {'NJM_LOTCTL', ''})
	aAdd(aAux, {'NJM_NMLOT' , ''})
	aAdd(aAux, {'NJM_VLRTOT' , 0})
	aAdd(aAux, {'NJM_TES', 	  ''})
	
	aAdd(aFldNJM, aAux)
	
	/*Integrações do Romaneio*/	
	aAux := {}
	
	// Busca as remessas marcadas para retorno da filial
	cQuery := " SELECT T_DOC, "
	cQuery += "        T_SERIE, "	
	cQuery += "        T_CLIFOR, "
	cQuery += "        T_LOJA, "
	cQuery += "        T_ITEDOC, "
	cQuery += "        T_QTDRET, "
	cQuery += "        T_QTDANT "
	cQuery += " FROM "+ __cNamRem + " REM "
	cQuery += " WHERE REM.T_FILIAL = '"+_cFilRem+"'"
	cQuery += "   AND REM.T_OK     = '1' "

	MPSysOpenQuery(cQuery, 'QRYQRET')
	
	DbSelectArea('QRYQRET')	
	While ('QRYQRET')->(!Eof())
	
		cDoc    := ('QRYQRET')->(FieldGet(1))
		cSerie  := ('QRYQRET')->(FieldGet(2))
		cCliFor := ('QRYQRET')->(FieldGet(3))
		cLoja   := ('QRYQRET')->(FieldGet(4))
		cItDoc  := ('QRYQRET')->(FieldGet(5))
		nQtdRet := ('QRYQRET')->(FieldGet(6))
		nQtdAnt := ('QRYQRET')->(FieldGet(7))
		
		If N7Q->N7Q_TPMERC == "2" .AND. nQtdAnt = 0
			cIndSld := "2"
		Else
			cIndSld := "1"
		EndIf
				
		DbSelectArea("N9I")
		N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
		If N9I->(DbSeek(_cFilRem+cDoc+cSerie+cCliFor+cLoja+cItDoc+cIndSld+N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE))
		
			aAux := {}
			 	
		 	aAdd(aAux, {'N9E_ORIGEM', '7'}) // Nota Fiscal
			aAdd(aAux, {'N9E_FILIE',  N7Q->N7Q_FILIAL})
			aAdd(aAux, {'N9E_CODINE', N7Q->N7Q_CODINE})
			aAdd(aAux, {'N9E_CODCTR', N9I->N9I_CTRREM})
			aAdd(aAux, {'N9E_ITEM',   N9I->N9I_ETGREM})
			aAdd(aAux, {'N9E_SEQPRI', N9I->N9I_REFREM})
			aAdd(aAux, {'N9E_DOC', 	  cDoc})
			aAdd(aAux, {'N9E_SERIE',  cSerie})
			aAdd(aAux, {'N9E_CLIFOR', cCliFor})
			aAdd(aAux, {'N9E_LOJA',   cLoja})
			aAdd(aAux, {'N9E_ITEDOC', cItDoc})
			aAdd(aAux, {'N9E_QTDRET', nQtdRet})
			
			aAdd(aFldN9E, aAux)	 												
		EndIf
					
		('QRYQRET')->(DbSkip())
	EndDo	
	('QRYQRET')->(DbCloseArea())
		
Return .T.

/*{Protheus.doc} InsRoman
Insere o romaneio pelo model do OGA250

@author francisco.nunes
@since 09/05/2018
@type function
*/
Static Function InsRoman()
	Local oModelNJJ	:= Nil
	Local oAux 		:= Nil
	Local oStruct	:= Nil
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux 		:= {}
	Local nItErro 	:= 0
	Local lAux 		:= .T.
	Local nOperacao := 3
	Local aFldNJJ   := {}
	Local aFldNJM   := {}
	Local aFldN9E   := {}
	
	cFilCor := cFilAnt
	cFilAnt := _cFilRem
	
	// Carrega o array das tabelas NJJ, NJM e N9E
	CarrRomArr(@aFldNJJ, @aFldNJM, @aFldN9E)
		
	// Recuperar o model do programa
	oModelNJJ := FWLoadModel("OGA250")
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModelNJJ:SetOperation(nOperacao)
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModelNJJ:Activate()
	
	/* Dados Principais do Romaneio */
	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux := oModelNJJ:GetModel("NJJUNICO")   
	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux    := oStruct:GetFields()
	
	For nI := 1 To Len(aFldNJJ)
		// Verifica se os campos passados existem na estrutura do cabeçalho
		If (nPos := aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aFldNJJ[nI][1])})) > 0
			// É feita a atribuição do dado aos campo do Model do cabeçalho
			If !(lAux := oModelNJJ:SetValue( 'NJJUNICO', aFldNJJ[nI][1],aFldNJJ[nI][2]))
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
	
	/*Comercialização*/
	If lRet
		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModelNJJ:GetModel("NJMUNICO")
		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux 	:= oStruct:GetFields()
		nItErro := 0
		
		For nI := 1 To Len(aFldNJM)
			// Incluímos uma linha nova
			// ATENÇÃO: Os itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
			If nI > 1
				// Incluímos uma nova linha de item
				If (nItErro := oAux:AddLine()) <> nI
					// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
					lRet := .F.
					Exit
				EndIf
			EndIf
			
			For nJ := 1 To Len(aFldNJM[nI])
				// Verifica se os campos passados existem na estrutura de item
				If (nPos := aScan(aAux, { |x| AllTrim( x[3]) == AllTrim(aFldNJM[nI][nJ][1])})) > 0
					If !(lAux := oModelNJJ:SetValue("NJMUNICO", aFldNJM[nI][nJ][1], aFldNJM[nI][nJ][2]))
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						nItErro := nI
						
						Exit
					EndIf
				EndIf
			Next nJ
			
			If !lRet
				Exit
			EndIf
		Next nI
	EndIf
	
	/*Origem Do Romaneio*/
	If lRet
		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModelNJJ:GetModel("N9EUNICO")
		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()
		nItErro := 0
		
		For nI := 1 To Len(aFldN9E)
			// Incluímos uma linha nova
			// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
			If nI > 1
				// Incluímos uma nova linha de item
				If (nItErro := oAux:AddLine()) <> nI
					// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
					lRet := .F.
					Exit
				EndIf
			EndIf
			
			For nJ := 1 To Len(aFldN9E[nI])
				// Verifica se os campos passados existem na estrutura de item
				If (nPos := aScan(aAux, {|x| AllTrim( x[3]) == AllTrim(aFldN9E[nI][nJ][1])})) > 0
					If !(lAux := oModelNJJ:SetValue("N9EUNICO", aFldN9E[nI][nJ][1], aFldN9E[nI][nJ][2]))
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						nItErro := nI
						Exit
					EndIf
				EndIf
			Next nJ
			
			If !lRet
				Exit
			EndIf
		Next nI
	EndIf
	
	/* Validação e Commit */
	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If (lRet := oModelNJJ:VldData()) 
			// Se o dados foram validados faz-se a gravação efetiva dos
			// dados (commit)
			//guarda o código do contrato a ser gravado 
			lRet := oModelNJJ:CommitData()
		EndIf
	EndIf
	
	If lRet		
		OGA250ATUC(Alias(), Recno(), 4, .T.)
	
		// Desativamos o Model
		oModelNJJ:DeActivate()
	ElseIf oModelNJJ <> Nil
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro := oModelNJJ:GetErrorMessage()

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
		
		If nItErro > 0
			AutoGrLog( "Erro no Item: " + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )
		EndIf
		
		MostraErro()
		
		lRet := .F.
		Help(,,'AJUDA',,'Não foi possivel gerar o romaneio.', 1,0) //"AJUDA" ##"Não foi possivel gerar o romaneio."

		// Desativamos o Model
		oModelNJJ:DeActivate()
	EndIf
	
	cFilAnt := cFilCor
	
	If !lRet
		DisarmTransaction()
	EndIf
	
Return lRet
