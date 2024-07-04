#INCLUDE "OGA251A.ch"
#INCLUDE 'PROTHEUS.ch'
#INCLUDE "FWMVCDEF.CH"

Static __cTabRem  := ""
Static __cNamRem  := ""
Static __oBrwRem  := Nil
Static oModelNJJ  := {}
Static oModelN9E  := {}
Static nOperation := 0

/*{Protheus.doc} OG251ARREM
Retorno da remessa formação de lote

@author francisco.nunes
@since 17/05/2018
@version 1.0
@type function
*/
Function OG251ARREM(oModel)
	
	nOperation := oModel:GetOperation()
	oModelNJJ  := oModel:GetModel("NJJUNICO")
	oModelN9E  := oModel:GetModel("N9EUNICO")
		
	If oModelNJJ:GetValue('NJJ_TIPO') != "7" // Devolução de Remessa
		MsgAlert(STR0002, STR0001) // "Opção disponível apenas para devolução de remessa" # Atenção
		Return .F.
	EndIf

	If Empty(oModelNJJ:GetValue('NJJ_ENTENT')) .OR. Empty(oModelNJJ:GetValue('NJJ_ENTLOJ')) .OR. Empty(oModelNJJ:GetValue('NJJ_CODPRO'))
		MsgAlert(STR0003, STR0001) // "Os campos Entidade, Loja e Código do Produto são necessário para vínculo das NFs de Remessa" # Atenção
		Return .F.
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
	Local aCoors     := FWGetDialogSize(oMainWnd)
	Local oDlg	     := Nil
	Local oFWL		 := Nil
	Local aSize		 := Nil
	Local oSize1     := Nil
	Local oSize2     := Nil
	Local oSize3     := Nil
	Local oPnl1      := Nil
	Local oPnlWnd1	 := Nil
	Local oPnlWnd2	:= Nil
	Local aFilBrwRem := {}		
	Local nCont		 := 0	
	Local nOpcX	     := 1	
	Local aHeader	 := {}
	Local lRetorno   := .T.
	Local lReadOnly  := .T.
	Local cReadVar   := ""
	Local aIndSeek	 := {}
	Local aCpsRemSk  := {}
	Local nCol		 := 1
	Local nPosFil	 := 0
	Local cCmpsTit	 := ""
	Local nCmpsTam	 := 0
	
	Private _nTotNFs  := 0	// Variavel totalizador da quantidade de retorno das NFs
	Private _nSldVinc := 0  // Variável para saldo dos vinculos com os retornos
	Private _nQtdVinc := 0	// Variavel totalizador de retornos vinculadas
		
	// Estrutura da tabela temporária de notas fiscais de remessa	
	AAdd(aStrcRem, {RetTitle("N9I_DOC"),    "T_DOC",    TamSX3("N9I_DOC")[3],    TamSX3("N9I_DOC") [1],   TamSX3("N9I_DOC") [2],   PesqPict("N9I","N9I_DOC")})
	AAdd(aStrcRem, {RetTitle("N9I_SERIE"),  "T_SERIE",  TamSX3("N9I_SERIE")[3],  TamSX3("N9I_SERIE")[1],  TamSX3("N9I_SERIE")[2],  PesqPict("N9I","N9I_SERIE")})	
	AAdd(aStrcRem, {RetTitle("N9I_ITEDOC"), "T_ITEDOC", TamSX3("N9I_ITEDOC")[3], TamSX3("N9I_ITEDOC")[1], TamSX3("N9I_ITEDOC")[2], PesqPict("N9I","N9I_ITEDOC")})
	AAdd(aStrcRem, {RetTitle("N9I_DOCEMI"), "T_DOCEMI", TamSX3("N9I_DOCEMI")[3], TamSX3("N9I_DOCEMI")[1], TamSX3("N9I_DOCEMI")[2], PesqPict("N9I","N9I_DOCEMI")})
	AAdd(aStrcRem, {STR0004, "T_QTDRET", TamSX3("N9I_QTDSLR")[3], TamSX3("N9I_QTDSLR")[1], TamSX3("N9I_QTDSLR")[2], PesqPict("N9I","N9I_QTDSLR")}) // Qtd. Ret.
	AAdd(aStrcRem, {STR0005, "T_QTDSEL", TamSX3("N9I_QTDSLR")[3], TamSX3("N9I_QTDSLR")[1], TamSX3("N9I_QTDSLR")[2], PesqPict("N9I","N9I_QTDSLR")}) // Qtd. Sel.
	AAdd(aStrcRem, {STR0006, "T_SLDRET", TamSX3("N9I_QTDSLR")[3], TamSX3("N9I_QTDSLR")[1], TamSX3("N9I_QTDSLR")[2], PesqPict("N9I","N9I_QTDSLR")}) // Sld. Ret.		
	AAdd(aStrcRem, {RetTitle("N9I_CLIFOR"), "T_CLIFOR", TamSX3("N9I_CLIFOR")[3], TamSX3("N9I_CLIFOR")[1], TamSX3("N9I_CLIFOR")[2], PesqPict("N9I","N9I_CLIFOR")})
	AAdd(aStrcRem, {RetTitle("N9I_LOJA"),   "T_LOJA",   TamSX3("N9I_LOJA")[3],   TamSX3("N9I_LOJA")[1],   TamSX3("N9I_LOJA")[2],   PesqPict("N9I","N9I_LOJA")})		
	AAdd(aStrcRem, {RetTitle("N9I_FILORG"), "T_FILORG", TamSX3("N9I_FILORG")[3], TamSX3("N9I_FILORG")[1], TamSX3("N9I_FILORG")[2], PesqPict("N9I","N9I_FILORG")})
	AAdd(aStrcRem, {RetTitle("N9I_CODINE"), "T_CODINE", TamSX3("N9I_CODINE")[3], TamSX3("N9I_CODINE")[1], TamSX3("N9I_CODINE")[2], PesqPict("N9I","N9I_CODINE")})
	AAdd(aStrcRem, {RetTitle("N7Q_DESINE"), "T_DESINE", TamSX3("N7Q_DESINE")[3], TamSX3("N7Q_DESINE")[1], TamSX3("N7Q_DESINE")[2], PesqPict("N7Q","N7Q_DESINE")})
	AAdd(aStrcRem, {RetTitle("N9I_CTRREM"), "T_CTRREM", TamSX3("N9I_CTRREM")[3], TamSX3("N9I_CTRREM")[1], TamSX3("N9I_CTRREM")[2], PesqPict("N9I","N9I_CTRREM")})
	AAdd(aStrcRem, {RetTitle("N9I_ETGREM"), "T_ETGREM", TamSX3("N9I_ETGREM")[3], TamSX3("N9I_ETGREM")[1], TamSX3("N9I_ETGREM")[2], PesqPict("N9I","N9I_ETGREM")})
	AAdd(aStrcRem, {RetTitle("N9I_REFREM"), "T_REFREM", TamSX3("N9I_REFREM")[3], TamSX3("N9I_REFREM")[1], TamSX3("N9I_REFREM")[2], PesqPict("N9I","N9I_REFREM")})
		
	// Definição dos índices da tabela
	aIndRem := {{"ORDER", "T_DOCEMI"}, {"CHAVE","T_DOC,T_SERIE,T_CLIFOR,T_LOJA,T_ITEDOC"}, {"SELEC", "T_OK"}}
		
	Processa({|| OG710ACTMP(@__cTabRem, @__cNamRem, aStrcRem, aIndRem)}, STR0007) // Aguarde. Carregando a tela
		
	// Carrega os registros das tabelas temporárias de Filiais e Remessas	
	Processa({|| InsRegRem()}, STR0008) // Aguarde. Selecionando notas fiscais de remessa disponíveis para retorno

	/************* TELA PRINCIPAL ************************/
	aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0009, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // Vincular NFs de Remessa

	// Desabilita o fechamento da tela através da tela ESC.
	oDlg:lEscClose := .F.

	oPnl1:= tPanel():New(oSize1:aPosObj[1,1], oSize1:aPosObj[1,2],, oDlg,,,,,, oSize1:aPosObj[1,4], oSize1:aPosObj[1,3] - 30)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init(oPnl1, .F.)

	// Cria as divisões horizontais
	oFWL:addLine('MASTER', 100, .F.)
	oFWL:addCollumn('CENTER', 100, .F., 'MASTER')

	//cria as janelas
	oFWL:addWindow('CENTER', 'Wnd1', STR0010, 25/*tamanho*/, .F., .T.,, 'MASTER') //"Total das Remessas"
	oFWL:addWindow('CENTER', 'Wnd2', STR0011, 75/*tamanho*/, .F., .T.,, 'MASTER') //"Remessas"
	
	oPnlWnd1 := oFWL:getWinPanel('CENTER', 'Wnd1', 'MASTER')
	oPnlWnd2 := oFWL:getWinPanel('CENTER', 'Wnd2', 'MASTER')
	
	/***********************************************************/
	
	//- Recupera coordenadas 
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject(STR0010,100,100,.T.,.T.) // Total das Remessas
	oSize2:SetWindowSize({0,0,oPnlWnd1:NHEIGHT, oPnlWnd1:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()
		
	//Cria campos totalizadores - Qtd. Fiscal
	oSay1  := TSay():New(001, 001, {|| STR0012}, oPnlWnd1,,,,,,.T., CLR_BLACK, CLR_WHITE, 050, 020) // Qtd. Fiscal
	oTGet1 := TGet():New(011, 001, bSetGet(_nTotNFs),   oPnlWnd1, 136, 010, PesqPict("N9I","N9I_QTDSLR"), { || .t. } /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {||.F. } /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| .T. } /*bChange*/, .T. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/,.T.,.F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
	
	//Cria campos totalizadores - Saldo a vincular
	oSay2  := TSay():New(001, 141, {|| STR0013}, oPnlWnd1,,,,,,.T., CLR_BLACK, CLR_WHITE, 080, 020) // Saldo a vincular
	oTGet2 := TGet():New(011, 141, bSetGet(_nSldVinc),  oPnlWnd1, 136, 010, PesqPict("N9I","N9I_QTDSLR"), { || .t. } /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, .F. /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {|| .F. } /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| .T. } /*bChange*/, .T. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, .T., .F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		lReadOnly := .F.
		cReadVar  := "_nQtdVinc"
	EndIf
	
	//Cria campos totalizadores - Quantidade vinculada
	oSay3  := TSay():New(001, 281, {|| STR0014}, oPnlWnd1,,,,,,.T., CLR_BLACK, CLR_WHITE, 080, 020) // Quantidade vinculada
	oTGet3 := TGet():New(011, 281, bSetGet(_nQtdVinc),  oPnlWnd1, 136, 010, PesqPict("N9I","N9I_QTDSLR"), { || .t. } /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, .F. /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {|| .T. } /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| .T. } /*bChange*/, lReadOnly /*lReadOnly*/, /*lPassword*/, /*uParam23*/, cReadVar /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, .T., .F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		//Cria o botão
		TButton():New(011, 421, STR0015, oPnlWnd1,{|| VldQtdTot()},,,,,,.T.,,) // Vincular remessas
	EndIf
		
	/****************** REMESSAS ********************************/
	
	aHeader := {}
	
	nPosFil := AScan(aIndRem, {|x| AllTrim(x[1]) == "CHAVE"})
	cChave  := aIndRem[nPosFil][2]
	
	For nCont := 2 to Len(aStrcRem)
	
		If !aStrcRem[nCont][2] $ "N9I_FILORG|N9I_CODINE" .AND. At(aStrcRem[nCont][2], cChave) > 0
			If !Empty(cCmpsTit)
				cCmpsTit += "+"
			EndIf
			
			cCmpsTit += AllTrim(aStrcRem[nCont][1])
			nCmpsTam += aStrcRem[nCont][4]			
		EndIf
				
		Aadd(aCpsRemSk, {aStrcRem[nCont][2], aStrcRem[nCont][3], aStrcRem[nCont][4], aStrcRem[nCont][5], aStrcRem[nCont][1], aStrcRem[nCont][6]})
	 	
	 	// Monta as colunas
	    If !aStrcRem[nCont][2] $ "N9I_CODINE|N9I_CTRREM|N9I_ETGREM|N9I_REFREM" // Não mostra os campos no browse	    	   
	    	AAdd(aHeader,FWBrwColumn():New())
			aHeader[nCol]:SetData(&("{||"+aStrcRem[nCont][2]+"}"))
			aHeader[nCol]:SetTitle(aStrcRem[nCont][1])
			aHeader[nCol]:SetPicture(aStrcRem[nCont][6])
			aHeader[nCol]:SetType(aStrcRem[nCont][3])
			aHeader[nCol]:SetSize(aStrcRem[nCont][4])
			aHeader[nCol]:SetReadVar(aStrcRem[nCont][2])
			nCol++
							   	    	
	    	Aadd(aFilBrwRem, {aStrcRem[nCont][2], aStrcRem[nCont][1], aStrcRem[nCont][3], aStrcRem[nCont][4], aStrcRem[nCont][5], aStrcRem[nCont][6]})    	    
	    EndIf	    
    Next nCont
	
	//- Recupera coordenadas 
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject(STR0011,100,100,.T.,.T.) //"Remessas"
	oSize3:SetWindowSize({0, 0, oPnlWnd2:NHEIGHT, oPnlWnd2:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {0,0,0,0}
	oSize3:Process()
					                       
	__oBrwRem := FWFormBrowse():New()
	__oBrwRem:SetOwner(oPnlWnd2)
	__oBrwRem:SetDataTable(.T.)
	__oBrwRem:SetTemporary(.T.)
    __oBrwRem:SetAlias(__cTabRem)
    __oBrwRem:SetProfileID("REM")    
                
    // Filtro
    __oBrwRem:SetUseFilter(.T.)
	__oBrwRem:SetUseCaseFilter(.T.)                         
    __oBrwRem:SetFieldFilter(aFilBrwRem)   
    __oBrwRem:SetDBFFilter(.T.)
          
    __oBrwRem:Acolumns := {}
    __oBrwRem:AddMarkColumns({||IIf((__cTabRem)->T_OK == "1", "LBOK", "LBNO")}, {|| MarkBrw(__oBrwRem, "R")}, {|| MarkAllBrw(__oBrwRem, "R")})
        
	Aadd(aIndSeek,{cCmpsTit ,{{"", 'C' , nCmpsTam, 0 , "@!" }}, 2, .T.})
    
	__oBrwRem:SetSeek(,aIndSeek)
	__oBrwRem:SetColumns(aHeader)
	
	// Habilitar edição no campo de Quantidade vinculada
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE    	    
		__oBrwRem:SetEditCell( .T. , {|lCancel, oBrowse| VldQtdRem(lCancel, oBrowse)})
		__oBrwRem:acolumns[7]:SetEdit(.T.)
		__oBrwRem:acolumns[7]:SetReadVar('T_QTDSEL')
	EndIf
    
    __oBrwRem:DisableReport(.T.)
    __oBrwRem:DisableDetails()
    __oBrwRem:Activate()
	
	oDlg:Activate(,,, .T.,,, EnchoiceBar(oDlg, {|| nOpcX := 1, ODlg:End()} /*OK*/, {|| nOpcX := 0, oDlg:End()} /*Cancel*/ ) )
	
	If nOpcX = 1 .AND. nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		Processa({|| lRetorno := VincRom()}, STR0016) // Aguarde. Vinculando notas fiscais de remessa no romaneio.
	
		If !lRetorno
	 		Return .F.
	 	EndIf		
	EndIf
		
Return .T.

/*{Protheus.doc} MarkBrw
Seleção individual Filiais / Remessas

@author francisco.nunes
@since  16/05/2018
@version 1.0
@param oBrwObj, object, Objeto do browser marcado
@param cBrwName, characters, Nome do browser ("F"=Filiais;"R"=Remessas)
@type function
*/
Static Function MarkBrw(oBrwObj, cBrwName)
	Local lMarcar := .F.
	
	If nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
	
	If Empty((oBrwObj:Alias())->(T_OK))
		lMarcar := .T.				
	EndIf
		
	/* Atualiza a grid de Remessas */
	AtualizRem(oBrwObj:Alias(), cBrwName, lMarcar)
	
	/* Atualiza os totais */
	AtualizTot()
				
	oBrwObj:SetFocus() 
	oBrwObj:GoColumn(1)

Return .T.

/*{Protheus.doc} MarkAllBrw
Seleção de todos os itens do browse [Filiais / Remessas]

@author francisco.nunes
@since  16/05/2018
@version 1.0
@param oBrwObj, object, Objeto do browser marcado
@param cBrwName, characters, Nome do browser ("F"=Filiais;"R"=Remessas)
@type function
*/
Static function MarkAllBrw(oBrwObj, cBrwName)
	Local lMarcar := .F.
	
	If nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
		
	(oBrwObj:Alias())->(DbGoTop())	
	lMarcar := IIf((oBrwObj:Alias())->T_OK == "1", .F., .T.)
	
	If lMarcar
		_nQtdVinc := 0
	EndIf
	
	While !(oBrwObj:Alias())->(Eof())		
		/* Atualiza a grid de Remessas */
		AtualizRem(oBrwObj:Alias(), cBrwName, lMarcar,,,.T.)
	
		(oBrwObj:Alias())->(DbSkip())
	EndDo
	
	/* Atualiza os totais */
	AtualizTot()
				
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
@param lQtdMan, logical, .T. - Digitado quantidade vinculada
@param nQtdMax, number, quantidade máxima (selecionada) - utilizada para quando informa uma quantidade manualmente na grid de filiais
@param lMarcarT, logical, .T. - Marcar todos;
@type function
*/
Static Function AtualizRem(cAliasBrw, cBrwName, lMarcar, lQtdMan, nQtdMax, lMarcarT)
	Local aAreaRem := (__cTabRem)->(GetArea())
	Local nQtdVin  := 0
	Local nQRemSel := 0
	
	Default lQtdMan  := .F.
	Default nQtdMax  := 0
	Default lMarcarT := .F.
			
	If cBrwName == "R" // Browser Remessas
			
		nQRemSel := (cAliasBrw)->T_QTDRET
	
		If lQtdMan			
			nQRemSel := nQtdMax
			
			If nQRemSel = 0			
				lMarcar  := .F.
			EndIf
		Else
			If lMarcar .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2" .AND. _nTotNFs < _nQtdVinc + (__cTabRem)->T_QTDRET
				nQRemSel := nQRemSel - ((_nQtdVinc + nQRemSel) - _nTotNFs)
			EndIf
		EndIf
		
		If nQRemSel = 0
			lMarcar := .F.
		EndIf
		
		If lMarcarT .AND. lMarcar
			_nQtdVinc += nQRemSel
		EndIf
	
		If RecLock(cAliasBrw, .F.)
			(cAliasBrw)->T_OK     := IIf(lMarcar, "1", "")
			(cAliasBrw)->T_QTDSEL := IIf(lMarcar, nQRemSel, 0)
			(cAliasBrw)->T_SLDRET := (cAliasBrw)->T_QTDRET - (cAliasBrw)->T_QTDSEL
				
			(cAliasBrw)->(MsUnlock())
		EndIf	
	EndIf
	
	If cBrwName == "F" // Browser Filiais
								
		DbSelectArea(__cTabRem)
		(__cTabRem)->(DbGoTop())
		While (__cTabRem)->(!Eof())
			
			nQRemSel := (__cTabRem)->T_QTDRET
			
			If lQtdMan // Se foi digitado a quantidade vinculada na grid de Filiais
				If lMarcar .AND. nQtdMax < nQtdVin + (__cTabRem)->T_QTDRET
					nQRemSel := (__cTabRem)->T_QTDRET - ((nQtdVin + (__cTabRem)->T_QTDRET) - nQtdMax)
				EndIf
			Else
				If lMarcar .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2" .AND. _nTotNFs < nQtdVin + (__cTabRem)->T_QTDRET
					nQRemSel := (__cTabRem)->T_QTDFIS - ((nQtdVin + (__cTabRem)->T_QTDFIS) - _nTotNFs)
				EndIf 			
			EndIf
			
			If nQRemSel = 0			
				lMarcar  := .F.
			EndIf
			
			If RecLock(__cTabRem, .F.)
				(__cTabRem)->T_OK     := IIf(lMarcar, "1", "")
				(__cTabRem)->T_QTDSEL := IIf(lMarcar, nQRemSel, 0)
				(__cTabRem)->T_SLDRET := (__cTabRem)->T_QTDRET - (__cTabRem)->T_QTDSEL
					
				(__cTabRem)->(MsUnlock())
			EndIf
			
			nQtdVin += nQRemSel
			
			(__cTabRem)->(DbSkip())
		EndDo					
	EndIf
	
	RestArea(aAreaRem)

Return .T.

/*{Protheus.doc} AtualizTot
Atualiza os totais

@author francisco.nunes
@since  17/05/2018
@version 1.0
@type function
*/
Static Function AtualizTot()	
	Local aAreaRem := (__cTabRem)->(GetArea())
	Local cQuery   := ""	
	
	_nQtdVinc := 0
	_nSldVinc := _nTotNFs 
	
	cQuery := " SELECT SUM(T_QTDSEL) AS QTREMSEL "
	cQuery += " FROM "+ __cNamRem + " REM "

	MPSysOpenQuery(cQuery, 'QRYQREM')
	
	DbSelectArea('QRYQREM')
	While ('QRYQREM')->(!Eof())
	
		_nQtdVinc += ('QRYQREM')->(FieldGet(1))
		_nSldVinc -= ('QRYQREM')->(FieldGet(1))
					
		('QRYQREM')->(DbSkip())
	EndDo	
	('QRYQREM')->(DbCloseArea())
	
	If _nSldVinc < 0
		_nSldVinc := 0
	EndIf
		
	oTGet2:Refresh()
	oTGet3:Refresh()
	
	RestArea(aAreaRem)
	
Return .T.

/*{Protheus.doc} VldQtdTot
Valida a quantidade informada nos totais e atualiza as remessas 

@type function
@author francisco.nunes
@since  02/05/2018
@version 1.0
@return lRetorno
*/
Static Function VldQtdTot()
			
	If _nQtdVinc < 0 
		MsgAlert(STR0017, STR0001) // "A quantidade informada é inválida." ## "Atenção"
		oTGet3:SetFocus()
		Return .F.
	EndIf 
		
	If _nQtdVinc > _nTotNFs .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2"
		MsgAlert(STR0018, STR0001) // "A quantidade informada é maior que a soma das quantidades das remessas." ## "Atenção"
		oTGet3:SetFocus()
		Return .F.
	EndIf
		
	/* Atualiza a grid de Remessa */
	/* Será marcado as remessas até a quantidade selecionada informada */
	AtualizRem("", "F", .T., .T., _nQtdVinc)
	
	/* Atualiza os totais */
	AtualizTot()
			
	__oBrwRem:Refresh(.T.)	

Return .T.

/*{Protheus.doc} VldQtdRem
Valida a quantidade vinculada informada manualmente no browse "Remessas" 

@type function
@author francisco.nunes
@since  07/05/2018
@version 1.0
@param lCancel, logical, Indica se a operação de digitação foi cancelada
@param oBrwObj, object, Objeto do browse alterado
@return lRetorno
*/
Static Function VldQtdRem(lCancel, oBrwObj)

	Local nQtdSel  := 0
	Local aAreaRem := (__cTabRem)->(GetArea())
	Local cDoc	   := ""
	Local cSerie   := ""
	Local cCliFor  := ""
	Local cLoja	   := ""
	Local cItDoc   := ""
	Local cFilIE   := ""
	Local cCodIE   := ""

	If lCancel
		Return .T.
	EndIf
	
	If (oBrwObj:Alias())->T_QTDSEL < 0 
		MsgAlert(STR0019, STR0001) // "A quantidade informada para a remessa é inválida." ## "Atenção"
		Return .F.
	EndIf
	
	If (oBrwObj:Alias())->T_QTDSEL > (oBrwObj:Alias())->T_QTDRET
		MsgAlert(STR0020, STR0001) // "A quantidade informada é maior que a quantidade a retornar." ## "Atenção" 
		Return .F.
	EndIf
	
	cDoc    := (oBrwObj:Alias())->T_DOC
	cSerie  := (oBrwObj:Alias())->T_SERIE
	cCliFor := (oBrwObj:Alias())->T_CLIFOR
	cLoja   := (oBrwObj:Alias())->T_LOJA
	cItDoc  := (oBrwObj:Alias())->T_ITEDOC
	cFilIE  := (oBrwObj:Alias())->T_FILORG
	cCodIE  := (oBrwObj:Alias())->T_CODINE	
	
	// Busca na tabela temporária de remessas a quantidade vinculada
	DbSelectArea(__cTabRem)
	(__cTabRem)->(DbSetOrder(3))
	If (__cTabRem)->(DbSeek("1"))
		While (__cTabRem)->(!Eof()) .AND. (__cTabRem)->(T_OK) == "1"
			If (__cTabRem)->T_DOC != cDoc .OR. (__cTabRem)->T_SERIE != cSerie .OR. (__cTabRem)->T_CLIFOR != cCliFor .OR.;
			   (__cTabRem)->T_LOJA != cLoja .OR. (__cTabRem)->T_ITEDOC != cItDoc .OR. (__cTabRem)->T_FILORG != cFilIE .OR.;
			   (__cTabRem)->T_CODINE != cCodIE
				nQtdSel += (__cTabRem)->T_QTDSEL
			EndIf
			
			(__cTabRem)->(DbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaRem)
	
	If (oBrwObj:Alias())->T_QTDSEL + nQtdSel > _nTotNFs .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2"
		MsgAlert(STR0021, STR0001) // "A quantidade informada é maior que a quantidade fiscal." ## "Atenção"
		Return .F.
	EndIf
			
	/* Atualiza a grid de Remessa */
	/* Será marcado as remessas até a quantidade selecionada informada */
	AtualizRem(oBrwObj:Alias(), "R", .T., .T., (oBrwObj:Alias())->T_QTDSEL)
	
	/* Atualiza os totais */
	AtualizTot()
				
	__oBrwRem:LineRefresh()
			
	__oBrwRem:SetFocus()
			
Return .T.

/*{Protheus.doc} InsRegRem
Seleção das notas fiscais de remessa para retorno

@author francisco.nunes
@since  17/05/2018
@version 1.0
@type function
*/
Static Function InsRegRem()
	Local cQuery     := ""
	Local cAliasN9I  := GetNextAlias()
	Local cQryInsert := ""
	Local nQtdRet	 := 0
	Local nX		 := 0
	Local nQtdSel	 := 0
	Local cMark		 := ""
						
	// Limpa a tabela temporária
	DbSelectArea(__cTabRem)
	(__cTabRem)->(DbSetorder(1))
	ZAP
	
	_nQtdVinc := 0
	
	If oModelNJJ:GetValue('NJJ_TPFORM') == "2" // Formulário Próprio = Não
		_nTotNFs  := oModelNJJ:GetValue('NJJ_QTDFIS')
		_nSldVinc := oModelNJJ:GetValue('NJJ_QTDFIS')
	EndIf
	    
    // Monta a query de busca
    cQuery := "SELECT N9I.N9I_FILIAL AS FILIAL, "
	cQuery += " 	  N9I.N9I_DOC    AS DOC, "
	cQuery += " 	  N9I.N9I_SERIE  AS SERIE, "
	cQuery += " 	  N9I.N9I_CLIFOR AS CLIFOR, "
	cQuery += " 	  N9I.N9I_LOJA   AS LOJA, "
	cQuery += " 	  N9I.N9I_ITEDOC AS ITEDOC, "	
	cQuery += " 	  N9I.N9I_DOCEMI AS DOCEMI, "
	cQuery += " 	  N9I.N9I_FILORG AS FILIE, "
	cQuery += " 	  N9I.N9I_CODINE AS CODINE, "	
	cQuery += " 	  N9I.N9I_CTRREM AS CTRREM, "
	cQuery += " 	  N9I.N9I_ETGREM AS ETGREM, "
	cQuery += " 	  N9I.N9I_REFREM AS REFREM, "
	cQuery += " 	  N7Q.N7Q_DESINE AS DESINE, "
	cQuery += " 	  N7Q.N7Q_TPMERC AS TPMERC, "
	cQuery += "       SUM(CASE WHEN N9I.N9I_INDSLD = '0' THEN N9I.N9I_QTDSLR ELSE 0 END) AS QTDRETSLD, "
	cQuery += "       SUM(CASE WHEN N9I.N9I_INDSLD = '1' THEN N9I.N9I_QTDSLR ELSE 0 END) AS QTDRETIE, "
	cQuery += "       SUM(CASE WHEN N9I.N9I_INDSLD = '2' THEN N9I.N9I_QTDSLR ELSE 0 END) AS QTDRETCT "
	cQuery += " FROM " + RetSqlName("N9I") + " N9I "	
	cQuery += " LEFT JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_FILIAL = N9I.N9I_FILORG AND N7Q.N7Q_CODINE = N9I.N9I_CODINE AND N7Q.D_E_L_E_T_ = '' "
	
	If oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado
		cQuery += " INNER JOIN " + RetSqlName("N9E") + " N9E ON N9E.N9E_FILIAL = N9I.N9I_FILIAL AND N9E.N9E_FILIE = N9I.N9I_FILORG " 
		cQuery += " AND N9E.N9E_CODINE = N9I.N9I_CODINE AND N9E.N9E_DOC = N9I.N9I_DOC AND N9E.N9E_SERIE = N9I.N9I_SERIE AND N9E.N9E_CLIFOR = N9I.N9I_CLIFOR " 
		cQuery += " AND N9E.N9E_LOJA = N9I.N9I_LOJA AND N9E.N9E_ITEDOC = N9I.N9I_ITEDOC AND N9E.N9E_ORIGEM = '7' AND N9E.D_E_L_E_T_ = '' "
	EndIf
					
	cQuery += " WHERE N9I.D_E_L_E_T_ = '' "
	cQuery += "   AND N9I.N9I_INDSLD IN ('0','1','2') "// Saldo ou vinculado a IE ou container
		
	If !oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado
		cQuery += "   AND N9I.N9I_QTDSLR > 0 "
	EndIf
	
	cQuery += "   AND N9I.N9I_FILIAL = '"+FWxFilial("NJJ")+"' "
	cQuery += "   AND N9I.N9I_CODENT = '"+oModelNJJ:GetValue('NJJ_CODENT')+"' "
	cQuery += "   AND N9I.N9I_LOJENT = '"+oModelNJJ:GetValue('NJJ_LOJENT')+"' "
	cQuery += "   AND N9I.N9I_CODPRO = '"+oModelNJJ:GetValue('NJJ_CODPRO')+"' "		
	cQuery += "	GROUP BY N9I.N9I_FILIAL, N9I.N9I_DOC, N9I.N9I_SERIE, N9I.N9I_CLIFOR, N9I.N9I_LOJA, N9I.N9I_ITEDOC, N9I.N9I_DOCEMI, "
	cQuery += "	         N9I.N9I_FILORG, N9I.N9I_CODINE, N9I.N9I_CTRREM, N9I.N9I_ETGREM, N9I.N9I_REFREM, N7Q.N7Q_DESINE, N7Q.N7Q_TPMERC "
    cQuery += " ORDER BY N9I.N9I_DOCEMI "
    					         		        
	cQuery := ChangeQuery(cQuery)
	cAliasN9I := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasN9I,.F.,.T.)
		
	If (cAliasN9I)->(!EoF())
		While (cAliasN9I)->(!EoF())
			
			If !oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado	
			
				nQtdRet := (cAliasN9I)->QTDRETCT + (cAliasN9I)->QTDRETIE + (cAliasN9I)->QTDRETSLD
											
				If nQtdRet = 0
					(cAliasN9I)->(DbSkip())
					LOOP
				EndIf
			EndIf
			
			nQtdSel := 0
			
			For nX := 1 to oModelN9E:Length()
				If .Not. oModelN9E:IsDeleted()
					If oModelN9E:GetValue('N9E_DOC', nX) == (cAliasN9I)->DOC .AND. oModelN9E:GetValue('N9E_SERIE', nX) == (cAliasN9I)->SERIE .AND.;
					   oModelN9E:GetValue('N9E_CLIFOR', nX) == (cAliasN9I)->CLIFOR .AND. oModelN9E:GetValue('N9E_LOJA', nX) == (cAliasN9I)->LOJA .AND.;
					   oModelN9E:GetValue('N9E_ITEDOC', nX) == (cAliasN9I)->ITEDOC .AND. oModelN9E:GetValue('N9E_FILIE', nX) == (cAliasN9I)->FILIE .AND.;
					   oModelN9E:GetValue('N9E_CODINE', nX) == (cAliasN9I)->CODINE
					   nQtdSel := oModelN9E:GetValue('N9E_QTDRET', nX)
					   EXIT
					EndIf			
				EndIf	
			Next nX
			
			If oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado
				If nQtdSel = 0
					(cAliasN9I)->(DbSkip())
					LOOP
				EndIf
			EndIf
			
			cMark := " "
			
			If nQtdSel > 0
				cMark := "1"
			EndIf
			
			_nQtdVinc += nQtdSel
			_nSldVinc -= nQtdSel
																					
			cQryInsert := "('"+(cAliasN9I)->DOC+"', '"+(cAliasN9I)->SERIE+"', '"+(cAliasN9I)->CLIFOR+"', '"+(cAliasN9I)->LOJA+"', '"+(cAliasN9I)->ITEDOC+"', '"+(cAliasN9I)->DOCEMI+"', '"+(cAliasN9I)->FILIE+"', '"+(cAliasN9I)->CODINE+"', '"+(cAliasN9I)->CTRREM+"', '"+(cAliasN9I)->ETGREM+"', '"+(cAliasN9I)->REFREM+"', '"+(cAliasN9I)->DESINE+"', '"+AllTrim(STR(nQtdRet))+"', '"+AllTrim(STR(nQtdSel))+"', '"+AllTrim(STR(nQtdRet))+"', '"+cMark+"') "
			TCSqlExec("INSERT INTO "+__cNamRem+" (T_DOC, T_SERIE, T_CLIFOR, T_LOJA, T_ITEDOC, T_DOCEMI, T_FILORG, T_CODINE, T_CTRREM, T_ETGREM, T_REFREM, T_DESINE, T_QTDRET, T_QTDSEL, T_SLDRET, T_OK) VALUES " + cQryInsert)
			
			(cAliasN9I)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasN9I)->(dbCloseArea())	
		
	// Refresh nos browsers
	TCRefresh(__cNamRem)
				
Return .T.

/*{Protheus.doc} VincRom
Vincula das NFs de Remessa no romaneio para Retorno da Formação de Lote

@author francisco.nunes
@since  17/05/2018
@type function
*/
Static Function VincRom()
	Local aAreaRem := (__cTabRem)->(GetArea())	
	Local lRet	   := .T.
	Local nI	   := 0
								
	For nI := 1 to oModelN9E:Length()
		oModelN9E:GoLine(nI)
		oModelN9E:DeleteLine()
	Next nI
	
	DbSelectArea((__cTabRem))
	(__cTabRem)->(DbGoTop())
	(__cTabRem)->(DbSetOrder(3)) // Remessas marcadas
	If (__cTabRem)->(DbSeek("1"))
								 
		While (__cTabRem)->(!Eof()) .AND. (__cTabRem)->T_OK == "1"
		
			oModelN9E:AddLine()
			oModelN9E:SetValue("N9E_ORIGEM", "7")
			oModelN9E:SetValue("N9E_FILIE", (__cTabRem)->T_FILORG)
			oModelN9E:SetValue("N9E_CODINE", (__cTabRem)->T_CODINE)
			oModelN9E:SetValue("N9E_CODCTR", (__cTabRem)->T_CTRREM)
			oModelN9E:SetValue("N9E_ITEM", (__cTabRem)->T_ETGREM)
			oModelN9E:SetValue("N9E_SEQPRI", (__cTabRem)->T_REFREM)
			oModelN9E:SetValue("N9E_DOC", (__cTabRem)->T_DOC)
			oModelN9E:SetValue("N9E_SERIE", (__cTabRem)->T_SERIE)
			oModelN9E:SetValue("N9E_CLIFOR", (__cTabRem)->T_CLIFOR)
			oModelN9E:SetValue("N9E_LOJA", (__cTabRem)->T_LOJA)
			oModelN9E:SetValue("N9E_ITEDOC", (__cTabRem)->T_ITEDOC)
			oModelN9E:SetValue("N9E_QTDRET", (__cTabRem)->T_QTDSEL)	
			
			(__cTabRem)->(DbSkip())	
		EndDo	
								
	EndIf	
			
	RestArea(aAreaRem)		
		
Return lRet

/*{Protheus.doc} OG251AQN9E
Retorna a quantidade vinculada na N9E com tipo "7 - Nota Referenciada"

@author francisco.nunes
@since  17/05/2018
@param cFilRom, Filial do Romaneio
@param cCodRom, Código do Romaneio
@type function
*/
Function OG251AQN9E(cFilRom, cCodRom)
	Local nQtN9E    := 0
	Local cAliasQry := ""
	Local cQry		:= ""
	
	cAliasQry := GetNextAlias()
	cQry := " SELECT SUM(N9E.N9E_QTDRET) AS QTDRET "
	cQry += "   FROM " + RetSqlName("N9E") + " N9E "
	cQry += "  WHERE N9E.N9E_FILIAL = '"+cFilRom+"' "
	cQry += "    AND N9E.N9E_CODROM = '"+cCodRom+"' "
	cQry += "    AND N9E.N9E_ORIGEM = '7' "  // Nota Referenciada
	cQry += "    AND N9E.D_E_L_E_T_ = '' "
	cQry := ChangeQuery(cQry)	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAliasQry, .F., .T.)
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
		nQtN9E := (cAliasQry)->QTDRET
	EndIf

Return nQtN9E
