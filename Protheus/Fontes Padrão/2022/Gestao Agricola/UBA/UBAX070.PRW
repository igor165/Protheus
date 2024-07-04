#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} A070Regra
//Confere se fardinho atende regras HVI do padrão posicionado
@author silvana.torres
@since 22/05/2017
@version 12.1.20
@param aRegras,   array, regras a serem avaliadas
@param cAliasHvi, chacteres, Alias da tabela a ser avaliadas
@type function
/*/
Function A070Regra(aRegras, cAliasHVI)
	Local lEntraReg := .T.
	Local nx
	Local cAuxBase  := "(cAliasHVI)->"
	Local cAuxRegra := ""

	If Len( aRegras ) > 0
		for nX:=1 to len( aRegras ) 
			cAuxRegra := cAuxBase + AllTrim(aRegras[nx,2])
			
			If &cAuxRegra < aRegras[nx,3] .Or. &cAuxRegra > aRegras[nx,4]
			 	lEntraReg := .F.
			 	Exit
			Endif
		NEXT nX
	ENDIF

Return lEntraReg

/*/{Protheus.doc} A070AvalMala
//Função responsável por efetuar a busca dos dados 
@author bruna.rocio
@since 15/08/2017
@version undefined
@param cFilAval, characters, descricao
@param cSafraAval, characters, descricao
@param __DXJTEMP, object, objeto da tabela DXJ
@param __DXKTEMP, object, objeto da tabela DXK
@type function
/*/
Function A070AvalMala(cFilAval, cSafraAval, __DXJTEMP, __DXKTEMP, __nMaxCols)
	Local aArea       := GetArea()
	Local lRet        := .T.
	Local cAliasN80   := GetNextAlias()
	Local cQuery      := ""
	Local cAliasItReg := GetNextAlias()
	Local aRegras
	Local lAtendeReg  := .T.
	Local cBaseRegra  := "(__DXJTEMP)->DXJ_PCRG"
	Local cRegra      := cBaseRegra   
	Local nQtdRegra   := 0  
	Local nIndiceTab  := 0

	//FWModeAccess("NJU",1)='C'	

	BuscaMalas(cFilAval, cSafraAval, __DXJTEMP, __DXKTEMP)
	
	/************************************************************************/
	/**          Processo de pré criação de blocos para simulação          **/
	/************************************************************************/
	cQuery := " Select * From " + RetSQLName('N80') + " N80 "
	cQuery += " WHERE N80.D_E_L_E_T_ = ' ' "

	If  FWModeAccess("N80",1)='C'
		cQuery += " AND N80.N80_FILIAL = '" + fwxFilial('N80') +"' "
	Else	
		cQuery += " AND N80.N80_FILIAL = '" + cFilAval + "' "
	Endif

	cQuery += " AND N80.N80_TIPEMB = '2' "
	cQuery += " ORDER BY N80.N80_RELEVA "

	cQuery    := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasN80, .F., .T. )

	/************************************************************************/
	/**         Processo de enfileiramento de Fardos nos blocos        **/
	/************************************************************************/

	(cAliasN80)->(dbGoTop())
	While (cAliasN80)->(!Eof())
				
		nIndiceTab++	
		
		// Se o indice for maior que o número máximo de colunas, significa que houve incremento de regra 
		// para alguma filial além do estimado na abertura do programa, trata pra não dar erro, mas, 
		// não considera para não precisar destruir e reconstruir a tabela temporária
		If nIndiceTab > __nMaxCols
			Return 
		Endif
			
		aRegras   := {}
		nQtdRegra := 0
		cRegra    := cBaseRegra + cValToChar(nIndiceTab)  
		
		//Busca os exames HVI que fazem parte da regra de emblocamento para tratamento posterior
		cQuery := "Select N81_CAMPO, N81_VLDE, N81_VLATE, N81_TIPEMB "
		cQuery += " From " + RetSQLName('N81') + " N81"
		cQuery += " Where N81.N81_CODEMB = '" + (cAliasN80)->N80_CODIGO +"' "

		If  FWModeAccess("N81",1)='C'
			cQuery += " AND N81.N81_FILIAL = '" + fwxFilial('N81') +"' "
		Else	
			cQuery += " AND N81.N81_FILIAL = '" + cFilAval +"' "
		Endif

		cQuery += " AND N81.N81_TIPEMB = '2' "
		cQuery += " AND N81.N81_TIPREG = '1' " 
		cQuery += " AND N81.D_E_L_E_T_ = ' '"

		cQuery    := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasItReg, .F., .T. )

		(cAliasItReg)->(dbGoTop())
		While (cAliasItReg)->(!Eof())	
			aAdd(aRegras, {(cAliasN80)->N80_CODIGO, (cAliasItReg)->N81_CAMPO, (cAliasItReg)->N81_VLDE, (cAliasItReg)->N81_VLATE})

			(cAliasItReg)->(dbSkip())
		EndDo

		(cAliasItReg)->(DbCloseArea())
		//Busca os exames HVI que fazem parte da regra de emblocamento para tratamento posterior
		
		//Verifica todas as malas para a regra posicionada
		(__DXJTEMP)->(dbGoTop())
		While (__DXJTEMP)->(!Eof())
			
			If (__DXJTEMP)->DXJ_FILIAL = cFilAval .And. (__DXJTEMP)->DXJ_SAFRA = cSafraAval
				nQtdRegra := 0 //Zera para recalcular o indice por regra corretamente
				dbSelectArea(__DXKTEMP)
				dbSetOrder(2)
				If (__DXKTEMP)->(MSSeek((__DXJTEMP)->DXJ_FILIAL+(__DXJTEMP)->DXJ_SAFRA+(__DXJTEMP)->DXJ_CODIGO))
				
					While (__DXKTEMP)->(!Eof()) .And. ;
						(__DXKTEMP)->(DXK_FILIAL+DXK_SAFRA+DXK_CODROM) = (__DXJTEMP)->(DXJ_FILIAL+DXJ_SAFRA+DXJ_CODIGO)
					
						lAtendeReg := A070Regra(aRegras, __DXKTEMP) 
						If lAtendeReg 
							nQtdRegra := nQtdRegra + 1
						Endif
						(__DXKTEMP)->(dbSkip())
					EndDo
				Endif
				
				If RecLock(__DXJTEMP, .F.)
					//De acordo com a regra, salva o resultado num campo específico
					(&cRegra) := ROUND(nQtdRegra/(__DXJTEMP)->DXJ_QTVINC * 100,0)
					MsUnlock(__DXJTEMP)
				Endif
			Endif
			dbSelectArea(__DXJTEMP)
			(__DXJTEMP)->(dbSkip())
		EndDo
			
		dbSelectArea(cAliasN80)	
		(cAliasN80)->(dbSkip())
	EndDo	
	(cAliasN80)->(dbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} BuscaMalas
//Realiza a busca das malas disponiveis para emblocamento
@author bruna.rocio
@since 18/08/2017
@version undefined
@param cFilAval, characters, descricao
@param cSafraAval, characters, descricao
@param __DXJTEMP, object, objeto da tabela DXJ
@param __DXKTEMP, object, objeto da tabela DXK
@type function
/*/
Static Function BuscaMalas(cFilAval, cSafraAval, __DXJTEMP, __DXKTEMP)
	Local cAliasPre   := GetNextAlias()
	Local cQuery      := ""

	cQuery := " SELECT DISTINCT DXI_ETIQ, DXI_CLACOM, DXI_CODIGO, DXI_SAFRA, DXJ.DXJ_CODIGO, "

	//Quantidade de Fardos TOTAL por mala
	cQuery += " (Select count(DXJ2.DXJ_QTVINC) from " + RetSqlName('DXJ') + " DXJ2 "
	cQuery += " 	INNER JOIN " + RetSQLName('DXK') + " DXK2 "

	If  FWModeAccess("DXK",1) = 'C' 
		cQuery += "        ON DXK2.DXK_FILIAL = '" + fwxFilial('DXK') + "' "
	Else
		cQuery += "        ON DXK2.DXK_FILIAL = '" + cFilAval + "' "
	Endif 

	cQuery += "       AND DXK2.DXK_SAFRA  = DXJ2.DXJ_SAFRA    "
	cQuery += " 	  AND DXK2.DXK_CODROM = DXJ2.DXJ_CODIGO   "
	cQuery += " 	  AND DXK2.DXK_TIPO   = DXJ2.DXJ_TIPO     "
	cQuery += " 	  AND DXK2.D_E_L_E_T_ = ' ' "
	
	cQuery += " 	INNER JOIN " + RetSQLName('DXI') + " DXI2 "

	If  FWModeAccess("DXI",1) = 'C' 
		cQuery += "        ON DXI2.DXI_FILIAL = '" + fwxFilial('DXI') + "' "
	Else
		cQuery += "        ON DXI2.DXI_FILIAL = '" + cFilAval + "' "
	Endif 
	
	cQuery += "       AND DXI2.DXI_SAFRA  = DXK2.DXK_SAFRA    "
	cQuery += " 	  AND DXI2.DXI_ETIQ   = DXK2.DXK_ETIQ     "
	cQuery += " 	  AND DXI2.DXI_BLOCO  = ' '     "
	cQuery += " 	  AND DXI2.D_E_L_E_T_ = ' ' "

	If  FWModeAccess("DXJ",1)='C'
		cQuery += " 	WHERE DXJ2.DXJ_FILIAL = '" + fwxFilial('DXJ') + "' "
	Else
		cQuery += " 	WHERE DXJ2.DXJ_FILIAL = '" + cFilAval + "' "
	Endif

	cQuery += "       AND DXJ2.DXJ_CODIGO = DXJ.DXJ_CODIGO "
	cQuery += " 	  AND DXJ2.DXJ_TIPO   = DXJ.DXJ_TIPO  "
	cQuery += "       AND DXJ2.D_E_L_E_T_ = ' ') as QTDMALA, "

	cQuery += " DX7_MIC, DX7_RES, DX7_FIBRA, DX7_UI, DX7_SFI, "
	cQuery += " DX7_ELONG, DX7_LEAF, DX7_AREA, DX7_CSP, DX7_CG, "
	cQuery += " DX7_MAISB, DX7_RD, DX7_COUNT, DX7_UHM, DX7_MATU, DX7_SCI, "

	cQuery += " DXI_PSLIQU, DXI_PSBRUT from " + RetSqlName('DXI') + " DXI "
	cQuery += " INNER JOIN " + RetSqlName('DX7') + " DX7"

	If FWModeAccess("DX7",1) = 'C'
		cQuery += "     ON DX7.DX7_FILIAL = '" + fwxFilial('DX7') + "' "
	Else
		cQuery += "     ON DX7.DX7_FILIAL = '" + cFilAval + "' "
	Endif

	cQuery += "    AND DX7.DX7_SAFRA = DXI.DXI_SAFRA "
	cQuery += "    AND DX7.DX7_ETIQ  = DXI.DXI_ETIQ  "
	cQuery += "    AND DX7.D_E_L_E_T_ = ' '  " 		

	cQuery += " INNER JOIN " + RetSqlName('DXK') + " DXK"

	If FWModeAccess("DXK",1)='C'
		cQuery += "     ON DXK.DXK_FILIAL = '" + fwxFilial('DXK') + "' "
	Else
		cQuery += "     ON DXK.DXK_FILIAL = '" + cFilAval + "' "
	Endif

	cQuery += " 	AND DXK.DXK_SAFRA = DXI.DXI_SAFRA "
	cQuery += " 	AND DXK.DXK_ETIQ  = DXI.DXI_ETIQ  "
	cQuery += " 	AND DXK.DXK_TIPO  = '2' "
	cQuery += " 	AND DXK.D_E_L_E_T_ = ' ' " 
	cQuery += " INNER JOIN " + RetSqlName('DXJ') + " DXJ"

	If FWModeAccess("DXJ",1) = 'C'
		cQuery += "     ON DXJ.DXJ_FILIAL = '" + fwxFilial('DXJ') + "' "
	Else
		cQuery += "     ON DXJ.DXJ_FILIAL = '" + cFilAval + "' "
	Endif
	
	cQuery += " 	AND DXJ.DXJ_SAFRA    = DXK.DXK_SAFRA " 
	cQuery += " 	AND DXJ.DXJ_CODIGO   = DXK.DXK_CODROM "
	cQuery += " 	AND DXJ.DXJ_TIPO     = DXK.DXK_TIPO "
	cQuery += " 	AND DXJ.DXJ_STATUS   = '6' " /*HVI importado*/
	cQuery += " 	AND DXJ.D_E_L_E_T_ = ' ' "
	
	If  FWModeAccess("DXI",1)='C'
		cQuery += "  WHERE DXI.DXI_FILIAL = '" + fwxFILIAL('DXI') + "'"
	Else
		cQuery += "  WHERE DXI.DXI_FILIAL = '" + cFilAval + "'"
	Endif
	cQuery += "      AND DXI.DXI_SAFRA  = '" + cSafraAval + "' "		
	cQuery += "	 	 AND DXI.DXI_BLOCO  = ' '  "			
	cQuery += "      AND DXI.DXI_CLACOM <> ' ' "
	cQuery += "      AND DXI.D_E_L_E_T_ = ' ' "

	cQuery    := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasPre, .F., .T. )

	While (cAliasPre)->(!Eof())

		dbSelectArea(__DXJTEMP)
		(__DXJTEMP)->(dbSetOrder(1))
		//Encontra a mala atribuida ao fardo e aberto
		If (__DXJTEMP)->(MsSeek(cFilAval+(cAliasPre)->DXI_SAFRA+(cAliasPre)->DXJ_CODIGO)) 

			dbSelectArea(__DXKTEMP)
			dbSetOrder(1)
			If !MsSeek(cFilAval+(cAliasPre)->DXI_SAFRA+(cAliasPre)->DXI_ETIQ)
				If RecLock(__DXKTEMP, .T.) //Cria registro vinculando o fardinho ao bloco

					(__DXKTEMP)->DXK_FILIAL := cFilAval 
					(__DXKTEMP)->DXK_SAFRA  := (cAliasPre)->DXI_SAFRA
					(__DXKTEMP)->DXK_CODROM := (cAliasPre)->DXJ_CODIGO
					(__DXKTEMP)->DXK_FARDO  := (cAliasPre)->DXI_CODIGO
					(__DXKTEMP)->DXK_ETIQ   := (cAliasPre)->DXI_ETIQ
					(__DXKTEMP)->DXK_PSLIQU := (cAliasPre)->DXI_PSLIQU
					(__DXKTEMP)->DXK_PSBRUT := (cAliasPre)->DXI_PSBRUT
					(__DXKTEMP)->DX7_SCI    := (cAliasPre)->DX7_SCI
					(__DXKTEMP)->DX7_MATU   := (cAliasPre)->DX7_MATU
					(__DXKTEMP)->DX7_UHM    := (cAliasPre)->DX7_UHM
					(__DXKTEMP)->DX7_COUNT  := (cAliasPre)->DX7_COUNT
					(__DXKTEMP)->DX7_RD     := (cAliasPre)->DX7_RD
					(__DXKTEMP)->DX7_MAISB  := (cAliasPre)->DX7_MAISB
					(__DXKTEMP)->DX7_CG     := (cAliasPre)->DX7_CG
					(__DXKTEMP)->DX7_CSP    := (cAliasPre)->DX7_CSP
					(__DXKTEMP)->DX7_AREA   := (cAliasPre)->DX7_AREA
					(__DXKTEMP)->DX7_ELONG  := (cAliasPre)->DX7_ELONG
					(__DXKTEMP)->DX7_SFI    := (cAliasPre)->DX7_SFI
					(__DXKTEMP)->DX7_UI     := (cAliasPre)->DX7_UI
					(__DXKTEMP)->DX7_FIBRA  := (cAliasPre)->DX7_FIBRA
					(__DXKTEMP)->DX7_RES    := (cAliasPre)->DX7_RES
					(__DXKTEMP)->DX7_MIC    := (cAliasPre)->DX7_MIC
					(__DXKTEMP)->DX7_LEAF   := (cAliasPre)->DX7_LEAF
										
					(__DXKTEMP)->(MsUnlock())
				Endif

				dbSelectArea(__DXJTEMP)
				If RecLock(__DXJTEMP,.F.) //Atualiza a quantidade vinculada ao bloco
					
					(__DXJTEMP)->DXJ_FRDFIM = (cAliasPre)->DXI_CODIGO
					(__DXJTEMP)->(MsUnlock()) 
				Endif
			Endif
		Else //Sem registro de mala do fardo
			dbSelectArea(__DXKTEMP)
			dbSetOrder(1)
			If !MsSeek(cFilAval+(cAliasPre)->DXI_SAFRA+(cAliasPre)->DXI_ETIQ)
				//Cria uma nova mala
				If RecLock(__DXJTEMP, .T.)
					(__DXJTEMP)->DXJ_FILIAL := cFilAval
					(__DXJTEMP)->DXJ_SAFRA  := (cAliasPre)->DXI_SAFRA
					(__DXJTEMP)->DXJ_CODIGO := (cAliasPre)->DXJ_CODIGO
					(__DXJTEMP)->DXJ_QTVINC := (cAliasPre)->QTDMALA
					(__DXJTEMP)->DXJ_FRDINI := (cAliasPre)->DXI_CODIGO
					(__DXJTEMP)->DXJ_FRDFIM := (cAliasPre)->DXI_CODIGO
				
					(__DXJTEMP)->(MsUnlock())
				Endif

				//Cria registro vinculando o fardinho a mala
				If RecLock(__DXKTEMP, .T.)
					(__DXKTEMP)->DXK_FILIAL := cFilAval
					(__DXKTEMP)->DXK_SAFRA  := (cAliasPre)->DXI_SAFRA
					(__DXKTEMP)->DXK_CODROM := (cAliasPre)->DXJ_CODIGO
					(__DXKTEMP)->DXK_FARDO  := (cAliasPre)->DXI_CODIGO
					(__DXKTEMP)->DXK_ETIQ   := (cAliasPre)->DXI_ETIQ
					(__DXKTEMP)->DXK_PSLIQU := (cAliasPre)->DXI_PSLIQU
					(__DXKTEMP)->DXK_PSBRUT := (cAliasPre)->DXI_PSBRUT
					(__DXKTEMP)->DX7_SCI   := (cAliasPre)->DX7_SCI
					(__DXKTEMP)->DX7_MATU  := (cAliasPre)->DX7_MATU
					(__DXKTEMP)->DX7_UHM   := (cAliasPre)->DX7_UHM
					(__DXKTEMP)->DX7_COUNT := (cAliasPre)->DX7_COUNT
					(__DXKTEMP)->DX7_RD    := (cAliasPre)->DX7_RD
					(__DXKTEMP)->DX7_MAISB := (cAliasPre)->DX7_MAISB
					(__DXKTEMP)->DX7_CG    := (cAliasPre)->DX7_CG
					(__DXKTEMP)->DX7_CSP   := (cAliasPre)->DX7_CSP
					(__DXKTEMP)->DX7_AREA  := (cAliasPre)->DX7_AREA
					(__DXKTEMP)->DX7_ELONG := (cAliasPre)->DX7_ELONG
					(__DXKTEMP)->DX7_SFI   := (cAliasPre)->DX7_SFI
					(__DXKTEMP)->DX7_UI    := (cAliasPre)->DX7_UI
					(__DXKTEMP)->DX7_FIBRA := (cAliasPre)->DX7_FIBRA
					(__DXKTEMP)->DX7_RES   := (cAliasPre)->DX7_RES
					(__DXKTEMP)->DX7_MIC   := (cAliasPre)->DX7_MIC
					(__DXKTEMP)->DX7_LEAF   := (cAliasPre)->DX7_LEAF
					(__DXKTEMP)->(MsUnlock())
				Endif
			Endif
		Endif

		dbSelectArea(cAliasPre)
		(cAliasPre)->(dbSkip())
	EndDo
	(cAliasPre)->(dbCloseArea())
	
Return 


/*/{Protheus.doc} A070BloqMala
//Função responsável pelo bloqueio das malas HVI
@author bruna.rocio
@since 15/08/2017
@version undefined
@type function
/*/
Function A070BloqMala(cFilAval, cSafra, cCodRom)
	Local aArea      := DXJ->(GetArea())
	Local lRet       := .T.

	dbSelectArea('DXJ')
	dbSetOrder(3)
	If MsSeek(cFilAval+cSafra+cCodRom+'2')
		If RecLock('DXJ',.F.)	
			DXJ->DXJ_STATUS = '8' //Bloqueada
			MsUnlock()
		Endif
	Endif	

	RestArea(aArea)
Return lRet