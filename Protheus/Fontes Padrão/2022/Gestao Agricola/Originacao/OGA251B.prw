#INCLUDE "OGA251B.ch"
#INCLUDE 'PROTHEUS.ch'
#INCLUDE "FWMVCDEF.CH"

Static __cTabNFs  := ""
Static __cNamNFs  := ""
Static __oBrwNFs  := Nil
Static oModelNJJ  := {}
Static oModelN9E  := {}
Static nOperation := 0


/*{Protheus.doc} OG251BDEV
Vincular NFs de origem para devolução/retorno

@author francisco.nunes
@since 24/08/2018
@version 1.0
@type function
*/
Function OG251BDEV(oModel)

	oModelNJJ := oModel:GetModel("NJJUNICO")
	
	If !oModelNJJ:GetValue('NJJ_TIPO') $ "7|9"
		MsgAlert(STR0022, STR0001) // "Opção disponível apenas para devolução ou retorno de remessa" # Atenção
		Return .F.
	EndIf
	
	If oModelNJJ:GetValue('NJJ_TIPO') == "7"
		// Retorno formação de lote
		OG251ARREM(oModel)
	Else
		// Devolução de venda
		OG251BDNFS(oModel)
	EndIf
	
Return .T.	


/*{Protheus.doc} OG251BDNFS
Vincular NFs de origem para devolução

@author francisco.nunes
@since 23/08/2018
@version 1.0
@type function
*/
Function OG251BDNFS(oModel)
	
	Local bKeyF12 := ""
	
	nOperation := oModel:GetOperation()
	oModelNJJ  := oModel:GetModel("NJJUNICO")
	oModelN9E  := oModel:GetModel("N9EUNICO")
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		bKeyF12 := SetKey(VK_F12, {|| AtuBrwF12()})
	EndIf
		
	If oModelNJJ:GetValue('NJJ_TIPO') != "9" // Devolução de Venda
		MsgAlert(STR0002, STR0001) // "Opção disponível apenas para devolução de venda" # Atenção
		Return .F.
	EndIf

	If oModelNJJ:GetValue('NJJ_TPFORM') == "2" .AND. (Empty(oModelNJJ:GetValue('NJJ_CODENT')) .OR. Empty(oModelNJJ:GetValue('NJJ_LOJENT')) .OR. Empty(oModelNJJ:GetValue('NJJ_CODPRO')) )
		MsgAlert(STR0003, STR0001) // "Os campos Entidade, Loja e Código do Produto são necessários para o vínculo das NFs de venda" # Atenção
		Return .F.
	ElseIf oModelNJJ:GetValue('NJJ_TPFORM') == "1" .AND. Empty(oModelNJJ:GetValue('NJJ_CODPRO'))
		MsgAlert(STR0024, STR0001) // ###"O campo Código do Produto é necessário para o vínculo das NFs de venda"
		Return .F.
	EndIf
						
	CriaBrowse()
		
Return .T.

/*{Protheus.doc} AtuBrwF12
Função chamada clicando no F12

@author francisco.nunes
@since 24/08/2018
@version 1.0
@type function
*/
Static Function AtuBrwF12()
	
	Local lProc := .F.

	lProc := InsRegNFs(.T.)
	
	If lProc
		__oBrwNFs:UpdateBrowse() // Atualiza os itens do browser
		__oBrwNFs:Refresh() // Aplica o Refresh no browser
	EndIf

Return .F.

/*{Protheus.doc} CriaBrowse
Cria browse das notas fiscais de venda para devolução

@author francisco.nunes
@since 23/08/2018
@version 1.0
@type function
*/
Static Function CriaBrowse()	
	Local aStrcNFs   := {{"", "T_OK", "C", 1,, "@!"}}
	Local aIndNFs    := {}	
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
	Local aFilBrwNFs := {}		
	Local nCont		 := 0	
	Local nOpcX	     := 1	
	Local aHeader	 := {}
	Local lRetorno   := .T.
	Local lReadOnly  := .T.
	Local cReadVar   := ""
	Local aIndSeek	 := {}
	Local aCpsNFsSk  := {}
	Local nCol		 := 1
	Local nPosFil	 := 0
	Local cCmpsTit	 := ""
	Local nCmpsTam	 := 0
	
	Private _nTotNFs  := 0	// Variavel totalizador da quantidade de devolução das NFs
	Private _nSldVinc := 0  // Variável para saldo dos vinculos com as devoluções
	Private _nQtdVinc := 0	// Variavel totalizador de nota fiscais vinculadas
		
	// Estrutura da tabela temporária de notas fiscais de origem	
	AAdd(aStrcNFs, {RetTitle("D2_DOC"),     "T_DOC",    TamSX3("D2_DOC")[3],     TamSX3("D2_DOC") [1],    TamSX3("D2_DOC") [2],    PesqPict("SD2","D2_DOC")})
	AAdd(aStrcNFs, {RetTitle("D2_SERIE"),   "T_SERIE",  TamSX3("D2_SERIE")[3],   TamSX3("D2_SERIE")[1],   TamSX3("D2_SERIE")[2],   PesqPict("SD2","D2_SERIE")})	
	AAdd(aStrcNFs, {RetTitle("D2_ITEM"),    "T_ITEDOC", TamSX3("D2_ITEM")[3],    TamSX3("D2_ITEM")[1],    TamSX3("D2_ITEM")[2],    PesqPict("SD2","D2_ITEM")})
	AAdd(aStrcNFs, {RetTitle("D2_EMISSAO"), "T_DOCEMI", TamSX3("D2_EMISSAO")[3], TamSX3("D2_EMISSAO")[1], TamSX3("D2_EMISSAO")[2], PesqPict("SD2","D2_EMISSAO")})
	AAdd(aStrcNFs, {STR0014,            	"T_QTDRET", TamSX3("D2_QUANT")[3],   TamSX3("D2_QUANT")[1],   TamSX3("D2_QUANT")[2],   PesqPict("SD2","D2_QUANT")}) // Qtd. Ret.
	AAdd(aStrcNFs, {STR0015,            	"T_QTDSEL", TamSX3("D2_QUANT")[3],   TamSX3("D2_QUANT")[1],   TamSX3("D2_QUANT")[2],   PesqPict("SD2","D2_QUANT")}) // Qtd. Sel.
	AAdd(aStrcNFs, {STR0016,            	"T_SLDRET", TamSX3("D2_QUANT")[3],   TamSX3("D2_QUANT")[1],   TamSX3("D2_QUANT")[2],   PesqPict("SD2","D2_QUANT")}) // Sld. Ret.		
	AAdd(aStrcNFs, {RetTitle("D2_CLIENTE"), "T_CLIENT", TamSX3("D2_CLIENTE")[3], TamSX3("D2_CLIENTE")[1], TamSX3("D2_CLIENTE")[2], PesqPict("SD2","D2_CLIENTE")})
	AAdd(aStrcNFs, {RetTitle("D2_LOJA"),    "T_LOJA",   TamSX3("D2_LOJA")[3],    TamSX3("D2_LOJA")[1],    TamSX3("D2_LOJA")[2],    PesqPict("SD2","D2_LOJA")})		
	AAdd(aStrcNFs, {RetTitle("NJM_FILORG"), "T_FILORG", TamSX3("NJM_FILORG")[3], TamSX3("NJM_FILORG")[1], TamSX3("NJM_FILORG")[2], PesqPict("NJM","NJM_FILORG")})
	AAdd(aStrcNFs, {RetTitle("NJM_CODINE"), "T_CODINE", TamSX3("NJM_CODINE")[3], TamSX3("NJM_CODINE")[1], TamSX3("NJM_CODINE")[2], PesqPict("NJM","NJM_CODINE")})
	AAdd(aStrcNFs, {RetTitle("NJM_DESINE"), "T_DESINE", TamSX3("NJM_DESINE")[3], TamSX3("NJM_DESINE")[1], TamSX3("NJM_DESINE")[2], PesqPict("NJM","NJM_DESINE")})
	AAdd(aStrcNFs, {RetTitle("NJM_CODCTR"), "T_CTRVND", TamSX3("NJM_CODCTR")[3], TamSX3("NJM_CODCTR")[1], TamSX3("NJM_CODCTR")[2], PesqPict("NJM","NJM_CODCTR")})
	AAdd(aStrcNFs, {RetTitle("NJM_ITEM"),   "T_ETGVND", TamSX3("NJM_ITEM")[3],   TamSX3("NJM_ITEM")[1],   TamSX3("NJM_ITEM")[2],   PesqPict("NJM","NJM_ITEM")})
	AAdd(aStrcNFs, {RetTitle("NJM_SEQPRI"), "T_REFVND", TamSX3("NJM_SEQPRI")[3], TamSX3("NJM_SEQPRI")[1], TamSX3("NJM_SEQPRI")[2], PesqPict("NJM","NJM_SEQPRI")})
		
	// Definição dos índices da tabela
	aIndNFs := {{"CHAVE","T_DOC,T_SERIE,T_CLIENT,T_LOJA,T_ITEDOC"}, {"SELEC", "T_OK"}}
		
	Processa({|| OG710ACTMP(@__cTabNFs, @__cNamNFs, aStrcNFs, aIndNFs)}, STR0004) // Aguarde. Carregando a tela
		
	// Carrega os registros das tabelas temporárias das notas fiscais	
	Processa({|| InsRegNFs(.F.)}, STR0005) // Aguarde. Selecionando notas fiscais disponíveis para devolução

	/************* TELA PRINCIPAL ************************/
	aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0006, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // Vincular NFs de origem

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
	oFWL:addWindow('CENTER', 'Wnd1', STR0007, 25/*tamanho*/, .F., .T.,, 'MASTER') //"Total de notas fiscais"
	oFWL:addWindow('CENTER', 'Wnd2', STR0008, 75/*tamanho*/, .F., .T.,, 'MASTER') //"Notas fiscais"
	
	oPnlWnd1 := oFWL:getWinPanel('CENTER', 'Wnd1', 'MASTER')
	oPnlWnd2 := oFWL:getWinPanel('CENTER', 'Wnd2', 'MASTER')
	
	/***********************************************************/
	
	//- Recupera coordenadas 
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject(STR0007,100,100,.T.,.T.) // Total de notas fiscais
	oSize2:SetWindowSize({0,0,oPnlWnd1:NHEIGHT, oPnlWnd1:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()
		
	//Cria campos totalizadores - Qtd. Fiscal
	oSay1  := TSay():New(001, 001, {|| STR0009}, oPnlWnd1,,,,,,.T., CLR_BLACK, CLR_WHITE, 050, 020) // Qtd. Fiscal
	oTGet1 := TGet():New(011, 001, bSetGet(_nTotNFs),   oPnlWnd1, 136, 010, PesqPict("SD2","D2_QUANT"), { || .t. } /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {||.F. } /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| .T. } /*bChange*/, .T. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/,.T.,.F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
	
	//Cria campos totalizadores - Saldo a vincular
	oSay2  := TSay():New(001, 141, {|| STR0010}, oPnlWnd1,,,,,,.T., CLR_BLACK, CLR_WHITE, 080, 020) // Saldo a vincular
	oTGet2 := TGet():New(011, 141, bSetGet(_nSldVinc),  oPnlWnd1, 136, 010, PesqPict("SD2","D2_QUANT"), { || .t. } /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, .F. /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {|| .F. } /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| .T. } /*bChange*/, .T. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, .T., .F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		lReadOnly := .F.
		cReadVar  := "_nQtdVinc"
	EndIf
	
	//Cria campos totalizadores - Quantidade vinculada
	oSay3  := TSay():New(001, 281, {|| STR0011}, oPnlWnd1,,,,,,.T., CLR_BLACK, CLR_WHITE, 080, 020) // Quantidade vinculada
	oTGet3 := TGet():New(011, 281, bSetGet(_nQtdVinc),  oPnlWnd1, 136, 010, PesqPict("SD2","D2_QUANT"), { || .t. } /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, .F. /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {|| .T. } /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| .T. } /*bChange*/, lReadOnly /*lReadOnly*/, /*lPassword*/, /*uParam23*/, cReadVar /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, .T., .F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		//Cria o botão
		TButton():New(011, 421, STR0012, oPnlWnd1,{|| VldQtdTot()},,,,,,.T.,,) // Vincular notas fiscais
	EndIf
		
	/****************** NFs de Origem ********************************/
	
	aHeader := {}
	
	nPosFil := AScan(aIndNFs, {|x| AllTrim(x[1]) == "CHAVE"})
	cChave  := aIndNFs[nPosFil][2]
	
	For nCont := 2 to Len(aStrcNFs)
	
		If !aStrcNFs[nCont][2] $ "NJM_FILORG|NJM_CODINE" .AND. At(aStrcNFs[nCont][2], cChave) > 0
			If !Empty(cCmpsTit)
				cCmpsTit += "+"
			EndIf
			
			cCmpsTit += AllTrim(aStrcNFs[nCont][1])
			nCmpsTam += aStrcNFs[nCont][4]			
		EndIf
				
		Aadd(aCpsNFsSk, {aStrcNFs[nCont][2], aStrcNFs[nCont][3], aStrcNFs[nCont][4], aStrcNFs[nCont][5], aStrcNFs[nCont][1], aStrcNFs[nCont][6]})
	 	
	 	// Monta as colunas
	    If !aStrcNFs[nCont][2] $ "NJM_CODINE|NJM_CODCTR|NJM_ITEM|NJM_SEQPRI" // Não mostra os campos no browse	    	   
	    	AAdd(aHeader,FWBrwColumn():New())
			aHeader[nCol]:SetData(&("{||"+aStrcNFs[nCont][2]+"}"))
			aHeader[nCol]:SetTitle(aStrcNFs[nCont][1])
			aHeader[nCol]:SetPicture(aStrcNFs[nCont][6])
			aHeader[nCol]:SetType(aStrcNFs[nCont][3])
			aHeader[nCol]:SetSize(aStrcNFs[nCont][4])
			aHeader[nCol]:SetReadVar(aStrcNFs[nCont][2])
			nCol++
							   	    	
	    	Aadd(aFilBrwNFs, {aStrcNFs[nCont][2], aStrcNFs[nCont][1], aStrcNFs[nCont][3], aStrcNFs[nCont][4], aStrcNFs[nCont][5], aStrcNFs[nCont][6]})    	    
	    EndIf	    
    Next nCont
	
	//- Recupera coordenadas 
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject(STR0008,100,100,.T.,.T.) //"Notas fiscais"
	oSize3:SetWindowSize({0, 0, oPnlWnd2:NHEIGHT, oPnlWnd2:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {0,0,0,0}
	oSize3:Process()
					                       
	__oBrwNFs := FWFormBrowse():New()
	__oBrwNFs:SetOwner(oPnlWnd2)
	__oBrwNFs:SetDataTable(.T.)
	__oBrwNFs:SetTemporary(.T.)
    __oBrwNFs:SetAlias(__cTabNFs)
    __oBrwNFs:SetProfileID("NFS")    
                
    // Filtro
    __oBrwNFs:SetUseFilter(.T.)
	__oBrwNFs:SetUseCaseFilter(.T.)                         
    __oBrwNFs:SetFieldFilter(aFilBrwNFs)   
    __oBrwNFs:SetDBFFilter(.T.)
          
    __oBrwNFs:Acolumns := {}
    __oBrwNFs:AddMarkColumns({||IIf((__cTabNFs)->T_OK == "1", "LBOK", "LBNO")}, {|| MarkBrw(__oBrwNFs, "R")}, {|| MarkAllBrw(__oBrwNFs, "R")})
        
	Aadd(aIndSeek,{cCmpsTit ,{{"", 'C' , nCmpsTam, 0 , "@!" }}, 2, .T.})
    
	__oBrwNFs:SetSeek(,aIndSeek)
	__oBrwNFs:SetColumns(aHeader)
	
	// Habilitar edição no campo de Quantidade vinculada
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE    	    
		__oBrwNFs:SetEditCell( .T. , {|lCancel, oBrowse| VldQtdNFs(lCancel, oBrowse)})
		__oBrwNFs:acolumns[7]:SetEdit(.T.)
		__oBrwNFs:acolumns[7]:SetReadVar('T_QTDSEL')
	EndIf
    
    __oBrwNFs:DisableReport(.T.)
    __oBrwNFs:DisableDetails()
    __oBrwNFs:Activate()
	
	oDlg:Activate(,,, .T.,,, EnchoiceBar(oDlg, {|| nOpcX := 1, IIF(vldQtdVinc(),ODlg:End(),nOpcX := 0)} /*OK*/, {|| nOpcX := 0, oDlg:End()} /*Cancel*/ ) )
	
	If nOpcX = 1 .AND. nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		Processa({|| lRetorno := VincRom()}, STR0013) // Aguarde. Vinculando notas fiscais no romaneio.
	
		If !lRetorno
	 		Return .F.
	 	EndIf		
	EndIf
		
Return .T.

Static Function vldQtdVinc()
	
	If _nQtdVinc > _nTotNFs .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2"
		MsgAlert(STR0021, STR0001) // "A quantidade informada é maior que a quantidade fiscal." ## "Atenção"
		Return .F.
	EndIf

Return .T.

/*{Protheus.doc} MarkBrw
Seleção individual do browse de notas fiscais

@author francisco.nunes
@since  23/08/2018
@version 1.0
@param oBrwObj, object, Objeto do browser marcado
@type function
*/
Static Function MarkBrw(oBrwObj)
	Local lMarcar := .F.
	
	If nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
	
	If Empty((oBrwObj:Alias())->(T_OK))
		lMarcar := .T.				
	EndIf
	
	If lMarcar .AND. !ValMarkBrw(oBrwObj, .F.)
		Return .F.
	EndIf
		
	/* Atualiza a grid de notas fiscais */
	AtualizNFs(oBrwObj:Alias(), "N", lMarcar)
	
	/* Atualiza os totais */
	AtualizTot()
				
	oBrwObj:SetFocus() 
	oBrwObj:GoColumn(1)

Return .T.

/*{Protheus.doc} MarkAllBrw
Seleção de todos os itens do browse de notas fiscais

@author francisco.nunes
@since  23/08/2018
@version 1.0
@param oBrwObj, object, Objeto do browser marcado
@type function
*/
Static function MarkAllBrw(oBrwObj)
	Local lMarcar := .F.
	
	If nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE
		Return .T.
	EndIf
		
	(oBrwObj:Alias())->(DbGoTop())	
	lMarcar := IIf((oBrwObj:Alias())->T_OK == "1", .F., .T.)
	
	If lMarcar .AND. !ValMarkBrw(oBrwObj, .T.)
		Return .F.
	EndIf
	
	If lMarcar
		_nQtdVinc := 0
	EndIf
	
	While !(oBrwObj:Alias())->(Eof())		
		/* Atualiza a grid de notas fiscais */
		AtualizNFs(oBrwObj:Alias(), "N", lMarcar,,,.T.)
	
		(oBrwObj:Alias())->(DbSkip())
	EndDo
	
	/* Atualiza os totais */
	AtualizTot()
				
	__oBrwNFs:Refresh(.T.)
		
	oBrwObj:SetFocus()

Return .T.

/*{Protheus.doc} AtualizNFs
Atualiza a grid de notas fiscais

@author francisco.nunes
@since  09/05/2018
@version 1.0
@param cAliasBrw, character, Alias do objeto do browser marcado
@param cBrwName, characters, Nome do browser ("T"=Totais;"N"=Notas Fiscais)
@param lMarcar, logical, .T. - Marcar; .F. - Desmarcar
@param lQtdMan, logical, .T. - Digitado quantidade vinculada
@param nQtdMax, number, quantidade máxima (selecionada) - utilizada para quando informa uma quantidade manualmente
na parte "Totais de notas fiscais"
@param lMarcarT, logical, .T. - Marcar todos;
@type function
*/
Static Function AtualizNFs(cAliasBrw, cBrwName, lMarcar, lQtdMan, nQtdMax, lMarcarT)
	Local aAreaNFs := (__cTabNFs)->(GetArea())
	Local nQtdVin  := 0
	Local nQNFsSel := 0
	
	Default lQtdMan  := .F.
	Default nQtdMax  := 0
	Default lMarcarT := .F.
	
	If cBrwName == "N" // Browser Notas Fiscais
			
		nQNFsSel := (cAliasBrw)->T_QTDRET
	
		If lQtdMan			
			nQNFsSel := nQtdMax
		Else
			If lMarcar .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2" .AND. _nTotNFs < _nQtdVinc + (__cTabNFs)->T_QTDRET
				nQNFsSel := nQNFsSel - ((_nQtdVinc + nQNFsSel) - _nTotNFs)
			EndIf
		EndIf
		
		If nQNFsSel = 0
			lMarcar := .F.
		EndIf
		
		If lMarcarT .AND. lMarcar
			_nQtdVinc += nQNFsSel
		EndIf
	
		If RecLock(cAliasBrw, .F.)
			(cAliasBrw)->T_OK     := IIf(lMarcar, "1", "")
			(cAliasBrw)->T_QTDSEL := IIf(lMarcar, nQNFsSel, 0)
			(cAliasBrw)->T_SLDRET := (cAliasBrw)->T_QTDRET - (cAliasBrw)->T_QTDSEL
				
			(cAliasBrw)->(MsUnlock())
		EndIf
	
	ElseIf cBrwName == "T" // Totais
								
		DbSelectArea(__cTabNFs)
		(__cTabNFs)->(DbGoTop())
		While (__cTabNFs)->(!Eof())
			
			nQNFsSel := (__cTabNFs)->T_QTDRET
			
			If lQtdMan // Se foi digitado a quantidade vinculada na grid de Filiais
				If lMarcar .AND. nQtdMax < nQtdVin + (__cTabNFs)->T_QTDRET
					nQNFsSel := (__cTabNFs)->T_QTDRET - ((nQtdVin + (__cTabNFs)->T_QTDRET) - nQtdMax)
				EndIf
			Else
				If lMarcar .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2" .AND. _nTotNFs < nQtdVin + (__cTabNFs)->T_QTDRET
					nQNFsSel := (__cTabNFs)->T_QTDFIS - ((nQtdVin + (__cTabNFs)->T_QTDFIS) - _nTotNFs)
				EndIf 			
			EndIf
			
			If nQNFsSel = 0			
				lMarcar  := .F.
			EndIf
			
			If RecLock(__cTabNFs, .F.)
				(__cTabNFs)->T_OK     := IIf(lMarcar, "1", "")
				(__cTabNFs)->T_QTDSEL := IIf(lMarcar, nQNFsSel, 0)
				(__cTabNFs)->T_SLDRET := (__cTabNFs)->T_QTDRET - (__cTabNFs)->T_QTDSEL
					
				(__cTabNFs)->(MsUnlock())
			EndIf
			
			nQtdVin += nQNFsSel
			
			(__cTabNFs)->(DbSkip())
		EndDo				
	
	EndIf
	
	RestArea(aAreaNFs)

Return .T.

/*{Protheus.doc} AtualizTot
Atualiza os totais

@author francisco.nunes
@since  23/08/2018
@version 1.0
@type function
*/
Static Function AtualizTot()	
	Local aAreaNFs := (__cTabNFs)->(GetArea())
	Local cQuery   := ""	
	
	_nQtdVinc := 0
	_nSldVinc := _nTotNFs 
	
	cQuery := " SELECT SUM(T_QTDSEL) AS QTNFSSEL "
	cQuery += " FROM "+ __cNamNFs + " NFS "

	MPSysOpenQuery(cQuery, 'QRYQNFS')
	
	DbSelectArea('QRYQNFS')
	While ('QRYQNFS')->(!Eof())
	
		_nQtdVinc += ('QRYQNFS')->(FieldGet(1))
		_nSldVinc -= ('QRYQNFS')->(FieldGet(1))
					
		('QRYQNFS')->(DbSkip())
	EndDo	
	('QRYQNFS')->(DbCloseArea())
	
	If _nSldVinc < 0
		_nSldVinc := 0
	EndIf
		
	oTGet2:Refresh()
	oTGet3:Refresh()
	
	RestArea(aAreaNFs)
	
Return .T.

/*{Protheus.doc} VldQtdTot
Valida a quantidade informada nos totais e atualiza as notas fiscais 

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
		MsgAlert(STR0018, STR0001) // "A quantidade informada é maior que a soma das quantidades das notas fiscais." ## "Atenção"
		oTGet3:SetFocus()
		Return .F.
	EndIf
		
	/* Atualiza a grid de notas fiscais */
	/* Será marcado as notas fiscais até a quantidade selecionada informada */
	AtualizNFs("", "T", .T., .T., _nQtdVinc)
		
	/* Atualiza os totais */
	AtualizTot()
				
	__oBrwNFS:Refresh(.T.)	

Return .T.

/*{Protheus.doc} VldQtdNFs
Valida a quantidade vinculada informada manualmente no browse "Notas fiscais" 

@type function
@author francisco.nunes
@since  24/08/2018
@version 1.0
@param lCancel, logical, Indica se a operação de digitação foi cancelada
@param oBrwObj, object, Objeto do browse alterado
@return lRetorno
*/
Static Function VldQtdNFs(lCancel, oBrwObj)

	Local nQtdSel  := 0
	Local aAreaNFs := (__cTabNFs)->(GetArea())
	Local cDoc	   := ""
	Local cSerie   := ""
	Local cClient  := ""
	Local cLoja	   := ""
	Local cItDoc   := ""
	Local cFilIE   := ""
	Local cCodIE   := ""

	If lCancel
		Return .T.
	EndIf
	
	If (oBrwObj:Alias())->T_QTDSEL < 0 
		MsgAlert(STR0019, STR0001) // "A quantidade informada para a nota fiscal é inválida." ## "Atenção"
		Return .F.
	EndIf
	
	If (oBrwObj:Alias())->T_QTDSEL > (oBrwObj:Alias())->T_QTDRET
		MsgAlert(STR0020, STR0001) // "A quantidade informada é maior que a quantidade a devolver." ## "Atenção" 
		Return .F.
	EndIf
	
	cDoc    := (oBrwObj:Alias())->T_DOC
	cSerie  := (oBrwObj:Alias())->T_SERIE
	cClient := (oBrwObj:Alias())->T_CLIENT
	cLoja   := (oBrwObj:Alias())->T_LOJA
	cItDoc  := (oBrwObj:Alias())->T_ITEDOC
	cFilIE  := (oBrwObj:Alias())->T_FILORG
	cCodIE  := (oBrwObj:Alias())->T_CODINE	
	
	// Busca na tabela temporária de notas fiscais a quantidade vinculada
	DbSelectArea(__cTabNFs)
	(__cTabNFs)->(DbSetOrder(2))
	If (__cTabNFs)->(DbSeek("1"))
		While (__cTabNFs)->(!Eof()) .AND. (__cTabNFs)->(T_OK) == "1"
			If (__cTabNFs)->T_DOC != cDoc .OR. (__cTabNFs)->T_SERIE != cSerie .OR. (__cTabNFs)->T_CLIENT != cClient .OR.;
			   (__cTabNFs)->T_LOJA != cLoja .OR. (__cTabNFs)->T_ITEDOC != cItDoc .OR. (__cTabNFs)->T_FILORG != cFilIE .OR.;
			   (__cTabNFs)->T_CODINE != cCodIE
				nQtdSel += (__cTabNFs)->T_QTDSEL
			EndIf
			
			(__cTabNFs)->(DbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaNFs)
	
	If (oBrwObj:Alias())->T_QTDSEL + nQtdSel > _nTotNFs .AND. oModelNJJ:GetValue('NJJ_TPFORM') == "2"
		MsgAlert(STR0021, STR0001) // "A quantidade informada é maior que a quantidade fiscal." ## "Atenção"
		Return .F.
	EndIf
			
	/* Atualiza a grid de Notas fiscais */
	/* Será marcado as notas fiscais até a quantidade selecionada informada */
	AtualizNFs(oBrwObj:Alias(), "N", .T., .T., (oBrwObj:Alias())->T_QTDSEL)
	
	/* Atualiza os totais */
	AtualizTot()
				
	__oBrwNFs:LineRefresh()
			
	__oBrwNFs:SetFocus()
			
Return .T.

/*{Protheus.doc} InsRegNFs
Seleção das notas fiscais para devolução

@author francisco.nunes
@since  23/08/2018
@param lF12, boolean, .T. - Chamado pelo F12; .F. - Chamado ao entrar na tela
@version 1.0
@type function
*/
Static Function InsRegNFs(lF12)
	Local cQuery     := ""
	Local cAliasNFs  := ""
	Local cQryInsert := ""
	Local nX		 := 0
	Local nQtdSel	 := 0
	Local cMark		 := ""
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		If !Pergunte("OGA251B001", .T.)
			If lF12
				Return .F.
			EndIf
		EndIf
	EndIf
						
	// Limpa a tabela temporária
	DbSelectArea(__cTabNFs)
	(__cTabNFs)->(DbSetorder(1))
	ZAP
	
	_nQtdVinc := 0
	_nTotNFs  := oModelNJJ:GetValue('NJJ_QTDFIS')
	_nSldVinc := oModelNJJ:GetValue('NJJ_QTDFIS')
			    
    // Monta a query de busca
    cQuery := "SELECT N8K.N8K_FILIAL  AS FILIAL, "
    cQuery += "       N8K.N8K_DOC     AS DOC, "
	cQuery += " 	  N8K.N8K_SERIE   AS SERIE, "
	cQuery += " 	  N8K.N8K_CLIFOR  AS CLIENTE, "
	cQuery += " 	  N8K.N8K_LOJA    AS LOJA, "
	cQuery += " 	  N8K.N8K_ITEDOC  AS ITEDOC, "
	cQuery += " 	  SD2.D2_EMISSAO  AS DOCEMI, "		
	cQuery += " 	  NJM.NJM_FILORG  AS FILIE, "
	cQuery += " 	  NJM.NJM_CODINE  AS CODINE, "
	cQuery += " 	  NJM.NJM_CODCTR  AS CTRVND, "
	cQuery += " 	  NJM.NJM_ITEM    AS ETGVND, "
	cQuery += " 	  NJM.NJM_SEQPRI  AS REFVND, "
    cQuery += " 	  N7Q.N7Q_DESINE AS DESINE, "
    cQuery += "       (SD2.D2_QUANT - SD2.D2_QTDEDEV) AS QTDSLDDEV "
    cQuery += " FROM " + RetSqlName("N8K") + " N8K "
    
    cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D2_FILIAL = N8K.N8K_FILIAL AND SD2.D2_DOC = N8K.N8K_DOC "
	cQuery += "   AND SD2.D2_SERIE = N8K.N8K_SERIE AND SD2.D2_ITEM = N8K.N8K_ITEDOC AND SD2.D2_CLIENTE = N8K.N8K_CLIFOR AND SD2.D2_LOJA = N8K.N8K_LOJA "
	cQuery += "   AND SD2.D_E_L_E_T_ = '' "
		
	cQuery += " INNER JOIN " + RetSqlName("NJM") + " NJM ON NJM.NJM_FILIAL = N8K.N8K_FILIAL AND NJM.NJM_CODROM = N8K.N8K_CODROM "
	cQuery += "   AND NJM.NJM_ITEROM = N8K.N8K_ITEROM AND NJM.D_E_L_E_T_ = '' "
		
	cQuery += " LEFT OUTER JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_FILIAL = NJM.NJM_FILORG AND N7Q.N7Q_CODINE = NJM.NJM_CODINE "
	cQuery += "   AND N7Q.D_E_L_E_T_ = '' " //Alterado para LEFT pois tem opção de não usar a IE no romaneio.
	
	If oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado
		cQuery += " INNER JOIN " + RetSqlName("N9E") + " N9E ON N9E.N9E_FILIAL = N8K.N8K_FILIAL AND N9E.N9E_FILIE = NJM.NJM_FILORG " 
		cQuery += " AND N9E.N9E_CODINE = NJM.NJM_CODINE AND N9E.N9E_DOC = N8K.N8K_DOC AND N9E.N9E_SERIE = N8K.N8K_SERIE "
		cQuery += " AND N9E.N9E_CLIFOR = N8K.N8K_CLIFOR AND N9E.N9E_LOJA = N8K.N8K_LOJA AND N9E.N9E_ITEDOC = N8K.N8K_ITEDOC "
		cQuery += " AND N9E.N9E_ORIGEM = '7' AND N9E.D_E_L_E_T_ = '' "
	EndIf
					
	cQuery += " WHERE N8K.D_E_L_E_T_ = '' "			
	cQuery += "   AND N8K.N8K_FILIAL = '"+FWxFilial("NJJ")+"' "
	cQuery += "   AND N8K.N8K_PRODUT = '"+oModelNJJ:GetValue('NJJ_CODPRO')+"' "
	
	If oModelNJJ:GetValue('NJJ_TPFORM') == "2" //formulario proprio igual a não, filtra pela entidade e loja
		cQuery += "   AND NJM.NJM_CODENT = '"+oModelNJJ:GetValue('NJJ_CODENT')+"' "
		cQuery += "   AND NJM.NJM_LOJENT = '"+oModelNJJ:GetValue('NJJ_LOJENT')+"' "
	EndIf
	
	If !oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado
		cQuery += "   AND (SD2.D2_QUANT - SD2.D2_QTDEDEV) > 0 "
	EndIf
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE	
		If !Empty(MV_PAR01)  // Data de Emissão De? 
			cQuery += " AND (SD2.D2_EMISSAO >= '" + dToS(MV_PAR01) + "')"
		EndIf
	
		If !Empty(MV_PAR02)  // Data de Emissão Até?
			cQuery += " AND (SD2.D2_EMISSAO <= '" + dToS(MV_PAR02) + "')"
		EndIf
	EndIf
			
	cQuery += "	GROUP BY N8K.N8K_FILIAL, N8K.N8K_DOC, N8K.N8K_SERIE, N8K.N8K_CLIFOR, N8K.N8K_LOJA, N8K.N8K_ITEDOC, SD2.D2_EMISSAO, "
	cQuery += "	         NJM.NJM_FILORG, NJM.NJM_CODINE, NJM.NJM_CODCTR, NJM.NJM_ITEM, NJM.NJM_SEQPRI, N7Q.N7Q_DESINE, SD2.D2_QUANT, "
	cQuery += "          SD2.D2_QTDEDEV "
        					         		        
	cQuery := ChangeQuery(cQuery)
	cAliasNFs := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasNFs,.F.,.T.)
		
	If (cAliasNFs)->(!EoF())
		While (cAliasNFs)->(!EoF())
			
			nQtdSel := 0
			
			For nX := 1 to oModelN9E:Length()
				If .Not. oModelN9E:IsDeleted()
					If oModelN9E:GetValue('N9E_DOC', nX) == (cAliasNFs)->DOC .AND. oModelN9E:GetValue('N9E_SERIE', nX) == (cAliasNFs)->SERIE .AND.;
					   oModelN9E:GetValue('N9E_CLIFOR', nX) == (cAliasNFs)->CLIENTE .AND. oModelN9E:GetValue('N9E_LOJA', nX) == (cAliasNFs)->LOJA .AND.;
					   oModelN9E:GetValue('N9E_ITEDOC', nX) == (cAliasNFs)->ITEDOC .AND. oModelN9E:GetValue('N9E_FILIE', nX) == (cAliasNFs)->FILIE .AND.;
					   oModelN9E:GetValue('N9E_CODINE', nX) == (cAliasNFs)->CODINE
					   nQtdSel := oModelN9E:GetValue('N9E_QTDRET', nX)
					   EXIT
					EndIf			
				EndIf	
			Next nX
			
			If oModelNJJ:GetValue('NJJ_STATUS') $ "2|3" // Atualizado / Confirmado
				If nQtdSel = 0
					(cAliasNFs)->(DbSkip())
					LOOP
				EndIf
			EndIf
			
			cMark := " "
			
			If nQtdSel > 0
				cMark := "1"
			EndIf
			
			_nQtdVinc += nQtdSel
			_nSldVinc -= nQtdSel
																					
			cQryInsert := "('"+(cAliasNFs)->DOC+"', '"+(cAliasNFs)->SERIE+"', '"+(cAliasNFs)->CLIENTE+"', '"+(cAliasNFs)->LOJA+"', '"+(cAliasNFs)->ITEDOC+"', '"+(cAliasNFs)->DOCEMI+"', '"+(cAliasNFs)->FILIE+"', '"+(cAliasNFs)->CODINE+"', '"+(cAliasNFs)->CTRVND+"', '"+(cAliasNFs)->ETGVND+"', '"+(cAliasNFs)->REFVND+"', '"+(cAliasNFs)->DESINE+"', '"+AllTrim(STR((cAliasNFs)->QTDSLDDEV))+"', '"+AllTrim(STR(nQtdSel))+"', '"+AllTrim(STR((cAliasNFs)->QTDSLDDEV))+"', '"+cMark+"') "
			TCSqlExec("INSERT INTO "+__cNamNFs+" (T_DOC, T_SERIE, T_CLIENT, T_LOJA, T_ITEDOC, T_DOCEMI, T_FILORG, T_CODINE, T_CTRVND, T_ETGVND, T_REFVND, T_DESINE, T_QTDRET, T_QTDSEL, T_SLDRET, T_OK) VALUES " + cQryInsert)
			
			(cAliasNFs)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasNFs)->(DbCloseArea())	
		
	// Refresh nos browsers
	TCRefresh(__cNamNFs)
				
Return .T.

/*{Protheus.doc} VincRom
Vincula das NFs no romaneio para Devolução de Venda

@author francisco.nunes
@since  24/08/2018
@type function
*/
Static Function VincRom()
	Local aAreaNFs := (__cTabNFs)->(GetArea())	
	Local lRet	   := .T.
	Local nI	   := 0
						
	For nI := 1 to oModelN9E:Length()
		oModelN9E:GoLine(nI)
		oModelN9E:DeleteLine()
	Next nI
	
	DbSelectArea((__cTabNFs))
	(__cTabNFs)->(DbGoTop())
	(__cTabNFs)->(DbSetOrder(2)) // Notas Fiscais marcadas
	If (__cTabNFs)->(DbSeek("1"))
								 
		While (__cTabNFs)->(!Eof()) .AND. (__cTabNFs)->T_OK == "1"
		
			oModelN9E:AddLine()
			oModelN9E:SetValue("N9E_ORIGEM", "7")
			oModelN9E:SetValue("N9E_FILIE", (__cTabNFs)->T_FILORG)
			oModelN9E:SetValue("N9E_CODINE", (__cTabNFs)->T_CODINE)
			oModelN9E:SetValue("N9E_CODCTR", (__cTabNFs)->T_CTRVND)
			oModelN9E:SetValue("N9E_ITEM", (__cTabNFs)->T_ETGVND)
			oModelN9E:SetValue("N9E_SEQPRI", (__cTabNFs)->T_REFVND)
			oModelN9E:SetValue("N9E_DOC", (__cTabNFs)->T_DOC)
			oModelN9E:SetValue("N9E_SERIE", (__cTabNFs)->T_SERIE)
			oModelN9E:SetValue("N9E_CLIFOR", (__cTabNFs)->T_CLIENT)
			oModelN9E:SetValue("N9E_LOJA", (__cTabNFs)->T_LOJA)
			oModelN9E:SetValue("N9E_ITEDOC", (__cTabNFs)->T_ITEDOC)
			oModelN9E:SetValue("N9E_QTDRET", (__cTabNFs)->T_QTDSEL)	
			
			(__cTabNFs)->(DbSkip())	
		EndDo	
								
	EndIf	
			
	RestArea(aAreaNFs)		
		
Return lRet


/*/{Protheus.doc} ValMarkBrw
//TODO Validação ao marcar o registro, para permitir selecionar apenas NFs do mesmo cliente/fornecedor
@author claudineia.reinert
@since 20/09/2018
@version 1.0
@return ${lRet}, ${verdadeiro(.T.) ou falso(.F.)}
@param oBrwObj, object, objeto do browser
@param lMakAll, logical, .T. = esta marcando todos os registro, .F. esta marcando apenas um registro
@type function
/*/
Static Function ValMarkBrw(oBrwObj, lMarkAll)
	Local lRet := .T.
	Local aAreaNFs := (__cTabNFs)->(GetArea())	
	Local cChavVal := ''
	Local cChavSeek := ''
	Local nOrder := 1
	
	If !lMarkAll //marcou apenas um registro
		cChavVal := (oBrwObj:Alias())->T_CLIENT + (oBrwObj:Alias())->T_LOJA //qdo marca um registro marcado
		cChavSeek := "1"
		nOrder := 2
	EndIf
	
	DbSelectArea((__cTabNFs))
	(__cTabNFs)->(DbGoTop())
	(__cTabNFs)->(DbSetOrder(nOrder)) // Notas Fiscais marcadas
	If (__cTabNFs)->(DbSeek(cChavSeek))
								 
		While (__cTabNFs)->(!Eof()) 
		
			If ( lMarkAll .OR. (!lMarkAll .and. (__cTabNFs)->T_OK == "1") ) 
				If Empty(cChavVal) 
					cChavVal := (__cTabNFs)->T_CLIENT + (__cTabNFs)->T_LOJA
				EndIf
				
				If cChavVal != (__cTabNFs)->T_CLIENT + (__cTabNFs)->T_LOJA
					lRet := .F.
					Exit
				EndIf
		
			EndIf 
			
			(__cTabNFs)->(DbSkip())	
		EndDo	
								
	EndIf	
			
	If !lRet
		MsgAlert(STR0023, STR0001) //###"Não é possivel selecionar NFs de clientes diferentes."
	EndIf
	
	RestArea(aAreaNFs)

Return lRet
