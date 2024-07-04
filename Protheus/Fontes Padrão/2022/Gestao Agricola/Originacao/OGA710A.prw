#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#include 'OGA710A.ch'

#DEFINE _CRLF CHR(13)+CHR(10)

Static __cTabRem := ""
Static __cNamRem := ""
Static __cTabFil := ""
Static __cNamFil := ""
Static __oBrwFil := Nil
Static __oBrwRem := Nil

/*{Protheus.doc} OG710AVREM
Vincular notas de remessa na IE de exportação (Apenas para grãos)

@author francisco.nunes
@since 30/04/2018
@version 1.0
@type function
*/
Function OG710AVREM()

	// Valida se o produto da IE é algodão, caso seja, não continua
	If AGRTPALGOD(N7Q->N7Q_CODPRO)
		MsgAlert(STR0003, STR0001) // Função não disponível para produto algodão. ## Alerta
		Return .T.
	EndIf

	// Valida se a IE é armazenagem, caso seja, não continua
	If N7Q->N7Q_TPCTR == "2" // Tipo do Contrato: 1=Venda;2=Armazenagem
		MsgAlert(STR0002, STR0001) // Função não disponível para instrução de embarque de armazenagem. ## Alerta
		Return .T.
	EndIf

	If N7Q->N7Q_TOTLIQ = 0
		MsgAlert(STR0026, STR0001) // Instrução de Embarque não possui quantidade instruída para vínculo das remessas. ## Alerta
		Return .T.
	EndIf

	CriaBrowse()

Return .T.

/*{Protheus.doc} CriaBrowse
Cria browse das notas fiscais de remessas

@author francisco.nunes
@since 02/05/2018
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
	Local oSize4     := Nil
	Local oPnl1      := Nil
	Local oPnlWnd1	 := Nil
	Local oPnlWnd2	 := Nil
	Local oPnlWnd3	 := Nil
	Local aFilBrwFil := {}
	Local aFilBrwRem := {}
	Local nCont		 := 0	
	Local nOpcX	     := 1
	Local lRetorno	 := .F.
	Local aHeader	 := {}

	Private _nQtdVinc := 0	// Variavel totalizador de remessas vinculadas
	Private _nSldVinc := 0	// Variavel totalizador do saldo das remessas a vincular (Instruída - Vinculada)

	// Estrutura da tabela temporária de notas fiscais de remessa
	AAdd(aStrcRem, {RetTitle("N9I_FILIAL"), "T_FILIAL", TamSX3("N9I_FILIAL")[3], TamSX3("N9I_FILIAL")[1], TamSX3("N9I_FILIAL")[2], PesqPict("N9I","N9I_FILIAL")})
	AAdd(aStrcRem, {RetTitle("N9I_DOC"),    "T_DOC",    TamSX3("N9I_DOC")[3],    TamSX3("N9I_DOC") [1],   TamSX3("N9I_DOC") [2],   PesqPict("N9I","N9I_DOC")})
	AAdd(aStrcRem, {RetTitle("N9I_SERIE"),  "T_SERIE",  TamSX3("N9I_SERIE")[3],  TamSX3("N9I_SERIE")[1],  TamSX3("N9I_SERIE")[2],  PesqPict("N9I","N9I_SERIE")})	
	AAdd(aStrcRem, {RetTitle("N9I_ITEDOC"), "T_ITEDOC", TamSX3("N9I_ITEDOC")[3], TamSX3("N9I_ITEDOC")[1], TamSX3("N9I_ITEDOC")[2], PesqPict("N9I","N9I_ITEDOC")})
	AAdd(aStrcRem, {RetTitle("N9I_DOCEMI"), "T_DOCEMI", TamSX3("N9I_DOCEMI")[3], TamSX3("N9I_DOCEMI")[1], TamSX3("N9I_DOCEMI")[2], PesqPict("N9I","N9I_DOCEMI")})
	AAdd(aStrcRem, {RetTitle("N9I_QTDFIS"), "T_QTDFIS", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")})	

	AAdd(aStrcRem, {STR0004, "T_QTDSEL", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Qtd. Vinc.
	AAdd(aStrcRem, {STR0005, "T_QTDDIS", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Saldo a vinc.

	AAdd(aStrcRem, {RetTitle("N9I_QTDRET"), "T_QTDRET", TamSX3("N9I_QTDRET")[3], TamSX3("N9I_QTDRET")[1], TamSX3("N9I_QTDRET")[2], PesqPict("N9I","N9I_QTDRET")})
	AAdd(aStrcRem, {RetTitle("N9I_CLIFOR"), "T_CLIFOR", TamSX3("N9I_CLIFOR")[3], TamSX3("N9I_CLIFOR")[1], TamSX3("N9I_CLIFOR")[2], PesqPict("N9I","N9I_CLIFOR")})
	AAdd(aStrcRem, {RetTitle("N9I_LOJA"),   "T_LOJA",   TamSX3("N9I_LOJA")[3],   TamSX3("N9I_LOJA")[1],   TamSX3("N9I_LOJA")[2],   PesqPict("N9I","N9I_LOJA")})	
	AAdd(aStrcRem, {STR0025, "T_QTDCTN", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Qtd. Ctn.

	// Definição dos índices da tabela
	aIndRem := {{"ORDER", "T_FILIAL,T_DOCEMI"}, {"CHAVE","T_FILIAL,T_DOC,T_SERIE,T_CLIFOR,T_LOJA,T_ITEDOC"}, {"SELEC", "T_OK"}}	

	// Estrutura da tabela temporária das filiais	
	AAdd(aStrcFil, {RetTitle("N9I_FILIAL"), "T_FILIAL", TamSX3("N9I_FILIAL")[3], TamSX3("N9I_FILIAL")[1], TamSX3("N9I_FILIAL")[2], PesqPict("N9I","N9I_FILIAL")})

	AAdd(aStrcFil, {RetTitle("N7S_QTDVIN"), "T_QTDINS", TamSX3("N7S_QTDVIN")[3], TamSX3("N7S_QTDVIN")[1], TamSX3("N7S_QTDVIN")[2], PesqPict("N7S","N7S_QTDVIN")})
	AAdd(aStrcFil, {STR0004, "T_QTDVINC", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Qtd. Vinc.	
	AAdd(aStrcFil, {STR0005, "T_SLDVINC", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Saldo a vinc.
	AAdd(aStrcFil, {STR0015, "T_TOTFIS", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Tot. Fis.
	AAdd(aStrcFil, {STR0025, "T_QVINCTN", TamSX3("N9I_QTDFIS")[3], TamSX3("N9I_QTDFIS")[1], TamSX3("N9I_QTDFIS")[2], PesqPict("N9I","N9I_QTDFIS")}) // Qtd. Ctn.

	aIndFil := {{"","T_FILIAL"}, {"SELEC", "T_OK"}}

	Processa({|| OG710ACTMP(@__cTabRem, @__cNamRem, aStrcRem, aIndRem)}, STR0006) // Aguarde. Carregando a tela
	Processa({|| OG710ACTMP(@__cTabFil, @__cNamFil, aStrcFil, aIndFil)}, STR0006) // Aguarde. Carregando a tela

	// Carrega os registros das tabelas temporárias de Filiais e Remessas	
	Processa({|| InsRegRem()}, STR0007) // Aguarde. Selecionando notas fiscais de remessa disponíveis

	/************* TELA PRINCIPAL ************************/
	aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0008, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // Vincular NFs de Remessa

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

	oFWL:addWindow('RIGHT', 'Wnd2', STR0010,  83/*tamanho*/, .F., .T.,, 'MASTER') //"Remessas"
	oFWL:addWindow('RIGHT', 'Wnd3', STR0011,  17 /*tamanho*/, .F., .T.,, 'MASTER') //"Total de Remessas"

	oFWL:setColSplit('LEFT', 0, 'MASTER')

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1 := oFWL:getWinPanel('LEFT', 'Wnd1', 'MASTER')
	oPnlWnd2 := oFWL:getWinPanel('RIGHT', 'Wnd2', 'MASTER')
	oPnlWnd3 := oFWL:getWinPanel('RIGHT', 'Wnd3', 'MASTER')

	/****************** FILIAIS ********************************/

	aHeader := {}

	For nCont := 2  to Len(aStrcFil)	
		If !aStrcFil[nCont][2] $ "T_TOTFIS|T_QVINCTN"
			Aadd(aHeader, {aStrcFil[nCont][1], &("{||"+aStrcFil[nCont][2]+"}"), aStrcFil[nCont][3], aStrcFil[nCont][6], 1, aStrcFil[nCont][4], aStrcFil[nCont][5], .F.})												
			Aadd(aFilBrwFil, {aStrcFil[nCont][2], aStrcFil[nCont][1], aStrcFil[nCont][3], aStrcFil[nCont][4], aStrcFil[nCont][5], aStrcFil[nCont][6]})
		EndIf
	Next nCont

	//- Recupera coordenadas
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject(STR0009,100,100,.T.,.T.)
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

	// Habilitar edição no campo de Quantidade vinculada
	__oBrwFil:SetEditCell( .T. , {|lCancel, oBrowse| VldQtdFil(lCancel, oBrowse) })
	__oBrwFil:acolumns[4]:SetEdit(.T.)
	__oBrwFil:acolumns[4]:SetReadVar('T_QTDVINC')

	__oBrwFil:Activate()		
	__oBrwFil:Enable()
	__oBrwFil:Refresh(.T.)

	/****************** REMESSAS ********************************/

	aHeader := {}

	For nCont := 2 to Len(aStrcRem)     
		If !aStrcRem[nCont][2] $ "T_QTDCTN"
			Aadd(aHeader, {aStrcRem[nCont][1], &("{||"+aStrcRem[nCont][2]+"}"), aStrcRem[nCont][3], aStrcRem[nCont][6], 1, aStrcRem[nCont][4], aStrcRem[nCont][5], .F.})
			Aadd(aFilBrwRem, {aStrcRem[nCont][2], aStrcRem[nCont][1], aStrcRem[nCont][3], aStrcRem[nCont][4], aStrcRem[nCont][5], aStrcRem[nCont][6]})
		EndIf 
	Next nCont

	//- Recupera coordenadas 
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject(STR0010,100,100,.T.,.T.)
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

	// Habilitar edição no campo de Quantidade vinculada
	__oBrwRem:SetEditCell( .T. , {|lCancel, oBrowse| VldQtdRem(lCancel, oBrowse)})
	__oBrwRem:acolumns[8]:SetEdit(.T.)
	__oBrwRem:acolumns[8]:SetReadVar('T_QTDSEL')

	__oBrwRem:Activate()
	__oBrwRem:Enable()
	__oBrwRem:Refresh(.T.)

	/*********************TOTALIZADORES *****************************/

	//- Recupera coordenadas 
	oSize4 := FWDefSize():New(.F.)
	oSize4:AddObject(STR0011,100,100,.T.,.T.)
	oSize4:SetWindowSize({0,0,oPnlWnd3:NHEIGHT, oPnlWnd3:NWIDTH})
	oSize4:lProp 	:= .T.
	oSize4:aMargins := {0,0,0,0}
	oSize4:Process()

	//Cria campos totalizadores - Quantidade vinculada
	oSay   := TSay():New(oSize4:aPosObj[1,1],   oSize4:aPosObj[1,2], {|| STR0012}, oPnlWnd3,,,,,,.T.,,,60,10,,,,,,.F.) // Quantidade vinculada
	oTGet1 := TGet():New(oSize4:aPosObj[1,1]+8, oSize4:aPosObj[1,2], bSetGet(_nQtdVinc), oPnlWnd3, oSize4:aPosObj[1,5] / 2, 009, PesqPict("N9I","N9I_QTDFIS"), /*bValid*/, 0, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {||.F. } , /*bWhen*/, /*uParam18*/, /*uParam19*/, .T. /*bChange*/, .F. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam26*/, /*uParam27*/,.T.,.F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)

	//Cria campos totalizadores - Saldo a vincular
	oSay2  := TSay():New(oSize4:aPosObj[1,1],   ((oSize4:aPosObj[1,5]/2) + oSize4:aPosObj[1,2] + 5), {|| STR0013}, oPnlWnd3,,,,,,.T.,,,60,10,,,,,,.F.) // Saldo a vincular
	oTGet2 := TGet():New(oSize4:aPosObj[1,1]+8, ((oSize4:aPosObj[1,5]/2) + oSize4:aPosObj[1,2] + 5), bSetGet(_nSldVinc), oPnlWnd3, (oSize4:aPosObj[1,5] /2) - 5, 009, PesqPict("N9I","N9I_QTDFIS"), /*bValid*/, 0, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .T., /*uParam15*/, /*uParam16*/, {||.F. } , /*bWhen*/, /*uParam18*/, /*uParam19*/, .T. /*bChange*/, .F. /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam26*/, /*uParam27*/,.T.,.F., /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/)

	__oBrwFil:SetFocus()	 // Focus no browser de Filiais - Principal
	__oBrwFil:GoColumn(1) // Posiciona o Browse 2 na primeira coluna depois da ativação

	oDlg:Activate(,,, .T.,,, EnchoiceBar(oDlg, {|| IIf(ValQtdSel(_nQtdVinc, @nOpcX), ODlg:End(), nOpcX := 0)} /*OK*/, {|| nOpcX := 0, oDlg:End()} /*Cancel*/ ) )

	If nOpcX = 1
		Processa({|| lRetorno := GrvRemSel(N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE)}, STR0014) // Aguarde. Vinculando notas fiscais de remessa na Instrução de Embarque.

		If !lRetorno
			Return .F.
		EndIf 
	EndIf

Return .T.

/** {Protheus.doc} OG710ACTMP
Função que monta as Temp-Tables da Rotina

@param:     Nil
@return:    boolean - True ou False
@author:    francisco.nunes
@since:     02/05/2018
@Uso:       OGA710 - Instrução de Embarque
*/
Function OG710ACTMP(cAliasTMP, cNameTMP, aCpsBrow, aIdxTab)
	Local nCont 	:= 0
	Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

	//-- Busca no aCpsBrow as propriedades para criar as colunas
	For nCont := 1 to Len(aCpsBrow)
		aADD(aStrTab, {aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5]})
	Next nCont

	//-- Tabela temporaria de pendencias
	cTabela  := GetNextAlias()

	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
	oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})

	// Inserido o alias de tabela
	cAliasTMP := cTabela

	// Inserido o real name da tabela
	cNameTMP := oArqTemp:GetRealName()

Return .T.

/*{Protheus.doc} MarkBrw
Seleção individual Filiais / Remessas

@author francisco.nunes
@since  02/05/2018
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

/*{Protheus.doc} AtualizRem
Atualiza a grid de Remessas

@author francisco.nunes
@since  03/05/2018
@version 1.0
@param cAliasBrw, character, Alias do objeto do browser marcado
@param cBrwName, characters, Nome do browser ("F"=Filiais;"R"=Remessas)
@param lMarcar, logical, .T. - Marcar; .F. - Desmarcar
@param lQtdMan, logical, .T. - Digitado quantidade vinculada
@param nQtdMax, number, quantidade máxima (selecionada) - utilizada para quando informa uma quantidade manualmente na grid de filiais
@type function
*/
Static Function AtualizRem(cAliasBrw, cBrwName, lMarcar, lQtdMan, nQtdMax)
	Local aAreaRem := (__cTabRem)->(GetArea())
	Local aQtdsFil := {}
	Local nQtdIns  := 0
	Local nQtdVin  := 0
	Local nQRemSel := 0

	Default lQtdMan := .F.
	Default nQtdMax := 0

	If lMarcar	
		aQtdsFil := RetQtdsFil((cAliasBrw)->T_FILIAL)

		nQtdIns := aQtdsFil[1]
		nQtdVin := aQtdsFil[2]
	EndIf

	If cBrwName == "R" // Browser Remessas

		If lQtdMan // Se foi digitado a quantidade vinculada na grid de Remessas

			nQRemSel := nQtdMax

			If (cAliasBrw)->T_OK == "1" // Se estiver marcado, para realizar a validação apenas com a quantidade digitada
				nQtdVin -=  (cAliasBrw)->T_QTDSEL
			EndIf			
		Else
			nQRemSel := (cAliasBrw)->T_QTDFIS

			If lMarcar .AND. nQtdIns < nQtdVin + nQRemSel
				nQRemSel := nQRemSel - ((nQtdVin + nQRemSel) - nQtdIns)
			EndIf
		EndIf		

		If nQRemSel = 0
			If RecLock(cAliasBrw, .F.)
				(cAliasBrw)->T_OK     := ""
				(cAliasBrw)->T_QTDSEL := 0
				(cAliasBrw)->T_QTDDIS := (cAliasBrw)->T_QTDFIS - (cAliasBrw)->T_QTDSEL

				(cAliasBrw)->(MsUnlock())
			EndIf
		ElseIf nQRemSel > 0	
			// Não deixa desmarcar uma nota fiscal de remessa que possua quantidade vinculada a container
			If !lMarcar .AND. (__cTabRem)->T_QTDCTN > 0
				lMarcar  := .T.
				nQRemSel := (__cTabRem)->T_QTDCTN
			EndIf		

			If RecLock(cAliasBrw, .F.)
				(cAliasBrw)->T_OK     := IIf(lMarcar, "1", "")
				(cAliasBrw)->T_QTDSEL := IIf(lMarcar, nQRemSel, 0)
				(cAliasBrw)->T_QTDDIS := (cAliasBrw)->T_QTDFIS - (cAliasBrw)->T_QTDSEL

				(cAliasBrw)->(MsUnlock())
			EndIf
		EndIf
	EndIf

	If cBrwName == "F" // Browser Filiais
		nQtdVin := 0

		DbSelectArea(__cTabRem)
		(__cTabRem)->(DbSetOrder(1))
		If (__cTabRem)->(DbSeek((cAliasBrw)->T_FILIAL))
			While (__cTabRem)->(!Eof()) .AND. (__cTabRem)->T_FILIAL == (cAliasBrw)->T_FILIAL

				nQRemSel := (__cTabRem)->T_QTDFIS

				If lQtdMan // Se foi digitado a quantidade vinculada na grid de Filiais
					If lMarcar .AND. nQtdMax < nQtdVin + (__cTabRem)->T_QTDFIS
						nQRemSel := (__cTabRem)->T_QTDFIS - ((nQtdVin + (__cTabRem)->T_QTDFIS) - nQtdMax)
					EndIf
				Else				
					If lMarcar .AND. nQtdIns < nQtdVin + (__cTabRem)->T_QTDFIS
						nQRemSel := (__cTabRem)->T_QTDFIS - ((nQtdVin + (__cTabRem)->T_QTDFIS) - nQtdIns)
					EndIf
				EndIf

				If nQRemSel < (__cTabRem)->T_QTDCTN
					nQRemSel := (__cTabRem)->T_QTDCTN
				EndIf

				If nQRemSel = 0
					If RecLock(__cTabRem, .F.)
						(__cTabRem)->T_OK     := ""
						(__cTabRem)->T_QTDSEL := 0
						(__cTabRem)->T_QTDDIS := (__cTabRem)->T_QTDFIS - (__cTabRem)->T_QTDSEL

						(__cTabRem)->(MsUnlock())
					EndIf
				ElseIf nQRemSel > 0
					// Não deixa desmarcar uma nota fiscal de remessa que possua quantidade vinculada a container
					If !lMarcar .AND. (__cTabRem)->T_QTDCTN > 0
						lMarcar  := .T.
						nQRemSel := (__cTabRem)->T_QTDCTN
					EndIf

					If RecLock(__cTabRem, .F.)
						(__cTabRem)->T_OK     := IIf(lMarcar, "1", "")
						(__cTabRem)->T_QTDSEL := IIf(lMarcar, nQRemSel, 0)
						(__cTabRem)->T_QTDDIS := (__cTabRem)->T_QTDFIS - (__cTabRem)->T_QTDSEL

						(__cTabRem)->(MsUnlock())
					EndIf											
				EndIf	

				nQtdVin += nQRemSel	

				(__cTabRem)->(DbSkip())
			EndDo
		EndIf			
	EndIf

	RestArea(aAreaRem)

Return .T.

/*{Protheus.doc} RetQtdsFil
Retonar a quantidade instruída e a quantidade vinculada da filial

@author francisco.nunes
@since  03/05/2018
@version 1.0
@param cFilRem, character, Filial da Remessa
@return aQtdsFil, objeto, [1] = Quantidade instruída; [2] = Quantidade vinculada 
@type function
*/
Static Function RetQtdsFil(cFilRem)
	Local aQtdsFil := {}
	Local aAreaFil := (__cTabFil)->(GetArea())
	Local aAreaRem := (__cTabRem)->(GetArea())

	aQtdsFil := {0, 0}

	// Busca na tabela temporária de filiais a quantidade instruída
	DbSelectArea(__cTabFil)
	(__cTabFil)->(DbSetOrder(1))
	If (__cTabFil)->(DbSeek(cFilRem))
		aQtdsFil[1] := (__cTabFil)->T_QTDINS
	EndIf

	// Busca na tabela temporária de remessas a quantidade vinculada
	DbSelectArea(__cTabRem)
	(__cTabRem)->(DbSetOrder(2))
	If (__cTabRem)->(DbSeek(cFilRem))
		While (__cTabRem)->(!Eof()) .AND. (__cTabRem)->(T_FILIAL) == cFilRem
			aQtdsFil[2] += (__cTabRem)->T_QTDSEL

			(__cTabRem)->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaRem)
	RestArea(aAreaFil)

Return aQtdsFil

/*{Protheus.doc} AtualizFil
Atualiza a grid de Filiais

@author francisco.nunes
@since  03/05/2018
@version 1.0
@type function
*/
Static Function AtualizFil()	
	Local aAreaFil := (__cTabFil)->(GetArea())
	Local cQuery   := ""	
	Local cFilRem  := ""
	Local nQtdSel  := 0

	_nQtdVinc := 0
	_nSldVinc := N7Q->N7Q_TOTLIQ

	cQuery := " SELECT T_FILIAL, " 
	cQuery += "        SUM(T_QTDSEL) AS QTREMSEL "
	cQuery += " FROM "+ __cNamRem + " REM "
	cQuery += " GROUP BY T_FILIAL "	

	MPSysOpenQuery(cQuery, 'QRYQREM')

	DbSelectArea('QRYQREM')
	While ('QRYQREM')->(!Eof())

		cFilRem := ('QRYQREM')->(FieldGet(1))
		nQtdSel := ('QRYQREM')->(FieldGet(2))

		DbSelectArea(__cTabFil)
		(__cTabFil)->(DbSetorder(1))
		If (__cTabFil)->(DbSeek(cFilRem))

			If RecLock(__cTabFil, .F.)
				(__cTabFil)->T_QTDVINC := nQtdSel
				(__cTabFil)->T_SLDVINC := IIf((__cTabFil)->T_QTDINS - nQtdSel < 0, 0, (__cTabFil)->T_QTDINS - nQtdSel) 

				(__cTabFil)->T_OK := IIf((__cTabFil)->T_QTDVINC > 0, "1","")

				(__cTabFil)->(MsUnlock())

				_nQtdVinc += (__cTabFil)->T_QTDVINC
				_nSldVinc -= (__cTabFil)->T_QTDVINC
			EndIf
		EndIf

		('QRYQREM')->(DbSkip())
	EndDo	
	('QRYQREM')->(DbCloseArea())

	If _nSldVinc < 0
		_nSldVinc := 0
	EndIf

	oTGet1:Refresh()
	oTGet2:Refresh()

	RestArea(aAreaFil)

Return .T.

/*{Protheus.doc} MarkAllBrw
Seleção de todos os itens do browse [Filiais / Remessas]

@author francisco.nunes
@since  02/05/2018
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

/*{Protheus.doc} InsRegRem
Seleção das notas fiscais de remessa

@author francisco.nunes
@since  02/05/2018
@version 1.0
@param cFiltro, character, Filtro utilizado para seleção das notas fiscais de remessa
@type function
*/
Static Function InsRegRem()
	Local aAreaN7S   := N7S->(GetArea())
	Local cQuery     := ""
	Local cFilsOrg   := ""
	Local cAliasN9I  := GetNextAlias()
	Local cQryInsert := ""
	Local aQtdInsFil := {}
	Local nPos		 := 0
	Local nQtdIns	 := 0
	Local nQtdSel	 := 0

	_nQtdVinc := 0
	_nSldVinc := N7Q->N7Q_TOTLIQ

	// Limpa a tabela temporária
	DbSelectArea(__cTabRem)
	(__cTabRem)->(DbSetorder(1))
	ZAP

	// Limpa a tabela temporária
	dbSelectArea(__cTabFil)
	(__cTabFil)->( dbSetorder(1) )
	ZAP

	// Monta a query de busca
	cQuery := "SELECT N9I.N9I_FILIAL AS FILIAL, "
	cQuery += " 	  N9I.N9I_DOC    AS DOC, "
	cQuery += " 	  N9I.N9I_SERIE  AS SERIE, "
	cQuery += " 	  N9I.N9I_CLIFOR AS CLIFOR, "
	cQuery += " 	  N9I.N9I_LOJA   AS LOJA, "
	cQuery += " 	  N9I.N9I_ITEDOC AS ITEDOC, "	
	cQuery += " 	  N9I.N9I_DOCEMI AS DOCEMI, " 
	cQuery += " 	  N9I2.QTDDIS, " // Quantidade disponível para seleção (N9I_INDSLD = '0')
	cQuery += " 	  N9I3.QTDSELIE, " // Quantidade já selecionada pela IE (N9I_INDSLD = '1')
	cQuery += " 	  N9I4.QTDSELCT, " // Quantidade já selecionada pela container da IE (N9I_INDSLD = '2')
	cQuery += " 	  N9I4.QTDRET  " // Quantidade já retornada pela IE (N9I_INDSLD = '2')
	cQuery += " FROM " + RetSqlName("N9I") + " N9I "

	// Busca a quantidade selecionada e retorna da notas fiscais de remessa não vinculadas nenhuma IE (N9I_INDSLD = '0')
	cQuery += " LEFT OUTER JOIN (SELECT N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_INDSLD, D_E_L_E_T_, SUM(N9I_QTDFIS) AS QTDDIS "
	cQuery += " 		      FROM " + RetSqlName("N9I") + " GROUP BY N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_INDSLD, D_E_L_E_T_) "
	cQuery += "            N9I2 ON N9I2.D_E_L_E_T_ = ' ' AND N9I2.N9I_FILIAL = N9I.N9I_FILIAL AND N9I2.N9I_DOC = N9I.N9I_DOC AND N9I2.N9I_SERIE = N9I.N9I_SERIE "
	cQuery += " 			  AND N9I2.N9I_CLIFOR = N9I.N9I_CLIFOR AND N9I2.N9I_LOJA = N9I.N9I_LOJA AND N9I2.N9I_INDSLD = '0' "

	// Busca a quantidade selecionada e retorna da notas fiscais de remessa vinculadas a IE	(N9I_INDSLD = '1')
	cQuery += " LEFT OUTER JOIN (SELECT N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_INDSLD, N9I_FILORG, N9I_CODINE, D_E_L_E_T_, SUM(N9I_QTDFIS) AS QTDSELIE "
	cQuery += " 		      FROM " + RetSqlName("N9I") + " GROUP BY N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_INDSLD, N9I_FILORG, N9I_CODINE, D_E_L_E_T_) "
	cQuery += "            N9I3 ON N9I3.D_E_L_E_T_ = ' ' AND N9I3.N9I_FILIAL = N9I.N9I_FILIAL AND N9I3.N9I_DOC = N9I.N9I_DOC AND N9I3.N9I_SERIE = N9I.N9I_SERIE "
	cQuery += " 			  AND N9I3.N9I_CLIFOR = N9I.N9I_CLIFOR AND N9I3.N9I_LOJA = N9I.N9I_LOJA AND N9I3.N9I_INDSLD = '1' "	
	cQuery += "               AND N9I3.N9I_FILORG = '"+N7Q->(N7Q_FILIAL)+"' AND N9I3.N9I_CODINE = '"+N7Q->(N7Q_CODINE)+"' "

	// Busca a quantidade selecionada e retorna da notas fiscais de remessa vinculadas ao container da IE (N9I_INDSLD = '2')
	cQuery += " LEFT OUTER JOIN (SELECT N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_INDSLD, N9I_FILORG, N9I_CODINE, D_E_L_E_T_, SUM(N9I_QTDFIS) AS QTDSELCT, SUM(N9I_QTDRET) AS QTDRET "
	cQuery += " 		      FROM " + RetSqlName("N9I") + " GROUP BY N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_INDSLD, N9I_FILORG, N9I_CODINE, D_E_L_E_T_) "
	cQuery += "            N9I4 ON N9I4.D_E_L_E_T_ = ' ' AND N9I4.N9I_FILIAL = N9I.N9I_FILIAL AND N9I4.N9I_DOC = N9I.N9I_DOC AND N9I4.N9I_SERIE = N9I.N9I_SERIE "
	cQuery += " 			  AND N9I4.N9I_CLIFOR = N9I.N9I_CLIFOR AND N9I4.N9I_LOJA = N9I.N9I_LOJA AND N9I4.N9I_INDSLD = '2' "	
	cQuery += "               AND N9I4.N9I_FILORG = '"+N7Q->(N7Q_FILIAL)+"' AND N9I4.N9I_CODINE = '"+N7Q->(N7Q_CODINE)+"' "

	cQuery += " WHERE N9I.D_E_L_E_T_ = ' ' "

	DbSelectArea("N7S")
	N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
	If N7S->(DbSeek(N7Q->(N7Q_FILIAL+N7Q_CODINE)))
		While N7S->(!Eof()) .AND. N7S->(N7S_FILIAL+N7S_CODINE) == N7Q->(N7Q_FILIAL+N7Q_CODINE)

			If N7S->N7S_QTDVIN > 0
				cFilsOrg += "'"+N7S->(N7S_FILORG)+"', "	

				nPos := aScan(aQtdInsFil, {|x| AllTrim(x[1]) == AllTrim(N7S->(N7S_FILORG))})

				If nPos > 0
					aQtdInsFil[nPos][2] += N7S->N7S_QTDVIN
				Else
					Aadd(aQtdInsFil, {N7S->(N7S_FILORG), N7S->N7S_QTDVIN})
				EndIf		
			EndIf

			N7S->(DbSkip())
		EndDo		
	EndIf	

	// Retira o último espaço e virgula
	cFilsOrg := SubStr(cFilsOrg, 1, Len(cFilsOrg) - 2)

	cQuery += " AND N9I.N9I_FILIAL IN (" + cFilsOrg + ") "	
	cQuery += " AND N9I.N9I_CODPRO = '"+N7Q->(N7Q_CODPRO)+"' "
	cQuery += " AND N9I.N9I_CODENT = '"+N7Q->(N7Q_ENTENT)+"' "
	cQuery += " AND N9I.N9I_LOJENT = '"+N7Q->(N7Q_LOJENT)+"' "

	cQuery += "	GROUP BY N9I.N9I_FILIAL, N9I.N9I_DOC, N9I.N9I_SERIE, N9I.N9I_CLIFOR, N9I.N9I_LOJA, N9I.N9I_ITEDOC, N9I.N9I_DOCEMI, N9I2.QTDDIS, N9I3.QTDSELIE, N9I4.QTDSELCT, N9I4.QTDRET "
	cQuery += " ORDER BY N9I.N9I_DOCEMI "

	cQuery := ChangeQuery(cQuery)
	cAliasN9I := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasN9I,.F.,.T.)

	If (cAliasN9I)->(!EoF())
		While (cAliasN9I)->(!EoF())

			nQtdSel := (cAliasN9I)->QTDSELIE + (cAliasN9I)->QTDSELCT

			If nQtdSel = 0 .AND. (cAliasN9I)->QTDDIS = 0
				(cAliasN9I)->(dbSkip())
				LOOP
			EndIf

			cMark := IIf(nQtdSel > 0, "1", " ")

			_nQtdVinc += nQtdSel
			_nSldVinc -= nQtdSel

			cQryInsert := "('"+(cAliasN9I)->FILIAL+"', '"+(cAliasN9I)->DOC+"', '"+(cAliasN9I)->SERIE+"', '"+(cAliasN9I)->CLIFOR+"', '"+(cAliasN9I)->LOJA+"', '"+(cAliasN9I)->ITEDOC+"', '"+(cAliasN9I)->DOCEMI+"', '"+AllTrim(STR(nQtdSel + (cAliasN9I)->QTDDIS))+"',  '"+AllTrim(STR((cAliasN9I)->QTDRET))+"', '"+AllTrim(STR(nQtdSel))+"', '"+AllTrim(STR((cAliasN9I)->QTDDIS))+"', '"+AllTrim(STR((cAliasN9I)->QTDSELCT))+"', '"+cMark+"') "
			TCSqlExec("INSERT INTO "+__cNamRem+" (T_FILIAL, T_DOC, T_SERIE, T_CLIFOR, T_LOJA, T_ITEDOC, T_DOCEMI, T_QTDFIS, T_QTDRET, T_QTDSEL, T_QTDDIS, T_QTDCTN, T_OK) VALUES " + cQryInsert)

			// ****** INSERE NA TABELA TEMPORÁRIA DE FILIAIS ******					
			If !(__cTabFil)->(DbSeek((cAliasN9I)->FILIAL))

				RecLock(__cTabFil, .T.)					
				(__cTabFil)->T_FILIAL  := (cAliasN9I)->FILIAL

				nQtdIns := 0			

				nPos := aScan(aQtdInsFil, {|x| AllTrim(x[1]) == AllTrim((cAliasN9I)->FILIAL)})

				If nPos > 0
					nQtdIns := aQtdInsFil[nPos][2]
				EndIf

				(__cTabFil)->T_QTDINS  := nQtdIns													
			Else
				RecLock(__cTabFil, .F.)
			EndIf

			(__cTabFil)->T_QTDVINC += nQtdSel			
			(__cTabFil)->T_SLDVINC := IIf((__cTabFil)->T_QTDINS - (__cTabFil)->T_QTDVINC < 0, 0, (__cTabFil)->T_QTDINS - (__cTabFil)->T_QTDVINC)
			(__cTabFil)->T_TOTFIS  += nQtdSel + (cAliasN9I)->QTDDIS
			(__cTabFil)->T_QVINCTN += (cAliasN9I)->QTDSELCT
			(__cTabFil)->T_OK	   := IIf((__cTabFil)->T_QTDVINC > 0, "1", "")

			(__cTabFil)->(MsUnlock())

			(cAliasN9I)->(dbSkip())
		EndDo
	EndIf

	(cAliasN9I)->(dbCloseArea())
	
	If _nSldVinc < 0
		_nSldVinc := 0
	EndIf

	// Refresh nos browsers
	TCRefresh(__cNamRem)
	TCRefresh(__cNamFil)

	Restarea(aAreaN7S)

Return .T.

/*{Protheus.doc} VldQtdFil
Valida a quantidade vinculada informada manualmente no browse "Filiais" 

@type function
@author francisco.nunes
@since  02/05/2018
@version 1.0
@param lCancel, logical, Indica se a operação de digitação foi cancelada
@param oBrwObj, object, Objeto do browse alterado
@return lRetorno
*/
Static Function VldQtdFil(lCancel, oBrwObj)

	If lCancel
		Return .T.
	EndIf

	If (oBrwObj:Alias())->T_QTDVINC < 0 
		MsgAlert(STR0016, STR0001) // "A quantidade informada para a filial é inválida." ## "Atenção"
		Return .F.
	EndIf 

	If (oBrwObj:Alias())->T_QTDVINC > (oBrwObj:Alias())->T_TOTFIS
		MsgAlert(STR0018, STR0001) // "A quantidade informada é maior que a soma das quantidades das remessas." ## "Atenção"
		Return .F.
	EndIf

	If (oBrwObj:Alias())->T_QTDVINC < (oBrwObj:Alias())->T_QVINCTN
		MsgAlert(STR0021, STR0001) // "A quantidade informada é menor que a quantidade vinculada em container para Instrução de Embarque." ## "Atenção"
		Return .F.
	EndIf

	/* Atualiza a grid de Remessa */
	/* Será marcado as remessas até a quantidade selecionada informada */
	AtualizRem(oBrwObj:Alias(), "F", .T., .T., (oBrwObj:Alias())->T_QTDVINC)

	/* Atualiza a grid de Filiais */
	AtualizFil()

	__oBrwRem:Refresh(.T.)
	__oBrwFil:LineRefresh()

	__oBrwFil:SetFocus()	

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

	If lCancel
		Return .T.
	EndIf

	If (oBrwObj:Alias())->T_QTDSEL < 0 
		MsgAlert(STR0019, STR0001) // "A quantidade informada para a remessa é inválida." ## "Atenção"
		Return .F.
	EndIf

	If (oBrwObj:Alias())->T_QTDSEL > (oBrwObj:Alias())->T_QTDFIS
		MsgAlert(STR0020, STR0001) // "A quantidade informada é maior que a quantidade da nota fiscal." ## "Atenção" 
		Return .F.
	EndIf

	If (oBrwObj:Alias())->T_QTDSEL < (oBrwObj:Alias())->T_QTDCTN
		MsgAlert(STR0021, STR0001) // "A quantidade informada é menor que a quantidade vinculada a container para Instrução de Embarque." ## "Atenção" 
		Return .F.
	EndIf

	/* Atualiza a grid de Remessa */
	/* Será marcado as remessas até a quantidade selecionada informada */
	AtualizRem(oBrwObj:Alias(), "R", .T., .T., (oBrwObj:Alias())->T_QTDSEL)

	/* Atualiza a grid de Filiais */
	AtualizFil()

	__oBrwFil:Refresh(.T.)
	__oBrwRem:LineRefresh()

	__oBrwRem:SetFocus()

Return .T.

/*{Protheus.doc} GrvRemSel
Grava as notas fiscais de remessas da N9I - Remessa X IE

@author francisco.nunes
@since 02/05/2018
@version 1.0
@param cFilIE, character, Filial da Instrução de Embarque
@param cCodIE, character, Código da Instrução de Embarque
@type function
*/
Static Function GrvRemSel(cFilIE, cCodIE)

	Local nQtdSel := 0

	// Exclui as remessas com indicador "1 - Vinculado a IE" da IE em questão para incluir novamente posteriormente
	// A exclusão irá agrupar novamente os registros para "0 - Saldo"
	OG710AEN9I("1", N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE)

	DbSelectArea((__cTabRem))
	(__cTabRem)->(DbGoTop())
	(__cTabRem)->(DbSetOrder(3)) // Remessas marcadas
	If (__cTabRem)->(DbSeek("1")) 
		While (__cTabRem)->(!Eof()) .AND. (__cTabRem)->T_OK == "1"

			// Envia para gravação apenas a quantidade vinculada a IE (Indicador = '1'), desconsidera a quantidade vinculada a container
			nQtdSel := (__cTabRem)->T_QTDSEL - (__cTabRem)->T_QTDCTN

			If nQtdSel > 0													
				OG710AGN9I((__cTabRem)->T_FILIAL, (__cTabRem)->T_DOC, (__cTabRem)->T_SERIE, (__cTabRem)->T_CLIFOR, (__cTabRem)->T_LOJA, (__cTabRem)->T_ITEDOC, "1", N7Q->N7Q_FILIAL, N7Q->N7Q_CODINE, , nQtdSel)
			EndIf

			(__cTabRem)->(DbSkip())	
		EndDo 
	EndIf

Return .T.

/*{Protheus.doc} OG710AEN9I
Reagrupa/Exclui as notas fiscais de remessas da N9I - Remessa X IE

@author francisco.nunes
@since 03/05/2018
@version 1.0
@param cIndSld, character, Indicador de saldo (0=Saldo;1=Vinculado IE;2=Vinculado Contêiner)
@param cFilOrg, character, Filial da Instrução de Embarque
@param cCodIE, character, Código da Instrução de Embarque
@param cCodCtn, character, Código do container
@type function
*/
Function OG710AEN9I(cIndSld, cFilOrg, cCodIE, cCodCtn)
	Local aAreaN9I  := N9I->(GetArea())
	Local nQtdFis   := 0	
	Local cChaveN9I := ""
	Local nIt		:= 0
	Local nItStr    := 0
	Local aCpsN9I   := {}	
	Local cCampos	:= ""
	Local cIndSld2  := ""
	Local aAgrN9I	:= {}
	Local lNovo		:= .T.	
	Local cFilDoc	:= ""
	Local cDoc		:= ""
	Local cSerie	:= ""
	Local cCliFor	:= ""
	Local cLoja		:= ""
	Local cIteDoc	:= ""
	Local cSeqN9I	:= ""
	Local cSeek     := ""

	Default cCodCtn := ""

	cChaveN9I := cIndSld+cFilOrg+cCodIE
	If cIndSld == "2" .Or. cIndSld == "3"
		cCampos := "N9I_INDSLD|N9I_CONTNR"
		cSeek   := cChaveN9I + cCodCtn
	Else
		cCampos   := "N9I_INDSLD|N9I_FILORG|N9I_CODINE|N9I_CODCTR|N9I_ITEM|N9I_SEQPRI|N9I_ITEFLO"
		cSeek   := cChaveN9I
	EndIF

	DbSelectArea("N9I")
	aStrN9I := N9I->(DbStruct())	

	N9I->(DbSetOrder(3)) // N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR
	If N9I->(DbSeek(cSeek))
		While N9I->(!Eof()) .AND. N9I->(N9I_INDSLD+N9I_FILORG+N9I_CODINE) == cChaveN9I .AND. ;
		(N9I->N9I_CONTNR == cCodCtn .OR. cIndSld == "1"  )

			lNovo := .T.

			For nIt := 1 To Len(aAgrN9I)		
				If AScan(aAgrN9I[nIt], {|x| AllTrim(x[2]) == N9I->(N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC)}) > 0
					nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_QTDFIS"})
					aAgrN9I[nIt][nPos][2] += N9I->N9I_QTDFIS
					lNovo := .F.

					EXIT												
				EndIf
			Next nIt

			If lNovo
				aCpsN9I := {}

				// Grava a chave para busca posterior
				Aadd(aCpsN9I, {"CHAVE", N9I->(N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC)})

				// Busca os campos da N9I para realizar a cópia
				// Os campos na variável cCampos NÃO serão considerados
				For nItStr := 1 To Len(aStrN9I)											
					If !Empty(N9I->&(AllTrim(aStrN9I[nItStr][1]))) .AND. !AllTrim(aStrN9I[nItStr][1]) $ cCampos
						Aadd(aCpsN9I, {aStrN9I[nItStr][1], N9I->&(AllTrim(aStrN9I[nItStr][1]))})
					EndIf													
				Next nItStr

				Aadd(aAgrN9I, aCpsN9I)
			EndIf

			If cIndSld == "1"
				ConsQtdRem(N9I->N9I_FILORG, N9I->N9I_CODINE, N9I->N9I_CODCTR, N9I->N9I_ITEM, N9I->N9I_SEQPRI, N9I->N9I_QTDFIS, .F.)
			EndIf

			If RecLock("N9I", .F.)		
				N9I->(DbDelete())						
				N9I->(MsUnlock())
			EndIf

			N9I->(DbSkip())			
		EndDo				
	EndIf	

	If cIndSld == "1" // Vinculado a IE
		cIndSld2 := "0"
	ElseIf cIndSld == "2" .Or. cIndSld == "3" // Vinculado Container
		cIndSld2 := "1"
	EndIf

	For nIt := 1 to Len(aAgrN9I)

		cChaveN9I := aAgrN9I[nIt][1][2]+cIndSld2

		N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
		If N9I->(DbSeek(cChaveN9I))
			nQtdFis := 0

			If nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_QTDFIS"})
				nQtdFis := aAgrN9I[nIt][nPos][2]
			EndIf

			If RecLock("N9I", .F.)
				N9I->N9I_QTDFIS += nQtdFis

				If cIndSld == "1" .Or. cIndSld == "2"
					N9I->N9I_QTDSLR := N9I->N9I_QTDFIS
				EndIf				
				N9I->(MsUnlock())
			EndIf
		Else
			nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_FILIAL"})
			cFilDoc := aAgrN9I[nIt][nPos][2]

			nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_DOC"})
			cDoc := aAgrN9I[nIt][nPos][2]

			nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_SERIE"})
			cSerie := aAgrN9I[nIt][nPos][2]

			nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_CLIFOR"})
			cCliFor := aAgrN9I[nIt][nPos][2]

			nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_LOJA"})
			cLoja := aAgrN9I[nIt][nPos][2]

			nPos := AScan(aAgrN9I[nIt], {|x| AllTrim(x[1]) == "N9I_ITEDOC"})
			cIteDoc := aAgrN9I[nIt][nPos][2]

			// Retorna o sequencial para inclusão na N9I
			cSeqN9I := OG710ARITF(cFilDoc, cDoc, cSerie, cCliFor, cLoja, cIteDoc)

			If RecLock("N9I", .T.)
				// Começa da segunda posição, pois a primeira é a chave
				For nItStr := 2 To Len(aAgrN9I[nIt])
					N9I->&(AllTrim(aAgrN9I[nIt][nItStr][1])) := aAgrN9I[nIt][nItStr][2]
				Next nItStr

				N9I->N9I_ITEFLO := cSeqN9I
				N9I->N9I_INDSLD := cIndSld2
				N9I->(MsUnlock())
			EndIf
		EndIf	

	Next nIt	

	RestArea(aAreaN9I)	
Return .T.

/*{Protheus.doc} OG710AGN9I
Grava as notas fiscais de remessas da N9I - Remessa X IE

@author francisco.nunes
@since 03/05/2018
@version 1.0
@type function
*/
Function OG710AGN9I(cFilRem, cDoc, cSerie, cCliFor, cLoja, cIteDoc, cIndSld, cFilOrg, cCodIE, cCodCtn, nQtdFis) 
	Local aAreaN9I  := N9I->(GetArea())
	Local aAreaN7S  := N7S->(GetArea())
	Local nItStr    := 0
	Local aStrN9I   := {}
	Local aCpsN9I   := {}
	Local cIndSld2  := ""
	Local cCodCtr   := ""
	Local cItPrev   := ""
	Local cItRef    := ""
	Local nQtdN9I   := nQtdFis
	Local cAliasQry := ""
	Local cQuery    := ""
	Local nQtdIns	:= 0
	Local nQtdRem	:= 0
	Local cChaveTab	:= ''

	Default cCodCtn := ""

	If cIndSld == "1"
		cAliasQry := GetNextAlias()
		cQuery := "SELECT SUM(N7S.N7S_QTDVIN) AS QTDINS, "
		cQuery += "       SUM(N7S.N7S_QTDREM) AS QTDREM "
		cQuery += "  FROM " + RetSqlName("N7S") + " N7S "
		cQuery += " WHERE N7S.N7S_FILIAL = '"+N7Q->N7Q_FILIAL+"' "
		cQuery += "   AND N7S.N7S_CODINE = '"+N7Q->N7Q_CODINE+"' "
		cQuery += "   AND N7S.N7S_FILORG = '"+cFilRem+"' "
		cQuery += "   AND N7S.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)	
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		DbSelectArea(cAliasQry)
		(cAliasQry)->(DbGoTop())

		If !(cAliasQry)->(Eof())
			nQtdIns := (cAliasQry)->QTDINS
			nQtdRem := (cAliasQry)->QTDREM
		EndIf

		DbSelectArea("N7S")
		N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
		If N7S->(DbSeek(N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE))				
			While N7S->(!Eof()) .AND. N7S->(N7S_FILIAL+N7S_CODINE) == N7Q->N7Q_FILIAL+N7Q->N7Q_CODINE			
				If N7S->N7S_FILORG == cFilRem .AND. N7S->N7S_QTDVIN > N7S->N7S_QTDREM
					cCodCtr := N7S->N7S_CODCTR
					cItPrev := N7S->N7S_ITEM
					cItRef  := N7S->N7S_SEQPRI

					If nQtdFis > (N7S->N7S_QTDVIN - N7S->N7S_QTDREM)
						// Realiza para saber se o remetido está ultrapassando o instruído, ou seja, se é o última regra fiscal da filial da IE
						// Caso o instruído (total por filial) seja maior que o remetido (total por filial) não é a última regra fiscal
						If nQtdIns > nQtdRem + nQtdFis 
							nQtdN9I := N7S->N7S_QTDVIN - N7S->N7S_QTDREM
						EndIf
					EndIf																															
				EndIf	

				N7S->(DbSkip())							
			EndDo				
		EndIf
	EndIf

	DbSelectArea("N9I")
	aStrN9I := N9I->(DbStruct())

	If cIndSld == "1"	
		If Empty(cCodCtn) .AND. (nPos := aScan(aStrN9I, {|x| AllTrim(x[1]) == "N9I_CONTNR" })) > 0		
			cCodCtn := SPACE(aStrN9I[nPos][3])
		EndIf	
	EndIf

	N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
	If N9I->(DbSeek(cFilRem+cDoc+cSerie+cCliFor+cLoja+cIteDoc+cIndSld+cFilOrg+cCodIE+cCodCtn+cCodCtr+cItPrev+cItRef))			
		If RecLock("N9I", .F.)
			N9I->N9I_QTDFIS += nQtdN9I

			If cIndSld == "1" .Or. cIndSld == "2" 
				N9I->N9I_QTDSLR := N9I->N9I_QTDFIS
			EndIf			
			N9I->(MsUnlock())
		EndIf
	Else
		If cIndSld == "1" // Vinculado a IE
			cIndSld2 := "0"	
			cChaveTab := cFilRem+cDoc+cSerie+cCliFor+cLoja+cIteDoc+cIndSld2
		EndIf

		If cIndSld == "2" .Or. cIndSld == "3" // Container
			cIndSld2 := "1"
			cChaveTab := cFilRem+cDoc+cSerie+cCliFor+cLoja+cIteDoc+cIndSld2+cFilOrg+cCodIE
		EndIf

		If N9I->(DbSeek(cChaveTab))

			// Caso a quantidade a ser incluída seja menor que a quantidade do registro, será realizado a quebra 
			If nQtdN9I < N9I->N9I_QTDFIS .Or. cIndSld == "3"

				// Subtrai a quantidade do registro encontrado, pois será realizado a quebra do mesmo
				If RecLock("N9I", .F.)
					If cIndSld <> "3"
						N9I->N9I_QTDFIS := N9I->N9I_QTDFIS - nQtdN9I
						N9I->N9I_QTDSLR := N9I->N9I_QTDFIS
					Else
						N9I->N9I_QTDANT := N9I->N9I_QTDANT + nQtdN9I 
					EndIf
					N9I->(MsUnlock())
				EndIf	

				If cIndSld == "1"
					cCampos := "N9I_INDSLD|N9I_FILORG|N9I_CODINE|N9I_CODCTR|N9I_ITEM|N9I_SEQPRI|N9I_ITEFLO"
				ElseIf cIndSld == "2" .Or. cIndSld == "3"
					cCampos := "N9I_INDSLD|N9I_QTDANT"
				EndIF						
				// Busca os campos da N9I para realizar a cópia
				// Os campos na variável cCampos NÃO serão considerados
				For nItStr := 1 To Len(aStrN9I)											
					If !Empty(N9I->&(AllTrim(aStrN9I[nItStr][1]))) .AND. !AllTrim(aStrN9I[nItStr][1]) $ cCampos
						Aadd(aCpsN9I, {aStrN9I[nItStr][1], N9I->&(AllTrim(aStrN9I[nItStr][1]))})
					EndIf
				Next nItStr

				// Retorna o sequencial para inclusão na N9I
				cSeqN9I := OG710ARITF(cFilRem, cDoc, cSerie, cCliFor, cLoja, cIteDoc)				

				// Insere um novo registro na N9I
				If RecLock("N9I", .T.)
					For nItStr := 1 To Len(aCpsN9I)
						N9I->&(AllTrim(aCpsN9I[nItStr][1])) := aCpsN9I[nItStr][2]
					Next nItStr

					N9I->N9I_ITEFLO := cSeqN9I 
					N9I->N9I_INDSLD := cIndSld
					N9I->N9I_QTDFIS := nQtdN9I
					N9I->N9I_QTDSLR := N9I->N9I_QTDFIS

					If cIndSld == "2" .Or. cIndSld == "3"
						N9I->N9I_CONTNR := cCodCtn
					Else
						N9I->N9I_FILORG := cFilOrg
						N9I->N9I_CODINE := cCodIE
						N9I->N9I_DESINE := Posicione("N7Q", 1, xFilial("N7Q")+cCodIE, "N7Q_DESINE")
						N9I->N9I_CODCTR := cCodCtr
						N9I->N9I_ITEM   := cItPrev
						N9I->N9I_SEQPRI := cItRef
					EndIF

					N9I->(MsUnlock())					
				EndIf	

				// Caso não, ou seja, o valor é igual, apenas será alterado o N9I_INDSLD e os demais campos							
			Else
				If RecLock("N9I", .F.)
					N9I->N9I_INDSLD := cIndSld

					If cIndSld == "1"
						N9I->N9I_FILORG := cFilOrg
						N9I->N9I_CODINE := cCodIE
						N9I->N9I_DESINE := Posicione("N7Q", 1, xFilial("N7Q")+cCodIE, "N7Q_DESINE")
						N9I->N9I_CODCTR := cCodCtr
						N9I->N9I_ITEM   := cItPrev
						N9I->N9I_SEQPRI := cItRef						
					EndIf

					If cIndSld == "2" .Or. cIndSld == "3"
						N9I->N9I_CONTNR := cCodCtn
					EndIF

					N9I->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf

	If cIndSld == "1"
		ConsQtdRem(cFilOrg, cCodIE, cCodCtr, cItPrev, cItRef, nQtdN9I, .T.)
	EndIf

	If cIndSld == "1" .AND. nQtdFis <> nQtdN9I
		nQtdFis := nQtdFis - nQtdN9I

		OG710AGN9I(cFilRem, cDoc, cSerie, cCliFor, cLoja, cIteDoc, cIndSld, cFilOrg, cCodIE, cCodCtn, nQtdFis)			 
	EndIf

	RestArea(aAreaN9I)
	RestArea(aAreaN7S)

Return .T.

/*{Protheus.doc} OG710ARITF
Retorna o sequencial para inclusão da N9I (N9I_ITEFLO)

@author francisco.nunes
@since 03/05/2018
@version 1.0
@type function
*/
Function OG710ARITF(cFilDoc, cDoc, cSerie, cCliFor, cLoja, cIteDoc)
	Local cItFlo    := ""
	Local cSeqInic  := ""
	Local cAliasQry := ""
	Local cQry		:= ""
	Local aStrN9I	:= {}
	Local nPos		:= 0

	DbSelectArea("N9I")
	aStrN9I := N9I->(DbStruct())

	If (nPos := aScan(aStrN9I, {|x| AllTrim(x[1]) == "N9I_ITEFLO" })) > 0
		cSeqInic := StrZero(1, aStrN9I[nPos][3])
	EndIf

	cAliasQry := GetNextAlias()
	cQry := " SELECT N9I.N9I_ITEFLO "
	cQry += "   FROM " + RetSqlName("N9I") + " N9I "
	cQry += "  WHERE N9I.N9I_FILIAL = '"+ cFilDoc +"' "   
	cQry += "    AND N9I.N9I_DOC    = '"+ cDoc +"' "   
	cQry += "    AND N9I.N9I_SERIE  = '"+ cSerie +"' "
	cQry += "    AND N9I.N9I_CLIFOR = '"+ cCliFor +"' "
	cQry += "    AND N9I.N9I_LOJA   = '"+ cLoja +"' "
	cQry += "    AND N9I.N9I_ITEDOC = '"+ cIteDoc +"' "
	cQry += "    AND N9I.D_E_L_E_T_ = ' ' "
	cQry += "    AND N9I.N9I_ITEFLO IN (SELECT MAX(N9I2.N9I_ITEFLO) "
	cQry += "	                     	  FROM " + RetSqlName("N9I") + " N9I2 "
	cQry += "							 WHERE N9I2.N9I_FILIAL = N9I.N9I_FILIAL "   
	cQry += "    						   AND N9I2.N9I_DOC    = N9I.N9I_DOC "   
	cQry += "    						   AND N9I2.N9I_SERIE  = N9I.N9I_SERIE "
	cQry += "   						   AND N9I2.N9I_CLIFOR = N9I.N9I_CLIFOR "
	cQry += "    						   AND N9I2.N9I_LOJA   = N9I.N9I_LOJA "
	cQry += "    						   AND N9I2.N9I_ITEDOC = N9I.N9I_ITEDOC "
	cQry += "		                  	   AND N9I2.D_E_L_E_T_ = ' ') "				
	cQry := ChangeQuery(cQry)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	If !(cAliasQry)->(Eof())
		cItFlo := Soma1((cAliasQry)->N9I_ITEFLO)
	Else
		cItFlo := cSeqInic
	EndIf

Return cItFlo

/*{Protheus.doc} ConsQtdRem
Consome a quantidade remetida das entregas da Instrução de Embarque (N7S_QTDREM)

@author francisco.nunes
@since 03/05/2018
@version 1.0
@param, cFilIE, character, Filial da Instrução de Embarque
@param, cCodIE, character, Código da Instrução de Embarque
@param, cCodCtr, character, Contrato da Instrução de Embarque
@param, cItPrev, character, Previsão de entrega da Instrução de Embarque
@param, cItRef, character, Regra fiscal da Instrução de Embarque
@param, nQtdRem, number, Quantidade da remessa
@param, lSoma, logical, .T. - Soma na N7S_QTDREM; .F. - Subtrai na N7S_QTDREM
@type function
*/
Static Function ConsQtdRem(cFilIE, cCodIE, cCodCtr, cItPrev, cItRef, nQtdRem, lSoma)

	DbSelectArea("N7S")
	N7S->(DbSetOrder(1)) // N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
	If N7S->(DbSeek(cFilIE+cCodIE+cCodCtr+cItPrev+cItRef))
		If RecLock("N7S", .F.)
			If lSoma
				N7S->N7S_QTDREM += nQtdRem
				If N7S->N7S_QTDVIN < N7S->N7S_QTDREM //Se a Quantidade Instruída é menor que a quantidade da remessa então recebe a quantidade da remessa
					N7S->N7S_QTDVIN := N7S->N7S_QTDREM
				EndIf
			Else
				N7S->N7S_QTDREM -= nQtdRem
			EndIf
			N7S->(MsUnlock())
		EndIf
	EndIf

	DbSelectArea("N7Q")
	N7Q->(DbSetOrder(1)) // N7Q_FILIAL+N7Q_CODINE
	If N7Q->(DbSeek(cFilIE+cCodIE))
		If RecLock("N7Q", .F.)
			If lSoma
				N7Q->N7Q_QTDREM += nQtdRem
				If N7Q->N7Q_TOTLIQ < N7Q->N7Q_QTDREM //Se Total Líquido menor que o total vinculado de remessas então recebe o total vinculado de remessas
					N7Q->N7Q_TOTLIQ := N7Q->N7Q_QTDREM
				EndIf
				If N7Q->N7Q_TOTBRU < N7Q->N7Q_QTDREM //Se Total Bruto menor que o total vinculado de remessas então recebe o total vinculado de remessas
					N7Q->N7Q_TOTBRU := N7Q->N7Q_QTDREM
				EndIf
			Else
				N7Q->N7Q_QTDREM -= nQtdRem
			EndIf
			N7Q->(MsUnlock())
		EndIf			
	EndIf

Return .T.

/*{Protheus.doc} ValQtdSel
(Antes de Sair, verifica a quantidade selecionada de acordo com a quantidade instruída)

@type function
@author francisco.nunes
@since  07/05/2018
@version 1.0
@param nQtdVinc, number, Quantidade de remessas vinculadas 
@param nOpcX, number, 1 - Salvar das remessas, 0 - Não salvar as remessas (erro)
@return lRet
*/
Static Function ValQtdSel(nQtdVinc, nOpcX)
	Local lRet 		:= .T.
	Local nQtdMaxima := 0
	Local cMsg 		:= ""

	// Validação Qtd máxima da Instrução
	nQtdMaxima := N7Q->N7Q_LIMMAX * ((100 - N7Q->N7Q_PERMAX) / 100) 

	If nQtdMaxima > 0 .AND. nQtdVinc > nQtdMaxima
		lRet  := .F.			
		cMsg := STR0022 + _CRLF + _CRLF // Quantidade total das remessas vinculados acima do permitido na Instrução de Embarque.
		cMsg += STR0023 + " " + cValToChar(nQtdMaxima) + _CRLF + _CRLF  // "Qtd. Máx. permitida na Instrução de Embarque: "
		cMsg += STR0024 + " " + cValToChar(nQtdVinc) + _CRLF + _CRLF   // "Qtd. Vinculada:"		 
	EndIf

	If !Empty(cMsg)
		MsgAlert(cMsg, STR0001)  
	EndIf	

	If lRet
		nOpcX := 1
	EndIf

Return lRet

/*{Protheus.doc} OG710AAREM
//Atualiza vínculo das notas de remessa com IE conforme fardos selecionados (Apenas para algodão)

Ao marcar um fardo sem DXI_CODINE -> Soma ou inclusão de um registro na N9I com INDSLD = '1' - Vinculado a IE 
e subtração ou exclusão do registro da N9I com INDSLD = '0' - Saldo

Ao desmarcar um fardo com DXI_CODINE -> Subtração ou exclusão de um registro na N9I com INDSLD = '1' - Vinculado a IE 
e soma ou inclusão de um registro da N9I com INDSLD = '0' - Saldo

@author tamyris.g
@since 17/05/2018
@version 1.0
@param lMarcar, .T. - Fardo marcado na IE; .F. - Fardo desmarcado na IE
@param cFilIE, Filial da Instrução de Embarque
@param cCodIE, Código da Instrução de Embarque
@param cDesIne, Código informado da Instrução de Embarque (N7Q_DESINE)
@type static function
*/
Function OG710AAREM(lMarcar, cFilIE, cCodIE, cDesIne)

	Local nQtdVinc  := 0
	Local cCodCtr   := ""
	Local cPrevEt   := ""
	Local cRefFis   := ""
	Local nItStr    := 0
	Local aStrN9I   := {}
	Local aCpsN9I   := {}
	Local cCampos   := ""
	Local cSeqN9I   := ""
	Local cChaveIE  := ""
	Local cChvSaldo := ""

	DbSelectArea("N9I")
	aStrN9I := N9I->(DbStruct())

	// Buscar o contrato, previsão de entrega e regra fiscal de venda do fardo no movimento de Take-up
	DbSelectArea("N9D")
	N9D->(DbSetOrder(5)) // N9D_FILIAL+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS
	If N9D->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+'02'+'2')) //Verifica se existe movimentação de Romaneio
		cCodCtr := N9D->N9D_CODCTR
		cPrevEt := N9D->N9D_ITEETG		
		cRefFis := N9D->N9D_ITEREF
	EndIf

	// Buscar o movimento de trânsito (Romaneio de Formação de Lote)
	DbSelectArea("N9D")
	N9D->(DbSetOrder(5)) // N9D_FILIAL+N9D_SAFRA+N9D_FARDO+N9D_TIPMOV+N9D_STATUS
	If N9D->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+'08'+'2')) //Verifica se existe movimentação de Romaneio

		nQtdVinc := N9D->N9D_PESINI

		// Busca a nota fiscal de remessa do romaneio de formação de lote
		cAliasQry := GetNextAlias()
		cQuery := " SELECT N8K_FILIAL, N8K_DOC, N8K_SERIE, N8K_CLIFOR, N8K_LOJA, N8K_ITEDOC "                                                                          
		cQuery += " FROM " + RetSqlName('NJM')+ " NJM "

		cQuery += " INNER JOIN " + RetSqlName("N8K") + " N8K "
		cQuery += "    ON N8K.N8K_FILIAL = NJM.NJM_FILIAL "
		cQuery += "   AND N8K.N8K_CODROM = NJM.NJM_CODROM "
		cQuery += "   AND N8K.N8K_ITEROM = NJM.NJM_ITEROM "
		cQuery += "   AND N8K.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE NJM.D_E_L_E_T_ = ' ' "
		cQuery += "   AND NJM.NJM_FILIAL = '" + N9D->N9D_FILORG  + "' "
		cQuery += "   AND NJM.NJM_CODROM = '" + N9D->N9D_CODROM  + "' "
		cQuery += "   AND NJM.NJM_CODCTR = '" + N9D->N9D_CODCTR  + "' "
		cQuery += "   AND NJM.NJM_ITEM   = '" + N9D->N9D_ITEETG  + "' "
		cQuery += "   AND NJM.NJM_SEQPRI = '" + N9D->N9D_ITEREF  + "' "
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

		DbSelectArea(cAliasQry)  
		(cAliasQry)->(DbGoTop())
		If (cAliasQry)->(!Eof())

			cChaveIE  := (cAliasQry)->N8K_FILIAL+(cAliasQry)->N8K_DOC+(cAliasQry)->N8K_SERIE+(cAliasQry)->N8K_CLIFOR+;
			(cAliasQry)->N8K_LOJA+(cAliasQry)->N8K_ITEDOC+"1"+cFilIE+cCodIE+SPACE(TamSX3("N9I_CONTNR")[1])+;
			cCodCtr+cPrevEt+cRefFis

			cChvSaldo := (cAliasQry)->N8K_FILIAL+(cAliasQry)->N8K_DOC+(cAliasQry)->N8K_SERIE+(cAliasQry)->N8K_CLIFOR+;
			(cAliasQry)->N8K_LOJA+(cAliasQry)->N8K_ITEDOC+"0"

			// Busca o vínculo da remessa com a IE com INDSLD = "0 - Saldo"		
			N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
			If N9I->(DbSeek(cChvSaldo))

				If RecLock("N9I", .F.)					
					If lMarcar
						If N9I->N9I_QTDFIS - nQtdVinc = 0
							N9I->(DbDelete())
						Else
							N9I->N9I_QTDFIS -= nQtdVinc
							N9I->N9I_QTDSLR -= nQtdVinc
						EndIf
					Else
						N9I->N9I_QTDFIS += nQtdVinc
						N9I->N9I_QTDSLR += nQtdVinc
					EndIf				

					N9I->(MsUnlock())
				EndIf
			ElseIf !lMarcar		

				// Busca o vínculo da remessa com a IE com INDSLD = "1 - Vinculado a IE"
				N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI			
				If N9I->(DbSeek(cChaveIE))

					cCampos := "N9I_INDSLD|N9I_FILORG|N9I_CODINE|N9I_DESINE|N9I_CODCTR|N9I_ITEM|N9I_SEQPRI"

					// Busca os campos da N9I para realizar a cópia
					// Os campos na variável cCampos NÃO serão considerados
					// O array aCpsN9I é utilizado para inclusão da N9I com INDSLD = '0'
					For nItStr := 1 To Len(aStrN9I)											
						If !Empty(N9I->&(AllTrim(aStrN9I[nItStr][1]))) .AND. !AllTrim(aStrN9I[nItStr][1]) $ cCampos

							If AllTrim(aStrN9I[nItStr][1]) == "N9I_ITEFLO"
								// Retorna o sequencial para inclusão na N9I
								cSeqN9I := OG710ARITF(N9I->N9I_FILIAL, N9I->N9I_DOC, N9I->N9I_SERIE, N9I->N9I_CLIFOR, N9I->N9I_LOJA, N9I->N9I_ITEDOC)
								Aadd(aCpsN9I, {"N9I_ITEFLO", cSeqN9I})
							Else									
								Aadd(aCpsN9I, {aStrN9I[nItStr][1], N9I->&(AllTrim(aStrN9I[nItStr][1]))})
							EndIf
						EndIf													
					Next nItStr				
				EndIf

				If RecLock("N9I", .T.)
					// Looping para inserção dos valores copiados anteriormente
					// Na exclusão do vínculo com INDSLD = '1', quando a quantidade do vínculo - quantidade a retirar é igual a 0
					For nItStr := 1 To Len(aCpsN9I)
						N9I->&(AllTrim(aCpsN9I[nItStr][1])) := aCpsN9I[nItStr][2]
					Next nItStr

					N9I->N9I_QTDFIS := nQtdVinc
					N9I->N9I_QTDRET := 0
					N9I->N9I_QTDSLR := nQtdVinc
					N9I->N9I_INDSLD := "0" // Saldo					
					N9I->(MsUnlock())
				EndIf

			EndIf

			// Busca o vínculo da remessa com a IE com INDSLD = "1 - Vinculado a IE"			
			N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI
			If N9I->(DbSeek(cChaveIE))

				If RecLock("N9I", .F.)			
					If lMarcar
						N9I->N9I_QTDFIS += nQtdVinc
						N9I->N9I_QTDSLR += nQtdVinc
					Else
						If N9I->N9I_QTDFIS - nQtdVinc = 0							
							N9I->(DbDelete())																																																																					
						Else
							N9I->N9I_QTDFIS -= nQtdVinc
							N9I->N9I_QTDSLR -= nQtdVinc
						EndIf
					EndIf

					N9I->(MsUnlock())
				EndIf									
			ElseIf lMarcar

				// Busca o vínculo da remessa com a IE com INDSLD = "0 - Saldo"
				N9I->(DbSetOrder(5)) // N9I_FILIAL+N9I_DOC+N9I_SERIE+N9I_CLIFOR+N9I_LOJA+N9I_ITEDOC+N9I_INDSLD+N9I_FILORG+N9I_CODINE+N9I_CONTNR+N9I_CODCTR+N9I_ITEM+N9I_SEQPRI			
				If N9I->(DbSeek(cChvSaldo))

					cCampos := "N9I_INDSLD|N9I_QTDFIS|N9I_QTDRET|N9I_QTDSLR|N9I_ITEFLO"

					// Busca os campos da N9I para realizar a cópia
					// Os campos na variável cCampos NÃO serão considerados
					For nItStr := 1 To Len(aStrN9I)											
						If !Empty(N9I->&(AllTrim(aStrN9I[nItStr][1]))) .AND. !AllTrim(aStrN9I[nItStr][1]) $ cCampos
							Aadd(aCpsN9I, {aStrN9I[nItStr][1], N9I->&(AllTrim(aStrN9I[nItStr][1]))})
						EndIf													
					Next nItStr

					// Retorna o sequencial para inclusão na N9I
					cSeqN9I := OG710ARITF(N9I->N9I_FILIAL, N9I->N9I_DOC, N9I->N9I_SERIE, N9I->N9I_CLIFOR, N9I->N9I_LOJA, N9I->N9I_ITEDOC)

					If RecLock("N9I", .T.)
						// Looping para inserção dos valores copiados anteriormente
						For nItStr := 1 To Len(aCpsN9I)
							N9I->&(AllTrim(aCpsN9I[nItStr][1])) := aCpsN9I[nItStr][2]
						Next nItStr

						N9I->N9I_QTDFIS := nQtdVinc
						N9I->N9I_QTDRET := 0
						N9I->N9I_QTDSLR := nQtdVinc
						N9I->N9I_ITEFLO := cSeqN9I
						N9I->N9I_INDSLD := "1" // Vinculado a IE
						N9I->N9I_FILORG := cFilIE
						N9I->N9I_CODINE := cCodIE
						N9I->N9I_DESINE := cDesIne			
						N9I->N9I_CODCTR := cCodCtr
						N9I->N9I_ITEM   := cPrevEt
						N9I->N9I_SEQPRI := cRefFis
						N9I->(MsUnlock())
					EndIf					
				EndIf											
			EndIf	


		EndIf 
		(cAliasQry)->(DbCloseArea())
	EndIf

Return .T.

/*/{Protheus.doc} OG710ARGIE
//TODO Rolagem das notas fiscais de remessa (N9I) - Grãos
@author francisco.nunes / claudineia.reinert
@since 12/07/2018
@version 2.0
@param oModelN7Q, object, Model de N7Q da IE
@param cIEOrig, characters, Codigo da instrução de embarque de origem da rolagem
@param aItRolagem, array, itens da tela de itens de rolagem do grão
@type function
/*/
Function OG710ARGIE(oModelN7Q, cIEOrig, aItRolagem)

	Local nX		 := 0
	Local nY		 := 0
	Local aRemRol	 := {}
	Local aItN7S 	 := aItRolagem[1] //regras fiscal 
	Local aItens 	 := {}

	// Ajustar as remessas da IE de Origem (N9I) por regra fiscal da IE (N7S)		
	For nX := 1 to Len(aItN7S)		
		If Len(aItN7S[nX][9]) > 0 //tem remessa para rolagem na N7S
			aRemRol := aItN7S[nX][9] //remessas para rolagem
			For nY := 1 to Len(aRemRol)	
				AADD(aItens, { aRemRol[nY][1], aRemRol[nY][2] })
			Next nY	//aRemRol		
		EndIf
	Next nX	//aItN7S
		
	If Len(aItens) > 0 
		//Faz a rolagem das notas de remessa
		OG710ARLRM( oModelN7Q, cIEOrig, aItens)
	EndIf

Return .T.

/*/{Protheus.doc} OG710ARRFR
//TODO Rolagem das Notas de Remessa dos fardos selecionados na instrução de embarque
@author claudineia.reinert
@since 12/07/2018
@version 1.0
@param cCodIE, characters, Codigo da instrução de embarque de origem da rolagem
@type function
/*/
Function OG710ARRFR(oModelN7Q, cIEOrig)
	Local aItens := {}
	Local cQry 	    := ""
	Local cAliasQry := GetNextAlias()

	//busca no banco de dados o recno e peso das notas de remessa(N9I) para rolagem 
	cQry := " SELECT N9I_DOC, N9I.R_E_C_N_O_ AS RECNO , SUM(N9D2.N9D_PESFIM) AS PESO "
	cQry += " FROM " + RetSqlName("N9D") + " N9D "
			/* NA N9I BUSCA AS NFs DE REMESSA PARA A IE DE ORIGEM DA ROLAGEM*/
	cQry += " INNER JOIN " + RetSqlName("N9I") + " N9I ON N9I.D_E_L_E_T_ = ' ' "
	cQry += "     AND N9I_FILORG = N9D.N9D_FILORG AND N9I_CODINE = '"+ cIEOrig +"' " 
			/* NA N9D DE ROMANEIO PELA IE DE REMESSA DA N9I BUSCA O PESO DOS FARDOS NA REMESSA CONFORME OS FARDOS DA IE DE VENDA */
	cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D2 ON N9D2.D_E_L_E_T_ = ' '  "
	cQry += "     AND N9D2.N9D_CODINE = N9I.N9I_CODINR AND N9D2.N9D_TIPMOV = '07' AND N9D2.N9D_STATUS='2' " 
	cQry += "     AND N9D2.N9D_CODROM = N9I.N9I_CODROM AND N9D2.N9D_ITEROM = N9I.N9I_ITEROM " 
	cQry += "     AND N9D2.N9D_FILIAL = N9D.N9D_FILIAL AND N9D2.N9D_FARDO = N9D.N9D_FARDO "
	cQry += " WHERE N9D.D_E_L_E_T_ = ' ' AND N9D.N9D_FILORG = '"+ FWxFilial("N7Q") +"' "
	cQry += " AND N9D.N9D_CODINE = '"+ oModelN7Q:GetValue("N7Q_CODINE") +"' "
	cQry += " AND N9D.N9D_TIPMOV = '04' AND N9D.N9D_STATUS='2' " //N9D PARA INSTRUÇÃO DE EMBARQUE
	cQry += " GROUP BY N9I_DOC,N9I.R_E_C_N_O_ "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		//armazena os registros para rolagem da notas de remessa
		AADD(aItens, { (cAliasQry)->RECNO, (cAliasQry)->PESO })
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	If Len(aItens) > 0
		//Faz a rolagem das notas de remessa
		OG710ARLRM( oModelN7Q, cIEOrig, aItens)
	EndIf

Return .T.

/*/{Protheus.doc} OG710ARLRM
//TODO Realiza a Rolagem das notas de remessa(N9I) das instruções de embarque
@author claudineia.reinert
@since 12/07/2018
@version undefined
@param oModelN7Q, object, descricao
@param cIEOrig, characters, descricao
@param aItens, array, array com os recno da N9I e a quantidade a ser rolada - {nRecno,nQtd}
@type function
/*/
Static Function OG710ARLRM( oModelN7Q, cIEOrig, aItens)

	Local nX		 := 0
	Local nQtdRetRF	 := 0	
	Local nItStr	 := 0
	Local aCpsN9I    := {}
	Local aStrN9I	 := {}
	Local cSeqN9I    := ""
	Local lRolRem 	 := .F.

	N9I->(DbSelectArea("N9I"))
	aStrN9I := N9I->(DbStruct())

	// Ajustar as remessas da IE de Origem (N9I) por regra fiscal da IE (N7S)		
	For nX := 1 to Len(aItens)		
		N9I->(dbGoto(aItens[nX][1])) //posiciona no registro pelo r_e_c_n_o_
		//encontrou o registro da remessa na N9I
		If N9I->N9I_QTDFIS = aItens[nX][2]
			//se qtd da rolagem igual a origem, rola registro todo
			If RecLock("N9I", .F.)
				N9I->N9I_CODINE := oModelN7Q:GetValue('N7Q_CODINE')	
				N9I->N9I_DESINE := oModelN7Q:GetValue('N7Q_DESINE')			
				N9I->N9I_QTDANT := 0 //SERÁ ajustada DEPOIS
				N9I->(MsUnlock())
				lRolRem := .T. //fez rolagem da remessa
			EndIf
		Else
			//qtd rolagem é menor
			For nItStr := 1 To Len(aStrN9I)		
				//copia a estrutura para criar um novo registro
				If !Empty(N9I->&(AllTrim(aStrN9I[nItStr][1]))) .AND.; 
				!aStrN9I[nItStr][1] $ "N9I_ITEFLO|N9I_CODINE|N9I_DESINE|N9I_QTDFIS|N9I_QTDRET|N9I_QTDSLR|N9I_QTDANT"
					Aadd(aCpsN9I, {aStrN9I[nItStr][1], N9I->&(AllTrim(aStrN9I[nItStr][1]))})
				EndIf
			Next nItStr	
			// Retorna o sequencial para inclusão na N9I
			cSeqN9I := OG710ARITF(N9I->N9I_FILIAL, N9I->N9I_DOC, N9I->N9I_SERIE, N9I->N9I_CLIFOR, N9I->N9I_LOJA, N9I->N9I_ITEDOC)
			//Seta valores nos campos da estrutura da N9I que será criada
			Aadd(aCpsN9I, {"N9I_ITEFLO", cSeqN9I})
			Aadd(aCpsN9I, {"N9I_CODINE", oModelN7Q:GetValue('N7Q_CODINE')})
			Aadd(aCpsN9I, {"N9I_DESINE", oModelN7Q:GetValue('N7Q_DESINE')})
			Aadd(aCpsN9I, {"N9I_QTDFIS", aItens[nX][2]})
			If N9I->N9I_QTDRET > (N9I->N9I_QTDFIS - aItens[nX][2]) 
				//se qtd retorno da remessa for maior que a qtd fiscal a ser rolada
				// calcula a qtd de retorno que ficará no registro novo conforme qtd a ser rolada
				nQtdRetRF := N9I->N9I_QTDRET - (N9I->N9I_QTDFIS - aItens[nX][2])
			EndIf
			Aadd(aCpsN9I, {"N9I_QTDRET", nQtdRetRF})
			Aadd(aCpsN9I, {"N9I_QTDSLR", ( aItens[nX][2] - nQtdRetRF ) })	
			//ajusta o registro atual N9I, com as qtd que ira ficar - IE origem da rolagem
			If RecLock("N9I", .F.)
				N9I->N9I_QTDFIS := N9I->N9I_QTDFIS - aItens[nX][2]
				N9I->N9I_QTDRET := N9I->N9I_QTDRET - nQtdRetRF	
				N9I->N9I_QTDSLR := N9I->N9I_QTDFIS - N9I->N9I_QTDRET													
				N9I->(MsUnlock())
			EndIf
			//cria novo registro para IE de rolagem
			If RecLock("N9I", .T.)
				For nItStr := 1 To Len(aCpsN9I)
					N9I->&(AllTrim(aCpsN9I[nItStr][1])) := aCpsN9I[nItStr][2]
				Next nItStr
				N9I->(MsUnlock())
				lRolRem := .T. //fez rolagem da remessa
			EndIf										
		EndIf

	Next nX	//aItens		

	If lRolRem
		// Teve rolagem de remessa
		// A principio foi definido que NÃO será feita rolagem do registro N9I_INDSLD=3
		// Definido que se teve rolagem de remessa, na IE de origem será excluido as N9I com N9I_INDSLD=3, e zerado o N9I_QTDANT dos registros N9I_INDSLD=1 e N9I_INDSLD=2
		For nX := 1 to 3	
			cSeek := cValToChar(nX)+N9I_FILORG+cIEOrig  //ordem do indice 6
			N9I->( dbSetOrder( 6 ) )//N9I_INDSLD+N9I_FILORG+N9I_CODINE
			If N9I->( dbSeek( cSeek ) )
				While N9I->(!Eof()) .AND. N9I->(N9I_INDSLD+N9I_FILORG+N9I_CODINE) == cSeek
					If N9I->N9I_INDSLD == "3"  .AND. RecLock("N9I", .F.)					
						N9I->(DbDelete()) 
						N9I->(MsUnlock())
					ElseIf N9I->N9I_INDSLD $ "1|2"  .AND. RecLock("N9I", .F.)	
						N9I->N9I_QTDANT := 0
						N9I->(MsUnlock())
					EndIf
					If !Empty(N9I->N9I_CONTNR)
						//SE TEM CONTAINER LIMPA QTD ANTECIPADA DO CONTAINER
						N91->(DbSelectArea("N91"))
						N91->( dbSetOrder( 1 ) ) //N91_FILIAL+N91_CODINE+N91_CONTNR
						If N91->( dbSeek( FWxFilial("N91")+N9I->N9I_CODINE+N9I->N9I_CONTNR ) )
							If RecLock("N91", .F.)	
								N91->N91_QTDANT := 0
								N91->(MsUnlock())
							EndIf
						EndIf
					EndIf
					N9I->(DbSkip())
				EndDo
			EndIf
		Next nX	
	EndIf	

Return lRolRem
