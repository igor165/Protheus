#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'UBAR0301.CH'

/*{Protheus.doc} UBAR0301
(Relatório de Listagem de Remessas)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
*/
Function UBAR0301()
	
	Local oReport
	Private cNome 	:= 'UBAR0301' // Nome da Rotina
	Private cPerg 	:= PadR('UBAA030R',10) // Nome do Pergunte
	
	If !N72->(ColumnPos('N72_CODREM'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf
	
	Pergunte(cPerg, .T.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
	
Return

 
/*{Protheus.doc} ReportDef
(Função responsável por montar a impressão do relatório)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
@param cNome, character, (Nome da Rotina)
@param cPerg, character, (Nome da Pergunta)
@return ${return}, ${Objeto oReport}
@example
(examples)
@see (links_or_references)
*/
Static Function ReportDef()
	
	Local oReport := NIL
	Local cTitulo := STR0001 // "Listagem de Remessa para Classificação"
	Local cDesc := STR0002 // "Relatório para impressão de itens da remessa."
 
	oReport := TReport():New(cNome, cTitulo, cPerg, {|oReport| PrintReport(oReport)}, cDesc) // Instanciação do objeto TReport
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:HideParamPage()
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 10 // Tamanho da fonte
 	
return (oReport)

 
/*{Protheus.doc} PrintReport
(Função responsável pela impressão do relatório)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
@param oReport, objeto, (Objeto TReport)
@return ${return}, ${Nil}
*/
Static Function PrintReport(oReport)

	Local nLinPC 		:= 0 // Linha Atual
	Local aRemessas	:= QueryN72() // Array com remessas, malas e fardinhos aRemessas[Remessas][4][Malas][3][Fardinhos]
	Local nItRemes	:= 0 
	Local nItMalas	:= 0
	Local nItFards	:= 0
	Local nFardCol	:= 0
	Local cValRem   := "0" 
	Local cValR2    := "0" 
	Local cValR3    := "0" 
	nLinPC := oReport:Row() // Pega a linha que está posicionada
	
	For nItRemes := 1 To Len(aRemessas) // Array de Remessas
		nLinPC := oReport:Row()
			// "Remessa" # "Tipo" # "Visual" # "HVI"
			oReport:PrintText(STR0010 + ": " + aRemessas[nItRemes][1] +"  "+ STR0011 +": " + ;
								Iif(aRemessas[nItRemes][3] == "1", STR0003, STR0004), nLinPc) 
			DoubleJump(oReport) // Salta duas Linhas
			oReport:FatLine() // Printa uma linha mais densa
			oReport:SkipLine() // Salta uma linha
			oReport:PrtLeft(STR0009 + Replicate(" ", 24)) // "Fardos"
			oReport:PrtCenter(STR0009 + Replicate(" ", 24)) // "Fardos"
			oReport:PrtRight(STR0009 + Replicate(" ", 24)) // "Fardos"
			oReport:SkipLine()
			oReport:PrtLeft(Replicate("=" , 30))
			oReport:PrtCenter(Replicate("=" , 30))
			oReport:PrtRight(Replicate("=" , 30))
			
			DoubleJump(oReport)
			
		For nItMalas := 1 To Len(aRemessas[nItRemes][4]) // Array de Malas
			nLinPC := oReport:Row() 
			cValRem   := "0" 
			cValR2    := "0" 
			cValR3    := "0" 

			If !Empty(aRemessas[nItRemes][4][nItMalas][1]) 
				cValRem:= aRemessas[nItRemes][4][nItMalas][1]
			ENDIF
			If len( aRemessas[nItRemes][4][nItMalas][3] ) > 0 .AND. !Empty( aRemessas[nItRemes][4][nItMalas][3][1] )
				cValR2:= aRemessas[nItRemes][4][nItMalas][3][1]

				If len( aRemessas[nItRemes][4][nItMalas][3][ Len(aRemessas[nItRemes][4][nItMalas][3]) ]) > 0
					cValR3:= aRemessas[nItRemes][4][nItMalas][3][ Len(aRemessas[nItRemes][4][nItMalas][3]) ]
				ENDIF
				
			ENDIF

			    
			// "Filial" # "Mala" # "Frd Ini" # "Frd Fim" # "Variedade"
			oReport:PrintText( STR0005 + ": "+xFilial('N72')+"  "+ STR0008 +": "+cValRem+;
								"  "+STR0006+": "+cValR2+;
								"  "+STR0007+": "+cValR3,nLinPC)
			
			// "Variedade" # "Descrição variedade"
			DoubleJump(oReport) // Salta duas Linhas
			nLinPC := oReport:Row()
			oReport:PrintText( 	STR0012 + ": "+aRemessas[nItRemes][5][1][1]+ " - " +aRemessas[nItRemes][5][1][2],nLinPC)
			
			DoubleJump(oReport) // Salta duas Linhas
			DoubleJump(oReport)
			
			For nItFards := 1 To Len(aRemessas[nItRemes][4][nItMalas][3]) // Array de Fardinhos
				nLinPC := oReport:Row()
				If "|" + cValToChar(nItFards)+ "|" $ "|1|4|7|10|13|16|19|22|25|28|31|34|37|40|43|45|48|"
					oReport:PrtLeft(Iif("|" +cValToChar(nItFards)+ "|" $ "|1|4|7|" , "0"+cValToChar(nItFards), cValToChar(nItFards)) + ;
					" " + aRemessas[nItRemes][4][nItMalas][3][nItFards]+ ;
					" " + Replicate("_", 6))
				ElseIf "|" + cValToChar(nItFards)+ "|" $ "|2|5|8|11|14|17|20|23|26|29|32|35|38|41|44|46|49|"
					oReport:PrtCenter(Iif("|" +cValToChar(nItFards)+ "|" $ "|2|5|8|" , "0"+cValToChar(nItFards), cValToChar(nItFards)) + ;
					" " + aRemessas[nItRemes][4][nItMalas][3][nItFards]+ ;
					" " + Replicate("_", 6))
				ElseIf "|" + cValToChar(nItFards)+ "|" $ "|3|6|9|12|15|18|21|24|27|30|33|36|39|42|45|47|50|"
					oReport:PrtRight(Iif("|" +cValToChar(nItFards)+ "|" $ "|3|6|9|" , "0"+cValToChar(nItFards), cValToChar(nItFards)) + ;
					" " + aRemessas[nItRemes][4][nItMalas][3][nItFards]+ ;
					" " + Replicate("_", 6))
				EndIf 
				nFardCol++
				If nFardCol == 3
					DoubleJump(oReport)
					nFardCol := 0
				EndIf
			Next nItFards
			
			nFardCol := 0
			DoubleJump(oReport) // Salta duas Linhas
			oReport:ThinLine() // Print uma linha fina
			
		Next nItMalas
		
		oReport:EndPage(.F.) // Finaliza a página da remessa
	
	Next nItRemes
	
	
Return	


/*{Protheus.doc} QueryN72
(Função responsavel por montar o Array de Remessas)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
@return ${return}, ${Array de remessas com malas e fardinhos}
*/
Static Function QueryN72()
	
	Local cAliasN72	:= GetNextAlias() // Obtém o proximo alias disponível
	Local cQryN72		:= "" // Query N72
	Local aRemessas	:= {}
	Local nRemes		:= 0
	
	cQryN72 := "SELECT N72_CODREM, N72_SAFRA, N72_TIPO"
	cQryN72 += " FROM "+ RetSqlName("N72") + " N72"
	cQryN72 += " WHERE D_E_L_E_T_ <> '*'"
	cQryN72 += " AND N72_STATUS <> '5'"
	
	If !Empty(MV_PAR01)
		cQryN72 += " AND N72_CODREM >= '" + MV_PAR01 + "'"
	EndIf
	If !Empty(MV_PAR02)
		cQryN72 += " AND N72_CODREM <= '" + MV_PAR02 + "'"
	EndIf
	
	If Select(cAliasN72) > 0
		(cAliasN72)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryN72 ), cAliasN72, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasN72)
	dbGoTop()
	While (cAliasN72)->(!Eof()) // Adiciona as Remessas

		aAdd( aRemessas, {(cAliasN72)->N72_CODREM, (cAliasN72)->N72_SAFRA, (cAliasN72)->N72_TIPO } )
		nRemes++
		aRemessas	:= QueryN73(aRemessas, nRemes)	
		
		(cAliasN72)->(DbSkip())
	EndDo
	
  	(cAliasN72)->(DbCloseArea())
		
Return aRemessas


/*{Protheus.doc} QueryN73
(Monta o Array de Remessas com as Malas)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
@param aRemessas, array, (Array de Remessas)
@param nRemes, numérico, (Numero da Remessa Atual)
@return ${return}, ${Array de Remessas}
*/
Static Function QueryN73(aRemessas, nRemes)
	
	Local cAliasN73	:= GetNextAlias()
	Local cQryN73 	:= "" // Query N73
	Local nMalas		:= 0
	
	aAdd(aRemessas[nRemes], {}) // Adiciona Array para inclusão das malas
		
	cQryN73 := "SELECT N73_CODMAL, N73_TIPO"
	cQryN73 += " FROM "+ RetSqlName("N73") + " N73"
	cQryN73 += " WHERE D_E_L_E_T_ <> '*'"
	cQryN73 += " AND N73_CODREM = '"+aRemessas[nRemes][1]+"'"
	cQryN73 += " AND N73_CODSAF = '"+aRemessas[nRemes][2]+"'"
	
	If Select(cAliasN73) > 0
		(cAliasN73)->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryN73 ), cAliasN73, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasN73)
	dbGoTop()
	While (cAliasN73)->(!Eof()) // Adiciona as Malas

		aAdd( aRemessas[nRemes][4], {(cAliasN73)->N73_CODMAL, (cAliasN73)->N73_TIPO })	
		nMalas++
		aRemessas	:= QueryDXK(aRemessas, nRemes, nMalas)
		
		
		(cAliasN73)->(DbSkip())
	EndDo
	
  	(cAliasN73)->(DbCloseArea())

Return aRemessas


/*{Protheus.doc} QueryDXK
(Monta o Array de Remessas com os Fardinhos)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
@param aRemessas, array, (Array de Remessas)
@param nRemes, numérico, (Numero da Remessa Atual)
@param nMalas, numérico, (Numero da Mala Atual)
@return ${return}, ${Array de Remessas}
*/
Static Function QueryDXK(aRemessas, nRemes ,nMalas)
	
	Local cAliasDXK	:= GetNextAlias()
	Local cQryDXK 	:= "" // Query DXK
	Local cCodVar   := ""
	Local cDesVar   := ""
		
	aAdd(aRemessas[nRemes][4][nMalas], {}) // Adiciona Array para inclusão dos Fardinhos
		
	cQryDXK := "SELECT DXK_ETIQ, DXK_CODVAR"
	cQryDXK += " FROM "+ RetSqlName("DXK") + " DXK"
	cQryDXK += " WHERE D_E_L_E_T_ <> '*'"
	cQryDXK += " AND DXK_CODROM = '"+aRemessas[nRemes][4][nMalas][1]+"'"
	cQryDXK += " AND DXK_TIPO = '"+aRemessas[nRemes][4][nMalas][2]+"'"
	
	If Select(cAliasDXK) > 0
		(cAliasDXK)->( dbCloseArea() )
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryDXK ), cAliasDXK, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasDXK)
	dbGoTop()
	While (cAliasDXK)->(!Eof()) // Adiciona as Etiquetas dos Fardinhos
		cCodVar := (cAliasDXK)->DXK_CODVAR
		
		aAdd( aRemessas[nRemes][4][nMalas][3], (cAliasDXK)->DXK_ETIQ)
			
		(cAliasDXK)->(DbSkip())
	EndDo
	
	//adiciona posição array para incluir variedade
	aAdd(aRemessas[nRemes], {})
	
	If !Empty(cCodVar)
		//busca descrição da variedade
		dbSelectArea('NNV')
		NNV->(dbSetOrder(2))    	
		If NNV->(MsSeek(FwxFilial("NNV")+cCodVar)) //NNV_FILIAL+NNV_CODIGO
			cDesVar := NNV->NNV_DESCRI
		EndIf  
		NNV->(dbCloseArea())
	EndIf	
	
	aAdd(aRemessas[nRemes][5], {cCodVar, cDesVar})

  	(cAliasDXK)->(DbCloseArea())

Return aRemessas


/*{Protheus.doc} DoubleJump
(Permite saltar duas linhas, devido a utilização de uma fonte maior que a padrão 8)
@type function
@author roney.maia
@since 15/02/2017
@version 1.0
@param oReport, objeto, (Objeto TReport)
*/
Static Function DoubleJump(oReport)
	
	oReport:SkipLine()
	oReport:SkipLine()

Return