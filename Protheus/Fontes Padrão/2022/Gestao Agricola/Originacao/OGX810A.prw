#INCLUDE 'PROTHEUS.ch'
#INCLUDE "FWMVCDEF.CH"

Static _aPrecos   := {}
Static _cCondDCO  := ""
Static _cUFOrig   := ""
Static _cCidOrig  := ""
Static _cUFDest   := ""
Static _ccCidDest := ""
Static _aDCOVinc  := {}
Static _aPrcVinc  := {}
Static _aStrcDCO  := {}
Static _aIndDCO   := {}
Static __cTabDCO  := ""
Static __cNamDCO  := ""
Static __oBrwDCO  := Nil
Static oModelNLN  := {}

Function OGX810ADCO(cTMerc, cTCtr, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, nPeso, cCodPro, cFilOrg, cCodEnt, cLojEnt, nOperation, oModel, cFinalid, nPesRom)
	
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local lRet      := .T.
	Local aHeader   := {}
	Local nPosChv    := 0
	Local cChave     := ""
	Local nCont      := 0
	Local nCol       := 1
	Local cCmpsTit   := ""
	Local nCmpsTam   := 0
	Local aFilBrwDCO := {}
	Local aIndSeek   := {}
	Local nOpcX	     := 1
	
	Default cFinalid := ""
	Default nPesRom  := 0
	
	oModelNLN := oModel:GetModel("NLNUNICO")
	
	nPeso := nPeso - nPesRom
	
	//Inicialização da tela
	Processa({|| IniTela(cTMerc, cTCtr, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, nPeso, cCodPro, cFilOrg, cCodEnt, cLojEnt, cFinalid)}, 'Aguarde. Carregando a tela') // Aguarde. Carregando a tela
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject("ALL", 100, 100, .T., .T.)    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] *0.8, oSize:aWindSize[4]*0.8,;
	'DCOs do PEPRO' , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"),;
			 ,oDlg, , , , , ,oSize:GetDimension("ALL","COLEND")/1.26, oSize:GetDimension("ALL","LINEND")/1.5)
			 
			 
	// Cria o browse	
	nPosChv := AScan(_aIndDCO, {|x| AllTrim(x[1]) == "CHAVE"})
	cChave  := _aIndDCO[nPosChv][2]
	
	For nCont := 2 to Len(_aStrcDCO)
	
		If At(_aStrcDCO[nCont][2], cChave) > 0
			If !Empty(cCmpsTit)
				cCmpsTit += "+"
			EndIf
			
			cCmpsTit += AllTrim(_aStrcDCO[nCont][1])
			nCmpsTam += _aStrcDCO[nCont][4]			
		EndIf
					 	
	 	// Monta as colunas	    	   
    	AAdd(aHeader,FWBrwColumn():New())
		aHeader[nCol]:SetData(&("{||"+_aStrcDCO[nCont][2]+"}"))
		aHeader[nCol]:SetTitle(_aStrcDCO[nCont][1])
		aHeader[nCol]:SetPicture(_aStrcDCO[nCont][6])
		aHeader[nCol]:SetType(_aStrcDCO[nCont][3])
		aHeader[nCol]:SetSize(_aStrcDCO[nCont][4])
		aHeader[nCol]:SetReadVar(_aStrcDCO[nCont][2])
		nCol++
							   	    	
	    Aadd(aFilBrwDCO, {_aStrcDCO[nCont][2], _aStrcDCO[nCont][1], _aStrcDCO[nCont][3], _aStrcDCO[nCont][4], _aStrcDCO[nCont][5], _aStrcDCO[nCont][6]})    	    
	    	    
    Next nCont
    
    Aadd(aIndSeek,{cCmpsTit ,{{"", 'C' , nCmpsTam, 0 , "@!" }}, 2, .T.})
	
	__oBrwDCO := FWBrowse():New()
	__oBrwDCO:SetDataTable(.T.)
	__oBrwDCO:SetOwner(oPnDown)
	__oBrwDCO:SetAlias(__cTabDCO)
	__oBrwDCO:SetProfileID('DCO')
	__oBrwDCO:Acolumns:= {}
	__oBrwDCO:AddMarkColumns({|| IIf((__cTabDCO)->T_OK == "OK", "LBOK", "LBNO")},{ || MarkBrw(__cTabDCO, nOperation)},{|| MarkAllBrw(__cTabDCO, nOperation)})
	__oBrwDCO:Setcolumns(aHeader)
	__oBrwDCO:DisableReport()
	__oBrwDCO:DisableConfig()
	__oBrwDCO:SetFieldFilter(aFilBrwDCO) //seta os campos para o botão filtro
	__oBrwDCO:SetUseFilter() //ativa filtro    
	__oBrwDCO:SetSeek(,aIndSeek)

	__oBrwDCO:Activate()
	__oBrwDCO:Enable()
	__oBrwDCO:Refresh(.T.)
	
	// Marca os itens já vinculados
	MarkItens(__cTabDCO, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE)
	
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },,) } )
	
	If nOpcX == 1 .AND. nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		SetDCOs(__cTabDCO, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, nOperation)
	EndIf
		
Return lRet

Static Function MarkItens(cAliasTab, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE)

	Local nX   := 0
	Local nY   := 0
		
	For nX := 1 To oModelNLN:Length()
		oModelNLN:GoLine(nX)
		
		If oModelNLN:GetValue("NLN_FILIAL") == cFilCtr .AND. oModelNLN:GetValue("NLN_CODCTR") == cCodCtr .AND.;
		   oModelNLN:GetValue("NLN_ITEMPE") == cItPrev .AND. oModelNLN:GetValue("NLN_ITEMRF") == cRegFis .AND.;
		   !oModelNLN:IsDeleted()		      		 
		   
		   (cAliasTab)->(DbSetOrder(1)) //T_NUMAVI+T_NUMDCO+T_SEQEST
			If (cAliasTab)->(DbSeek(oModelNLN:GetValue("NLN_NUMAVI")+oModelNLN:GetValue("NLN_NUMDCO")+oModelNLN:GetValue("NLN_SEQDCO")))
				
				If RecLock(cAliasTab, .F.)
					
					For nY := 1 to Len(_aPrecos)
			
						nVlrUni := _aPrecos[nY][2]																
						
						If oModelNLN:GetValue("NLN_PRECO") == nVlrUni
						
							If Empty(cCodIE)
						
								nQtdFat := GetDataSql(" SELECT SUM(NLN.NLN_QTDFAT) " +;
										   	          "   FROM " + RetSQLName("NLN") + " NLN " +;
												      "  WHERE NLN.NLN_NUMAVI = '" + oModelNLN:GetValue("NLN_NUMAVI") + "' " +;
												      "    AND NLN.NLN_NUMDCO = '" + oModelNLN:GetValue("NLN_NUMDCO") + "' " +;
												      "    AND NLN.NLN_SEQDCO = '" + oModelNLN:GetValue("NLN_SEQDCO") + "' " +;
												      "    AND NLN.NLN_PRECO  = '" + cValToChar(oModelNLN:GetValue("NLN_PRECO")) + "' " +;
												      "    AND NLN.NLN_CODINE != ' ' " +;							       
												      "    AND NLN.D_E_L_E_T_ = ' ' ")
							Else
								
								nQtdFat := oModelNLN:GetValue("NLN_QTDFAT")
											      
							EndIf
											
							(cAliasTab)->&("T_VPRC"+cValToChar(nY)) := oModelNLN:GetValue("NLN_QTDVIN")
							(cAliasTab)->&("T_FPRC"+cValToChar(nY)) := nQtdFat
							EXIT	
						EndIf
						
					Next nY
					
					(cAliasTab)->T_QTDSDO := (cAliasTab)->T_QTDSDO - oModelNLN:GetValue("NLN_QTDVIN")
					(cAliasTab)->T_QTDVNC := (cAliasTab)->T_QTDVNC + oModelNLN:GetValue("NLN_QTDVIN")
					(cAliasTab)->T_OK     := "OK"
					
					(cAliasTab)->(MsUnlock())
				EndIf
				
			EndIf
			
		ElseIf !oModelNLN:IsDeleted()
			
			(cAliasTab)->(DbSetOrder(1)) //T_NUMAVI+T_NUMDCO+T_SEQEST
			If (cAliasTab)->(DbSeek(oModelNLN:GetValue("NLN_NUMAVI")+oModelNLN:GetValue("NLN_NUMDCO")+oModelNLN:GetValue("NLN_SEQDCO")))
				
				If RecLock(cAliasTab, .F.)
					(cAliasTab)->T_QTDSDO := (cAliasTab)->T_QTDSDO - oModelNLN:GetValue("NLN_QTDVIN")
					
					(cAliasTab)->(MsUnlock())
				EndIf
			EndIf
		   						
		EndIf				
	Next nX
	
	(cAliasTab)->(DbGoTop())
	While !(cAliasTab)->(Eof())	
		
		If Empty((cAliasTab)->T_OK) .AND. (cAliasTab)->T_QTDSDO == 0
			
			If RecLock(cAliasTab, .F.)
				(cAliasTab)->(DbDelete())
				(cAliasTab)->(MsUnlock())
			EndIf			
		EndIf		
		
		(cAliasTab)->(DbSkip())
	EndDo
	
	__oBrwDCO:Refresh(.T.)

Return .T.

Static Function SetDCOs(cAliasTab, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, nOperation)

	Local nX      := 0
	Local cSequen := ""
	Local cNumAvi := ""
	Local cNumDCO := ""
	Local cSeqDCO := ""
	
	If nOperation == MODEL_OPERATION_VIEW .OR. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
	
	// Remove os vinculos do DCO com preço(s) da regra fiscal da IE
	OGX810RNLN(cFilCtr, cCodCtr, cItPrev, cRegFis, @oModelNLN)

	(cAliasTab)->(DbGoTop())	
	While !(cAliasTab)->(Eof())	
		
		If !Empty((cAliasTab)->T_OK)
			
			For nX := 1 to Len(_aPrecos)
				
				nQtdFat := (cAliasTab)->&("T_FPRC"+cValToChar(nX))
				nQtdVin := (cAliasTab)->&("T_VPRC"+cValToChar(nX))
				nVlrUni := _aPrecos[nX][2]
				cNumAvi := (cAliasTab)->T_NUMAVI 
				cNumDCO := (cAliasTab)->T_NUMDCO
				cSeqDCO := (cAliasTab)->T_SEQEST
				
				If nQtdVin > 0				
					// Inclui os vinculos do DCO com preço(s) da regra fiscal da IE
					OGX810INLN(cFilCtr, cCodCtr, cItPrev, cRegFis, @cSequen, nVlrUni, cNumAvi, cNumDCO, cSeqDCO, nQtdVin, cCodIE, @oModelNLN, nQtdFat)
				EndIf
				
			Next nX
			
		EndIf		
		
		(cAliasTab)->(DbSkip())
	EndDo

Return .T.

Static Function MarkBrw(cAliasTab, nOperation)

	Local lMarcar  := IIf(Empty((cAliasTab)->T_OK), .T., .F.)
	Local lAtualiz := .F.
	Local nX       := 0
	
	If nOperation == MODEL_OPERATION_VIEW .OR. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
	
	// Verifica se ele está atualizando o campo, caso esteja atualiza as quantidades
	If (lMarcar .AND. Empty((cAliasTab)->T_OK)) .OR. (!lMarcar .AND. !Empty((cAliasTab)->T_OK))
		
		If !lMarcar
		
			nDCOFat := 0
		
			For nX := 1 To Len(_aPrecos)
							
				nDCOFat := nDCOFat + (cAliasTab)->&("T_FPRC"+cValToChar(nX))
								
			Next nX
			
			If nDCOFat == (cAliasTab)->T_QTDVNC
				MsgAlert("DCO não pode ser desmarcado, pois está totalmente faturado.", "Atenção")
				Return .T.
			ElseIf nDCOFat > 0
				If !MsgYesNo("DCO possui quantidade faturada. Deseja desmarcar o saldo não faturado?", "Desvincular DCO Faturado")
					Return .T.
				EndIf				
			EndIf
		
		EndIf
	
		lAtualiz :=  AtuGrid(lMarcar, cAliasTab)
				
	EndIf
	
	If lAtualiz
		If RecLock(cAliasTab, .F.)
			(cAliasTab)->T_OK := IIf(lMarcar, 'OK', '')
			(cAliasTab)->(MsUnlock())
		EndIf
	EndIf
	
Return .T.

Static Function MarkAllBrw(cAliasTab, nOperation)

	Local lMarcar  := .F.
	Local lAtualiz := .F.
	Local nX       := 0
	
	If nOperation == MODEL_OPERATION_VIEW .OR. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
	
	(cAliasTab)->(DbGoTop())	
	lMarcar := IIf(Empty((cAliasTab)->T_OK), .T., .F.)
	
	If !lMarcar
	
		lDCOFat := .F.
		
		While !(cAliasTab)->(Eof())	
		
			For nX := 1 To Len(_aPrecos)
			
				If (cAliasTab)->&("T_FPRC"+cValToChar(nX)) > 0
					lDCOFat := .T.
					EXIT
				EndIf
			
			Next nX
			
			If lDCOFat
				EXIT
			EndIf
			
			(cAliasTab)->(DbSkip())
		EndDo
		
		If lDCOFat
			If !MsgYesNo("DCO(s) possui(em) quantidade faturada. Deseja desmarcar o saldo não faturado?", "Desvincular DCO Faturado")
				Return .T.
			EndIf
		EndIf
		
	EndIf
	
	(cAliasTab)->(DbGoTop())
	While !(cAliasTab)->(Eof())	
	
		lAtualiz := .F.
		
		// Verifica se ele está atualizando o campo, caso esteja atualiza as quantidades
		If (lMarcar .AND. Empty((cAliasTab)->T_OK)) .OR. (!lMarcar .AND. !Empty((cAliasTab)->T_OK))
			lAtualiz := AtuGrid(lMarcar, cAliasTab)
		EndIf
		
		If lAtualiz
			If RecLock(cAliasTab, .F.)
				
				(cAliasTab)->T_OK  := IIf(lMarcar, "OK", "")							
				(cAliasTab)->(MsUnlock())
			EndIf		
		EndIf
		
		(cAliasTab)->(DbSkip())
	EndDo
	
	__oBrwDCO:Refresh(.T.)

Return .T.

Static Function AtuGrid(lMarcar, cAliasTab)
	
	Local cCodReg    := ""
	Local aPrPEPRO   := {}	
	Local nX         := 0
	Local nPrMiDco   := 0
	Local nVlrPre    := 0
	Local nQtdVin    := 0
	Local nVlrUni    := 0
	Local nQtdJaVinc := 0
	Local nQtdDCOVn  := 0
	Local lAtualiz   := .F.

	If lMarcar
	
		cCodReg := OGX810REG((cAliasTab)->T_NUMAVI, _cUFOrig, _cCidOrig)
		
		// Busca o preco minimo e preco do premio
		aPrPEPRO := OGX810GtPr((cAliasTab)->T_NUMAVI, , _cUFOrig, _cUFDest, cCodReg)
		
		nPrMiDco := aPrPEPRO[1]
		nVlrPre  := aPrPEPRO[2]
		
		If RecLock(cAliasTab, .F.)
		
			For nX := 1 to Len(_aPrecos)
				
				// Caso já consumiu todo o saldo do DCO não utiliza mais o mesmo
				If (cAliasTab)->T_QTDSDO == 0
					EXIT
				EndIf
				
				nQtdVin := _aPrecos[nX][3]
				nVlrUni := _aPrecos[nX][2]
				
				// Busca a quantidade já vinculada ao preço para aquele contrato+cadência+regra fiscal
				nQtdJaVinc := GetQPrcVn(cAliasTab, nX)
				
				// Validar se já foi vinculado a outros DCOs toda a quantidade do preço
				If nQtdJaVinc > 0
					nQtdVin := nQtdVin - nQtdJaVinc
					
					If nQtdVin <= 0
						LOOP
					EndIf
				EndIf
				
				// Validar preço mínimo
			 	If nPrMiDco > nVlrUni + nVlrPre
			 		LOOP
				EndIf
				
				// Quantidade do preço for maior que o saldo da comprovação do DCO - o que já está sendo vinculado, 
				// será utilizado mais de um DCO por preço
				If nQtdVin > (cAliasTab)->T_QTDSDO
					nQtdVin := (cAliasTab)->T_QTDSDO
				EndIf
							
				(cAliasTab)->&("T_VPRC"+cValToChar(nX)) := nQtdVin
				(cAliasTab)->T_QTDSDO := (cAliasTab)->T_QTDSDO - (cAliasTab)->&("T_VPRC"+cValToChar(nX))
				nQtdDCOVn := nQtdDCOVn + nQtdVin
				lAtualiz  := .T.
				
			Next nX
			
			(cAliasTab)->T_QTDVNC := nQtdDCOVn			
			(cAliasTab)->(MsUnlock())
		EndIf
		
	Else
	
		lAtualiz := .T.	
	
		If RecLock(cAliasTab, .F.)
	
			For nX := 1 to Len(_aPrecos)
				
				(cAliasTab)->T_QTDSDO := (cAliasTab)->T_QTDSDO + ((cAliasTab)->&("T_VPRC"+cValToChar(nX)) - (cAliasTab)->&("T_FPRC"+cValToChar(nX)))
				(cAliasTab)->&("T_VPRC"+cValToChar(nX)) := (cAliasTab)->&("T_FPRC"+cValToChar(nX))		
												
				nQtdVin := nQtdVin + (cAliasTab)->&("T_VPRC"+cValToChar(nX))
							
			Next nX
			
			(cAliasTab)->T_QTDVNC := nQtdVin
			
			If (cAliasTab)->T_QTDVNC > 0
				lAtualiz := .F.
			EndIf
			
			(cAliasTab)->(MsUnlock())
		EndIf
		
	EndIf
		
Return lAtualiz

Static Function GetQPrcVn(cAliasTab, nPosPrc)
	
	Local nQtdPrc  := 0
	Local aAreaDCO := (cAliasTab)->(GetArea())
	
	(cAliasTab)->(DbGoTop())	
		
	While !(cAliasTab)->(Eof())		
		
		nQtdPrc := nQtdPrc + (cAliasTab)->&("T_VPRC"+cValToChar(nPosPrc))
		
		(cAliasTab)->(DbSkip())
	EndDo
	
	RestArea(aAreaDCO)

Return nQtdPrc

Static Function IniTela(cTMerc, cTCtr, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, nPeso, cCodPro, cFilOrg, cCodEnt, cLojEnt, cFinalid)
	
	Local aRet := {}
	
	Default cFinalid := ""
	
	// Busca a cidade e UF de destino
	aRet := OGX810BUF(cTMerc, cCodEnt, cLojEnt, cFilCtr, cCodCtr, cItPrev, cRegFis)
	
	_cUFDest  := aRet[1]
	_cCidDest := aRet[2]
	
	_cUFOrig  := UPPER(POSICIONE("SM0",1,cEmpAnt+cFilOrg,"M0_ESTENT"))   
	_cCidOrig := SubStr(POSICIONE("SM0",1,cEmpAnt+cFilOrg,"M0_CODMUN"), 3, TamSx3('CC2_CODMUN')[1])
	
	BuscaPrc(cTCtr, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodEnt, cLojEnt, nPeso, cFilOrg, cCodIE)
		
	CriaTemp()
	
	InsRegDCO(cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodPro, cFilOrg, cCodEnt, cLojEnt, cFinalid, cCodIE)
	
Return .T.

Static Function CriaTemp()

	Local nX := 0	
	
	_aStrcDCO := {{"", "T_OK", "C", 2,, "@!"}}
	
	// Estrutura da tabela temporária
	AAdd(_aStrcDCO, {RetTitle("N9W_NUMAVI"), "T_NUMAVI", TamSX3("N9W_NUMAVI")[3], TamSX3("N9W_NUMAVI") [1], TamSX3("N9W_NUMAVI") [2], PesqPict("N9W","N9W_NUMAVI")})
	AAdd(_aStrcDCO, {RetTitle("N9W_NUMDCO"), "T_NUMDCO", TamSX3("N9W_NUMDCO")[3], TamSX3("N9W_NUMDCO")[1],  TamSX3("N9W_NUMDCO")[2],  PesqPict("N9W","N9W_NUMDCO")})	
	AAdd(_aStrcDCO, {RetTitle("N9W_SEQEST"), "T_SEQEST", TamSX3("N9W_SEQEST")[3], TamSX3("N9W_SEQEST")[1],  TamSX3("N9W_SEQEST")[2],  PesqPict("N9W","N9W_SEQEST")})
	AAdd(_aStrcDCO, {RetTitle("N9W_QTDSDO"), "T_QTDSDO", TamSX3("N9W_QTDSDO")[3], TamSX3("N9W_QTDSDO")[1],  TamSX3("N9W_QTDSDO")[2],  PesqPict("N9W","N9W_QTDSDO")})
	AAdd(_aStrcDCO, {'Qtd. Vinc.',           "T_QTDVNC", TamSX3("N9W_QTDSDO")[3], TamSX3("N9W_QTDSDO")[1],  TamSX3("N9W_QTDSDO")[2],  PesqPict("N9W","N9W_QTDSDO")})
	
	For nX := 1 to Len(_aPrecos)
	
		cTitulo := "Preço " + cValtoChar(_aPrecos[nX][2])
		cCampo  := "T_VPRC"+cValtoChar(nX)
		
		AAdd(_aStrcDCO, {cTitulo, cCampo, TamSX3("N9W_QTDSDO")[3], TamSX3("N9W_QTDSDO")[1],  TamSX3("N9W_QTDSDO")[2],  PesqPict("N9W","N9W_QTDSDO")})
		
		cTitulo := "Q Fat Prc " + cValtoChar(_aPrecos[nX][2])
		cCampo  := "T_FPRC"+cValtoChar(nX)
		
		AAdd(_aStrcDCO, {cTitulo, cCampo, TamSX3("N9W_QTDSDO")[3], TamSX3("N9W_QTDSDO")[1],  TamSX3("N9W_QTDSDO")[2],  PesqPict("N9W","N9W_QTDSDO")})
		
	Next nX
	
	// Definição dos índices da tabela
	_aIndDCO := {{"CHAVE","T_NUMAVI, T_NUMDCO, T_SEQEST"}, {"SELEC", "T_OK"}}
	
	OG710ACTMP(@__cTabDCO, @__cNamDCO, _aStrcDCO, _aIndDCO)
		
Return .T.

Static Function BuscaPrc(cTCtr, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodEnt, cLojEnt, nPeso, cFilOrg, cCodIE)

	Local lAchou := .F.
	Local nX     := 0
	Local nY     := 0
	
	// Busca a lista de preços disponíveis
	If cTCtr == "1" // Venda
				
		_aPrecos := OGX810GetPr(cTCtr, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodIE, cCodEnt, cLojEnt, nPeso)
	Else // Armazenagem
						
		_aPrecos := OGX810GetPr(cTCtr, , cFilCtr, cCodCtr, , , , , , nPeso, _cUFOrig, _cUFDest)
	EndIf
	
	For nX := 1 To oModelNLN:Length()
		oModelNLN:GoLine(nX)
					
		If oModelNLN:GetValue("NLN_FILIAL") == cFilCtr .AND. oModelNLN:GetValue("NLN_CODCTR") == cCodCtr .AND.;
		   oModelNLN:GetValue("NLN_ITEMPE") == cItPrev .AND. oModelNLN:GetValue("NLN_ITEMRF") == cRegFis .AND.;
		   !oModelNLN:IsDeleted()
		   
		   lAchou := .F.	
		   
		   For nY := 1 To Len(_aPrecos)
		   	
		   		If _aPrecos[nY][2] == oModelNLN:GetValue("NLN_PRECO")
		   			_aPrecos[nY][3] := _aPrecos[nY][3] + oModelNLN:GetValue("NLN_QTDVIN")		
		   			lAchou := .T. 
		   			
		   			EXIT 		
		   		EndIf
		   	
		   Next nY
		   
		   If !lAchou 
		   	  Aadd(_aPrecos, {"", oModelNLN:GetValue("NLN_PRECO"), oModelNLN:GetValue("NLN_QTDVIN"), "", ""})
		   EndIf		
		   			
		EndIf		
	
	Next nX
	
Return .T.

Static Function InsRegDCO(cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodPro, cFilOrg, cCodEnt, cLojEnt, cFinalid, cCodIE)

	Local cQry      := ""
	Local cAliasDCO := ""
	Local nX        := 0
	Local nQtdVinc  := 0
	
	Default cFinalid := ""
	
	// Limpa a tabela temporária
	DbSelectArea(__cTabDCO)
	(__cTabDCO)->(DbSetorder(1))
	ZAP
	
	If Empty(cFinalid)
		cFinalid := Posicione("N9A",1,cFilCtr+cCodCtr+cItPrev+cRegFis, "N9A_CODFIN")
	EndIf
	
	cQry := OGX810QRY(1, cTMerc, cFilCtr, cCodCtr, cItPrev, cRegFis, cCodPro, cFilOrg, "", "", "", cCodEnt, cLojEnt, _cUFDest, cFinalid)
	
	cQry := ChangeQuery(cQry)
   
	cAliasDCO := GetNextAlias()			
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry),cAliasDCO, .F., .T.)
   
	DbselectArea(cAliasDCO)
	(cAliasDCO)->(DbGoTop())
   
	If !(cAliasDCO)->(Eof())
   		
		While !(cAliasDCO)->(Eof())
		
			If Empty((cAliasDCO)->N9W_EST)   				
   				// Valida se a UF da IE está dentro das regras do Aviso do PEPRO
   				If !OGX810VUF((cAliasDCO)->N9W_NUMAVI, _cUFDest, _cCidDest, "2")
   					(cAliasDCO)->(DbSkip())
   					LOOP
   				EndIf		   				
   			EndIf
   			
   			If Empty((cAliasDCO)->N9W_CODFIN)
   				
   				// Valida se a finalidade da IE está dentro das regras do Aviso do PEPRO
   				If !OGX810VFN((cAliasDCO)->N9W_NUMAVI, cFinalid)
   					(cAliasDCO)->(DbSkip())
   					LOOP
   				EndIf   				
   			EndIf
   			
   			If !Empty(cCodIE)
   			
	   			nQtdVinc := GetDataSql(" SELECT SUM(NLN.NLN_QTDVIN) " +;
								       "   FROM " + RetSQLName("NLN") + " NLN " +;
								       "  WHERE NLN.NLN_NUMAVI = '" + (cAliasDCO)->N9W_NUMAVI + "' " +;
								       "    AND NLN.NLN_NUMDCO = '" + (cAliasDCO)->N9W_NUMDCO + "' " +;
								       "    AND NLN.NLN_SEQDCO = '" + (cAliasDCO)->N9W_SEQEST + "' " +;
								       "    AND NLN.NLN_CODINE NOT IN ('" + cCodIE + "', ' ') " +;							       
								       "    AND NLN.D_E_L_E_T_ = ' ' ")
			Else
				
				nQtdVinc := GetDataSql(" SELECT SUM(NLN.NLN_QTDVIN) " +;
								       "   FROM " + RetSQLName("NLN") + " NLN " +;
								       "  WHERE NLN.NLN_NUMAVI = '" + (cAliasDCO)->N9W_NUMAVI + "' " +;
								       "    AND NLN.NLN_NUMDCO = '" + (cAliasDCO)->N9W_NUMDCO + "' " +;
								       "    AND NLN.NLN_SEQDCO = '" + (cAliasDCO)->N9W_SEQEST + "' " +;
								       "    AND NLN.NLN_CODCTR != '" + cCodCtr + "' " +;
								       "    AND NLN.NLN_CODINE = ' ' " +;							       
								       "    AND NLN.D_E_L_E_T_ = ' ' ")
				
			EndIf
   			
   			If RecLock(__cTabDCO, .T.)
   				(__cTabDCO)->T_NUMAVI := (cAliasDCO)->N9W_NUMAVI
   				(__cTabDCO)->T_NUMDCO := (cAliasDCO)->N9W_NUMDCO
   				(__cTabDCO)->T_SEQEST := (cAliasDCO)->N9W_SEQEST
   				(__cTabDCO)->T_QTDSDO := (cAliasDCO)->N9W_QUANT - nQtdVinc
   				(__cTabDCO)->T_QTDVNC := 0
   				
   				For nX := 1 to Len(_aPrecos)
   					
   					(__cTabDCO)->&("T_VPRC"+cValToChar(nX)) := 0
   					(__cTabDCO)->&("T_FPRC"+cValToChar(nX)) := 0
   					
   				Next nX
   				
   				(__cTabDCO)->(MsUnlock())
   			EndIf
   			   			
   			(cAliasDCO)->(DbSkip())		   			
   		EndDo		
   		
   	EndIf
   
   	(cAliasDCO)->(DbCloseArea())

Return .T.
