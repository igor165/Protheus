#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'DBTREE.CH'
#INCLUDE "PCPA144.CH"
#INCLUDE "PCPA144DEF.CH"

Static soMenu
Static __oInfProd := JsonObject():New()
Static __oInfHWB  := JsonObject():New()
Static __oProdPai := JsonObject():New()
Static __lUsaME   := usaME()

Static _lMRPExport := ExistBlock("MRPExport")
Static _lP144ATGR  := ExistBlock("P144ATGR")
Static _lP144BTN   := ExistBlock("P144BTN")
Static _lP144COL   := ExistBlock("P144COL")
Static _lP144ITM   := ExistBlock("P144ITM")
Static _lP144VLGD  := ExistBlock("P144VLGD")

/*/{Protheus.doc} PCPA144
Resultados do MRP

@author douglas.heydt
@since 15/11/2019
@version 1.0
/*/
Function PCPA144()

	Local cTitulo    := STR0001//"Resultados MRP"

	Private oTGet1, oTGet2, oTGet3, oTGet4, oTGet5, oTGet6
	Private aTamanhos     := FWGetDialogSize(oMainwnd)
	Private aProdutos     := {}
	Private aResults      := {}
	Private aSubsts       := {}
	Private aTransfers    := {}
	Private aParMRP       := {}
	Private aDocs 	      := {}
	Private cTicket       := Space(6)
	Private cPeriodo      := Space(15)
	Private cDataIni      := Space(10)
	Private cDataFim      := Space(10)
	Private cFiltroPrd    := Space(GetSx3Cache("B1_COD", "X3_TAMANHO" ))
	Private cStatus       := Space(50)
	Private nActiveFld    := 1
	Private oParJson      := JsonObject():New()
	Private oJsParametros := JsonObject():New()
	Private nPosGR1Btn    := 0
	Private nWidthDif     := 0
	Private lOpenLat      := .T.
	Private lSubsMont     := Nil
	Private oDlg, oLayer, oFont
	Private oPnlPai, oPnlCab, oPnlFold, oPnlProd, oPnlRslt1, oPnlRslt, oPnlDocs, oPnlEst, oPnlResult, oPnlSubst, oPnlTransf
	Private oFolderDoc
	Private oBrwResult, oBrwDocs, oBrwSubst, oBrwProd, oBrwTrans
	Private oGetComp, oGetDesc, oGetQtd, oGetDocto
	Private oConTicket, oConParam, oAlteracao
	Private oButton, oButton2, oButton3, oButton4, oButton5, oBtnGR1, oButton6, oButton7, oButtonExp, oBtnCustom
	Private nRE_DATA   := 0
	Private nRE_ESTOQU := 0
	Private nRE_ENTRAD := 0
	Private nRE_SAIDAS := 0
	Private nRE_SAIEST := 0
	Private nRE_TRAENT := 0
	Private nRE_TRASAI := 0
	Private nRE_SALDOF := 0
	Private nRE_NECESS := 0
	Private nRE_FLAG   := 0
	Private nRE_TAM    := 0
	Private nDC_FILIAL := 0
	Private nDC_DOCFIL := 0
	Private nDC_QTNEOR := 0
	Private nDC_QTSLES := 0
	Private nDC_QTBXES := 0
	Private nDC_QTEMPE := 0
	Private nDC_QTSUBS := 0
	Private nDC_TRAENT := 0
	Private nDC_TRASAI := 0
	Private nDC_QTRENT := 0
	Private nDC_QTRSAI := 0
	Private nDC_QTNECE := 0
	Private nDC_LOCAL  := 0
	Private nDC_DATA   := 0
	Private nDC_DTINIC := 0
	Private nDC_TPDCPA := 0
	Private nDC_DOCPAI := 0
	Private nDC_PRDPAI := 0
	Private nDC_TRT    := 0
	Private nDC_REV    := 0
	Private nDC_ROTEIR := 0
	Private nDC_OPERAC := 0
	Private nDC_TDCERP := 0
	Private nDC_DOCERP := 0
	Private nDC_VERSAO := 0
	Private nDC_CHAVE  := 0
	Private nDC_CHVSUB := 0
	Private nDC_SEQUEN := 0
	Private nDC_FLAG   := 0
	Private nDC_TAM    := 0

	Default lAutoMacao    := .F.

	If GetRpoRelease() < "12.1.025"
		HELP(' ',1,"Release" ,,STR0209,2,0,,,,,,) //"Rotina disponível a partir do release 12.1.25."
		Return
	EndIf

	//verifica se a filial atual pode executar a rotina
	If !chkFilExec()
		Return
	EndIf

	LoadMVPar("PCPA144FIL", .F.)
	LoadMVPar("PCPA144GR1", .F.)

	IF !lAutoMacao
		oFont := TFont():New( , , 14, , .F.,,,,, .F. , .F.)

		oDlg := MSDialog():New( aTamanhos[1],aTamanhos[2],aTamanhos[3],aTamanhos[4],cTitulo,,,.F.,,,,,,.T.,,,.T. )

		//Cria o painel principal
		oPnlPai := TPanel():New(01,01,,oDlg,,,,,,aTamanhos[4]/2,(aTamanhos[3]/2)-5,.T.,.T.)

		oLayer := FWLayer():New()
		oLayer:Init(oPnlPai,.T.)

		oLayer:addCollumn("ColunaEsq",25,.F.)
		oLayer:addCollumn("ColunaDir",75,.F.)

		oLayer:setColSplit("ColunaEsq",CONTROL_ALIGN_RIGHT,,{||lOpenLat := !lOpenLat, RefreshRes(.T.) })

		oLayer:addWindow("ColunaEsq",'C_Win04',STR0032,100,.T.,.T.,{||RefreshRes() },,{|| }) //"Produtos"

		oPnlProd  := oLayer:getWinPanel("ColunaEsq",'C_Win04')

		oPnlRslt1 := TPanel():New(01,01,,oPnlProd,,,,,,(oPnlProd:nClientWidth*0.5),,.T.,.T.)
		oPnlRslt1:Align :=CONTROL_ALIGN_LEFT

		oLayer:addWindow("ColunaDir",'C_Win01',STR0002,21,.T.,.T.,{||RefreshRes() },,{|| }) //"Ticket"
		oLayer:addWindow("ColunaDir",'C_Win02',STR0033,30,.T.,.F.,{||RefreshRes() },,{|| }) //"Resultados"
		oLayer:addWindow("ColunaDir",'C_Win03',STR0004,49,.T.,.F.,{||RefreshRes() },,{|| }) //"Documentos"

		oPnlCab  := oLayer:getWinPanel("ColunaDir",'C_Win01')
		oPnlResult := oLayer:getWinPanel("ColunaDir",'C_Win02')
		oPnlFold := oLayer:getWinPanel("ColunaDir",'C_Win03')

		oPnlRslt := TPanel():New(01,01,,oPnlResult,,,,,,(oPnlResult:nClientWidth*0.5),,.T.,.T.)
		oPnlRslt:Align :=CONTROL_ALIGN_ALLCLIENT

		oFolderDoc := TFolder():New(0,0,{STR0004, STR0005, STR0006, STR0247},{"HEAD1","HEAD2","HEAD3","HEAD4"},oPnlFold,,,,.T.,.F.,oPnlFold:nClientWidth*0.5,(oPnlFold:nClientHeight*0.5),)  //"Documentos", "Estoque", "Substituição", "Transferências"
		oFolderDoc:Align := CONTROL_ALIGN_ALLCLIENT
		oFolderDoc:bSetOption := {|nFolder| chgFolder(nFolder)}
		If !kendoOk()
			oFolderDoc:HidePage( 2 )
			oFolderDoc:ShowPage( 1 )
		EndIf
		If !usaME()
			oFolderDoc:HidePage( 4 )
			oFolderDoc:ShowPage( 1 )
		EndIf

		oPnlDocs := TPanel():New(01,200,,oFolderDoc:aDialogs[1],,,,, ,,,.T.,.T.)
		oPnlDocs:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlEst := TPanel():New(01,200,,oFolderDoc:aDialogs[2],,,,, ,,,.T.,.T.)
		oPnlEst:Align := CONTROL_ALIGN_ALLCLIENT
		nPosGR1Btn     := oPnlEst:nClientWidth - 45
		nWidthDif     := ((oPnlEst:nClientWidth / 0.75) - nPosGR1Btn) * 0.9

		oPnlSubst := TPanel():New(0,0,,oFolderDoc:aDialogs[3],,,,,,,,.T.,.T.)
		oPnlSubst:Align := CONTROL_ALIGN_ALLCLIENT

		If usaME()
			oPnlTransf := TPanel():New(0,0,,oFolderDoc:aDialogs[4],,,,,,,,.T.,.T.)
			oPnlTransf:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf

		//Classe para o controle das alterações
		oAlteracao := AlteracaoResultado():New()

		montaCab()
		gridProd()
		gridResult()
		gridDocs()

		ACTIVATE MSDIALOG oDlg CENTERED

		oAlteracao:Destroy()
		FreeObj(soMenu)
	ENDIF

Return Nil

/*/{Protheus.doc} montaCab
Monta cabeçalho da rotina

@author douglas.heydt
@since 15/11/2019
@version 1.0
/*/
Static Function montaCab()

	Local cLabel   := ""
	Local nTamanho := 0
	Local oSay     := 1

	/*PRIMEIRA LINHA*/
	oSay       := TSay():New(04, 05, {|| STR0007}, oPnlCab, ,oFont , , , , .T., , , 20, 20) //"Ticket:"
	oSay:SetTextAlign(1, 0)
	oTGet1     := TGet():New(01, 30, {|u| If(PCount()>0, cTicket:=u, cTicket)}, oPnlCab, 30, 13, "@!", {|| vldTicket(cTicket, @aParMrp)}, 0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.F.,.F.,/*23*/,"cTicket")
	oTGet1:cF3 := "PCPA144F3()"

	oButton3   := TButton():New(01, 68, STR0015, oPnlCab, {|| FWMsgRun(,{|| vldTicket(cTicket, @aParMrp), AtuProduto()},STR0038,STR0039)}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Consultar" - "Carregando dados..." "Aguarde"

	oSay       := TSay():New(04, 130, {|| STR0241}, oPnlCab, ,oFont , , , , .T., , , 20, 20) //"Status:"
	oSay:SetTextAlign(1, 0)
	oTGet2     := TGet():New(01, 155, {|u| If(PCount()>0, cStatus:=u, cStatus)}, oPnlCab, 100, 13, "",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cStatus")

	oButton    := TButton():New(01, 270, STR0012, oPnlCab, {|| AbreParam()}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Parâmetros MRP"
	oButton5   := TButton():New(01, 325, STR0118, oPnlCab, {|| LoadMVPar("PCPA144FIL", .T.)}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Filtros"

	nTamanho := GetSx3Cache("HWM_TICKET", "X3_TAMANHO")
	If nTamanho != Nil .AND. nTamanho > 0
		oButton6 := TButton():New(01, 380, STR0190, oPnlCab, {|| PCPA144Log()}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Eventos"
	EndIf

	//Exibe o botão específico para exportação
	If _lMRPExport
		oButtonExp := TButton():New(01, 435, STR0210, oPnlCab, {|| ExecBlock("MRPExport",.F.,.F.,{cTicket})}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Exportar"
	EndIf

	//Exibe o botão específico para tratamentos diversos
	If _lP144BTN
		cLabel     := ExecBlock("P144BTN", .F., .F., {cTicket, 1})
		oBtnCustom := TButton():New(21, 435, cLabel, oPnlCab, {|| ExecBlock("P144BTN", .F., .F., {cTicket, 2})}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.)
    EndIf

	//SEGUNDA LINHA
	oSay   := TSay():New(23, 05, {|| STR0009}, oPnlCab, ,oFont , , , , .T., , , 20, 20) //"Período:"
	oSay:SetTextAlign(1, 0)
	oTGet3 := TGet():New(21, 30, {|u| If(PCount()>0, cPeriodo := u, cPeriodo)}, oPnlCab, 90, 13, "@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cPeriodo")

	oSay   := TSay():New(23, 130, {|| STR0010}, oPnlCab, ,oFont , , , , .T., , , 20, 20) //"Início:"
	oSay:SetTextAlign(1, 0)
	oTGet4 := TGet():New(21, 155, {|u| If(PCount()>0, cDataIni := u, cDataIni)}, oPnlCab, 40, 13, "@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cDataIni")

	oSay   := TSay():New(23, 190, {|| STR0011 }, oPnlCab, ,oFont , , , , .T., , , 20, 20) //"Fim:"
	oSay:SetTextAlign(1, 0)
	oTGet5 := TGet():New(21, 215, {|u| If(PCount()>0, cDataFim := u, cDataFim)}, oPnlCab, 40, 13, "@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cDataFim")

	oButton7 := TButton():New(21, 270, STR0214, oPnlCab,{|| TelaSalvar()}   , 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Salvar"
	oButton7:Disable()
	oButton2 := TButton():New(21, 325, STR0014, oPnlCab,{|| gerarDocs()}    , 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Gerar"
	oButton4 := TButton():New(21, 380, STR0013, oPnlCab,{|| FechaTela(oDlg)}, 50, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //"Fechar"

Return Nil

/*/{Protheus.doc} gridProd
Cria a grid de produtos

@author douglas.heydt
@since 15/11/2019
@version 1.0
/*/
Static Function gridProd()
	Local aHeaders	 := {}
	Local aColSizes	 := {}

	oTGet6     := TGet():New( 05, 03,{|u| If(PCount()>0,cFiltroPrd:=u,cFiltroPrd)},oPnlRslt1,95,13,"@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.F.,.F.,/*23*/,"cFiltroPrd")
	oTGet6:cF3 := "SB1"

	oButton6  := TButton():New( 05, 100, STR0015 ,oPnlRslt1,{|| ConsultPrd()}, 45,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	IniAProd()

	aAdd(aHeaders, STR0036                 ) //"Código"
	aAdd(aHeaders, STR0037                 ) //"Descrição"
	aAdd(aHeaders, STR0155                 ) //"Opcional"
	aAdd(aHeaders, FWX3Titulo("B1_ESTSEG") ) //Estoque de segurança
	aAdd(aHeaders, FWX3Titulo("B1_EMIN"  ) ) //Ponto de pedido
	aAdd(aHeaders, FWX3Titulo("B1_LE"    ) ) //Lote econômico
	aAdd(aHeaders, FWX3Titulo("B1_QE"    ) ) //Quantidade de embalagem
	aAdd(aHeaders, FWX3Titulo("B1_PE"    ) ) //Prazo de entrega
	aAdd(aHeaders, FWX3Titulo("B1_TIPE"  ) ) //Tipo prazo entrega

	aAdd(aColSizes, 50) //"Código"
	aAdd(aColSizes, 50) //"Descrição"
	aAdd(aColSizes, 40) //"Opcional"
	aAdd(aColSizes, 20) //Estoque de segurança
	aAdd(aColSizes, 45) //Ponto de pedido
	aAdd(aColSizes, 45) //Lote econômico
	aAdd(aColSizes, 40) //Quantidade de embalagem
	aAdd(aColSizes, 20) //Prazo de entrega
	aAdd(aColSizes, 25) //Tipo prazo entrega

	oBrwProd := TWBrowse():New(023,001, oPnlRslt1:nClientWidth*0.5, (oPnlRslt1:nClientHeight*0.5)-23, , aHeaders, aColSizes, oPnlRslt1,,,, /*bChange*/, , /*bRClick*/, , , /*nClrFore*/,,,,, .T.,, ,{|| .T.}, .T., .T. )
	AtuBrwPrd()
	oBrwProd:bChange := { || AtuResulta(oBrwProd:nAt) }

	MenuContxt()

Return .T.

/*/{Protheus.doc} ConsultPrd
Realizar a consulta de um produto no grid.

@author renan.roeder
@since 23/03/2020
@version 1.0
/*/
Static Function ConsultPrd()
	Local lRet   := .T.
	Local nPos   := 0
	Local nStart := 0

	IF !Empty(cFiltroPrd) .And. Len(aProdutos) > 0 .And. !Empty(aProdutos[1][IND_APRODUTOS_CODIGO])

		If AllTrim(cFiltroPrd) $ aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO]
			nStart := oBrwProd:nAt + 1
		Else
			nStart := 1
		EndIf

		nPos := AScan(aProdutos, {|x| AllTrim(cFiltroPrd) $ x[IND_APRODUTOS_CODIGO] },nStart)
		If nPos > 0
			oBrwProd:GoPosition(nPos)
			oBrwProd:Refresh()
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} gridResult
Cria a grid de resultados

@author douglas.heydt
@since 15/11/2019
@version 1.0
/*/
Static Function gridResult()
	Local aAlter     := {}
	Local aCabCustom := {}
	Local aHeaderRes := {}
	Local cTitulo    := ""
	Local cValid     := ""
	Local nDecimal   := 0
	Local nIndex     := 0
	Local nLenCabCus := 0
	Local nPos       := 1
	Local nTamanho   := 0
	Default lAutoMacao := .F.

	cTitulo  := STR0017 //"Período"
	nTamanho := 8
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_DATA","",nTamanho,nDecimal,cValid,"û","D",""})
	nRE_DATA := nPos
	nPos++

	cTitulo  := STR0005 //"Estoque"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_QTSLES","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nRE_ESTOQU := nPos
	nPos++

	cTitulo  := STR0018 //"Entradas"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_QTENTR","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nRE_ENTRAD := nPos
	nPos++

	cTitulo  := STR0019 //"Saídas"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_QTSAID","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nRE_SAIDAS := nPos
	nPos++

	cTitulo  := STR0020 //"Saída Estrut."
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_QTSEST","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nRE_SAIEST := nPos
	nPos++

	If usaME()
		cTitulo  := STR0248 //"Transf. Entrada"
		nTamanho := 12
		nDecimal := 2
		cValid   := ""
		aAdd(aHeaderRes,{cTitulo,"HWB_QTRENT","@E 999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})
		nRE_TRAENT := nPos
		nPos++
		
		cTitulo  := STR0249 //"Transf. Saída"
		nTamanho := 12
		nDecimal := 2
		cValid   := ""
		aAdd(aHeaderRes,{cTitulo,"HWB_QTRSAI","@E 999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})
		nRE_TRASAI := nPos
		nPos++
	EndIf

	cTitulo  := STR0034 //"Saldo Final"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_QTSALD","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nRE_SALDOF := nPos
	nPos++

	cTitulo  := STR0021 //"Necessidade"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderRes,{cTitulo,"HWB_QTNECE","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nRE_NECESS := nPos
	nPos++

	//Ponto de entrada para incluir colunas nos grids de resultados e documentos
	If _lP144COL
        aCabCustom := ExecBlock("P144COL",.F.,.F.,{"gridResult",aHeaderRes})
		nLenCabCus := Len(aCabCustom)
		For nIndex := 1 To nLenCabCus
			aAdd(aHeaderRes,{	aCabCustom[nIndex][1],;
								aCabCustom[nIndex][2],;
								aCabCustom[nIndex][3],;
								aCabCustom[nIndex][4],;
								aCabCustom[nIndex][5],;
								aCabCustom[nIndex][6],;
								aCabCustom[nIndex][7],;
								aCabCustom[nIndex][8],;
								aCabCustom[nIndex][9]})
			nPos++									
		Next nIndex
    EndIf

	nRE_FLAG := nPos
	nRE_TAM := nPos

	IniAResul()

	IF !lAutoMacao
		oBrwResult := MsNewGetDados():New(001,001,oPnlRslt:nClientHeight*0.5,oPnlRslt:nClientWidth*0.5,GD_UPDATE,/*LinhaOk*/,/*tudoOk*/,/*IniCpos*/,aAlter,0,1000,,,"AllwaysFalse",oPnlRslt,aHeaderRes,aResults,{|| AtuDocs() })
		oBrwResult:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwResult:oBrowse:lUseDefaultColors := .F.
		oBrwResult:oBrowse:SetBlkBackColor({|| GETDCLR(aResults,oBrwResult:nAt)})
		oBrwResult:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
	ENDIF

Return .T.

/*/{Protheus.doc} GETDCLR
Retorna a cor para a linha da grid.

@author lucas.franca
@since 06/02/2020
@version 1.0
/*/
Static Function GETDCLR(aLinha, nLinha)
	Local nCor2 := RGB(28, 157, 189) //Azul
	Local nCor3 := RGB(255, 255, 255) //Branco
	Local nRet := nCor3

	If Len(aLinha) >= nLinha .And. nLinha > 0
		If aLinha[nLinha][Len(aLinha[nLinha])]
			nRet := nCor2
		Else
			nRet := nCor3
		Endif
	EndIf
Return nRet

/*/{Protheus.doc} gridDocs
Cria a grid de documentos

@author douglas.heydt
@since 15/11/2019
@version 1.0
/*/
Static Function gridDocs()
	Local aAlter     := {"HWC_QTNECE"}
	Local aCabCustom := {}
	Local aHeaderDoc := {}
	Local cCBOX      := GetSx3Cache("VR_TIPO","X3_CBOX")
	Local cTitulo    := ""
	Local cValid     := ""
	Local nDecimal   := 0
	Local nIndex     := 0
	Local nLenCabCus := 0
	Local nPos       := 1
	Local nTamanho   := 0
	Default lAutoMacao := .F.

	cCBOX += ";" + AllTrim(STR0126) + "=" + AllTrim(STR0130) //";OP=Ordem de Produção"
	cCBOX += ";" + AllTrim(STR0127) + "=" + AllTrim(STR0131) //";Pré-OP=Ordem de Produção Pré Existente"
	cCBOX += ";" + AllTrim(STR0128) + "=" + AllTrim(STR0132) //";Est.Seg.=Estoque de Segurança"
	cCBOX += ";" + AllTrim(STR0129) + "=" + AllTrim(STR0133) //";Ponto Ped.=Ponto de Pedido"
	cCBOX += ";" + "0"              + "=" + AllTrim(STR0160) //";0=Consolidado"
	cCBOX += ";" + "SUBPRD"         + "=" + AllTrim(STR0181) //";SUBPRD=Subproduto de OP"
	cCBOX += ";" + "AGL"            + "=" + AllTrim(STR0246) //";AGL=Necessidade aglutinada"
	cCBOX += ";" + "TRANF_PR"       + "=" + AllTrim(STR0256) //";TRANF_PR=Transferência de produção"
	cCBOX += ";" + "TRANF_ES"       + "=" + AllTrim(STR0267) //";TRANF_ES=Transferência de estoque"
	cCBOX += ";" + "ESTNEG"         + "=" + AllTrim(STR0276) //";ESTNEG=Estoque inicial negativo"
	cCBOX += ";" + "LTVENC"         + "=" + AllTrim(STR0281) //";LTVENC=Lote vencido"

	If usaME()
		cTitulo  := STR0055 // "Filial"
		nTamanho := FwSizeFilial()
		nDecimal := 0
		cValid   := ""
		aAdd(aHeaderDoc,{cTitulo,"HWC_FILIAL","",nTamanho,nDecimal,cValid," ","C",""})
		nDC_FILIAL := nPos
		nPos++
	EndIf

	cTitulo  := STR0023 //"Número"
	nTamanho := 11
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_DOCFIL","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_DOCFIL := nPos
	nPos++

	cTitulo  := STR0159 //"Necessidade Original"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_QTNEOR","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nDC_QTNEOR := nPos
	nPos++

	cTitulo  := STR0103 //"Estoque"
	nTamanho := 12
	nDecimal := 3
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_QTSLES","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nDC_QTSLES := nPos
	nPos++

	cTitulo  := STR0104 //"Baixa"
	nTamanho := 14
	nDecimal := 2
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_QTBXES","@E 99,999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})
	nDC_QTBXES := nPos
	nPos++

	cTitulo  := STR0105 //"Empenho"
	nTamanho := 12
	nDecimal := 2
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_QTEMPE","@E 999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})
	nDC_QTEMPE := nPos
	nPos++

	cTitulo  := STR0106 //"Substituição"
	nTamanho := 12
	nDecimal := 2
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_QTSUBS","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})
	nDC_QTSUBS := nPos
	nPos++

	If usaME()
		cTitulo  := STR0248 //"Transf. Entrada"
		nTamanho := 12
		nDecimal := 2
		cValid   := ""
		aAdd(aHeaderDoc,{cTitulo,"HWC_QTRENT","@E 999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})
		nDC_TRAENT := nPos
		nPos++

		cTitulo  := STR0249 //"Transf. Saída"
		nTamanho := 12
		nDecimal := 2
		cValid   := ""
		aAdd(aHeaderDoc,{cTitulo,"HWC_QTRSAI","@E 999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})
		nDC_TRASAI := nPos
		nPos++
	EndIf

	cTitulo  := STR0024 //"Quantidade"
	nTamanho := 12
	nDecimal := 3
	cValid   := "A144VldNec()"
	aAdd(aHeaderDoc,{cTitulo,"HWC_QTNECE","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N","",/*10*/,/*11*/,/*12*/,"A144When()","A"})
	nDC_QTNECE := nPos
	nPos++

	cTitulo  := STR0025 //"Armazém"
	nTamanho := 2
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_LOCAL","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_LOCAL := nPos
	nPos++

	cTitulo  := STR0026 //"Entrega"
	nTamanho := 8
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_DATA","",nTamanho,nDecimal,cValid,"û","D","",})
	nDC_DATA := nPos
	nPos++

	cTitulo  := STR0260 //"Início"
	nTamanho := 8
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWB_DTINIC","",nTamanho,nDecimal,cValid,"û","D","",})
	nDC_DTINIC := nPos
	nPos++

	cTitulo  := STR0022 //"Tipo Pai"
	nTamanho := 30
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_TPDCPA","",nTamanho,nDecimal,cValid,"û","C","",,cCBOX})
	nDC_TPDCPA := nPos
	nPos++

	cTitulo  := STR0027 //"Documento pai"
	nTamanho := 50
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_DOCPAI","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_DOCPAI := nPos
	nPos++

	cTitulo  := STR0261 //"Produto Pai"
	nTamanho := GetSx3Cache("B1_COD", "X3_TAMANHO")
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_PRODUT","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_PRDPAI := nPos
	nPos++

	cTitulo  := STR0107 //"TRT"
	nTamanho := 3
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_TRT","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_TRT := nPos
	nPos++

	cTitulo  := STR0028 //"Revisão"
	nTamanho := 3
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_REV","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_REV := nPos
	nPos++

	cTitulo  := STR0035 //"Roteiro"
	nTamanho := 2
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_ROTEIR","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_ROTEIR := nPos
	nPos++

	cTitulo  := STR0183 //"Operação"
	nTamanho := 2
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_OPERAC","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_OPERAC := nPos
	nPos++

	cTitulo  := STR0184 //"Tp.Doc.ERP"
	nTamanho := 1
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_TDCERP","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_TDCERP := nPos
	nPos++

	cTitulo  := STR0029 //"Documento ERP"
	nTamanho := 14
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_DOCERP","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_DOCERP := nPos
	nPos++

	cTitulo  := STR0154 //"Versão da produção"
	nTamanho := 4
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderDoc,{cTitulo,"HWC_VERSAO","",nTamanho,nDecimal,cValid,"û","C",""})
	nDC_VERSAO := nPos
	nPos++

	If _lP144COL
        aCabCustom := ExecBlock("P144COL",.F.,.F.,{"gridDocs",aHeaderDoc})
		nLenCabCus := Len(aCabCustom)
		For nIndex := 1 To nLenCabCus
			aAdd(aHeaderDoc,{	aCabCustom[nIndex][1],;
								aCabCustom[nIndex][2],;
								aCabCustom[nIndex][3],;
								aCabCustom[nIndex][4],;
								aCabCustom[nIndex][5],;
								aCabCustom[nIndex][6],;
								aCabCustom[nIndex][7],;
								aCabCustom[nIndex][8],;
								aCabCustom[nIndex][9]})
			nPos++									
		Next nIndex 
    EndIf

	nDC_CHAVE := nPos
	nPos++
	nDC_CHVSUB := nPos
	nPos++
	nDC_SEQUEN := nPos
	nPos++
	nDC_FLAG := nPos
	nPos++
	nDC_TAM := nPos
	IniADocs()

	IF !lAutoMacao
		oBrwDocs := MsNewGetDados():New(001,001,oPnlDocs:nClientHeight*0.5,oPnlDocs:nClientWidth*0.5,GD_UPDATE,/*LinhaOk*/,/*tudoOk*/,/*IniCpos*/,aAlter,0,1000,,,"AllwaysFalse",oPnlDocs,aHeaderDoc,aDocs,{|| changeDocs()})
		oBrwDocs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwDocs:oBrowse:lUseDefaultColors := .F.
		oBrwDocs:oBrowse:SetBlkBackColor({|| GETDCLR(aDocs,oBrwDocs:nAt)})
		oBrwDocs:oBrowse:SetBlkColor( { || RGB(0,0,0) } )
	ENDIF

Return .T.

/*/{Protheus.doc} AtuProduto
Carrega os produtos conforme o ticket informado em tela.

@return lRet, Logico, Indica se a api encontrou registros para atualizar no grid.
@author renan.roeder
@since 21/11/2019
@version 1.0
/*/
Static Function AtuProduto()
	Local aResProd := {}
	Local aResOpc  := {}
	Local aItems   := {}
	Local cError   := ""
	Local lRet     := .T.
	Local nX       := 0
	Local nIndPrd  := 0
	Local nTamPrd  := TamSX3("B1_COD")[1]
	Local nLenIte  := 0
	Local nOpcao   := 0
	Local oJsonRes := JsonObject():New()

	If oAlteracao:TemAlteracao()
		nOpcao := Aviso(STR0137,                      ; //"Atenção"
		                STR0215 + CHR(13) + CHR(10) + ; //"Foram feitas alterações na tela e não foram salvas."
						STR0216 + CHR(13) + CHR(10) + ; //"Uma nova consulta fará com que as alterações realizadas sejam perdidas."
						STR0217,                      ; //"Deseja salvar as alterações?"
		                {STR0226, STR0219, STR0214}, 2) //"Descartar", "Voltar", "Salvar"

		If nOpcao == 1
			oAlteracao:DesfazAlteracao()

		ElseIf nOpcao == 2
			Return .F.

		ElseIf nOpcao == 3
			oAlteracao:SalvaAlteracao()
		EndIf
	EndIf

	LimpaCache()

	IniAProd()
	AtuBrwPrd()

	aResProd := MrpGetProd(cTicket)
	If aResProd[1]
		cError := oJsonRes:FromJson(aResProd[2])
	EndIf

	If !Empty(cError) .Or. !aResProd[1]
		aSize(aResults, 0)
		IniAResul()
		oBrwResult:SetArray(aResults)
		oBrwResult:ForceRefresh()
		oBrwResult:GoTop()

		aSize(aDocs, 0)
		IniADocs()
		oBrwDocs:SetArray(aDocs)
		oBrwDocs:ForceRefresh()
		oBrwDocs:GoTop()
		lRet := .F.
		Help( ,  , "Help", ,  STR0206, ; //"Não existem produtos calculados."
		     1, 0, , , , , , {STR0207} ) //"O processamento realizado pelo MRP não considerou nenhum produto durante o cálculo. Não existem dados para exibir."
	Else
		aSize(aProdutos, 0)

		aItems  := oJsonRes["items"]
		nLenIte := Len(aItems)
		For nX := 1 to nLenIte
			If oJsParametros["exibe_necessidade_zerada"] .OR. aItems[nX]["necessityQuantity"] > 0
				nIndPrd++
				aAdd(aProdutos, Array(IND_APRODUTOS_TAMANHO))
				aProdutos[nIndPrd][IND_APRODUTOS_CODIGO       ] := Padr(aItems[nX]["product"],nTamPrd)
				aProdutos[nIndPrd][IND_APRODUTOS_DESCRICAO    ] := P144InfPrd(aItems[nX]["product"],"B1_DESC"  )
				aProdutos[nIndPrd][IND_APRODUTOS_EST_SEG      ] := P144InfPrd(aItems[nX]["product"],"B1_ESTSEG")
				aProdutos[nIndPrd][IND_APRODUTOS_LOTE_ECON    ] := P144InfPrd(aItems[nX]["product"],"B1_LE"    )
				aProdutos[nIndPrd][IND_APRODUTOS_QTD_EMBAL    ] := P144InfPrd(aItems[nX]["product"],"B1_QE"    )
				aProdutos[nIndPrd][IND_APRODUTOS_PONT_PED     ] := P144InfPrd(aItems[nX]["product"],"B1_EMIN"  )
				aProdutos[nIndPrd][IND_APRODUTOS_PRAZO_ENTREGA] := P144InfPrd(aItems[nX]["product"],"B1_PE"    )
				aProdutos[nIndPrd][IND_APRODUTOS_TIPO_PRAZO   ] := P144InfPrd(aItems[nX]["product"],"B1_TIPE"  )
				aProdutos[nIndPrd][IND_APRODUTOS_OPCIONAL     ] := ""
				aProdutos[nIndPrd][IND_APRODUTOS_ID_OPCIONAL  ] := " "

				If !Empty(aItems[nX]["optionalId"])
					aResOpc := MrpGetOPC(cFilAnt, cTicket, aItems[nX]["optionalId"])
					oJson   := JsonObject():New()
					oJson:fromJson(aResOpc[2])
					aSize(aResOpc, 0)

					aProdutos[nIndPrd][IND_APRODUTOS_OPCIONAL   ] := AllTrim(oJson["optionalSelected"] + " (" + AllTrim(aItems[nX]["optionalId"]) + ")")
					aProdutos[nIndPrd][IND_APRODUTOS_ID_OPCIONAL] := aItems[nX]["optionalId"]
				EndIf
			EndIf
		Next nX
		If Len(aProdutos) > 0 .And. !Empty(aProdutos[1][IND_APRODUTOS_CODIGO])
			AtuBrwPrd()
			If !Empty(aProdutos[1][IND_APRODUTOS_CODIGO])
				AtuResulta(1)
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AtuResulta
Carrega os resultados conforme o ticket informado em tela e o produto selecionado no browse.

@param  nAt  , Numerico, Linha posicionada no grid.
@return lRet , Logico  , Indica se a api encontrou registros para atualizar no grid.
@author renan.roeder
@since 22/11/2019
@version 1.0
/*/
Static Function AtuResulta(nAt)
	Local aAuxRst  := {}
	Local aItems   := {}
	Local aResMat  := {}
	Local cCampos  := ""
	Local cData    := ""
	Local cError   := ""
	Local dPeriod  := Nil
	Local nX       := 0
	Local nIndRes  := 0
	Local nLenAite := 0
	Local lRet     := .T.
	Local oJsonRes := JsonObject():New()

	aSize(aResults, 0)
	If Len(aProdutos) > 0 .And. !Empty(aProdutos[1][IND_APRODUTOS_CODIGO])

		cCampos := "branchId,necessityDate,stockBalance,inFlows,outFlows,structureOutFlows,finalBalance,necessityQuantity,startDate"
		If nRE_TRAENT > 0
			cCampos += ",transferIn,transferOut"
		EndIf

		aResMat := MrpGetSPd(cFilAnt,;
		                     cTicket,;
		                     aProdutos[nAt][IND_APRODUTOS_CODIGO     ],;
		                     aProdutos[nAt][IND_APRODUTOS_ID_OPCIONAL],;
		                     cCampos,;
		                     "necessityDate",,9999,"Matriz")
		cError := oJsonRes:FromJson(aResMat[2])

		If !Empty(cError)
			aSize(aDocs, 0)
			IniADocs()
			oBrwDocs:SetArray(aDocs)
			oBrwDocs:ForceRefresh()
			oBrwDocs:GoTop()
			lRet := .F.
		Else
			aItems := oJsonRes["items"]
			nLenAite := Len(aItems)

			If nDC_FILIAL > 0
				For nX := 1 to Len(aItems)
					If oJsParametros["exibe_necessidade_zerada"] .OR. aItems[nX]["necessityQuantity"] > 0
						cData   := StrTran(aItems[nX]["necessityDate"],"-","")
						dPeriod := SToD(cData)
						nPos    := aScan(aResults, {|x| x[nRE_DATA] == dPeriod})
						If  nPos > 0
							aResults[nPos][nRE_ESTOQU] += aItems[nX]["stockBalance"]
							aResults[nPos][nRE_ENTRAD] += aItems[nX]["inFlows"]
							aResults[nPos][nRE_SAIDAS] += aItems[nX]["outFlows"]
							aResults[nPos][nRE_SAIEST] += aItems[nX]["structureOutFlows"]
							aResults[nPos][nRE_SALDOF] += aItems[nX]["finalBalance"]
							aResults[nPos][nRE_NECESS] += aItems[nX]["necessityQuantity"]

							If nRE_TRAENT > 0
								aResults[nIndRes][nRE_TRAENT] += aItems[nX]["transferIn"]
								aResults[nIndRes][nRE_TRASAI] += aItems[nX]["transferOut"]
							EndIf
						Else
							aAdd(aResults, Array(nRE_TAM))
							nIndRes++
							aResults[nIndRes][nRE_DATA  ] := dPeriod
							aResults[nIndRes][nRE_ESTOQU] := aItems[nX]["stockBalance"]
							aResults[nIndRes][nRE_ENTRAD] := aItems[nX]["inFlows"]
							aResults[nIndRes][nRE_SAIDAS] := aItems[nX]["outFlows"]
							aResults[nIndRes][nRE_SAIEST] := aItems[nX]["structureOutFlows"]
							aResults[nIndRes][nRE_SALDOF] := aItems[nX]["finalBalance"]
							aResults[nIndRes][nRE_NECESS] := aItems[nX]["necessityQuantity"]
							aResults[nIndRes][nRE_FLAG  ] := IIf(nIndRes == 1, .T., .F.)

							If nRE_TRAENT > 0
								aResults[nIndRes][nRE_TRAENT] := aItems[nX]["transferIn"]
								aResults[nIndRes][nRE_TRASAI] := aItems[nX]["transferOut"]
							EndIf
						EndIf

						If _lP144ITM
							aAuxRst := ExecBlock("P144ITM",.F.,.F.,{"AtuResulta",cTicket,aProdutos[nAt][IND_APRODUTOS_CODIGO],aResults,nIndRes,nPos,__lUsaME})
							If Len(aAuxRst) > 0
								aResults := aClone(aAuxRst)
							EndIf 
						EndIf

						SetInfoHWB(aItems[nX]["branchId"]                   ,;
						           aProdutos[nAt][IND_APRODUTOS_CODIGO]     ,;
		                           aProdutos[nAt][IND_APRODUTOS_ID_OPCIONAL],;
								   cData                                    ,;
								   aItems[nX])

						oAlteracao:RecuperaAlteracao("RES", nIndRes, DToS(dPeriod))
					EndIf
				Next nX
			Else
				For nX := 1 to nLenAite
					If oJsParametros["exibe_necessidade_zerada"] .OR. aItems[nX]["necessityQuantity"] > 0
						cData   := StrTran(aItems[nX]["necessityDate"],"-","")
						dPeriod := SToD(cData)
						nPos    := aScan(aResults, {|x| x[nRE_DATA] == dPeriod})

						aAdd(aResults, Array(nRE_TAM))
						nIndRes++
						aResults[nIndRes][nRE_DATA  ] := dPeriod
						aResults[nIndRes][nRE_ESTOQU] := aItems[nX]["stockBalance"]
						aResults[nIndRes][nRE_ENTRAD] := aItems[nX]["inFlows"]
						aResults[nIndRes][nRE_SAIDAS] := aItems[nX]["outFlows"]
						aResults[nIndRes][nRE_SAIEST] := aItems[nX]["structureOutFlows"]
						aResults[nIndRes][nRE_SALDOF] := aItems[nX]["finalBalance"]
						aResults[nIndRes][nRE_NECESS] := aItems[nX]["necessityQuantity"]
						aResults[nIndRes][nRE_FLAG  ] := Iif(nIndRes==1,.T.,.F.)

						If _lP144ITM
							aAuxRst := ExecBlock("P144ITM",.F.,.F.,{"AtuResulta",cTicket,aProdutos[nAt][IND_APRODUTOS_CODIGO],aResults,nIndRes,nPos,__lUsaME})
							If Len(aAuxRst) > 0
								aResults := aClone(aAuxRst)
							EndIf 
						EndIf

						SetInfoHWB(cFilAnt                                  ,;
						           aProdutos[nAt][IND_APRODUTOS_CODIGO]     ,;
								   aProdutos[nAt][IND_APRODUTOS_ID_OPCIONAL],;
								   cData                                    ,;
								   aItems[nX])

						oAlteracao:RecuperaAlteracao("RES", nIndRes, DToS(dPeriod))
					EndIf
				Next nX
			EndIf

			If Len(aResults) <= 0
				IniAResul()
				aSize(aDocs, 0)
				IniADocs()
				oBrwDocs:SetArray(aDocs)
				oBrwDocs:ForceRefresh()
				oBrwDocs:GoTop()
			EndIf
			oBrwResult:SetArray(aResults)
			oBrwResult:ForceRefresh()
			oBrwResult:GoTop()

			If nActiveFld == 2
				montaEstoq()

			ElseIf nActiveFld == 3
				montaSubst()
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} AtuBrwPrd
Atualiza o browse de produto conforme array carregado pela api

@author renan.roeder
@since 22/11/2019
@version 1.0
/*/
Static Function AtuBrwPrd()
	oBrwProd:SetArray(aProdutos)
	oBrwProd:GoTop()
	oBrwProd:bLine := {||{ aProdutos[oBrwProd:nAT,IND_APRODUTOS_CODIGO       ],;
	                       aProdutos[oBrwProd:nAT,IND_APRODUTOS_DESCRICAO    ],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_OPCIONAL     ],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_EST_SEG      ],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_PONT_PED     ],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_LOTE_ECON    ],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_QTD_EMBAL    ],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_PRAZO_ENTREGA],;
	                       aProdutos[oBrwProd:nAt,IND_APRODUTOS_TIPO_PRAZO   ]}}
	oBrwProd:Refresh()
Return

/*/{Protheus.doc} AtuDocs
Carrega os documentos conforme os campos filial,ticket,produto,data de necessidade.

@return lRet , Logico  , Indica se a api encontrou registros para atualizar no grid.
@author renan.roeder
@since 22/11/2019
@version 1.0
/*/
Static Function AtuDocs()
	Local aAuxDoc    := {}
	Local aResMat    := {}
	Local aItems     := {}
	Local cError     := ""
	Local cStartDate := ""
	Local cVersao    := ""
	Local nX         := 0
	Local nIndDocs   := 0
	Local nLinha     := oBrwResult:nAt
	Local nLenAite   := 0
	Local nTamFil    := FwSizeFilial()
	Local nTamCod    := GetSx3Cache("VC_VERSAO","X3_TAMANHO")
	Local lRet       := .T.
	Local oJsonRes   := JsonObject():New()

	//Flag para mudar a cor da linha selecionada
	If Len(aResults) > 0
		For nX := 1 To Len(aResults)
			aResults[nX, nRE_FLAG] := .F.
		Next nX
		aResults[nLinha, nRE_FLAG] := .T.
		oBrwResult:Refresh()
	EndIf

	aSize(aDocs, 0)
	If Len(aProdutos) > 0 .And. !Empty(aProdutos[1][IND_APRODUTOS_CODIGO])
		aResMat := MrpGetTPD(cFilAnt,;
		                     cTicket,;
		                     aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO     ],;
		                     aProdutos[oBrwProd:nAt][IND_APRODUTOS_ID_OPCIONAL],;
		                     aResults[oBrwResult:nAt][nRE_DATA   ],;
		                     "branchId,parentDocumentType,childDocument,originalNecessity,stockBalanceQuantity,quantityStockWriteOff,alocationQuantity,quantitySubstitution,quantityNecessity,consumptionLocation,necessityDate,parentDocument,structureReview,routing,operation,erpDocumentType,erpDocument,recordKey,substitutionKey,sequenceInStructure,productionVersion,breakupSequence,transferIn,transferOut",;
		                     "recno",,9999,"Rastreio")
		cError := oJsonRes:FromJson(aResMat[2])

		If !Empty(cError)
			lRet := .F.
			IniADocs()
		Else
			aItems := oJsonRes["items"]
			nLenAite := Len(aItems)

			For nX := 1 to nLenAite
				If oJsParametros["exibe_necessidade_zerada"] .OR. aItems[nX]["quantityNecessity"] > 0
					If aItems[nX]["parentDocumentType"] == "1"
						aItems[nX]["parentDocumentType"] := "3"
					ElseIf aItems[nX]["parentDocumentType"] == "3"
						aItems[nX]["parentDocumentType"] := "1"
					EndIf

					cVersao := ""
					If !Empty(aItems[nX]["productionVersion"])
						cVersao := SubStr(aItems[nX]["productionVersion"], nTamFil+1, nTamCod)
					EndIf

					aAdd(aDocs, Array(nDC_TAM))
					nIndDocs++

					If nDC_FILIAL > 0
						aDocs[nIndDocs][nDC_FILIAL] := aItems[nX]["branchId"]
					EndIf
					aDocs[nIndDocs][nDC_DOCFIL] := aItems[nX]["childDocument"]
					aDocs[nIndDocs][nDC_QTNEOR] := aItems[nX]["originalNecessity"]
					aDocs[nIndDocs][nDC_QTSLES] := aItems[nX]["stockBalanceQuantity"]
					aDocs[nIndDocs][nDC_QTBXES] := aItems[nX]["quantityStockWriteOff"]
					aDocs[nIndDocs][nDC_QTEMPE] := aItems[nX]["alocationQuantity"]
					aDocs[nIndDocs][nDC_QTSUBS] := aItems[nX]["quantitySubstitution"]

					If nDC_TRAENT > 0
						aDocs[nIndDocs][nDC_TRAENT] := aItems[nX]["transferIn"]
						aDocs[nIndDocs][nDC_TRASAI] := aItems[nX]["transferOut"]
					EndIf

					aDocs[nIndDocs][nDC_QTNECE] := aItems[nX]["quantityNecessity"]
					aDocs[nIndDocs][nDC_LOCAL ] := aItems[nX]["consumptionLocation"]
					aDocs[nIndDocs][nDC_DATA  ] := SToD(StrTran(aItems[nX]["necessityDate"],"-",""))
					aDocs[nIndDocs][nDC_TPDCPA] := aItems[nX]["parentDocumentType"]
					aDocs[nIndDocs][nDC_DOCPAI] := aItems[nX]["parentDocument"]
					aDocs[nIndDocs][nDC_TRT   ] := aItems[nX]["sequenceInStructure"]
					aDocs[nIndDocs][nDC_REV   ] := aItems[nX]["structureReview"]
					aDocs[nIndDocs][nDC_ROTEIR] := aItems[nX]["routing"]
					aDocs[nIndDocs][nDC_OPERAC] := aItems[nX]["operation"]
					aDocs[nIndDocs][nDC_TDCERP] := aItems[nX]["erpDocumentType"]
					aDocs[nIndDocs][nDC_DOCERP] := aItems[nX]["erpDocument"]
					aDocs[nIndDocs][nDC_VERSAO] := cVersao
					aDocs[nIndDocs][nDC_CHAVE ] := aItems[nX]["recordKey"]
					aDocs[nIndDocs][nDC_CHVSUB] := aItems[nX]["substitutionKey"]
					aDocs[nIndDocs][nDC_SEQUEN] := aItems[nX]["breakupSequence"]
					aDocs[nIndDocs][nDC_FLAG  ] := IIf(nIndDocs==1, .T., .F.)

					If aItems[nX]["quantityNecessity"] > 0
						cStartDate := GetInfoHWB(IIf(nDC_FILIAL > 0, aDocs[nIndDocs][nDC_FILIAL], cFilAnt),;
												 aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO]            ,;
												 aProdutos[oBrwProd:nAt][IND_APRODUTOS_ID_OPCIONAL]       ,;
												 DToS(aResults[oBrwResult:nAt][nRE_DATA])                 ,;
												 "startDate")

						cStartDate := StrTran(cStartDate,"-","")
					Else
						cStartDate := ""
					EndIf
					aDocs[nIndDocs][nDC_DTINIC] := SToD(cStartDate)

					If !Empty(aDocs[nIndDocs][nDC_DOCPAI]) .And. ;
					   (oParJson["consolidatePurchaseRequest"] <> "1" .Or. oParJson["consolidateProductionOrder"] <> "1")
						aDocs[nIndDocs][nDC_PRDPAI] := GetProdPai(aDocs[nIndDocs][nDC_DOCPAI])
					EndIf

					If _lP144ITM
						aAuxDoc := ExecBlock("P144ITM",.F.,.F.,{"AtuDocs",cTicket,aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO],aDocs,nIndDocs,0,__lUsaME})
						If Len(aAuxDoc) > 0
							aDocs := aClone(aAuxDoc)
						EndIf 
					EndIf

					oAlteracao:RecuperaAlteracao("DOC", nIndDocs, DToS(aResults[oBrwResult:nAt][nRE_DATA]), oAlteracao:GetChavDoc(nIndDocs))
				EndIf
			Next nX
			If Len(aDocs) <= 0
				IniADocs()
			EndIf
		EndIf
	EndIf

	If nActiveFld == 4
		montaTrans()
	EndIf

	oBrwDocs:SetArray(aDocs)
	oBrwDocs:ForceRefresh()
	oBrwDocs:GoTop()
Return lRet

/*/{Protheus.doc} IniAResul
Inicializa array do grid de resultados

@author renan.roeder
@since 28/11/2019
@version 1.0
/*/
Static Function IniAResul()
	Local aAuxRst := {}

	aAdd(aResults, Array(nRE_TAM))

	aResults[1][nRE_DATA  ] := SToD("")
	aResults[1][nRE_ESTOQU] := 0
	aResults[1][nRE_ENTRAD] := 0
	aResults[1][nRE_SAIDAS] := 0
	aResults[1][nRE_SAIEST] := 0
	aResults[1][nRE_SALDOF] := 0
	aResults[1][nRE_NECESS] := 0
	aResults[1][nRE_FLAG  ] := .T.

	If nRE_TRAENT > 0
		aResults[1][nRE_TRAENT] := 0
		aResults[1][nRE_TRASAI] := 0
	EndIF

	If _lP144ATGR
		aAuxRst := ExecBlock("P144ATGR",.F.,.F.,{"IniAResul",aResults, 1})
		If Len(aAuxRst) > 0
			aResults := aClone(aAuxRst)
		EndIf	
	EndIf 

Return

/*/{Protheus.doc} IniADocs
Inicializa array do grid de documentos

@author renan.roeder
@since 28/11/2019
@version 1.0
/*/
Static Function IniADocs()
	Local aAuxDoc := {}

	aAdd(aDocs, Array(nDC_TAM))

	If nDC_FILIAL > 0
		aDocs[1][ nDC_FILIAL] := ""
	EndIf

	aDocs[1][nDC_DOCFIL] := ""
	aDocs[1][nDC_QTNEOR] := 0
	aDocs[1][nDC_QTSLES] := 0
	aDocs[1][nDC_QTBXES] := 0
	aDocs[1][nDC_QTEMPE] := 0
	aDocs[1][nDC_QTSUBS] := 0
	aDocs[1][nDC_QTNECE] := 0
	aDocs[1][nDC_LOCAL ] := ""
	aDocs[1][nDC_DATA  ] := SToD("")
	aDocs[1][nDC_DTINIC] := SToD("")
	aDocs[1][nDC_TPDCPA] := ""
	aDocs[1][nDC_DOCPAI] := ""
	aDocs[1][nDC_PRDPAI] := ""
	aDocs[1][nDC_TRT   ] := ""
	aDocs[1][nDC_REV   ] := ""
	aDocs[1][nDC_ROTEIR] := ""
	aDocs[1][nDC_OPERAC] := ""
	aDocs[1][nDC_TDCERP] := ""
	aDocs[1][nDC_DOCERP] := ""
	aDocs[1][nDC_VERSAO] := ""
	aDocs[1][nDC_CHAVE ] := ""
	aDocs[1][nDC_CHVSUB] := ""
	aDocs[1][nDC_SEQUEN] := ""
	aDocs[1][nDC_FLAG  ] := .T.

	If _lP144ATGR
		aAuxDoc := ExecBlock("P144ATGR",.F.,.F.,{"IniADocs",aDocs, 1})
		If Len(aAuxDoc) > 0
			aDocs := aClone(aAuxDoc)
		EndIf	
	EndIf 

Return

/*/{Protheus.doc} IniAProd
Inicializa array do grid de produtos

@author lucas.franca
@since 07/12/2020
@version 1.0
/*/
Static Function IniAProd()
	aSize(aProdutos, 0)

	aAdd(aProdutos, Array(IND_APRODUTOS_TAMANHO))

	aProdutos[1][IND_APRODUTOS_CODIGO       ] := ""
	aProdutos[1][IND_APRODUTOS_DESCRICAO    ] := ""
	aProdutos[1][IND_APRODUTOS_OPCIONAL     ] := ""
	aProdutos[1][IND_APRODUTOS_EST_SEG      ] := 0
	aProdutos[1][IND_APRODUTOS_PONT_PED     ] := 0
	aProdutos[1][IND_APRODUTOS_LOTE_ECON    ] := 0
	aProdutos[1][IND_APRODUTOS_QTD_EMBAL    ] := 0
	aProdutos[1][IND_APRODUTOS_PRAZO_ENTREGA] := 0
	aProdutos[1][IND_APRODUTOS_TIPO_PRAZO   ] := ""
	aProdutos[1][IND_APRODUTOS_ID_OPCIONAL  ] := " "
Return

/*/{Protheus.doc} PCPA144F3
Abre a consulta de tickets do MRP.

@author renan.roeder
@since 22/11/2019
@version 1.0
/*/
Function PCPA144F3()
	Local nOpcao := 0
	Local oConTicket

	oConTicket := ConsultaTickets():New()
	nOpcao := oConTicket:AbreTela()

	If nOpcao != 0
		cTicket := oConTicket:GetCodigo()
		oTGet1:CtrlRefresh()
	EndIf
	oConTicket:Destroy()

	//Seta o foco no botão de Consulta
	oButton3:SetFocus()

Return

/*/{Protheus.doc} AbreParam
Abre a consulta de parametros do MRP.

@author renan.roeder
@since 22/11/2019
@version 1.0
/*/
Static Function AbreParam()
	Local lRet := .T.
	oConParam := ConsultaParametros():New(aParMRP, cTicket)
	oConParam:AbreTela()
	oConParam:Destroy()
Return lRet

/*/{Protheus.doc} PCPA144PAR
Carga de parametros do MRP

@author Renan Roeder
@since 26/11/2019
@version P12
@param cTicketMRP, Character, Número do ticket do MRP
@param aParametro, Array    , Retorna por referência o array com os parâmetros do MRP.
                              Estrutura do array:
                              aParametro[nIndex][1] - ID do Registro (utilizado para exibir em tela). Sempre 0
                              aParametro[nIndex][2] -> Array
                              aParametro[nIndex][2][nIndice][1] - Descrição do parâmetro
                              aParametro[nIndex][2][nIndice][2] - Descrição do conteúdo do parâmetro
                              aParametro[nIndex][2][nIndice][3] - Código do parâmetro
                              aParametro[nIndex][2][nIndice][4] - Valor do parâmetro
@param lAtuTela  , Lógico   , Indica se os componentes de tela devem ser atualizados.
@return lRet     , Lógico   , Validação do campo ticket
/*/
Function PCPA144PAR(cTicketMRP, aParametro, lAtuTela)
	Local aParam   := {}
	Local aItems   := {}
	Local cError   := ""
	Local lRet     := .T.
	Local nX       := 0
	Local nLenIte  := 0
	Local oJsonPar := JsonObject():New()

	Default lAtuTela := .F.

	aParam := MrpGetPar(cFilAnt, cTicketMRP, "ticket,parameter,value,list",,,9999,"Parametros", .T.)
	cError := oJsonPar:FromJson(DecodeUTF8(aParam[2]))

	aSize(aParametro, 0)
	FreeObj(oParJson)
	oParJson := JsonObject():New()

	If Empty(cError)
		aItems := oJsonPar["items"]
		nLenIte := Len(aItems)

		For nX := 1 to nLenIte
			If aItems[nX]["code"] == "periodType"
				cPeriodo := aItems[nX]["valueDescription"]
				oTGet3:CtrlRefresh()
				Loop
			EndIf
			If aItems[nX]["code"] == "demandStartDate"
				cDataIni := CtoD(aItems[nX]["valueDescription"])
				oTGet4:CtrlRefresh()
				Loop
			EndIf
			If aItems[nX]["code"] == "demandEndDate"
				cDataFim := CtoD(aItems[nX]["valueDescription"])
				oTGet5:CtrlRefresh()
				Loop
			EndIf

			aAdd(aParametro, {0, {aItems[nX]["parameter"], aItems[nX]["valueDescription"], aItems[nX]["code"], aItems[nX]["value"]} })
			oParJson[aItems[nX]["code"]] := aItems[nX]["value"]
		Next nX

	ElseIf lAtuTela
		cPeriodo := ""
		oTGet3:CtrlRefresh()

		cDataIni := ""
		oTGet4:CtrlRefresh()

		cDataFim := ""
		oTGet5:CtrlRefresh()
	EndIf

	aSize(aItems, 0)
	FreeObj(oJsonPar)

Return lRet

/*/{Protheus.doc} chgFolder
Change Folder de Documentos
@author brunno.costa
@since 03/12/2019
@version P12
@param 01 nFolder, número, indice do folder
@return lReturn, lógico, indica se permite selecionar o folder
/*/
Static Function chgFolder(nFolder)
	Local lReturn := .T.

	nActiveFld := nFolder

	If nFolder == 2
		montaEstoq()

	ElseIf nFolder == 3
		montaSubst()

	ElseIf nFolder == 4
		montaTrans()
	EndIf

Return lReturn

/*/{Protheus.doc} kendoOk
Verifica se o pacote do KendoChart está compilado no RPO
@author brunno.costa
@since 13/01/2020
@version P12
/*/
Static Function kendoOk()
	Local aApoInfo   := GetApoInfo("kendouichart.zip")
	Local lCompilado := !Empty(aApoInfo)
Return lCompilado

/*/{Protheus.doc} montaEstoq
Monta tela de Documentos - Estoque
@author brunno.costa
@since 03/12/2019
@version P12
/*/
Static Function montaEstoq()

	Local aSeries    := {}
	Local cTitulo    := ""
	Local oKendo
	Local aData

	If !kendoOk() .OR. oPnlEst == NIL .or. oPnlEst:nClientHeight == 0 .OR. oPnlEst:nClientWidth == 0
		Return
	EndIf

	If Empty(oBrwProd:aArray[oBrwProd:nAT,1])
		lReturn := .F.
	Else
		oKendo  := KendoChart():New(oPnlEst, oPnlEst:nClientHeight, oPnlEst:nClientWidth)
		aData   := DadoEstGR1()

		oKendo:AddChart('chart1', cTitulo, "bottom", .F.)

		If !Empty(oJsParametros["grafico_saldo_inicial"])
			Aadd(aSeries, KendoSeries():New(STR0119,"y1", "x1", , , oJsParametros["grafico_saldo_inicial"]))              //"Saldo Inicial"
		EndIf

		If !Empty(oJsParametros["grafico_entradas"])
			Aadd(aSeries, KendoSeries():New(STR0120,"y2", "x2", , , oJsParametros["grafico_entradas"]))                   //"Entradas"
		EndIf

		If !Empty(oJsParametros["grafico_saidas"])
			Aadd(aSeries, KendoSeries():New(AjAcento(STR0121),"y3", "x3", , , oJsParametros["grafico_saidas"]))           //"Saídas"
		EndIf

		If !Empty(oJsParametros["grafico_saidas_estrutura"])
			Aadd(aSeries, KendoSeries():New(AjAcento(STR0122),"y4", "x4", , , oJsParametros["grafico_saidas_estrutura"])) //Saídas Estrutura
		EndIf

		If !Empty(oJsParametros["grafico_saldo_final"])
			Aadd(aSeries, KendoSeries():New(STR0123,"y5", "x5", , , oJsParametros["grafico_saldo_final"]))                //"Saldo Final"
		EndIf

		If !Empty(oJsParametros["grafico_necessidade"])
			Aadd(aSeries, KendoSeries():New(STR0124,"y6", "x6", , , oJsParametros["grafico_necessidade"]))                //"Necessidade"
		EndIf

		If !Empty(oJsParametros["grafico_saldo_posterior"])
			Aadd(aSeries, KendoSeries():New(STR0125,"y7", "x7", , , oJsParametros["grafico_saldo_posterior"]))            //"Saldo Posterior"
		EndIf

		oKendo:SetSeries('chart1', aSeries)
		oKendo:SetData('chart1'  , aData  )

		oBtnGR1 := TBtnBmp2():New( 01, nPosGR1Btn, 26, 26,'engrenagem',,,,{||LoadMVPar("PCPA144GR1", .T.)},oPnlEst,,,.T. )
		oPnlEst:Refresh()

	EndIf

Return Nil

/*/{Protheus.doc} DadoEstGR1
Gera dados para o Gráfico de Movimentação de Estoque
@author brunno.costa
@since 03/12/2019
@version P12
/*/
Static Function DadoEstGR1()
	Local nInd
	Local aData      := {}
	Local oData
	Local nTotal     := Len(aResults)
	Local nPosSldIni := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_QTSLES"})
	Local nPosEntrad := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_QTENTR"})
	Local nPosSaidas := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_QTSAID"})
	Local nPosSaidEs := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_QTSEST"})
	Local nPosSaldo  := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_QTSALD"})
	Local nPosNecess := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_QTNECE"})
	Local nPosData   := aScan(oBrwResult:aHeader, {|x| AllTrim(x[2]) == "HWB_DATA"})
	Local cData

	For nInd := 1 To nTotal
		If oJsParametros["exibe_necessidade_zerada"] .OR. oBrwResult:aCols[nInd, nPosNecess] > 0
			oData := JsonObject():New()
			cData := DtoC(oBrwResult:aCols[nInd, nPosData])
			oData['y1'] := oBrwResult:aCols[nInd, nPosSldIni]
			oData['x1'] := cData

			oData['y2'] := oBrwResult:aCols[nInd, nPosEntrad]
			oData['x2'] := cData

			oData['y3'] := oBrwResult:aCols[nInd, nPosSaidas]
			oData['x3'] := cData

			oData['y4'] := oBrwResult:aCols[nInd, nPosSaidEs]
			oData['x4'] := cData

			oData['y5'] := oBrwResult:aCols[nInd, nPosSaldo]
			oData['x5'] := cData

			oData['y6'] := oBrwResult:aCols[nInd, nPosNecess]
			oData['x6'] := cData

			oData['y7'] := oBrwResult:aCols[nInd, nPosNecess] + oBrwResult:aCols[nInd, nPosSaldo]
			oData['x7'] := cData

			Aadd(aData, oData)
		EndIf
	Next

Return aData

/*/{Protheus.doc} montaSubst
Monta tela de Documentos - Substituição
@author brunno.costa
@since 03/12/2019
@version P12
/*/
Static Function montaSubst()

	Local aHeaderSub  := {}
	Local aSubstitui  := {}
	Local cFilAux     := ""
	Local cChave      := ""
	Local cChaveSubs  := ""
	Local cComponente := ""
	Local cDescricao  := ""
	Local cDocumento  := ""
	Local cOptionalID := ""
	Local cTitulo     := ""
	Local cValid      := ""
	Local nDecimal    := 0
	Local nLinDoc     := 0
	Local nQtdTotal   := 0
	Local nTamanho    := 0

	If Empty(aDocs)
		Return
	EndIf

	nLinDoc    := oBrwDocs:nAt
	cChave     := aDocs[nLinDoc][nDC_CHAVE]
	cChaveSubs := aDocs[nLinDoc][nDC_CHVSUB]

	If nDC_FILIAL > 0
		cFilAux := aDocs[nLinDoc][nDC_FILIAL]
	Else
		cFilAux := cFilAnt
	EndIf

	If Empty(cChaveSubs)
		If aDocs[nLinDoc][nDC_QTSUBS] != 0 //Registro Substituído
			If nDC_FILIAL > 0
				cChaveSubs := PadR(cFilAux, FwSizeFilial())
			Else
				cChaveSubs := ""
			EndIf
			cChaveSubs  += cChave
			cComponente := Left(cChave, GetSx3Cache("B1_COD", "X3_TAMANHO"))
			If "|" $ cChaveSubs .AND. CHR(13) $ cChaveSubs
				cOptionalID := Substr(cChaveSubs, At("|", cChaveSubs), At(chr(13)-1, cChaveSubs))
			Else
				cOptionalID := aProdutos[oBrwProd:nAt][IND_APRODUTOS_ID_OPCIONAL]
				cChaveSubs  := addOptID(cChaveSubs, cOptionalID)
			EndIf

			cDescricao  := P144DesPrd(cComponente)
			cDocumento  := aDocs[nLinDoc][nDC_DOCPAI]
			nQtdTotal   := GetQtdOrig(cFilAux                   , ;
			                          cComponente               , ;
			                          cOptionalID               , ;
			                          aDocs[nLinDoc][nDC_DATA]  , ;
			                          aDocs[nLinDoc][nDC_TPDCPA], ;
			                          cDocumento                , ;
			                          aDocs[nLinDoc][nDC_TRT])
		Else
			cComponente := ""
			cOptionalID := ""
			cDescricao  := ""
			cDocumento  := ""
			nQtdTotal   := 0
		EndIf

	Else//Registro Substituto
		If nDC_FILIAL > 0
			cComponente := SubStr(cChaveSubs, FwSizeFilial()+1, GetSx3Cache("B1_COD", "X3_TAMANHO"))
		Else
			cComponente := Left(cChaveSubs, GetSx3Cache("B1_COD", "X3_TAMANHO"))
		EndIf
		If "|" $ cChaveSubs .AND. CHR(13) $ cChaveSubs
			cOptionalID := Substr(cChaveSubs, At("|", cChaveSubs), At(chr(13)-1, cChaveSubs))
		EndIf

		cDescricao := P144DesPrd(cComponente)
		cDocumento := aDocs[nLinDoc][nDC_DOCPAI]
		nQtdTotal  := GetQtdOrig(cFilAux                   , ;
		                         cComponente               , ;
		                         cOptionalID               , ;
		                         aDocs[nLinDoc][nDC_DATA]  , ;
		                         aDocs[nLinDoc][nDC_TPDCPA], ;
		                         cDocumento                , ;
		                         aDocs[nLinDoc][nDC_TRT])
	EndIf

	criaASubst(cFilAux, aDocs[nLinDoc][nDC_TPDCPA], cDocumento, aDocs[nLinDoc][nDC_TRT], cChaveSubs)

	If lSubsMont != Nil
		oGetComp:cText  := cComponente
		oGetDesc:cText  := cDescricao
		oGetQtd:cText   := nQtdTotal
		oGetDocto:cText := cDocumento
	Else
		TSay():New(05, 08, {|| STR0108 }, oPnlSubst, ,oFont , , , , .T., , , 40, 20) //"Componente:"
		oGetComp := TGet():New(02, 50, {|u| If(PCount()>0,cComponente:=u,cComponente)},oPnlSubst,100,13,"@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cComponente")
		oGetDesc := TGet():New(02, 150, {|u| If(PCount()>0,cDescricao:=u,cDescricao)},oPnlSubst,200,13,"@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cDescricao")

		TSay():New(24, 185, {|| STR0109 }, oPnlSubst, ,oFont , , , , .T., , , 50, 20) //"Quantidade Original:"
		oGetQtd  := TGet():New(21, 250, {|u| If(PCount()>0,nQtdTotal:=u,nQtdTotal)},oPnlSubst,100,13,"@E 99,999,999.999",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"nQtdTotal")

		TSay():New(24, 08, {|| STR0110 }, oPnlSubst, ,oFont , , , , .T., , , 30, 20) //"Documento:"
		oGetDocto := TGet():New(21, 50, {|u| If(PCount()>0,cDocumento:=u,cDocumento)},oPnlSubst,100,13,"@!",/*08*/,0,/*10*/,/*11*/,.F.,/*13*/,.T.,/*15*/,.F.,/*17*/,.F.,.F.,/*20*/,.T.,.F.,/*23*/,"cDocumento")

		If usaME()
			cTitulo  := STR0055
			nTamanho := FwSizeFilial()
			nDecimal := 0
			cValid   := ""
			aAdd(aHeaderSub,{cTitulo,"cFilial","",nTamanho,nDecimal,cValid,"û","C",""})
		EndIf

		cTitulo  := STR0111 //"Alternativo"
		nTamanho := 15
		nDecimal := 0
		cValid   := ""
		aAdd(aHeaderSub,{cTitulo,"cAlternativo","",nTamanho,nDecimal,cValid,"û","C",""})

		cTitulo  := STR0112 //"Descrição"
		nTamanho := 30
		nDecimal := 0
		cValid   := ""
		aAdd(aHeaderSub,{cTitulo,"cDescricao","",nTamanho,nDecimal,cValid,"û","C",""})

		cTitulo  := STR0113 //"Saldo"
		nTamanho := 12
		nDecimal := 3
		cValid   := ""
		aAdd(aHeaderSub,{cTitulo,"nSaldo","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})

		cTitulo  := STR0114 //"Empenho"
		nTamanho := 12
		nDecimal := 3
		cValid   := ""
		aAdd(aHeaderSub,{cTitulo,"nEmpenho","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})

		cTitulo  := STR0115 //"Necessidade"
		nTamanho := 12
		nDecimal := 3
		cValid   := ""
		aAdd(aHeaderSub,{cTitulo,"nNecess","@E 99,999,999.999",nTamanho,nDecimal,cValid,"û","N",""})

		oBrwSubst := MsNewGetDados():New(040,;
		                                 002,;
		                                 oPnlSubst:nClientHeight-100,;
		                                 oPnlSubst:nClientWidth*0.5,;
		                                 GD_UPDATE,;
		                                 /*LinhaOk*/,;
		                                 /*tudoOk*/,;
		                                 /*IniCpos*/,;
		                                 aSubstitui,;
		                                 0,;
		                                 1000,;
		                                 ,;
		                                 ,;
		                                 "AllwaysFalse",;
		                                 oPnlSubst,;
		                                 aHeaderSub,;
		                                 aSubsts,;
		                                 {|| changeSubs()} )

		oBrwSubst:oBrowse:lUseDefaultColors := .F.
		oBrwSubst:oBrowse:SetBlkBackColor({|| GETDCLR(aSubsts,oBrwSubst:nAt)})
		oBrwSubst:oBrowse:SetBlkColor( { || RGB(0,0,0) } )

		lSubsMont := .T.
	EndIf

	oBrwSubst:SetArray(aSubsts)
	oBrwSubst:ForceRefresh()
	oBrwSubst:GoTop()

Return

/*/{Protheus.doc} criaASubst
Popula dados na Grid de Substituição
@author brunno.costa
@since 03/12/2019
@version P12
@param 01 - cFilAux   , caracter, código da filial para realizar a consulta
@param 02 - cTpPai    , caracter, tipo do documento pai
@param 03 - cDocumento, caracter, documento pai
@param 04 - cTRT      , caracter, código do TRT do produto
@param 05 - cChaveSubs, caracter, chave de substituição do registro
/*/
Static Function criaASubst(cFilAux, cTpPai, cDocumento, cTRT, cChaveSubs)

	Local aResMat  := {}
	Local aItems   := {}
	Local cError   := ""
	Local nTotal
	Local oJsonRes := JsonObject():New()
	Local nInd     := 0

	aSize(aSubsts, 0)
	If Empty(cChaveSubs)
		If nDC_FILIAL > 0
			aAdd(aSubsts, Array(7))
			aSubsts[1][1] := ""
			aSubsts[1][2] := ""
			aSubsts[1][3] := ""
			aSubsts[1][4] := 0
			aSubsts[1][5] := 0
			aSubsts[1][6] := 0
			aSubsts[1][7] := .T.
		Else
			aAdd(aSubsts, Array(6))
			aSubsts[1][1] := ""
			aSubsts[1][2] := ""
			aSubsts[1][3] := 0
			aSubsts[1][4] := 0
			aSubsts[1][5] := 0
			aSubsts[1][6] := .T.
		EndIf

	Else
		aResMat := MrpGetSUB(cFilAux, cTicket, cTpPai, cDocumento, cTRT, cChaveSubs,"branchId,componentCode,stockBalanceQuantity,alocationQuantity,quantityNecessity",,,9999,"Rastreio")
		cError := oJsonRes:FromJson(aResMat[2])

		If Empty(cError)
			aItems := oJsonRes["items"]
			nTotal := Len(aItems)

			For nInd := 1 to nTotal
				If nDC_FILIAL > 0
					aAdd(aSubsts, Array(7))
					aSubsts[nInd][1] := aItems[nInd]["branchId"]
					aSubsts[nInd][2] := aItems[nInd]["componentCode"]
					aSubsts[nInd][3] := P144DesPrd(aItems[nInd]["componentCode"])
					aSubsts[nInd][4] := aItems[nInd]["stockBalanceQuantity"]
					aSubsts[nInd][5] := aItems[nInd]["alocationQuantity"]
					aSubsts[nInd][6] := aItems[nInd]["quantityNecessity"]
					aSubsts[nInd][7] := Iif(nInd==1,.T.,.F.)
				Else
					aAdd(aSubsts, Array(6))
					aSubsts[nInd][1] := aItems[nInd]["componentCode"]
					aSubsts[nInd][2] := P144DesPrd(aItems[nInd]["componentCode"])
					aSubsts[nInd][3] := aItems[nInd]["stockBalanceQuantity"]
					aSubsts[nInd][4] := aItems[nInd]["alocationQuantity"]
					aSubsts[nInd][5] := aItems[nInd]["quantityNecessity"]
					aSubsts[nInd][6] := Iif(nInd==1,.T.,.F.)
				EndIf
			Next
		EndIf
	EndIf

Return

/*/{Protheus.doc} GetDocOrig
Inicializa Grid de Substituição
@author brunno.costa
@since 04/12/2019
@version P12
@param 01 - cFilAux     , caracter, código da filial para consulta
@param 02 - cProdOrig   , caracter, código do produto relacionado
@param 03 - cOptionalID , caracter, código ID do opcional
@param 04 - dNecessidade, data    , data da necessidade
@param 05 - cTipoPai    , caracter, tipo do documento Pai
@param 06 - cDocumento  , caracter, código do documento
@param 07 - cTRT        , caracter, cógido da sequência TRT do registro
@return nQtdOrig, número, quantidade substituição original
/*/
Static Function GetQtdOrig(cFilAux, cProdOrig, cOptionalID, dNecessidade, cTipoPai, cDocumento, cTRT)
	Local cError   := ""
	Local aResMat  := {}
	Local aItems   := {}
	Local oJsonRes := JsonObject():New()
	Local nX       := 0
	Local nQtdOrig := 0

	If Len(aProdutos) > 0 .And. !Empty(aProdutos[1][IND_APRODUTOS_CODIGO])
		aResMat := MrpGetTPD(cFilAux, cTicket, cProdOrig, cOptionalID, dNecessidade,"parentDocumentType,parentDocument,sequenceInStructure,quantitySubstitution",,,9999,"Rastreio")
		cError := oJsonRes:FromJson(aResMat[2])

		If Empty(cError)
			aItems := oJsonRes["items"]
			nX     := aScan(aItems, {|x| x["parentDocumentType"]  == cTipoPai   .AND.;
			                             x["parentDocument"]      == cDocumento .AND.;
			                             x["sequenceInStructure"] == cTRT             })
			If nX > 0
				nQtdOrig := aItems[nX]["quantitySubstitution"]
			EndIf

		EndIf
	EndIf
Return nQtdOrig

/*/{Protheus.doc} AjAcento
Converte Acentuação das Palavras para String HTML
@author brunno.costa
@since 04/12/2019
@version P12
@param 01 - cTexto, caracter, texto para conversão
@return cTexto, caracter, texto convertido
/*/
Static Function AjAcento(cTexto)
	cTexto = StrTran(cTexto, "á", "&aacute;" )
	cTexto = StrTran(cTexto, "â", "&acirc;" )
	cTexto = StrTran(cTexto, "à", "&agrave;" )
	cTexto = StrTran(cTexto, "ã", "&atilde;" )
	cTexto = StrTran(cTexto, "ç", "&ccedil;" )
	cTexto = StrTran(cTexto, "é", "&eacute;" )
	cTexto = StrTran(cTexto, "ê", "&ecirc;" )
	cTexto = StrTran(cTexto, "í", "&iacute;" )
	cTexto = StrTran(cTexto, "ó", "&oacute;" )
	cTexto = StrTran(cTexto, "ô", "&ocirc;" )
	cTexto = StrTran(cTexto, "õ", "&otilde;" )
	cTexto = StrTran(cTexto, "ú", "&uacute;" )
	cTexto = StrTran(cTexto, "ü", "&uuml;" )
	cTexto = StrTran(cTexto, "Á", "&Aacute;" )
	cTexto = StrTran(cTexto, "Â", "&Acirc;" )
	cTexto = StrTran(cTexto, "À", "&Agrave;" )
	cTexto = StrTran(cTexto, "Ã", "&Atilde;" )
	cTexto = StrTran(cTexto, "Ç", "&Ccedil;" )
	cTexto = StrTran(cTexto, "É", "&Eacute;" )
	cTexto = StrTran(cTexto, "Ê", "&Ecirc;" )
	cTexto = StrTran(cTexto, "Í", "&Iacute;" )
	cTexto = StrTran(cTexto, "Ó", "&Oacute;" )
	cTexto = StrTran(cTexto, "Ô", "&Ocirc;" )
	cTexto = StrTran(cTexto, "Õ", "&Otilde;" )
	cTexto = StrTran(cTexto, "Ú", "&Uacute;" )
	cTexto = StrTran(cTexto, "Ü", "&Uuml;" )
Return AllTrim(cTexto)

/*/{Protheus.doc} AjAcento
Converte Acentuação das Palavras para String HTML
@author brunno.costa
@since 04/12/2019
@version P12
@param 01 - cTexto, caracter, texto para conversão
@return cTexto, caracter, texto convertido
/*/
Static Function LoadMVPar(cPergunte, lExibe)
	Local lOk := .T.
	lOk := Pergunte(cPergunte, lExibe)
	If cPergunte == "PCPA144FIL"
		oJsParametros["exibe_necessidade_zerada"] := MV_PAR01 == 1

		If lExibe .And. lOk
			FWMsgRun(,{|| AtuProduto() },STR0038,STR0039)
		EndIf

	ElseIf cPergunte == "PCPA144GR1"
		If MV_PAR01 == 1
			oJsParametros["grafico_saldo_inicial"] := "column"
		ElseIf MV_PAR01 == 2
			oJsParametros["grafico_saldo_inicial"] := "line"
		Else
			oJsParametros["grafico_saldo_inicial"] := ""
		EndIf

		If MV_PAR02 == 1
			oJsParametros["grafico_entradas"] := "column"
		ElseIf MV_PAR02 == 2
			oJsParametros["grafico_entradas"] := "line"
		Else
			oJsParametros["grafico_entradas"] := ""
		EndIf

		If MV_PAR03 == 1
			oJsParametros["grafico_saidas"] := "column"
		ElseIf MV_PAR03 == 2
			oJsParametros["grafico_saidas"] := "line"
		Else
			oJsParametros["grafico_saidas"] := ""
		EndIf

		If MV_PAR04 == 1
			oJsParametros["grafico_saidas_estrutura"] := "column"
		ElseIf MV_PAR04 == 2
			oJsParametros["grafico_saidas_estrutura"] := "line"
		Else
			oJsParametros["grafico_saidas_estrutura"] := ""
		EndIf

		If MV_PAR05 == 1
			oJsParametros["grafico_saldo_final"] := "column"
		ElseIf MV_PAR05 == 2
			oJsParametros["grafico_saldo_final"] := "line"
		Else
			oJsParametros["grafico_saldo_final"] := ""
		EndIf

		If MV_PAR06 == 1
			oJsParametros["grafico_necessidade"] := "column"
		ElseIf MV_PAR06 == 2
			oJsParametros["grafico_necessidade"] := "line"
		Else
			oJsParametros["grafico_necessidade"] := ""
		EndIf

		If MV_PAR07 == 1
			oJsParametros["grafico_saldo_posterior"] := "column"
		ElseIf MV_PAR07 == 2
			oJsParametros["grafico_saldo_posterior"] := "line"
		Else
			oJsParametros["grafico_saldo_posterior"] := ""
		EndIf

		If lExibe .AND. nActiveFld == 2
			montaEstoq()
		EndIf

	EndIf
Return

/*/{Protheus.doc} RefreshRes
Realiza Refresh das Telas Após Resize
@author brunno.costa
@since 04/12/2019
@version P12
@param 01 - lLateral, lógico, indica se refere-se a operação de resize da divisão lateral
/*/
Static Function RefreshRes(lLateral)
	Default lLateral := .F.

	If lLateral
		If lOpenLat
			nPosGR1Btn -= nWidthDif
		Else
			nPosGR1Btn += nWidthDif
		EndIf
	EndIf

	If nActiveFld == 2
		montaEstoq()
	EndIf

	//Força Reposicionamento após Maximizar - Grid de Resultados
	oBrwResult:SetArray(aResults)
	oBrwResult:ForceRefresh()
	oBrwResult:GoTop()
	oBrwResult:GoTo(oBrwResult:nAt)

	//Força Reposicionamento após Maximizar - Grid de Documentos
	oBrwDocs:SetArray(aDocs)
	oBrwDocs:ForceRefresh()
	oBrwDocs:GoTop()
	oBrwDocs:GoTo(oBrwDocs:nAt)
Return

/*/{Protheus.doc} gerarDocs
Executa a geração dos documentos do ticket consultado.

@type  Static Function
@author lucas.franca
@since 12/12/2019
@version P12.1.28
/*/
Static Function gerarDocs()

	Local aReturn    := {}
	Local cErrorUID  := "PCPA145_"+cTicket
	Local nOpcao     := 0
	Local oPCPError  := PCPMultiThreadError():New(cErrorUID, .F.)
	Local oPCPLock   := PCPLockControl():New()
	Local oTimer     := Nil
	Local oJson      := Nil
	Local b145Recove := {|| oPCPLock:unlock("MRP_MEMORIA", "PCPA145", cTicket) }

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera  := 3

	If oAlteracao:TemAlteracao()
		nOpcao := Aviso(STR0137,                      ; //"Atenção"
		                STR0215 + CHR(13) + CHR(10) + ; //"Foram feitas alterações na tela e não foram salvas."
						STR0217,                      ; //"Deseja salvar as alterações?"
		                {STR0226, STR0219, STR0214}, 2) //"Descartar", "Voltar", "Salvar"

		If nOpcao == 1
			oAlteracao:DesfazAlteracao()
			AtuBrwPrd()

		ElseIf nOpcao == 2
			Return

		ElseIf nOpcao == 3
			oAlteracao:SalvaAlteracao()
		EndIf
	EndIf

	If !PCPLock("PCPA145")
		Help( ,  , "Help", ,  STR0271, ; //"Exite outro processo bloqueando a geração de documentos."
		     1, 0, , , , , , {STR0272} ) //"Aguarde e tente novamente mais tarde."
		Return
	EndIf

	If oPCPLock:lock("MRP_MEMORIA", "PCPA145", cTicket, .F., {"PCPA712", "PCPA145", "PCPA151"}, nEspera)

		If !validaGera(cTicket)
			oPCPLock:unlock("MRP_MEMORIA", "PCPA145", cTicket)
			Return
		EndIf

		If MsgYesNo(STR0136,STR0137) //"Deseja iniciar o processo de geração de documentos?" # "Atenção"
			oTimer := TTimer():New(1000, {|| AvalErro("PCPA145_"+cTicket) }, oDlg )
			oTimer:Activate()

			FWMsgRun(, {|| oPCPError:startJob("PCPA145", GetEnvServer(), .T., cEmpAnt, cFilAnt, cTicket, aClone(aParMrp), .F., cErrorUID, RetCodUsr(), , , , , , b145Recove) }, STR0138, STR0139) //"Processando" # "Gerando documentos..."

			//Verifica oorrencia de erros no PCPA145
			If oPCPError:possuiErro()
				oPCPLock:unlock("MRP_MEMORIA", "PCPA145", cTicket)
				GravaCV8("4", GetGlbValue("PCPA145PROCCV8"), /*cMsg*/, oPCPError:getcError(3), "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt)
				oPCPError:final()
			EndIf
			oPCPError:destroy()
			oTimer:DeActivate()

			//Atualiza o status do ticket em tela.
			aReturn := MrpGetPrc(cFilAnt, cTicket)
			If aReturn[1]
				oJson := JsonObject():New()
				oJson:FromJson(aReturn[2])

				cStatus := P144Status(oJson["status"])
				FreeObj(oJson)
			EndIf
			aSize(aReturn, 0)

			//Atualiza os dados em tela.
			AtuResulta(oBrwProd:nAT)
		Else
			oPCPError:destroy()
		EndIf

		oPCPLock:unlock("MRP_MEMORIA", "PCPA145", cTicket)
	EndIf

	PCPUnlock("PCPA145")

Return

/*/{Protheus.doc} AvalErro
Avalia ocorrencia de erros no PCPA145
@type  Static Function
@author brunno.costa
@since 17/07/2020
@version P12.1.27
@param 01 - cErrorUID, caracter, codigo identificador da secao de controle de erros
/*/
Static Function AvalErro(cErrorUID)
	Local oPCPError := PCPMultiThreadError():New(cErrorUID, .F.)
	//Verifica oorrencia de erros no PCPA145
	If oPCPError:possuiErro()
		oPCPError:final()
	EndIf
Return

/*/{Protheus.doc} validaGera
Valida se um ticket pode iniciar o processamento da geração de documentos.

@type  Static Function
@author lucas.franca
@since 16/12/2019
@version P12.1.28
@param cTicket, Character, Ticket do MRP para validação
@return lRet, Logical, Identifica se o ticket pode gerar os documentos.
/*/
Static Function validaGera(cTicket)
	Local lRet := .T.

	If Empty(cTicket)
		Help( ,  , "Help", ,  STR0134, ; //"Não foi informado o ticket de processamento do MRP."
		     1, 0, , , , , , {STR0135} ) //"Informe o ticket do MRP antes de gerar os documentos."
		lRet := .F.
	EndIf

	If lRet
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3")+cTicket))
			If HW3->HW3_STATUS != "3"
				Help( ,  , "Help", ,  STR0140, ; //"Somente processamentos do MRP com o status 'Finalizado' podem iniciar a geração de documentos."
				     1, 0, , , , , , {STR0141} ) //"Informe um Ticket com o status 'Finalizado' para gerar os documentos."
				lRet := .F.
			EndIf
		Else
			Help( ,  , "Help", ,  STR0142, ; //"Ticket não encontrado nos processamentos do MRP."
			     1, 0, , , , , , {STR0143} ) //"Informe um Ticket válido para processamento."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. _lP144VLGD
		lRet := ExecBlock("P144VLGD",.F.,.F.,{cTicket})
	EndIf 

Return lRet

/*/{Protheus.doc} MenuContxt
Cria Menu de Contexto - Botão Direito

@author brunno.costa
@since 10/01/2018
@version 1.0

@return Nil
/*/
Static Function MenuContxt()

	//Criacao do Menu PopUp com as opcoes para a criacao da arvore
	//de perguntas e respostas.
	MENU soMenu POPUP OF oMainWnd
	MENUITEM STR0148 ACTION ConsultOPC() //"Consultar os Opcionais"
	ENDMENU

	//Criacao da arvore de perguntas e respostas.
	//Ao clicar com o botao direito sera exibido o menu popup.
	oBrwProd:bRClicked := {|o,x,y| (MostraMenu(soMenu, x, y+200)) } // Posicao x,y em relacao a Dialog
	oBrwProd:cToolTip  := STR0149	//"Utilize o botão direito do mouse para consular os opcionais."

Return

/*/{Protheus.doc} MostraMenu
Exibe menu contexto da Tree (botão direito)

@author brunno.costa
@since 10/01/2018
@version P12

@return Nil
@param oMenu, object, objeto oMenu
@param nCoorX, numeric, coordenada X
@param nCoorY, numeric, coordenada Y
@param oArea, object, objeto oDbTree passado por referência
@type Function
/*/

Static Function MostraMenu(oMenu, nCoorX, nCoorY, oArea)

	oMenu:Activate(nCoorX, nCoorY)

Return Nil

/*/{Protheus.doc} ConsultOPC
Consulta Opcionais

@author brunno.costa
@since 10/01/2018
@version 1.0

@return Nil
/*/
Static Function ConsultOPC()
	Local aReturn     := {}
	Local cProduto    := aProdutos[oBrwProd:nAT,IND_APRODUTOS_CODIGO     ]
	Local cOptionalID := aProdutos[oBrwProd:nAT,IND_APRODUTOS_ID_OPCIONAL]
	Local oJson       := Nil

	If Empty(cOptionalID)
		VisOpcPcp(cProduto, "", "", 1)
	Else
		If "|" $ cOptionalID
			cOptionalID := Left(cOptionalID, (At("|", cOptionalID)-1) )
		EndIf

		aReturn := MrpGetOPC(cFilAnt, cTicket, cOptionalID)
		oJson   := JsonObject():New()
		oJson:fromJson(aReturn[2])
		VisOpcPcp(cProduto, Array2STR(oJson["optionalMemo"], .F.), oJson["optionalString"], 2)
	EndIf

Return

/*/{Protheus.doc} vldTicket
Faz a validação do ticket informado.

@type  Static Function
@author lucas.franca
@since 31/01/2020
@version P12.1.27
@param cTicket, Character, Ticket informado.
@param aParMRP, Array    , Array para retorno dos parâmetros do MRP.
@return lRet, Logic, Indica se o ticket é válido.
/*/
Static Function vldTicket(cNumTicket, aParametro)
	Local aReturn := {}
	Local lRet    := .T.
	Local oJson   := Nil

	If !Empty(cNumTicket)
		aReturn := MrpGetPrc(cFilAnt, cNumTicket)
		cStatus := ""
		If aReturn[1]
			oJson := JsonObject():New()
			oJson:FromJson(aReturn[2])

			cStatus := P144Status(oJson["status"]) 
			If ! oJson["status"] $ "3|6|7|9"
				Help( ,  , "Help", ,  STR0156 + " '" + AllTrim(cStatus) + "'. " + STR0157, ; //"Ticket com status" 'xxx'. "Consulta não permitida."
			         1, 0, , , , , , {STR0158} ) //"Consulte apenas os tickets com status 'Finalizado' ou 'Documentos gerados'."
				lRet := .F.
			EndIf
		Else
			Help( ,  , "Help", ,  STR0116, ; //"Não foram encontrados registros para o ticket informado."
			     1, 0, , , , , , {STR0117} ) //"Informe um ticket válido para consulta."
			lRet := .F.
		EndIf

		If lRet
			PCPA144PAR(cNumTicket, @aParametro, .T.)
		EndIf
		oTGet2:CtrlRefresh()
	EndIf
Return lRet

/*/{Protheus.doc} changeDocs
Função executada ao mudar de linha na grid de documentos.

@type  Static Function
@author lucas.franca
@since 06/02/2020
@version P12.1.27
@return .T.
/*/
Static Function changeDocs()
	Local nX     := 0
	Local nLinha := oBrwDocs:nAt

	//Flag para mudar a cor da linha selecionada
	If Len(aDocs) > 0
		For nX := 1 To Len(aDocs)
			aDocs[nX,Len(aDocs[nX])] := .F.
		Next nX
		aDocs[nLinha,Len(aDocs[nLinha])] := .T.
	EndIf
	oBrwDocs:Refresh()
Return .T.

/*/{Protheus.doc} changeSubs
Função executada ao mudar de linha na grid de substituições.

@type  Static Function
@author lucas.franca
@since 06/02/2020
@version P12.1.27
@return .T.
/*/
Static Function changeSubs()
	Local nX     := 0
	Local nLinha := oBrwSubst:nAt

	//Flag para mudar a cor da linha selecionada
	If Len(aSubsts) > 0
		For nX := 1 To Len(aSubsts)
			aSubsts[nX,Len(aSubsts[nX])] := .F.
		Next nX
		aSubsts[nLinha,Len(aSubsts[nLinha])] := .T.
	EndIf
	oBrwSubst:Refresh()
Return .T.

/*/{Protheus.doc} PCPA144Log
Abre o log de eventos do MRP

@author Douglas Heydt
@since 11/05/2020
@version 1.0
/*/
Function PCPA144Log()
	Local oLogTicket

	oLogTicket := LogTickets():New()
	oLogTicket:AbreTela()
	oLogTicket:Destroy()
Return

/*/{Protheus.doc} A144ClData
Função para limpar a tela principal da rotina quando
o ticket consultado previamente não existe mais
@author douglas.heydt
@since 28/07/2020
@version P12
/*/
Function A144ClData()

	cTicket := ""
	oTGet1:CtrlRefresh()

	cStatus := ""
	oTGet2:CtrlRefresh()

	cPeriodo := ""
	oTGet3:CtrlRefresh()

	cDataIni := ""
	oTGet4:CtrlRefresh()

	cDataFim := ""
	oTGet5:CtrlRefresh()

	//Grid Produtos
	aSize(aProdutos, 0)
	AtuBrwPrd()
	aturesulta(0)

	//Grid Resultados
	aSize(aResults, 0)
	IniAResul()
	oBrwResult:SetArray(aResults)
	oBrwResult:ForceRefresh()
	oBrwResult:GoTop()

	//Grid Documento
	aSize(aDocs, 0)
	IniADocs()

Return

/*/{Protheus.doc} A144When
Função responsável por permitir ou não a alteração dos campos do Documento
@author marcelo.neumann
@since 14/10/2020
@version P12
@return lPermite, logical, indica se o campo pode ser alterado
/*/
Function A144When()

	Local lPermite := .F.
	Local nLinha   := oBrwDocs:nAt

	If Len(aDocs) > 0
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3") + cTicket))
			//Só permite alterar se o Ticket estiver Finalizado
			If HW3->HW3_STATUS == "3"
				If aDocs[nLinha][nDC_QTNECE] > 0
					lPermite := .T.
				EndIf
			EndIf
		EndIf
	EndIf

Return lPermite

/*/{Protheus.doc} A144VldNec
Função para validar o valor digitado no campo "Qtd. Necessidade"
@author marcelo.neumann
@since 14/10/2020
@version P12
@return lOk, logical, indica se o valor informado é válido
/*/
Function A144VldNec()

	Local lOk     := .T.
	Local nLinRes := oBrwResult:nAt

	If Len(aDocs) > 0 .And. oAlteracao:AlterouQuantidade(M->HWC_QTNECE)
		If M->HWC_QTNECE == 0
			lOk := .F.
			Help( ,  , "Help", ,  STR0220, ; //"Quantidade necessária não pode ser alterada para zero."
				 1, 0, , , , , , {STR0221} ) //"Informe uma quantidade maior que 0,00."

		ElseIf M->HWC_QTNECE < 0
			lOk := .F.
			Help( ,  , "Help", ,  STR0222, ; //"Quantidade necessária não pode ser menor que zero."
				 1, 0, , , , , , {STR0221} ) //"Informe uma quantidade maior que 0,00."
			lOk := .F.
		EndIf

		If lOk
			oAlteracao:GuardaAlteracao()

			//Força a alteração da linha posicionada
			aCols := aDocs
			oBrwResult:SetArray(aResults)
			oBrwResult:ForceRefresh()
			oBrwResult:GoTo(nLinRes)

			//Habilita/Desabilita o botão Salvar
			If oAlteracao:TemAlteracao()
				oButton7:Enable()
			Else
				oButton7:Disable()
			EndIf
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} TelaSalvar
Abre tela para confirmar as alterações realizadas na tela
@type  Static Function
@author marcelo.neumann
@since 14/10/2020
@version P12
@return lRet, logical, indica se foi escolhida a opção "Voltar" (.F.) para não fechar a tela
/*/
Static Function TelaSalvar()

	Local lRet   := .T.
	Local nOpcao := 0

	If oAlteracao:TemAlteracao()
		nOpcao := oAlteracao:AbreTela()
		//Voltar
		If nOpcao == 1
			lRet := .F.

		//Descartar
		ElseIf nOpcao == 2
			FWMsgRun( , {|| AtuProduto()}, STR0223, STR0039) //"Restaurando dados..." "Aguarde"
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} P144DesPrd
Retorna a descrição de um produto
@type Function
@author marcelo.neumann
@since 19/10/2020
@version P12
@param cProd, character, código do produto
@return P144InfPrd(cProd,"B1_DESC"), character, descrição do produto
/*/
Function P144DesPrd(cProd)
Return P144InfPrd(cProd, "B1_DESC")

/*/{Protheus.doc} FechaTela
Função chamada ao clicar no botão Fechar
@type Static Function
@author marcelo.neumann
@since 19/10/2020
@version P12
@param oDlg, object, referência do Dialog
/*/
Static Function FechaTela(oDlg)

	Local nOpcao := 0

	If oAlteracao:TemAlteracao()
		nOpcao := Aviso(STR0137,                               ; //"Atenção"
		                STR0215 + CHR(13) + CHR(10) +          ; //"Foram feitas alterações na tela e não foram salvas."
						STR0217,                               ; //"Deseja salvar as alterações?"
		                {STR0224, STR0218, STR0219, STR0214}, 2) //"Visualizar", "Não Salvar", "Voltar", "Salvar"

		If nOpcao == 1
			If TelaSalvar()
				oDlg:End()
			EndIf

		ElseIf nOpcao == 2
			oDlg:End()

		ElseIf nOpcao == 4
			oAlteracao:SalvaAlteracao()
			oDlg:End()
		EndIf
	Else
		oDlg:End()
	EndIf

Return

/*/{Protheus.doc} P144InfPrd
Recupera informações do produto

@type  Static Function
@author lucas.franca
@since 07/12/2020
@version P12
@param cProduto, Character, Código do produto para busca
@param cTipo   , Character, Coluna da SB1 identificando informação a retornar
@return __oInfProd[cProduto][cTipo], Conteúdo da informação do produto que foi solicitada
/*/
Static Function P144InfPrd(cProduto, cTipo)

	If __oInfProd[cProduto] == Nil
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cProduto))
			__oInfProd[cProduto] := JsonObject():New()
			__oInfProd[cProduto]["B1_DESC"  ] := SB1->B1_DESC
			__oInfProd[cProduto]["B1_ESTSEG"] := RetFldProd(SB1->B1_COD,"B1_ESTSEG")
			__oInfProd[cProduto]["B1_LE"    ] := RetFldProd(SB1->B1_COD,"B1_LE"    )
			__oInfProd[cProduto]["B1_QE"    ] := RetFldProd(SB1->B1_COD,"B1_QE"    )
			__oInfProd[cProduto]["B1_EMIN"  ] := RetFldProd(SB1->B1_COD,"B1_EMIN"  )
			__oInfProd[cProduto]["B1_PE"    ] := RetFldProd(SB1->B1_COD,"B1_PE"    )
			__oInfProd[cProduto]["B1_TIPE"  ] := RetFldProd(SB1->B1_COD,"B1_TIPE"  )
			If !Empty(__oInfProd[cProduto]["B1_TIPE"])
				__oInfProd[cProduto]["B1_TIPE"] := getDesCBox("SB1", "B1_TIPE", __oInfProd[cProduto]["B1_TIPE"])
			EndIf
		Else
			__oInfProd[cProduto] := JsonObject():New()
		EndIf
	EndIf

Return __oInfProd[cProduto][cTipo]

/*/{Protheus.doc} getDesCBox
Retorna a descrição do campo ComboBox
@type Static Function
@author lucas.franca
@since 08/12/2020
@version P12
@param 01 cAlias, Character, Alias do campo
@param 02 cCampo, Character, Nnome do campo a ser retornada a descrição do combobox
@param 03 cValue, Character, Valor do campo
@return   cDesc , Character, Descrição da opção no combobox
/*/
Static Function getDesCBox(cAlias, cCampo, cValue)
	Local aOpcoes := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)
	Local cDesc   := ""
	Local nOrigem := Val(cValue)

	If nOrigem > 0
		cDesc := RTrim(aOpcoes[nOrigem][3])
	ElseIf (nOrigem := aScan(aOpcoes, {|x| x[2] == cValue})) > 1
		cDesc := RTrim(aOpcoes[nOrigem][3])
	EndIf

Return cDesc


/*/{Protheus.doc} chkFilExec
Verifica se o MRP pode ser executado na filial atual.
(validação de empresas centralizadas/centralizadoras do MRP Multi-empresas.)

@type  Static Function
@author douglas.heydt
@since 09/12/2020
@version P12
@return lRet, Logic, Identifica se é permitido executar o MRP na filial atual
/*/
Static Function chkFilExec()
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local cFilCent   := ""
	Local lRet       := .T.
	Local nTamOPGE   := GetSx3Cache("OP_CDEPGR", "X3_TAMANHO")
	Local nTamOPEmp  := GetSx3Cache("OP_EMPRGR", "X3_TAMANHO")
	Local nTamOPUnid := GetSx3Cache("OP_UNIDGR", "X3_TAMANHO")
	Local nTamOPFil  := GetSx3Cache("OP_CDESGR", "X3_TAMANHO")

	cGrupo := PadR(cGrupo, nTamOPGE)
	cEmp   := PadR(cEmp  , nTamOPEmp)
	cUnid  := PadR(cUnid , nTamOPUnid)
	cFil   := PadR(cFil  , nTamOPFil)

	SOP->(dbSetOrder(4))
	If SOP->(dbSeek(xFilial("SOP")+cGrupo+cEmp+cUnid+cFil))
		lRet := .F.

		cFilCent := PadR(SOP->OP_EMPRCZ, Len(cEmp)) + PadR(SOP->OP_UNIDCZ, Len(cUnid)) + PadR(SOP->OP_CDESCZ, Len(cFil))

		Help(,,'Help',,STR0055 + " '" + AllTrim(cFilAnt) + "' " + STR0243,; //"Filial 'XX' está configurada como Filial Centralizada. Execução não permitida."
			 1,0,,,,,,{STR0245 + " '" + AllTrim(cFilCent) + "'."}) //"Para executar o a rotina de resultados do MRP, a execução deve ser realizada em uma filial centralizadora. Execute o MRP na filial"
	EndIf

Return lRet

/*/{Protheus.doc} usaME
Verifica se a filial em execução é centralizadora para definir se apresenta dados de filiais diferentes
@type  Static Function
@author douglas.heydt
@since 09/12/2020
@version P12
@return lRet, Logic, Identifica se apresenta dados de filiais diferentes ou não
/*/
Static Function usaME()
	Local cGrupo := ""
	Local cEmp   := ""
	Local cUnid  := ""
	Local cFil   := ""

	If __lUsaME == Nil
		cGrupo := PadR(cEmpAnt         , GetSx3Cache("OO_CDEPCZ", "X3_TAMANHO"))
		cEmp   := PadR(FWCompany()     , GetSx3Cache("OP_EMPRCZ", "X3_TAMANHO"))
		cUnid  := PadR(FWUnitBusiness(), GetSx3Cache("OP_UNIDCZ", "X3_TAMANHO"))
		cFil   := PadR(FwFilial()      , GetSx3Cache("OP_CDESCZ", "X3_TAMANHO"))

		SOO->(dbSetOrder(2))
		If SOO->(dbSeek(xFilial("SOO")+cGrupo+cEmp+cUnid+cFil))
			__lUsaME := .T.
		Else
			__lUsaME := .F.
		EndIf
	EndIf

Return __lUsaME

/*/{Protheus.doc} montaTrans
Monta tela de Documentos - Transferências
@type Static Function
@author marcelo.neumann
@since 06/01/2021
@version P12
/*/
Static Function montaTrans()
	Local aHeaderTra := {}
	Local cTitulo    := ""
	Local cValid     := ""
	Local nDecimal   := 0
	Local nLinDoc    := 0
	Local nTamanho   := 0

	nLinDoc := oBrwDocs:nAt

	criaATrans()

	cTitulo  := STR0250 //"Filial Origem"
	nTamanho := 12
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_FILORIG","",nTamanho,nDecimal,cValid,"û","C",""})

	cTitulo  := STR0251 //"Filial Destino""
	nTamanho := 12
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_FILDEST","",nTamanho,nDecimal,cValid,"û","C",""})

	cTitulo  := STR0259 //"Qtd. Transf."
	nTamanho := 12
	nDecimal := 2
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_QTDTRAN","@E 999,999,999.99",nTamanho,nDecimal,cValid,"û","N",""})

	cTitulo  := STR0269 //"Data transferência"
	nTamanho := 8
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_DTTRANS","@D",nTamanho,nDecimal,cValid,"û","D",""})
	cTitulo  := STR0262 //"Armazém Origem"
	nTamanho := 10
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_ARMORIG","",nTamanho,nDecimal,cValid,"û","C",""})
	cTitulo  := STR0270 //"Data recebimento"
	nTamanho := 8
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_DTRECEB","@D",nTamanho,nDecimal,cValid,"û","D",""})

	cTitulo  := STR0263 //"Armazém Destino"
	nTamanho := 10
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_ARMDEST","",nTamanho,nDecimal,cValid,"û","C",""})

	cTitulo  := STR0264 //"Documento"
	nTamanho := 100
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_DOCUM","",nTamanho,nDecimal,cValid,"û","C",""})

	cTitulo  := STR0265 //"Status"
	nTamanho := 1
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_STATUS","",nTamanho,nDecimal,cValid,"û","C",""})

	cTitulo  := STR0266 //"Mensagem"
	nTamanho := 254
	nDecimal := 0
	cValid   := ""
	aAdd(aHeaderTra,{cTitulo,"MA_MSG","",nTamanho,nDecimal,cValid,"û","C",""})

	oBrwTrans := MsNewGetDados():New(001,;
	                                 001,;
									 oPnlTransf:nClientHeight-100,;
									 oPnlTransf:nClientWidth*0.5,;
									 /*GD_UPDATE*/,;
									 /*LinhaOk*/,;
									 /*tudoOk*/,;
									 /*IniCpos*/,;
									 /*aAlter*/,;
									 0,;
									 1000,;
									 ,;
									 ,;
									 "AllwaysFalse",;
									 oPnlTransf,;
									 aHeaderTra,;
									 aTransfers,;
									 {|| changeTran()} )

	oBrwTrans:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwTrans:oBrowse:lUseDefaultColors := .F.
	oBrwTrans:oBrowse:SetBlkBackColor({|| GETDCLR(aTransfers,oBrwTrans:nAt)})
	oBrwTrans:oBrowse:SetBlkColor( { || RGB(0,0,0) } )

	oBrwTrans:SetArray(aTransfers)
	oBrwTrans:ForceRefresh()
	oBrwTrans:GoTop()

Return

/*/{Protheus.doc} criaATrans
Popula dados na Grid de Transferências
@type Static Function
@author marcelo.neumann
@since 06/01/2021
@version P12
/*/
Static Function criaATrans()
	Local aItems   := {}
	Local aResTran := {}
	Local nTotal   := 0
	Local nInd     := 0

	aSize(aTransfers, 0)

	If Empty(aResults) .Or. Empty(aResults[1][nRE_DATA])
		aAdd(aResTran, .F.)
	Else
		aResTran := MrpGetSMA(cTicket, , .T., aProdutos[oBrwProd:nAt][IND_APRODUTOS_CODIGO], aResults[oBrwResult:nAt][nRE_DATA])
	EndIf

	If aResTran[1]
		aItems   := aResTran[2]["items"]
		nTotal   := Len(aItems)

		For nInd := 1 To nTotal
			aAdd(aTransfers, Array(IND_ATRANSFERS_TAMANHO))

			aTransfers[nInd][IND_ATRANSFERS_FILIAL_ORIGEM  ] := aItems[nInd]['originBranchId'         ]
			aTransfers[nInd][IND_ATRANSFERS_FILIAL_DESTINO ] := aItems[nInd]['destinyBranchId'        ]
			aTransfers[nInd][IND_ATRANSFERS_QTD_TRANSFER   ] := aItems[nInd]['transferenceQuantity'   ]
			aTransfers[nInd][IND_ATRANSFERS_DATA_TRANSFER   ] := aItems[nInd]['transferenceDate'    ]
			aTransfers[nInd][IND_ATRANSFERS_DATA_RECEBIMENTO] := aItems[nInd]['receiptDate'         ]
			aTransfers[nInd][IND_ATRANSFERS_ARMAZEM_ORIGEM ] := aItems[nInd]['originWarehouse'        ]
			aTransfers[nInd][IND_ATRANSFERS_ARMAZEM_DESTINO] := aItems[nInd]['destinyWarehouse'       ]
			aTransfers[nInd][IND_ATRANSFERS_DOCUMENTO      ] := aItems[nInd]['document'               ]
			aTransfers[nInd][IND_ATRANSFERS_STATUS         ] := aItems[nInd]['status'                 ]
			aTransfers[nInd][IND_ATRANSFERS_MENSAGEM       ] := aItems[nInd]['message'                ]
			aTransfers[nInd][IND_ATRANSFERS_FLAG_SEL       ] := IIf(nInd == 1, .T., .F.)
		Next
	Else
		IniATransf()
	EndIf

Return

/*/{Protheus.doc} changeTran
Função executada ao mudar de linha na grid de transferências.
@type Static Function
@author marcelo.neumann
@since 06/01/2021
@version P12
@return .T.
/*/
Static Function changeTran()
	Local nX     := 0
	Local nLinha := oBrwTrans:nAt

	//Flag para mudar a cor da linha selecionada
	If Len(aTransfers) > 0
		For nX := 1 To Len(aTransfers)
			aTransfers[nX,Len(aTransfers[nX])] := .F.
		Next nX
		aTransfers[nLinha,Len(aTransfers[nLinha])] := .T.
	EndIf
	oBrwTrans:Refresh()

Return .T.

/*/{Protheus.doc} IniATransf
Inicializa array do grid de transferências
@type Static Function
@author marcelo.neumann
@since 06/01/2021
@version P12
/*/
Static Function IniATransf()

	aAdd(aTransfers, Array(IND_ATRANSFERS_TAMANHO))

	aTransfers[1][IND_ATRANSFERS_FILIAL_ORIGEM  ] := ""
	aTransfers[1][IND_ATRANSFERS_FILIAL_DESTINO ] := ""
	aTransfers[1][IND_ATRANSFERS_QTD_TRANSFER   ] := 0
	aTransfers[1][IND_ATRANSFERS_DATA_TRANSFER   ] := StoD("")
	aTransfers[1][IND_ATRANSFERS_DATA_RECEBIMENTO] := StoD("")
	aTransfers[1][IND_ATRANSFERS_ARMAZEM_ORIGEM ] := ""
	aTransfers[1][IND_ATRANSFERS_ARMAZEM_DESTINO] := ""
	aTransfers[1][IND_ATRANSFERS_DOCUMENTO      ] := ""
	aTransfers[1][IND_ATRANSFERS_STATUS         ] := ""
	aTransfers[1][IND_ATRANSFERS_MENSAGEM       ] := ""
	aTransfers[1][IND_ATRANSFERS_FLAG_SEL       ] := .T.

Return

/*/{Protheus.doc} GetProdPai
Busca o produto pai do documento gerado
@type Static Function
@author marcelo.neumann
@since 02/03/2021
@version P12
@param cDocPai, Caracter, Número do documento gerado pelo MRP
@return __oProdPai[cDocPai], Caracter, código do produto pai do documento
/*/
Static Function GetProdPai(cDocPai)
	Local aProdPai := {}
	Local oProdPai := Nil

	If __oProdPai[cDocPai] == Nil
		aProdPai := MrpGetPrdP(cFilAnt, cTicket, cDocPai)

		oProdPai := JsonObject():New()
		oProdPai:FromJson(aProdPai[2])

		__oProdPai[cDocPai] := oProdPai[cDocPai]

		aSize(aProdPai, 0)
		FreeObj(oProdPai)
	EndIf

Return __oProdPai[cDocPai]

/*/{Protheus.doc} SetInfoHWB
Grava alguma informação de nível de Resultado (HWB) que não é exibida no array Resultados para recuperar em outro momento
@type Static Function
@author marcelo.neumann
@since 02/03/2021
@version P12
@param 01 cFilAux , Caracter, Código da filial do documento
@param 02 cProduto, Caracter, Código do produto
@param 03 cIdOpc  , Caracter, Identificador do opcional do produto
@param 04 cPeriodo, Caracter, Período da informação
@param 05 aItens  , Array   , Informações da HWB a serem gravadas
@return Nil
/*/
Static Function SetInfoHWB(cFilAux, cProduto, cIdOpc, cPeriodo, aItens)

	If __oInfHWB[cFilAux] == Nil
		__oInfHWB[cFilAux] := JsonObject():New()
	EndIf

	If __oInfHWB[cFilAux][cProduto] == Nil
		__oInfHWB[cFilAux][cProduto] := JsonObject():New()
	EndIf

	If __oInfHWB[cFilAux][cProduto][cIdOpc] == Nil
		__oInfHWB[cFilAux][cProduto][cIdOpc] := JsonObject():New()
	EndIf

	If __oInfHWB[cFilAux][cProduto][cIdOpc][cPeriodo] == Nil
		__oInfHWB[cFilAux][cProduto][cIdOpc][cPeriodo] := JsonObject():New()
	EndIf

	__oInfHWB[cFilAux][cProduto][cIdOpc][cPeriodo]["startDate"] := StrTran(aItens["startDate"],"-","")

Return

/*/{Protheus.doc} GetInfoHWB
Recupera alguma informação de nível de Resultado (HWB) que não é exibida no array Resultados
@type Static Function
@author marcelo.neumann
@since 02/03/2021
@version P12
@param 01 cFilAux , Caracter  , Código da filial do documento
@param 02 cProduto, Caracter  , Código do produto
@param 03 cIdOpc  , Caracter  , Identificador do opcional do produto
@param 04 cPeriodo, Caracter  , Período da informação
@param 05 cInfo   , Caracter  , Informação a ser retornada
@return   xInfo   , Indefinido, Informação solicitada
/*/
Static Function GetInfoHWB(cFilAux, cProduto, cIdOpc, cPeriodo, cInfo)

	Local xInfo := Nil

	If __oInfHWB[cFilAux] <> Nil
		If __oInfHWB[cFilAux][cProduto] <> Nil
			If __oInfHWB[cFilAux][cProduto][cIdOpc] <> Nil
				If __oInfHWB[cFilAux][cProduto][cIdOpc][cPeriodo] <> Nil
					If __oInfHWB[cFilAux][cProduto][cIdOpc][cPeriodo][cInfo] <> Nil
						xInfo := __oInfHWB[cFilAux][cProduto][cIdOpc][cPeriodo][cInfo]
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return xInfo

/*/{Protheus.doc} LimpaCache
Limpa as estáticas de cache
@type Static Function
@author marcelo.neumann
@since 02/03/2021
@version P12
@return Nil
/*/
Static Function LimpaCache()

	FreeObj(__oProdPai)
	__oProdPai := JsonObject():New()

	FreeObj(__oInfHWB)
	__oInfHWB := JsonObject():New()

Return

/*/{Protheus.doc} addOptID
Adiciona o ID de Opcionais na chave de substituição

@type Static Function
@author lucas.franca
@since 03/05/2022
@version P12
@param 01 cChaveSubs, Character, Chave de substituição original
@param 02 cIDOpc    , Character, ID de opcionais a ser incluído na chave.
@return cChaveSubs  , Character, Chave de substituição com o ID Opcional.
/*/
Static Function addOptID(cChaveSubs, cIDOpc)
	Local cAvalia   := ""
	Local lAchouPer := .F.
	Local nIndex    := 0
	Local nTotal    := Len(cChaveSubs)
	Local nPosAdd   := 0

	cIdOpc := AllTrim(cIdOpc)
	If Empty(cIdOpc)
		Return cChaveSubs
	EndIf

	For nIndex := nTotal To 1 Step -1
		cAvalia := SubStr(cChaveSubs, nIndex, 1)
		If Empty(cAvalia) .And. lAchouPer == .F.
			//Espaços em branco no final de cChaveSubs. Pula.
			Loop
		ElseIf lAchouPer
			//Já encontrou as posições do período e retornou a ter espaços em branco.
			//Esta é a posição para adicionar o ID de opcionais.
			nPosAdd := nIndex
			Exit
		ElseIf IsDigit(cAvalia)
			//Se for um número, indica que encontrou as posições do período.
			lAchouPer := .T.
		EndIf
	Next nIndex

	If nPosAdd > 0
		cChaveSubs := Stuff(cChaveSubs, nPosAdd+1, 0, "|" + cIDOpc)
	EndIf

Return cChaveSubs
