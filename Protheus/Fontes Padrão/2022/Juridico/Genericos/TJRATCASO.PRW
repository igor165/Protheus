#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TJRATCASO.CH"

Static _lFwPDCanUse := FindFunction("FwPDCanUse")

Function __TJRATCASO() // Function Dummy
ApMsgInfo( 'TJRATCASO -> Utilizar Classe ao inves da funcao' )
Return NIL 

Class TJRATCASO From FWSerialize

	Data oDlg
	Data lOk
	//Campos exibidos na tela
	//Variáveis
	Data cTipoRat
	Data cEscrit
	Data cFatura
	Data cPreFt
	
	Data CampoRat
	Data cCliente
	Data cLoja
	Data cRazao
	Data cMoeda
	Data nVlRatFat
	Data nTotCaso
	Data nSaldoCaso
	Data cGetCCli
	Data cGetCLoja
	Data cGetContr
	Data cGetCCaso
	Data cGetValor

	// Objetos
	Data oGetEscrit
	Data oGetFatura
	Data oGetCClien
	Data oGetCLoja
	Data oGetContr
	Data oGetDClien
	Data oGetMoeda
	Data oGetVlFat
	Data oGetVlCas
	Data oGetSldCas
	Data oGetCodCliCaso
	Data oGetCodLojCaso
	Data oGetCodCaso
	Data oGetVlCaso
	Data oLbxRatCas

	Data aItems

	Method New(cEscrit, cFatura, cTipo, cCodPre) Constructor
	Method GetTipoRat()
	Method GetEscrit()
	Method GetFatura()
	Method GetPreFt()
	Method GetCliente()
	Method GetLoja()
	Method GetQtdItems()
	Method GetQtdCaso()
	Method GetGrdCaso(nLinha)

	Method LimpaLista()
	Method addItem( aItem )
	Method addCaso()
	Method remCaso()
	Method remItem()
	Method SomaCol( ncol )

	Method RefreshList( nItem )
	Method RefreshCampos()
	Method SelItem( nItem )
	Method LoadCasos()
	Method AtualizaSld()
	Method InsereSaldo()
	Method ZeraSaldo()
	Method DrawScreen()
	Method ActiveScreen()
	
	Method ValidaCampos(cAlias)
	Method ValidaSaldos() 
	Method RateioPF() 
	Method RateioF() 
	Method Cancela()
	Method Confirma()
	Method VldDescCas()
	Method SetF3Caso(cCaso)
	Method SetF3Contr(cContr)

EndClass

Method New(cEscrit, cFatura, cTipo, cCodPre) Class TJRATCASO
	Local cCodMoeda
	Local cCampoRat

	self:aItems := {}

	If Empty(cCodPre)

		self:cEscrit  := cEscrit
		self:cFatura  := cFatura
		self:cTipoRat := cTipo
		self:cPreFt   := ""
	
		If cTipo == "1" //Rateio do Desconto Especial
			cCampoRat := "NXA_VLDSCE"
		ElseIf cTipo == "2" //Rateio do Acréscimo
			cCampoRat := "NXA_VLACRE"
		ElseIf cTipo == "3" //Rateio do Desconto do Pagador
			cCampoRat := "NXA_VLDSCP"
		EndIf
	
		self:cCliente   := Posicione("NXA", 1, xFilial("NXA") + self:GetEscrit() + self:GetFatura(), "NXA_CCLIEN" )
		self:cLoja      := Posicione("NXA", 1, xFilial("NXA") + self:GetEscrit() + self:GetFatura(), "NXA_CLOJA" )
	
		cCodMoeda       := Posicione("NXA", 1, xFilial("NXA") + self:GetEscrit() + self:GetFatura(), "NXA_CMOEDA" )
		self:cMoeda     := Posicione("CTO", 1, xFilial("CTO") + cCodMoeda, "CTO_SIMB" )
	
		self:nVlRatFat  := Posicione("NXA", 1, xFilial("NXA") + self:GetEscrit() + self:GetFatura(), cCampoRat )
		self:cRazao     := Posicione("SA1", 1, xFilial("SA1") + self:GetCliente() + self:GetLoja(), "A1_NOME" )
	
	Else
		self:cTipoRat   := "1"
		self:cPreFt     := cCodPre
		self:cFatura    := cCodPre
		self:cCliente   := Posicione("NX0", 1, xFilial("NX0") + self:cPreFt, "NX0_CCLIEN" )
		self:cLoja      := Posicione("NX0", 1, xFilial("NX0") + self:cPreFt, "NX0_CLOJA" )
	
		cCodMoeda       := Posicione("NX0", 1, xFilial("NX0") + self:cPreFt, "NX0_CMOEDA" )
		self:cMoeda     := Posicione("CTO", 1, xFilial("CTO") + cCodMoeda, "CTO_SIMB" )
	
		self:nVlRatFat  := FwFldGet("NX0_DESCH")
		self:cRazao     := Posicione("SA1", 1, xFilial("SA1") + self:GetCliente() + self:GetLoja(), "A1_NOME" )
	EndIf

	self:nTotCaso       := 0
	self:nSaldoCaso     := self:nVlRatFat

	self:cGetCCli       := CriaVar('NVE_CCLIEN', .F.)
	self:cGetCLoja      := CriaVar('NVE_LCLIEN', .F.)
	self:cGetContr      := CriaVar('NT0_COD'   , .F.)
	self:cGetCCaso      := CriaVar('NVE_NUMCAS', .F.)
	self:cGetValor      := 0

	self:LoadCasos()

Return self

Method GetTipoRat() Class TJRATCASO
Return self:cTipoRat

Method GetEscrit() Class TJRATCASO
Return self:cEscrit

Method GetFatura() Class TJRATCASO
Return self:cFatura

Method GetPreFt() Class TJRATCASO
Return self:cPreFt

Method GetCliente() Class TJRATCASO
Return self:cCliente

Method GetLoja() Class TJRATCASO
Return self:cLoja

Method GetQtdItems() Class TJRATCASO
Return Len(self:aItems)

Method GetQtdCaso() Class TJRATCASO
	Local nQtdCasos
	
	If Len(self:aItems) == 1 .And. Empty(self:aItems[1])
		nQtdCasos := 0
	Else
		nQtdCasos := Len(self:aItems)
	EndIf

Return nQtdCasos

Method SetF3Caso(cCaso) Class TJRATCASO

	Self:cGetCCaso := cCaso
	Self:oGetCodCaso:SetValue(cCaso)
	Self:oGetCodCaso:Refresh()

Return Self:cGetCCaso

Method SetF3Contr(cContr) Class TJRATCASO

	Self:cGetContr := cContr
	Self:oGetContr:SetValue(cContr)
	Self:oGetContr:Refresh()

Return Self:oGetContr:GetValue()

Method GetGrdCaso(nLinha) Class TJRATCASO
	
	If nLinha <= 0 .Or. nLinha > Len( self:aItems )
		nLinha := self:oLbxRatCas:nAt
	EndIf
	
Return ( { self:aItems[nLinha][ 2], self:aItems[nLinha][ 3], self:aItems[nLinha][ 5], self:aItems[nLinha][ 6], self:aItems[nLinha][ 8] } )

Method LimpaLista() Class TJRATCASO 
	Local aTemp     := {}

	Local cClien    := CriaVar('NVE_CCLIEN', .F. )
	Local cLoja     := CriaVar('NVE_LCLIEN', .F.)
	Local cCaso     := CriaVar('NVE_NUMCAS', .F.)
	Local cContr    := CriaVar('NT0_COD'   , .F.)
	Local cNomeCli  := CriaVar('A1_NOME'   , .F.)
	Local cTitCaso  := CriaVar('NVE_TITULO', .F.)
	Local cGetValor := 0
	
	aAdd(aTemp, {"", cClien, cLoja, cNomeCli, cContr, cCaso, cTitCaso, cGetValor})

	self:aItems := {}
	aAdd(self:aItems, aTemp[1])

Return Nil

Method addItem(aItem) Class TJRATCASO
	Local aRet := {.F., "addItem"}

	If Len(self:aItems) == 1 .And. Empty(self:aItems[1][2])
		self:aItems := {}
	EndIf
	
	If !Empty(self:aItems) .And. Len(self:aItems[1]) <> Len(aItem)
		aRet := {.F., "addItem: Len(self:aItems[1]) <> Len(aItem) "}
	Else
		aAdd(self:aItems, aItem)
	EndIf

Return aRet

Method addCaso() Class TJRATCASO
	Local aRet       := {.T., "addCaso"}
	Local cGetCCli   := self:cGetCCli
	Local cGetCLoja  := self:cGetCLoja
	Local cRazao     := ""
	Local cGetContr  := self:cGetContr
	Local cGetCCaso  := self:cGetCCaso
	Local cTitulo    := ""
	Local cGetValor  := self:cGetValor
	Local nSaldoCaso := self:nSaldoCaso
	Local aTemp      := {}
	Local nValLiq    := 0
	Local cValLiq    := 0
	Local oModel     := Nil
	Local oModelNX1  := Nil
	Local oModelNX8  := Nil

	If cGetValor <= 0
		aRet := {.F., STR0001} //"Deve ser informado um valor positivo para ratear"
	EndIf

	If aRet[1] .And. !Empty( cGetCCli ) .And. !Empty( cGetCLoja ) .And. !Empty( cGetContr ) .And. !Empty( cGetCCaso )

		nPos := aScan( self:aItems, { |ax| ax[2] == cGetCCli .And. ax[3] == cGetCLoja .And. ax[5] == cGetContr .And. ax[6] == cGetCCaso } )
		oModel     := FWModelActive()
		oModelNX8  := oModel:GetModel("NX8DETAIL")
		oModelNX1  := oModel:GetModel("NX1DETAIL")

		oModelNX8:SeekLine({{"NX8_CCONTR", cGetContr}})
		oModelNX1:SeekLine({{"NX1_CCLIEN", cGetCCli}, {"NX1_CLOJA", cGetCLoja}, {"NX1_CCASO", cGetCCaso}})
		nValLiq := oModelNX1:GetValue("NX1_VTS") +  oModelNX1:GetValue("NX1_VFIXO") - oModelNX1:GetValue("NX1_VDESCO")

		If cGetValor > nValLiq
			cValLiq := Alltrim(JA202DMOED(NX0->NX0_CMOEDA)) + " " + Alltrim(Transform(nValLiq, PesqPict("NX0", "NX0_VLFATH")))
			aRet := {.F., I18N(STR0025, {cValLiq})} //"O valor do desconto não pode ser maior do que o valor líquido de: #1 do caso"
		Else
			If nPos == 0
				
				If nSaldoCaso - cGetValor >= 0
					cRazao  := Posicione('SA1', 1, xFilial('SA1') + cGetCCli + cGetCLoja, 'A1_NOME')
					cTitulo := Posicione('NVE', 1, xFilial('NVE') + cGetCCli + cGetCLoja + cGetCCaso, 'NVE_TITULO')
					aAdd(aTemp, {"", cGetCCli, cGetCLoja, cRazao, cGetContr, cGetCCaso, cTitulo, cGetValor } )

					self:addItem(aTemp[1])
				Else
					aRet := {.F., STR0002 } //"O Saldo Ficará negativo"
				EndIf

			Else
				//Ajusta o valor
				If nSaldoCaso + self:aItems[nPos][ 8 ] - cGetValor >= 0
					self:aItems[nPos][ 8 ] := cGetValor
				Else
					aRet := {.F., STR0002 } //"O Saldo Ficará negativo"
				EndIf

			EndIf
		EndIf

		self:RefreshList()
		self:RefreshCampos()

	Else
		aRet := {.F., STR0003 } // "Preencha os campos"
	EndIf

	If !aRet[1]
		MsgAlert(aRet[2])
	EndIf

Return aRet

Method remCaso( ) Class TJRATCASO
	Local aRet  := {.T., "remCaso"}
	Local nItem := self:oLbxRatCas:nAt

	If Len(self:aItems) > 1 
		self:aItems := JaRemPos(self:aItems, nItem)
	Else
		self:LimpaLista()
	EndIf
	self:RefreshList( self:GetQtdItems() )
	nItem := nItem - 1
	If nItem <= 0
		nItem := 1
	EndIf
	self:SelItem( nItem )
	self:cGetValor := 0
	self:RefreshCampos()

Return aRet

Method SomaCol( ncol ) Class TJRATCASO
	Local nSoma  := 0
	Local nCount := 0

	If !Empty(self:aItems) .And. ValType(self:aItems[1][ncol]) == "N"

		For nCount := 1 To Len(self:aItems)
			nSoma := nSoma + self:aItems[nCount][ncol]
		Next
	
	EndIf

Return nSoma

Method RefreshList( nItem ) Class TJRATCASO

	Local aCposLGPD   := {}
	Local aNoAccLGPD  := {}
	Local aDisabLGPD  := {}
	Local cPict       := "*********"

	If _lFwPDCanUse .And. FwPDCanUse(.T.) // Tratamentos LGPD
		aCposLGPD := {"NVE_CCLIEN", "NVE_LCLIEN", "A1_NOME", "NT0_COD", "NVE_NUMCAS", "NVE_TITULO"}
		aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aNoAccLGPD, {|x| AAdd( aDisabLGPD, x:CFIELD)})
	EndIf

	If Len(self:aItems) >= (self:oLbxRatCas:nAt)
		self:oLbxRatCas:setarray(self:aItems)
		self:oLbxRatCas:bLine := { || {;
		self:aItems[ self:oLbxRatCas:nAt, 1], ;
		IIf(aScan(aDisabLGPD,"NVE_CCLIEN") > 0, cPict, self:aItems[ self:oLbxRatCas:nAt, 2]), ;
		IIf(aScan(aDisabLGPD,"NVE_LCLIEN") > 0, cPict, self:aItems[ self:oLbxRatCas:nAt, 3]), ;
		IIf(aScan(aDisabLGPD,"A1_NOME"   ) > 0, cPict, self:aItems[ self:oLbxRatCas:nAt, 4]), ;
		IIf(aScan(aDisabLGPD,"NT0_COD"   ) > 0, cPict, self:aItems[ self:oLbxRatCas:nAt, 5]), ;
		IIf(aScan(aDisabLGPD,"NVE_NUMCAS") > 0, cPict, self:aItems[ self:oLbxRatCas:nAt, 6]), ;
		IIf(aScan(aDisabLGPD,"NVE_TITULO") > 0, cPict, self:aItems[ self:oLbxRatCas:nAt, 7]), ;
		Transform( self:aItems[ self:oLbxRatCas:nAt, 8], "@E 999,999,999.99") } }
		If nItem == 0
			self:oLbxRatCas:nAt := 1
		Else
			self:oLbxRatCas:nAt := nItem
		EndIf
		self:oLbxRatCas:refresh()
	EndIf

Return Nil

Method RefreshCampos() Class TJRATCASO
	
	If Empty(self:cPreFt)
		self:oGetEscrit:Refresh()
	EndIf
	self:oGetCodCliCaso:SetValue(self:cGetCCli, self:cGetCCli)
	self:oGetCodLojCaso:SetValue(self:cGetCLoja, self:cGetCLoja)
	self:oGetContr:SetValue(self:cGetContr, self:cGetContr)
	self:oGetCodCaso:SetValue(self:cGetCCaso, self:cGetCCaso)
	
	self:AtualizaSld()

	self:oGetFatura:Refresh()
	self:oGetCClien:Refresh()
	self:oGetCLoja:Refresh()
	self:oGetDClien:Refresh()
	self:oGetMoeda:Refresh()
	self:oGetVlFat:Refresh()
	self:oGetCodCliCaso:Refresh()
	self:oGetCodLojCaso:Refresh()
	self:oGetContr:Refresh()
	self:oGetCodCaso:Refresh()
	
	self:oGetVlCaso:SetValue(self:cGetValor, self:cGetValor)
	self:oGetVlCas:SetValue(self:nTotCaso, self:nTotCaso)
	self:oGetSldCas:SetValue(self:nSaldoCaso, self:nSaldoCaso)

Return Nil

Method SelItem( nItem ) Class TJRATCASO

	self:cGetCCli  := self:aItems[ nItem ][ 2 ]
	self:cGetCLoja := self:aItems[ nItem ][ 3 ]
	self:cGetContr := self:aItems[ nItem ][ 5 ]
	self:cGetCCaso := self:aItems[ nItem ][ 6 ]
	self:cGetValor := self:aItems[ nItem ][ 8 ]

	self:oLbxRatCas:nAt := nItem
	
	self:RefreshList(nItem)
	self:RefreshCampos()

Return Nil

Method LoadCasos()  Class TJRATCASO
	Local lRet          := .F.  
	Local aArea         := GetArea()
	Local cQuery        := ""
	Local cQryRes       := GetNextAlias()
	Local aTemp         := {}
	Local cCampoRat     := ""
	Local oModel        := Nil
	Local oModelNX0     := Nil
	Local oModelNX8     := Nil
	Local oModelNX1     := Nil
	Local aSaveLines    := {}
	Local nNX8          := 0
	Local nNX1          := 0

	If Empty(self:cPreFt)

		If self:GetTipoRat() == "1"
			cCampoRat := "NXC_DRATE"
		ElseIf self:GetTipoRat() == "2"
			cCampoRat := "NXC_ARATF"
		ElseIf self:GetTipoRat() == "3"
			cCampoRat := "NXC_DRATP"
		EndIf
	
		cQuery := " SELECT NXC.NXC_CESCR, NXC.NXC_CFATUR, NXC.NXC_CCLIEN CCLIEN, NXC.NXC_CLOJA CLOJA, SA1.A1_NOME NOME, "
		cQuery += " NXC.NXC_CCONTR CCONTR, NXC.NXC_CCASO CCASO, NVE.NVE_TITULO TITULO, NXC." + cCampoRat + " VALOR "
		cQuery +=    " FROM " + RetSqlName( 'NXC' ) + " NXC, " + RetSqlName( 'SA1' ) + " SA1, " + RetSqlName( 'NVE' ) + " NVE "
		cQuery +=  " WHERE NXC.NXC_FILIAL = '" + xFilial('NXC') + "' "
		cQuery +=     " AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' "
		cQuery +=     " AND NVE.NVE_FILIAL = '" + xFilial('NVE') + "' "
		cQuery +=     " AND NXC.NXC_CCLIEN = NVE.NVE_CCLIEN "
		cQuery +=     " AND NXC.NXC_CLOJA = NVE.NVE_LCLIEN "
		cQuery +=     " AND NXC.NXC_CCASO = NVE.NVE_NUMCAS "
		cQuery +=     " AND NXC.NXC_CCLIEN = SA1.A1_COD "
		cQuery +=     " AND NXC.NXC_CLOJA = SA1.A1_LOJA "
		cQuery +=     " AND NXC.NXC_CESCR = '" + self:GetEscrit() + "' "
		cQuery +=     " AND NXC.NXC_CFATUR = '" + self:GetFatura() + "' "
		cQuery +=     " AND NXC." + cCampoRat + " > 0 "
		cQuery +=     " AND NXC.D_E_L_E_T_ = ' ' "
		cQuery +=     " AND SA1.D_E_L_E_T_ = ' ' "
		cQuery +=     " AND NVE.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery, .F.)
		DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)	
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
		self:aItems := {}
		If !(cQryRes)->(EOF())
			While !(cQryRes)->(EOF())
				aTemp := {}
				aAdd(aTemp, {"", (cQryRes)->CCLIEN, (cQryRes)->CLOJA, (cQryRes)->NOME, (cQryRes)->CCONTR, (cQryRes)->CCASO, (cQryRes)->TITULO, (cQryRes)->VALOR } )
				self:addItem(aTemp[1])
		
				(cQryRes)->(DbSkip())
			EndDo
			(cQryRes)->(dbCloseArea())
			RestArea(aArea)
		Else 
			self:LimpaLista()
		EndIf
	
	Else

		oModel     := FWModelActive()
		oModelNX0  := oModel:GetModel("NX0MASTER")
		oModelNX8  := oModel:GetModel("NX8DETAIL")
		oModelNX1  := oModel:GetModel("NX1DETAIL")
		aSaveLines := FWSaveRows( )

		self:aItems := {}
		
		For nNX8 := 1 To oModelNX8:GetQtdLine()
	
			oModelNX8:GoLine(nNX8)
			
			For nNX1 := 1 To oModelNX1:GetQtdLine()

				oModelNX1:GoLine(nNX1)
				aTemp := {}
				If (oModelNX1:GetValue( "NX1_VLDESC" ) > 0)
					aAdd(aTemp, {"", 	oModelNX1:GetValue( "NX1_CCLIEN" ), ;
										oModelNX1:GetValue( "NX1_CLOJA" ), ;
										oModelNX1:GetValue( "NX1_DCLIEN" ), ;
										oModelNX1:GetValue( "NX1_CCONTR" ), ;
										oModelNX1:GetValue( "NX1_CCASO" ), ;
										oModelNX1:GetValue( "NX1_DCASO" ), ;
										oModelNX1:GetValue( "NX1_VLDESC" ) } )
		
					self:addItem(aTemp[1])
				EndIf
			
			Next nNX1
		
		Next nNX8

		FWRestRows(aSaveLines)

		If Len(self:aItems) = 0
			aAdd(aTemp, {"", CriaVar('NVE_CCLIEN', .F.), ;
			                 CriaVar('NVE_LCLIEN', .F.), ;
			                 CriaVar('A1_NOME', .F.), ;
			                 CriaVar('NT0_COD', .F.), ;
			                 CriaVar('NVE_NUMCAS', .F.), ;
			                 CriaVar('NVE_TITULO', .F.), ;
			                 0.00 } )
	
			self:addItem(aTemp[1])
		EndIf

	EndIf

	self:AtualizaSld()
	lRet := .T.

Return lRet

Method AtualizaSld() Class TJRATCASO
	Local nValor := 0
	
	nValor := self:SomaCol( 8 )

	self:nTotCaso   := nValor
	self:nSaldoCaso := self:nVlRatFat - nValor

Return Nil

Method InsereSaldo(lExibe) Class TJRATCASO
	Local aArea     := GetArea()
	Local nNXC      := 0
	Local cQuery    := ""
	Local cQryRes   := GetNextAlias()
	Local nSomaCaso := 0
	Local nSomaHon  := 0
	Local nQtdCaso  := 0
	Local nValor    := 0
	Local nResto    := 0
	Local nIdxCaso  := 0
	Local aTemp     := {}
	Local cGetCCli  := ""
	Local cGetCLoja := ""
	Local cGetContr := ""
	Local cRazao    := ""
	Local cGetCCaso := ""
	Local cTitulo   := ""
	Local nPos      := 0
	Local cCpoClien := ""
	Local cCpoLoja  := ""
	Local cCpoContr := ""
	Local cCpoCaso  := ""
	Local cCpoVlTs  := ""
	Local nValLiq   := 0
	Local lRet      := .T.
	Local nSomaPeso := 0
	Local nQtdDec   := 0
	Local oModel    := Nil
	Local oModelNX0 := Nil
	Local oModelNX8 := Nil
	Local oModelNX1 := Nil
	Local nLNX8     := 0
	Local nLNX1     := 0
	Local nIMod     := 0
	Local ACASMOD   := {}
	Local nMaiorTS  := 0
	Local nPosMaior := 0
	Local cTpDiv    := AllTrim(GetMv("MV_JDIVCAS",, "1")) //Padrao "1" - (1=”TS”;2=”Peso do Caso”)
	
	Default lExibe  := .T.

	If self:nSaldoCaso > 0

		If IsInCallStack("JURA202") .And. !IsInCallStack("JURA203")
		
			oModel    := FwModelActive()
			oModelNX0 := oModel:GetModel("NX0MASTER")
			oModelNX8 := oModel:GetModel("NX8DETAIL")
			oModelNX1 := oModel:GetModel("NX1DETAIL")
			nQtdDec   := TamSX3('NX1_VLDESC')[2]
			
			nSomaCaso := 0
			nSomaHon  := 0
			nQtdCaso  := 0
			nTotDesc  := 0
			
			For nLNX8 := 1 To oModelNX8:Length()
				oModelNX8:GoLine(nLNX8)
				
				For nLNX1 := 1 To oModelNX1:Length()

					oModelNX1:GetValue("NX1_CCLIEN", nLNX1)

					cGetCCli  := oModelNX1:GetValue("NX1_CCLIEN", nLNX1 )
					cGetCLoja := oModelNX1:GetValue("NX1_CLOJA", nLNX1 )
					cGetContr := oModelNX1:GetValue("NX1_CCONTR", nLNX1 )
					cGetCCaso := oModelNX1:GetValue("NX1_CCASO", nLNX1 )
					nValLiq   := oModelNX1:GetValue("NX1_VTS", nLNX1 ) + oModelNX1:GetValue("NX1_VFIXO", nLNX1 ) - oModelNX1:GetValue("NX1_VDESCO", nLNX1 )

					nPeso     := JurGetDados("NVE", 1, xFilial("NVE") + oModelNX1:GetValue("NX1_CCLIEN") +; 
												oModelNX1:GetValue("NX1_CLOJA") + oModelNX1:GetValue("NX1_CCASO"), "NVE_PESO")
					
					nPos := aScan( self:aItems, { |ax| ax[2] == cGetCCli ;
					                             .And. ax[3] == cGetCLoja;
					                             .And. ax[5] == cGetContr;
					                             .And. ax[6] == cGetCCaso } )
					
					aAdd( aCasMod, { nPos, cGetCCli, cGetCLoja, cGetContr, cGetCCaso, nValLiq, nPeso })
				
					If nPos = 0
						nSomaCaso += oModelNX1:GetValue("NX1_VTS", nLNX1 ) + oModelNX1:GetValue("NX1_VFIXO", nLNX1 ) - oModelNX1:GetValue("NX1_VDESCO", nLNX1 )
						nSomaHon  += oModelNX1:GetValue("NX1_VHON", nLNX1 ) - oModelNX1:GetValue("NX1_VTAB", nLNX1 )
						nSomaPeso += nPeso
						nQtdCaso  += 1
					EndIf
					
				Next nLNX1

			Next nLNX8
			
			nMaiorTS  := 0
			nPosMaior := 0

			If nSomaHon > 0 .Or. nSomaCaso > 0
			
				For nIMod := 1 To Len(aCasMod)
	
					aTemp := {}
	
					If aCasMod[nIMod][1] = 0
					
						//Por Valor TS
						If cTpDiv == "1"
					
							If nSomaCaso > 0
								nValor := Round( ( aCasMod[nIMod][6]) / nSomaCaso * ( self:nSaldoCaso ), nQtdDec )
							Else 
								nValor := Round( self:nSaldoCaso / nQtdCaso, nQtdDec )
							EndIf
						
						//Por Peso de Caso
						ElseIf cTpDiv == "2" .And. nSomaPeso > 0
							nValor := Round( aCasMod[nIMod][7] / nSomaPeso * ( self:nSaldoCaso ), nQtdDec )
						
						//Se não tem TS e nem peso Valor dividido pela quantidade de casos
						Else
							nValor := Round( self:nSaldoCaso / nQtdCaso, nQtdDec )
						EndIf 
						
						If nValor > 0
						
							cRazao  := Posicione('SA1', 1, xFilial('SA1') + aCasMod[nIMod][2] + aCasMod[nIMod][3], 'A1_NOME')
							cTitulo := Posicione('NVE', 1, xFilial('NVE') + aCasMod[nIMod][2] + aCasMod[nIMod][3] + aCasMod[nIMod][5], 'NVE_TITULO')
							cPeso   := Posicione('NVE', 1, xFilial('NVE') + aCasMod[nIMod][2] + aCasMod[nIMod][3] + aCasMod[nIMod][5], 'NVE_PESO')
				
							aAdd(aTemp, {"", aCasMod[nIMod][2], aCasMod[nIMod][3], cRazao, aCasMod[nIMod][4], aCasMod[nIMod][5], cTitulo, nValor } )

							self:addItem(aTemp[1])
							
							nTotDesc += nValor
							
							If aCasMod[nIMod][6] > nMaiorTS
								nMaiorTS  := aCasMod[nIMod][6]
								nPosMaior := self:GetQtdCaso()
							EndIf
						
						EndIf
					
					EndIf 
				
				Next nIMod
			
			EndIf
			
			nResto := self:nSaldoCaso - nTotDesc
			
			If nResto <> 0 .And. nPosMaior > 0
				self:aItems[nPosMaior][8] += nResto
			EndIf

		ElseIf Empty(self:cPreFt)
			//Insere Saldo dos Casos:
			cQuery := " SELECT SUM(NXC.NXC_VLTS) SOMACASO, "
			cQuery +=        " SUM(NXC.NXC_VLHFAT) SOMAHON, "
			cQuery +=        " SUM(NVE.NVE_PESO) SOMAPESO, "
			cQuery +=        " SUM(NXC_DRATL) DESCLIN,
			cQuery +=        " SUM(NXC_DRATE) DESCESP,
			cQuery +=        " COUNT(*) QTDCASO "
			cQuery +=   " FROM " + RetSqlName( 'NXC' ) + " NXC, "
			cQuery +=        " " + RetSqlName( 'NVE' ) + " NVE "
			cQuery += "  WHERE NXC.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND NXC.NXC_FILIAL = '" + xFilial('NXC') + "' "
			cQuery +=    " AND NVE.NVE_FILIAL = '" + xFilial('NVE') + "' "
			cQuery +=    " AND NVE.NVE_CCLIEN = NXC.NXC_CCLIEN "
			cQuery +=    " AND NVE.NVE_LCLIEN = NXC.NXC_CLOJA "
			cQuery +=    " AND NVE.NVE_NUMCAS = NXC.NXC_CCASO "
			cQuery +=    " AND NXC.NXC_CESCR  = '" + self:cEscrit + "' "
			cQuery +=    " AND NXC.NXC_CFATUR = '" + self:cFatura + "' "

			If self:cTipoRat == '1'  // filtro somente para desconto Especial, para o pagador ou acréscimo é automático para todos os casos
				cQuery += "  AND NXC.NXC_CCLIEN||NXC.NXC_CLOJA||NXC.NXC_CCONTR||NXC.NXC_CCASO NOT IN ( "
				For nNXC := 1 To oRateio:GetQtdCaso()
					cQuery += " '" + self:aItems[nNXC][2] + '||' + self:aItems[nNXC][3] + '||' + self:aItems[nNXC][5] + '||' + self:aItems[nNXC][6] + "',"
				Next
				cQuery += " '' ) " + CRLF
			EndIf
	
			cQuery := ChangeQuery(cQuery, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)	
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
	
			nSomaCaso  := (cQryRes)->SOMACASO
			nTotDesLin := (cQryRes)->DESCLIN
			nTotDesEsp := (cQryRes)->DESCESP
			nSomaHon   := (cQryRes)->SOMAHON
			nQtdCaso   := (cQryRes)->QTDCASO
			nSomaPeso  := (cQryRes)->SOMAPESO
	
			(cQryRes)->(dbCloseArea())
	
			If self:cTipoRat == '1' // filtro somente para desconto Espedial, para o pagador ou acréscimo é automático para todos os casos
				cQuery += "  AND NXC.NXC_CCLIEN||NXC.NXC_CLOJA||NXC.NXC_CCONTR||NXC.NXC_CCASO NOT IN ( "
				For nNXC := 1 To oRateio:GetQtdCaso()
					cQuery += " '" + self:aItems[nNXC][2] + '||' + self:aItems[nNXC][3] + '||' + self:aItems[nNXC][5] + '||' + self:aItems[nNXC][6] + "',"
				Next
				cQuery += " '' ) " + CRLF
			EndIf
			
			cQuery := J203QRYRAT(self:cEscrit, self:cFatura, "NXC", '3', "")
			
			cCpoClien  := "NXC_CCLIEN"
			cCpoLoja   := "NXC_CLOJA"
			cCpoContr  := "NXC_CCONTR"
			cCpoCaso   := "NXC_CCASO"
			cCpoVlTs   := "NXC_VLTS"
			nQtdDec    := TamSX3('NXC_DRATE')[2]

			cQuery := ChangeQuery(cQuery, .F.)	
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
	
			nResto   := self:nSaldoCaso
			nIdxCaso := 0

			While !(cQryRes)->(EOF()) 
				aTemp     := {}
				cGetCCli  := (cQryRes)->&(cCpoClien)
				cGetCLoja := (cQryRes)->&(cCpoLoja)
				cGetContr := (cQryRes)->&(cCpoContr)
				cGetCCaso := (cQryRes)->&(cCpoCaso)
	
				cRazao  := Posicione('SA1', 1, xFilial('SA1') + cGetCCli + cGetCLoja, 'A1_NOME')
				cTitulo := Posicione('NVE', 1, xFilial('NVE') + cGetCCli + cGetCLoja + cGetCCaso, 'NVE_TITULO')
				cPeso   := Posicione('NVE', 1, xFilial('NVE') + cGetCCli + cGetCLoja + cGetCCaso, 'NVE_PESO')
	
				If nSomaCaso > 0
					nTSLiqNXC := (cQryRes)->&(cCpoVlTs) - (cQryRes)->NXC_DRATL - (cQryRes)->NXC_DRATE // Valor líquido de TS por caso (subtraí os demais descontos)
					nTSLiqTot := nSomaCaso - nTotDesLin - nTotDesEsp                                  // Valor líquido de TS Total menos descontos (linear e especial) 
					nValor := Round( nTSLiqNXC / nTSLiqTot * ( self:nSaldoCaso ), nQtdDec )
				ElseIf nSomaHon > 0
					nValor := Round( self:nSaldoCaso / nQtdCaso, nQtdDec )
				Else
					If nSomaPeso > 0 
						nValor := Round( cPeso / nSomaPeso * ( self:nSaldoCaso ), nQtdDec ) 
					Else
						nValor := Round( self:nSaldoCaso / nQtdCaso, nQtdDec )
					EndIf
				EndIf
				
				nIdxCaso++
				nResto -= nValor
				
				If nIdxCaso == nQtdCaso .And. nResto <> 0
					nValor += nResto
				EndIf
	
				aAdd(aTemp, {"", cGetCCli, cGetCLoja, cRazao, cGetContr , cGetCCaso, cTitulo, nValor } )

				self:addItem(aTemp[1])
	
				(cQryRes)->(dbSkip())
			EndDo
			
			(cQryRes)->( DBCloseArea() )
			RestArea(aArea)

		EndIf

		If nSomaCaso > 0 .Or. nSomaHon > 0 .Or. ( nSomaCaso == 0 .And. nSomaHon == 0 .And. self:cTipoRat == '2')
			nPos := Len(self:aItems)
			self:AtualizaSld()
			If ( self:nVlRatFat - self:nTotCaso ) <> 0
				self:aItems[nPos][ 8 ] := self:aItems[nPos][ 8 ] + self:nVlRatFat - self:nTotCaso
			EndIf
		Else
			MsgAlert( STR0019 ) //  "Não há Casos disponíveis para incluir
			lRet := .F.
		EndIf
		
		If lExibe
			self:RefreshList( self:GetQtdItems() )
			self:SelItem( 1 )
			self:RefreshCampos()
		EndIf
	
	EndIf
	
Return lRet

Method ZeraSaldo(lExibe) Class TJRATCASO
	Local lRet := .T.
	
	While Len(self:aItems) > 0 .And. !Empty(self:aItems[1][2])
		self:remCaso()
	EndDo

Return lRet

Method DrawScreen() Class TJRATCASO

	Local OTELA

	Local nSizeX := 460
	Local nSizeY := 700
	
	//Horizontal Boxes
	Local cIdDetalhe
	Local cIdRateio
	Local cIdFooter
	//Panel
	Local oPnlDet
	Local oPnlRat
	Local oPnlFoot
	
	Local oBtnOk
	Local oBtnCancel
	Local oBtnSld
	Local oBtnZera
	Local oBtnAddCs
	Local oBtnRemCs
	
	Local clblEscr      := ""
	Local clblFatu      := ""
	Local clblClien     := ""
	Local clblLoja      := ""
	Local clblContr     := ""
	Local clblNome      := ""
	Local clblCaso      := ""
	Local clblTitulo    := ""
	Local clblMoeda     := ""
	Local clblDesFat    := ""
	Local clblDesCas    := ""
	Local clblSldCas    := ""
	Local clblVlIns     := ""
	Local clblAdd       := ""
	Local clblRem       := ""
	Local clblOK        := ""
	Local clblCanc      := ""
	Local clblInsSld    := ""
	Local clblZeraSld   := ""
	Local cAlias        := ""
	Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	
	Local aCposLGPD     := {}
	Local aNoAccLGPD    := {}
	Local aDisabLGPD    := {}

	clblEscr := RetTitle( "NXA_CESCR" )  // "Cód Escritório"
	If Empty(self:cPreFt)
		clblFatu   := RetTitle( "NXA_COD"    ) // "Número Fat"
		clblClien  := RetTitle( "NXA_CCLIEN" ) // "Cód Cliente"
		clblLoja   := RetTitle( "NXA_CLOJA"  ) // "Cód Loja"
		clblNome   := RetTitle( "A1_NOME"    ) // "Nome"
		clblContr  := RetTitle( "NXC_CCONTR" ) // "Título"
		clblCaso   := RetTitle( "NXC_CCASO"  ) // "Cód Caso"
		clblTitulo := RetTitle( "NVE_TITULO" ) // "Título"
		clblMoeda  := RetTitle( "NXA_CMOEDA" ) // "Moeda"
		If self:cTipoRat == "1"
			clblDesFat := RetTitle( "NXA_VLDSCE" ) + STR0023  // "Des Especial Fatura
			clblDesCas := RetTitle( "NXC_DRATE"  ) + STR0022  // "Des Especial Casos"
			clblVlIns  := RetTitle( "NXA_VLDSCE" )            // "Des Especial"
		ElseIf self:cTipoRat == "2"
			clblDesFat := RetTitle( "NXA_VLACRE" ) + STR0023  // "Vl Acréscimo Fatura
			clblDesCas := RetTitle( "NXC_ARATF"  )            // "Acre Rat Fat"
			clblVlIns  := RetTitle( "NXA_VLACRE" )
		ElseIf self:cTipoRat == "3"
			clblDesFat := RetTitle( "NXA_VLDSCP" )
			clblDesCas := RetTitle( "NXC_DRATP"  )
			clblVlIns  := RetTitle( "NXA_VLDSCP" )
		EndIf

		cAlias     := "NXC"
	Else
		clblFatu   := RetTitle( "NX0_COD"  ) // "Cód Pré-Fat"
		clblClien  := RetTitle( "NX0_CCLIEN" ) // "Cód Cliente"
		clblLoja   := RetTitle( "NX0_CLOJA"  ) // "Cód Loja"
		clblNome   := RetTitle( "A1_NOME"    ) // "Nome"
		clblContr  := RetTitle( "NX1_CCONTR" ) // "Título"
		clblCaso   := RetTitle( "NX1_CCASO"  ) // "Cód Caso"
		clblTitulo := RetTitle( "NVE_TITULO" ) // "Título"
		clblMoeda  := RetTitle( "NX0_CMOEDA" ) // "Moeda"
		clblDesFat := RetTitle( "NX0_DESCH"  ) + STR0021  // "Desc Especial Pré
		clblDesCas := RetTitle( "NX1_VLDESC" ) + STR0022  // "Desc Especial Casos"
		clblVlIns  := RetTitle( "NX0_DESCH"  )  //

		cAlias     := "NX1"

	EndIf

	clblTitulo  := IIf(self:cTipoRat $ "13", STR0004, STR0005 )  // "Rateio do Desconto", "Rateio do Acréscimo"
	clblSldCas  := STR0006 //"Saldo Casos"
	clblAdd     := STR0007 //"Adiciona"
	clblRem     := STR0008 //"Remove"
	clblOK      := STR0009 //"Confirma"
	clblCanc    := STR0010 //"Cancela"
	clblInsSld  := STR0011 //"Insere Saldo"
	clblZeraSld := STR0020 //"Exclui todos"
	
	Self:lOk := .T.

	If _lFwPDCanUse .And. FwPDCanUse(.T.) // Tratamentos LGPD
		aCposLGPD := {"NX0_CCLIEN", "NX0_CLOJA" ,"NX0_DCLIEN" ,"NX1_CCONTR" ,"NX1_CCASO"}
		aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aNoAccLGPD, {|x| AAdd( aDisabLGPD, x:CFIELD)})
	EndIf
		
	DEFINE MSDIALOG  self:oDlg TITLE clblTitulo FROM 0, 0 TO  nSizeX, nSizeY  PIXEL Style DS_MODALFRAME //"Rateio do Desconto"
		oTela      := FWFormContainer():New(self:oDlg)

		cIdDetalhe := oTela:CreateHorizontalBox(24)
		cIdRateio  := oTela:CreateHorizontalBox(62)
		cIdFooter  := oTela:CreateHorizontalBox(14)
		oTela:Activate(self:oDlg, .F.)
		
		oPnlDet    := oTela:GeTPanel(cIdDetalhe)
		oPnlRat    := oTela:GeTPanel(cIdRateio)
		oPnlFoot   := oTela:GeTPanel(cIdFooter)

		//---------------------HEADER-------------------/
		self:oGetFatura := TJurPnlCampo():New(003, 005, 045, 023, oPnlDet, clblFatu, "NX0_COD", {|| }, {|| }, self:cFatura,,,) // "Cód Pré-Fat" 
		self:oGetFatura:SetWhen({|| .F. })

		self:oGetCClien := TJurPnlCampo():New(003, 050, 045, 023, oPnlDet, clblClien, "NX0_CCLIEN", {|| }, {|| }, self:cCliente,,,,,,,,aScan(aDisabLGPD,"NX0_CCLIEN") > 0) // "Cód Cliente"
		self:oGetCClien:SetWhen({|| .F. })

		self:oGetCLoja := TJurPnlCampo():New(003, 095, 040, 023, oPnlDet, clblLoja, "NX0_CLOJA", {|| }, {|| }, self:cLoja,,,,,,,,aScan(aDisabLGPD,"NX0_CLOJA") > 0) // "Cód Loja"
		self:oGetCLoja:SetWhen({|| .F. })

		self:oGetDClien := TJurPnlCampo():New(003, 140, 200, 023, oPnlDet, clblNome, "NX0_DCLIEN", {|| }, {|| }, self:cRazao,,,,,,,,aScan(aDisabLGPD,"NX0_DCLIEN") > 0) // "Nome"
		self:oGetDClien:SetWhen({|| .F. })

		//------------------------------------------------
		// Valores a Ratear / Rateados
		self:oGetMoeda := TJurPnlCampo():New(032, 005, 040, 023, oPnlDet, clblMoeda, "NX0_CMOE", {|| }, {|| }, self:cMoeda,,,) // "Moeda" 
		self:oGetMoeda:SetWhen({|| .F. })

		self:oGetVlFat := TJurPnlCampo():New(032, 050, 085, 023, oPnlDet, clblDesFat, "NX0_VLFATH", {|| }, {|| }, self:nVlRatFat,,,) // "Desc Especial Pré
		self:oGetVlFat:SetWhen({|| .F. })

		self:oGetVlCas := TJurPnlCampo():New(032, 140, 085, 023, oPnlDet, clblDesCas, "NX0_VLFATH", {|| }, {|| }, self:nTotCaso,,,) // "Desc Especial Casos"
		self:oGetVlCas:SetWhen({|| .F. })

		self:oGetSldCas := TJurPnlCampo():New(032, 230, 085, 023, oPnlDet, clblSldCas, "NX0_VLFATH", {|| }, {|| }, self:nSaldoCaso,,,) // "Saldo Casos" 
		self:oGetSldCas:SetWhen({|| .F. })

		// "Cód Cliente" //
		self:oGetCodCliCaso := TJurPnlCampo():New(003, 005, 055, 023, oPnlRat, clblClien, "NX0_CCLIEN", {|| }, {|| },,,, 'NX1SA1',,,,,aScan(aDisabLGPD,"NX0_CCLIEN") > 0)
		self:oGetCodCliCaso:SetChange({|| self:cGetCCli := self:oGetCodCliCaso:GetValue()})
		self:oGetCodCliCaso:SetValid({|| IIF(self:oGetCodCliCaso:IsChanged(), (self:oGetCodCliCaso:SetValueold(self:oGetCodCliCaso:GetValue()),;
											 self:cGetcLoja := CriaVar("A1_COD"),;
											 self:cGetCCaso := CriaVar("NVE_NUMCAS"),;
											 self:oGetCodLojCaso:Limpar(),;
											 self:oGetCodCaso:Limpar(), .T.), .T.) .And. self:ValidaCampos(cAlias, "CLI")})

		// "Cód Loja" //
		self:oGetCodLojCaso := TJurPnlCampo():New(003, 060, 042, 023, oPnlRat, clblLoja, "NX0_CLOJA", {|| }, {|| },,,,,,,,,aScan(aDisabLGPD,"NX0_CLOJA") > 0)
		self:oGetCodLojCaso:SetChange({|| self:cGetcLoja := self:oGetCodLojCaso:GetValue()})
		self:oGetCodLojCaso:SetValid({|| IIF(self:oGetCodLojCaso:IsChanged(), (self:oGetCodLojCaso:SetValueold(self:oGetCodLojCaso:GetValue()),;
											 self:cGetCCaso := CriaVar("NVE_NUMCAS"),;
											 self:oGetCodCaso:Limpar(), .T.), .T.) .And. self:ValidaCampos(cAlias, "LOJ")})
		self:oGetCodLojCaso:SetWhen({|| IIF(!Empty(self:cGetCCli), .T., .F.)})
		If (cLojaAuto == "1")
			self:oGetCodLojCaso:Hide()
		EndIf

		// "Cód Contrato" //
		self:oGetContr := TJurPnlCampo():New(003, 105, 050, 023, oPnlRat, clblContr, "NX1_CCONTR", {|| }, {|| },,,, 'NX1NT0',,,,,aScan(aDisabLGPD,"NX1_CCONTR") > 0)
		self:oGetContr:SetChange({|| self:cGetContr := self:oGetContr:GetValue()})
		self:oGetContr:SetValid({|| self:ValidaCampos(cAlias)})

		// "Cód Caso" //
		self:oGetCodCaso := TJurPnlCampo():New(003, 160, 050, 023, oPnlRat, clblCaso, "NX1_CCASO", {|| }, {|| },,,, 'NX1NVE',,,,,aScan(aDisabLGPD,"NX1_CCASO") > 0)
		self:oGetCodCaso:SetChange({|| self:cGetCCaso := self:oGetCodCaso:GetValue()})
		self:oGetCodCaso:SetValid({|| self:ValidaCampos(cAlias)})
		self:oGetCodCaso:SetWhen({|| IIF(!Empty(self:cGetCCli) .And. !Empty(self:cGetCLoja), .T., .F.)})

		self:oGetVlCaso := TJurPnlCampo():New(003, 220, 085, 023, oPnlRat, clblVlIns, "NX0_VLFATH", {|| }, {|| }, self:cGetValor,,,) // "Vl Desc"
		self:oGetVlCaso:SetChange({|| self:cGetValor := self:oGetVlCaso:GetValue() })
		self:oGetVlCaso:SetValid({|| self:ValidaCampos("")})

		//Adiciona 
		@ 000, 320 Button oBtnAddCs Prompt clblAdd Size 025, 012 Of oPnlRat Pixel;
			Action (self:addCaso())
		
		//Remove 
		@ 016, 320 Button oBtnRemCs Prompt clblRem Size 025, 012 Of oPnlRat Pixel;
			Action (self:remCaso())

		nSizeX := 351
		nSizeY := 110

		@ 032, 001 ListBox self:oLbxRatCas Fields Header '', clblClien, clblLoja, clblNome, clblContr, clblCaso, clblTitulo, clblVlIns Size nSizeX, nSizeY Of oPnlRat Pixel ;
		          ON CHANGE (self:SelItem(self:oLbxRatCas:nAt))       //"Cód Cliente","Loja", "Nome Cliente", "Cód Caso", "Título" ,"Desconto"
		self:RefreshList(0)

		//-------------------------------------------------------------------
		// Define a área dos botões
		//-------------------------------------------------------------------    
		//Confirma
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 005 Button oBtnOk Prompt clblOK Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( iif(self:Confirma(), ( Self:lOk := .T., self:oDlg:End()), Self:lOk := .F.) )

		//Cancela
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 045 Button oBtnCancel Prompt clblCanc Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( iif(!self:Cancela(), ( Self:lOk := .F., self:oDlg:End()), ) )
		
		//Insere Saldo
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 085 Button oBtnSld Prompt clblInsSld Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( self:InsereSaldo() )
		                                           
		//Exclui todos
		@ oPnlFoot:nTop + 05, oPnlFoot:nLeft + 125 Button oBtnZera Prompt clblZeraSld Size 35, 12 Of oPnlFoot Pixel ;
		                                           Action ( self:ZeraSaldo() )

	self:oDlg:lEscClose := .F.
	self:RefreshCampos()
	self:SelItem(1)
	
Return (Self:lOk)

Method ActiveScreen()  Class TJRATCASO
	// Variáveis usadas nas consultas específicas NX1SA1 / NX1NVE / NX1NT0
	Private cGetCliF3 := Criavar('A1_COD', .F.) 
	Private cGetLjF3  := Criavar('A1_LOJA', .F.) 
	Private cGetCtrF3 := Criavar('NT0_COD', .F.) 

	ACTIVATE MSDIALOG  self:oDlg CENTERED
	
Return (Self:lOk)

Method ValidaCampos(cAlias, cVal) Class TJRATCASO
	Local lRet    := .F.  
	Local aArea   := GetArea()
	Local cQuery  := ""
	Local cQryRes := GetNextAlias()
	Local cMsg    := ""

	Default cVal  := ""

	If cAlias == 'NXC'
	
		If (!Empty(self:cGetCCli) .Or. !Empty(self:cGetCLoja) .Or. !Empty(self:cGetContr) .Or. !Empty(self:cGetCCaso))
	
			cQuery := J203QRYRAT(self:cEscrit, self:cFatura, cAlias, '1')
			If !Empty(self:cGetCCli)
				cQuery += " AND NXC.NXC_CCLIEN = '" + self:cGetCCli + "' "
			EndIf
			If !Empty(self:cGetCLoja)
				cQuery += " AND NXC.NXC_CLOJA = '" + self:cGetCLoja + "' "
			EndIf
			If !Empty(self:cGetContr)
				cQuery += " AND NXC.NXC_CCONTR = '" + self:cGetContr + "' "
			EndIf
			If !Empty(self:cGetCCaso)
				cQuery += " AND NXC.NXC_CCASO = '" + self:cGetCCaso + "' "
			EndIf
	
			cQuery := ChangeQuery(cQuery, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
			dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cQryRes, .T., .F.)
	
			lRet := (cQryRes)->COUNTNXC > 0
	
			cMsg := STR0012 //"Não existe registro relacionado a este código"
	
			(cQryRes)->(dbCloseArea())
		Else
			lRet  := .T.
		EndIf
	
	ElseIf cAlias == "NX1"

		If cVal == "CLI"
			cGetCliF3 := self:cGetCCli
			cGetLjF3  := JurGetLjAt()
		ElseIf cVal == "LOJ"
			cGetLjF3 := self:cGetCLoja
		EndIf

		cGetCtrF3 := self:cGetContr

		If (!Empty(self:cGetCCli) .Or. !Empty(self:cGetCLoja) .Or. !Empty(self:cGetContr) .Or. !Empty(self:cGetCCaso))

			cQuery := J203QRYRAT("", "", "NX1", '1', self:cPreFT)
			If !Empty(self:cGetCCli)
				cQuery += " AND NX1.NX1_CCLIEN = '" + self:cGetCCli + "' "
			EndIf
			If !Empty(self:cGetCLoja)
				cQuery += " AND NX1.NX1_CLOJA = '" + self:cGetCLoja + "' "
			EndIf
			If !Empty(self:cGetContr)
				cQuery += " AND NX1.NX1_CCONTR = '" + self:cGetContr + "' "
			EndIf
			If !Empty(self:cGetCCaso)
				cQuery += " AND NX1.NX1_CCASO = '" + self:cGetCCaso + "' "
			EndIf
			
			cQuery := ChangeQuery(cQuery, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
	
			lRet := (cQryRes)->COUNTNX1 > 0

			If !lRet
				cMsg := STR0012 //"Não existe registro relacionado a este código"
			EndIf

			(cQryRes)->(dbCloseArea())
		Else
			lRet := .T.
		EndIf

	ElseIf cAlias == ""
		If self:cGetValor < 0
			lRet := .F.
			cMsg := STR0013 //"O valor não pode ser negativo"
		Else
			If !Empty(self:cPreFt)
				lRet := self:VldDescCas()
				cMsg := STR0024 //"O caso não possue valor de honorários para serem descontados!"
			Else
				lRet := .T.
			EndIf
		EndIf
	EndIf
	
	If !lRet
		MsgAlert(cMsg)
	EndIf
	
	RestArea(aArea)
	
Return (lRet)

Method ValidaSaldos()  Class TJRATCASO
	Local aRet := {.T., }

	If aRet[1] .And. ( Round(self:nSaldoCaso, 2) < 0 )
		aRet[2] := STR0014 //"O saldo não pode ser negativo"
		aRet[1] := .F.
	EndIf
	
	If aRet[1] .And. ( Round(self:nSaldoCaso, 2) > 0 )
		aRet[2] := STR0015 //"É preciso zerar o saldo antes de continuar"
		aRet[1] := .F.
	EndIf

Return (aRet)

Method RateioF() Class TJRATCASO
	Local lRet   := .T.
	Local ni     := 0
	Local cCpCas := ""
	Local cSkCas := ""
	Local cCpCon := ""
	Local cSkCon := ""
	Local cCpPar := ""
	Local cSkPar := ""
	Local nVlPar := 0
	Local nQtPar := 0
	Local nSaldo := 0
	
	If self:cTipoRat == "1"
		cCpCon := "NXB_DRATE"
		cCpCas := "NXC_DRATE"
		cCpPar := "NXD_DESCTO"
	ElseIf self:cTipoRat == "2"
		cCpCon := "NXB_ARATF"
		cCpCas := "NXC_ARATF"
		cCpPar := "NXD_ACRESC"
	ElseIf self:cTipoRat == "3"
		cCpCon := "NXB_DRATP"
		cCpCas := "NXC_DRATP"
		cCpPar := "NXD_DESCTO"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os valores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ni := 1 To Len(self:aItems)
		lRet := .F.
		
		nSaldo += self:aItems[ni][8]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os contratos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSkCon := xFilial("NXB") +  self:cEscrit + self:cFatura + self:aItems[ni][2] + self:aItems[ni][3] + self:aItems[ni][5]
		//NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCLIEN+NXB_CLOJA+NXB_CCONTR
		
		NXB->(dbSetOrder(1))
		If NXB->( DBSeek(cSkCon)  )
			RecLock("NXB", .F.)
			NXB->&(cCpCon) += self:aItems[ni][8]
			NXB->NXB_DRATF := NXB->NXB_DRATL + NXB->NXB_DRATE + NXB->NXB_DRATP
			NXB->(MsUnlock())
			NXB->(DbSkip())
			NXB->(DbGoTop())
			lRet := .T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza os casos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
															   //cliente            loja                  contrato            caso
		cSkCas := xFilial("NXC") +  self:cEscrit + self:cFatura + self:aItems[ni][2] + self:aItems[ni][3] + self:aItems[ni][5] + self:aItems[ni][6]
		//NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCLIEN+NXC_CLOJA+NXC_CCONTR+NXC_CCASO
		
		NXC->(dbSetOrder(1))
		If NXC->( DBSeek(cSkCas) )
			RecLock("NXC", .F.)
			NXC->&(cCpCas) := self:aItems[ni][8]
			NXC->NXC_DRATF := NXC->NXC_DRATL + NXC->NXC_DRATE + NXC->NXC_DRATP
			NXC->(MsUnlock())
			NXC->(DbSkip())
			NXC->(DbGoTop())
			lRet := .T.
		EndIf

	Next ni
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza os participantes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cSkPar := xFilial("NXD") + self:cFatura + self:cEscrit //NXD_FILIAL+NXD_CFATUR+NXD_CESCR
	
	nVlPar := 0
	nQtPar := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sumariza os valores nVlPar e nQtPar dos participantes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	NXD->(dbSetOrder(1))
	If NXD->( DBSeek(cSkPar)  )
		While !NXD->(Eof()) .And. NXD->(NXD_FILIAL+NXD_CFATUR+NXD_CESCR) == cSkPar
			nVlPar += NXD->NXD_VLCORR
			nQtPar++
			NXD->(DbSkip())
		EndDo
	EndIf

	NXD->(DbGoTop())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Distribui os valores de desconto/acrescimo dos participantes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If NXD->( DBSeek(cSkPar)  )
		While !NXD->(Eof()) .And. NXD->(NXD_FILIAL+NXD_CFATUR+NXD_CESCR) == cSkPar
			RecLock("NXD", .F.)
			NXD->&(cCpPar) := Round(NXD->&(cCpPar) + (nSaldo * (NXD->NXD_VLCORR / nVlPar)), TamSX3(cCpPar)[2])
			NXD->(MsUnlock())
			NXD->(DbSkip())
		EndDo
	EndIf

Return (lRet)

Method RateioPF() Class TJRATCASO
	Local lRet        := .T.
	Local nNX8        := 0
	Local nNX1        := 0
	Local npos        := 0
	Local oModel      := FWModelActive()
	Local oModelNX8   := oModel:GetModel("NX8DETAIL")
	Local oModelNX1   := oModel:GetModel("NX1DETAIL")
	Local aSaveLines  := FWSaveRows( )
	Local nSomaDesc   := 0
	
	For nNX8 := 1 To oModelNX8:GetQtdLine()
	
		oModelNX8:GoLine(nNX8)
		nSomaDesc := 0
		For nNX1 := 1 To oModelNX1:GetQtdLine()
		
			oModelNX1:GoLine(nNX1)
			
			nPos := ascan( self:aItems, { |ax| ax[2] == oModelNX1:GetValue( "NX1_CCLIEN" ) .And.;
							ax[3] == oModelNX1:GetValue( "NX1_CLOJA" ) .And. ;
							ax[5] == oModelNX1:GetValue( "NX1_CCONTR" ) .And. ;
							ax[6] == oModelNX1:GetValue( "NX1_CCASO" ) } )
			
			If nPos > 0
				nNewDesc := self:aItems[nPos][8]
			Else
				nNewDesc := 0
			EndIf
			nOldDesc := oModelNX1:GetValue( "NX1_VLDESC" ) //Desc Especial
			nVlHon   := oModelNX1:GetValue( "NX1_VHON" ) - oModelNX1:GetValue( "NX1_VTAB" ) - oModelNX1:GetValue( "NX1_VDESCO" ) // Vl Hon - Vl Tab - Desc Linear
			
			If nNewDesc <> nOldDesc
				nVlDif := nNewDesc - nOldDesc 
				
				lRet := oModelNX1:LoadValue( "NX1_VLDESC", nNewDesc )
				lRet := oModelNX1:LoadValue( "NX1_PCDESC", ( nNewDesc / nVlHon ) * 100)
	
				nSomaDesc += oModelNX1:GetValue( "NX1_VLDESC" )
				lRet := oModelNX1:LoadValue( "NX1_VDESCT", oModelNX1:GetValue( "NX1_VLDESC" ) + oModelNX1:GetValue( "NX1_VDESCO" ) )

			EndIf
			
		Next nNX1
		
		lRet := oModelNX8:LoadValue( "NX8_VLDESC", nSomaDesc )
		lRet := oModelNX8:LoadValue( "NX8_VDESCT", oModelNX8:GetValue( "NX8_VLDESC" ) + oModelNX8:GetValue( "NX8_VDESCO" ) )
	
	Next nNX8

	FWRestRows(aSaveLines)

Return (lRet)

Method Cancela() Class TJRATCASO
	Local lRet := .T.
	
	If MsgYesNo(STR0016) //"Deseja realmente cancelar a Rotina Rateio?"
		lRet := .F.
	EndIf

Return (lRet)

Method Confirma() Class TJRATCASO
	Local lRet := .F.
	
	If self:ValidaSaldos()[1]
		If Empty(self:cPreFt) 
			If self:RateioF()
				lRet := .T.
			Else
				lRet := .F.
				cMsg := STR0018 // Erro ao Gravar o rateio na Fatura.
			EndIf
		Else
			If self:RateioPF()
				lRet := .T.
			Else
				lRet := .F.
				cMsg := STR0018 // Erro ao Gravar o rateio na Fatura.
			EndIf
		EndIf
	Else
		lRet := .F.
		cMsg := STR0015 // "É preciso zerar o saldo antes de continuar
	EndIf

	If !lRet
		MsgAlert(cMsg)
	EndIf
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DCotPag(cCodPre, dDtEmi )
Método para verificar se o caso pode sofrer desconto.

@Param	    Nil

@Return		.F. Se o caso não tem valores de honorarios para sofrerem desconto	

@author Luciano Pereira dos Santos
@since 15/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Method VldDescCas() Class TJRATCASO
	Local lRet        := .T.
	Local oModel      := FWModelActive()
	Local oModelNX8   := oModel:GetModel("NX8DETAIL")
	Local oModelNX1   := oModel:GetModel("NX1DETAIL")
	Local aSaveLines  := FWSaveRows( )
	Local nSavlNX8    := 0
	Local nSavlNX1    := 0
	Local nNX8        := 0
	Local nNX1        := 0
	
	If self:cGetValor > 0
		
		nSavlNX8 := oModelNX8:GetLine()
		For nNX8 := 1 To oModelNX8:GetQtdLine()
			
			If oModelNX8:GetValue("NX8_CCONTR", nNX8) == self:cGetContr
				nSavlNX1 := oModelNX1:GetLine()
				For nNX1 := 1 To oModelNX1:GetQtdLine()
					
					If oModelNX1:GetValue("NX1_CCLIEN", nNX1) == self:cGetCCli .And.;
						oModelNX1:GetValue("NX1_CLOJA", nNX1) == self:cGetCLoja .And. ;
						oModelNX1:GetValue("NX1_CCASO", nNX1) == self:cGetCCaso
						
						If oModelNX1:GetValue("NX1_VHON", nNX1) - oModelNX1:GetValue("NX1_VTAB", nNX1) == 0 .And.;
						   oModelNX1:GetValue("NX1_VTS", nNX1) == 0
							lRet := .F.
							Exit
						EndIf
						
					EndIf
					
				Next nNX1
				oModelNX1:GoLine(nSavlNX1)
			EndIf
			
		Next nNX8
		oModelNX8:GoLine(nSavlNX8)
		
	EndIf
	
	FWRestRows(aSaveLines)

Return (lRet)
