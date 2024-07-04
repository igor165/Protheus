#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA260.CH"

Static lSalvou 		:= .F.	//Define que houve alguma alteção nas liminares
Static oModel095			//Modelo do JURA095 - Assunto Juridico

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA260
Liminares

@author  Rafael Tenorio da Costa
@since   12/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA260(cFilPro, cCodPro, lChgAll)

	Local oBrowse	:= Nil

	Default cFilPro := ""
	Default cCodPro	:= ""
	Default lChgAll := .T.

	lSalvou := .F.

	//Atualiza as multas das liminares a partir do assunto juridico
	J260Multas(cFilPro, cCodPro)

	oBrowse := FWMBrowse():New()
	oBrowse:SetChgAll(lChgAll)
	oBrowse:SetDescription(STR0001)	//"Liminares"
	oBrowse:SetAlias("O0S")
	oBrowse:SetLocate()

	If !Empty(cCodPro)
		oBrowse:SetFilterDefault("O0S_FILIAL == '" + cFilPro + "' .And. O0S_CAJURI == '" + cCodPro + "'")
	EndIf

	oBrowse:SetMenuDef("JURA260")
	oBrowse:Activate()

Return lSalvou

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Rafael Tenorio da Costa
@since 12/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, {STR0002, "PesqBrw", 0, 1, 0, .T. } )	//"Pesquisar"

	If JA162AcRst("20", 2)
		aAdd( aRotina, {STR0003, "VIEWDEF.JURA260", 0, 2, 0, NIL } )	//"Visualizar"
	EndIf

	If JA162AcRst("20", 3)
		aAdd( aRotina, {STR0004, "VIEWDEF.JURA260", 0, 3, 0, NIL } )	//"Incluir"
	EndIf

	If JA162AcRst("20", 4)
		aAdd( aRotina, {STR0005, "VIEWDEF.JURA260", 0, 4, 0, NIL } )	//"Alterar"
	EndIf

	If JA162AcRst("20", 5)
		aAdd( aRotina, {STR0006, "VIEWDEF.JURA260", 0, 5, 0, NIL } )	//"Excluir"
	EndIf

	aAdd( aRotina, { STR0007, "VIEWDEF.JURA260", 0, 8, 0, NIL } )	//"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados das Liminares

@author Rafael Tenorio da Costa
@since  12/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	 := FwLoadModel( "JURA260" )
	Local oStructO0S := Nil
	Local oStructO0T := Nil
	Local oView		 := Nil

	//--------------------------------------------------------------
	//Montagem da interface via dicionario de dados
	//--------------------------------------------------------------
	oStructO0S := FWFormStruct( 2, "O0S" )
	oStructO0S:RemoveField("O0S_CAJURI")

	oStructO0S:SetProperty("O0S_DTIPLI", MVC_VIEW_INSERTLINE, .T.)
	oStructO0S:SetProperty("O0S_DTPRAZ", MVC_VIEW_INSERTLINE, .T.)

	oStructO0T := FWFormStruct( 2, "O0T" )
	oStructO0T:RemoveField("O0T_CLIMIN")
	oStructO0T:RemoveField("O0T_CAJURI")

	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0001 )	//"Liminares"

	oView:AddField( "O0SMASTER_JURA260", oStructO0S, "O0SMASTER" )
	oView:AddGrid(  "O0TDETAIL_JURA260", oStructO0T, "O0TDETAIL" )

	oView:CreateHorizontalBox( "ACIMA" , 60)
	oView:CreateHorizontalBox( "ABAIXO", 40)

	oView:SetOwnerView( "O0SMASTER_JURA260", "ACIMA" )
	oView:SetOwnerView( "O0TDETAIL_JURA260", "ABAIXO" )

	oView:AddIncrementField( "O0TDETAIL", "O0T_COD" )

	oView:EnableTitleView( "O0TDETAIL_JURA260" )

	oView:AddUserButton( "Anexos", "CLIPS", {|oView| IIF ( J95AcesBtn(), J260VldAnx(oModel, .F.), FWModelActive()  )} )

	oView:SetUseCursor( .T. )
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados das Liminares

@author Rafael Tenorio da Costa
@since 12/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructO0S := NIL
Local oStructO0T := NIL
Local oModel	 := NIL
Local lWSTLegal  := JModRst()

	//-----------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructO0S := FWFormStruct(1, "O0S")
	oStructO0T := FWFormStruct(1, "O0T")

	If lWSTLegal // Se a chamada estiver vindo do TOTVS Legal
		//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
		oStructO0S:AddField( ;
			""                                                 , ; // [01] Titulo do campo
			""                                                 , ; // [02] ToolTip do campo
			"O0S__TEMANX"                                      , ; // [03] Id do Field
			"C"                                                , ; // [04] Tipo do campo
			2                                                  , ; // [05] Tamanho do campo
			0                                                  , ; // [06] Decimal do campo
			,                                                    ; // [07] Bloco de código de validação do campo
			,                                                    ; // [08] Bloco de código de validação when do campo
			,                                                    ; // [09] Lista de valores permitido do campo
			,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
			{|| JTemAnexo("O0S",O0S->O0S_CAJURI,O0S->O0S_COD)} , ; // [11] Bloco de código de inicialização do campo
			,                                                    ; // [12] Indica se trata-se de um campo chave
			,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
			.T.                                                  ; // [14] Indica se o campo é virtual
			,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
	Endif

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MpFormModel():New( "JURA260", /*Pre-Validacao*/, {|oModel| ValidaPos(oModel)}/*Pos-Validacao*/, {|oModel| SalvaMod(oModel)}/*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0010 )	//"Modelo de dados das Liminares"

	oModel:AddFields( "O0SMASTER", /*cOwner*/, oStructO0S,/*Pre-Validacao*/,/*Pos-Validacao*/)
	oModel:GetModel( "O0SMASTER" ):SetDescription( STR0001 )	//"Liminares"

	//O0T - Multa da Liminar
	oModel:AddGrid( "O0TDETAIL", "O0SMASTER", oStructO0T, /*bLinePre*/, {|oModelO0T, nLinhaAtu| ValidaLin(oModelO0T, nLinhaAtu)}, /*bPre*/, /*bPost*/ )

	oModel:GetModel( "O0TDETAIL"  ):SetDescription( STR0008 )	//"Multas da Liminar"
	oModel:SetRelation( "O0TDETAIL", { { "O0T_FILIAL", "xFilial('O0T')" }, { "O0T_CLIMIN", "O0S_COD" } }, O0T->( IndexKey( 1 ) ) )	//O0T_FILIAL+O0T_CLIMIN+O0T_COD

	oModel:GetModel( "O0TDETAIL" ):SetUniqueLine( { "O0T_DTBASE", "O0T_DTTERM" } )

	oModel:SetOptional( "O0TDETAIL" , .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaPos(oModel)
Valida confirmação da tela.

@param 	 oModel 	- Model a ser verificado

@return  lRetorno	- .T./.F. As informações são válidas ou não

@author  Rafael Tenorio da Costa
@since   23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaPos(oModel)
Local lRetorno  := .T.
Local lWSTLegal := JModRst()
Local nOpc      := oModel:GetOperation()
Local oModelO0T := oModel:GetModel("O0TDETAIL")
Local oModelO0S := oModel:GetModel("O0SMASTER")
Local cSituac   := oModelO0S:GetValue("O0S_SITINT")
Local cCajuri   := oModelO0S:GetValue("O0S_CAJURI")
Local cCod      := oModelO0S:GetValue("O0S_COD")
Local nLinha    := 0

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE

		//Valida vigência data inicial maior que data final
		If lRetorno .And. FwFldGet("O0S_DTINLI") > FwFldGet("O0S_DTFILI")
			JurMsgErro( I18n(STR0018, { AllTrim(JurX3Info("O0S_DTINLI", "X3_TITULO")), AllTrim(JurX3Info("O0S_DTFILI", "X3_TITULO")) } ) )		//"A #1 não pode ser maior que a #2"
			lRetorno := .F.
		EndIf

		//Data do recebimento maior que data prazo
		If lRetorno .And. !Empty(FwFldGet("O0S_DTPRAZ")) .And. FwFldGet("O0S_DTRECE") > FwFldGet("O0S_DTPRAZ")
			JurMsgErro( I18n(STR0018, { AllTrim(JurX3Info("O0S_DTRECE", "X3_TITULO")), AllTrim(JurX3Info("O0S_DTPRAZ", "X3_TITULO")) } ) )		//"A #1 não pode ser maior que a #2"
			lRetorno := .F.
		EndIf

		//Alteração 3=Cumprida
		If lRetorno .And. cSituac == "3"
			If Empty( FwFldGet("O0S_DTCUMP") )
				JurMsgErro( I18n(STR0009, { AllTrim(JurX3Info("O0S_DTCUMP", "X3_TITULO")) }) )	//"O campo #1 deve ser preenchido, quando a Situação da Liminar for Cumprida"
				lRetorno := .F.
			EndIf
		EndIf

		//Valida Liminares com mesma vigência
		If lRetorno
			lRetorno := ExisteLim(oModel)
		EndIf

		//Atualiza multas
		If lRetorno .And. oModelO0T:IsModified()
			For nLinha:= 1 To oModelO0T:GetQtdLine()
				If !oModelO0T:IsDeleted(nLinha)
					oModelO0T:GoLine(nLinha)
					If !oModelO0T:VldLineData() .Or. !J260ValCmp("O0T_DTBASE")
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			Next nLinha
		EndIf
	
		//Valida obrigatoriedade de anexos para liminares cumpridas
		If lRetorno .And. !lWSTLegal
			Begin Transaction
				If JTemAnexo("O0S", cCajuri, cCod) == '02'
					lRetorno := J260VldAnx(oModel)
				EndIf
			End Transaction
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaMod(oModel)
Faz gravações auxiliares.

@param 	oModel 		- Model a ser verificado
@Return lRetorno	- .T./.F. Determina se as informações forão salvas corretamente
@author Rafael Tenorio da Costa
@since  23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SalvaMod(oModel)
Local aArea     := GetArea()
Local aErro     := {}
Local aIncFup   := {}
Local cModProv  := ""
Local cModCump  := ""
Local cFilPro   := xFilial("NSZ")
Local cProcesso := oModel:GetValue("O0SMASTER","O0S_CAJURI")
Local cSituac   := oModel:GetValue("O0SMASTER","O0S_SITINT")
Local cTipLim   := oModel:GetValue("O0SMASTER","O0S_CTIPLI")
Local dPrazo    := oModel:GetValue("O0SMASTER","O0S_DTPRAZ")
Local nI        := 0
Local nOpc      := oModel:GetOperation()
Local lRetorno  := .F.

		lRetorno := FwFormCommit(oModel)
		
		If lRetorno

			lSalvou  := .T.
			AtuAssJur(oModel, cFilPro, cProcesso)

			If nOpc == MODEL_OPERATION_INSERT
		
				//Inclui follow-up
				If cSituac != '3'
					//Pega modelo do follow-up do tipo de liminar
					cModProv := JurGetDados("O0R", 1, xFilial("O0R") + cTipLim, "O0R_CMODFW")//Mod. de FUP para Providencia
					cModCump := JurGetDados("O0R", 1, xFilial("O0R") + cTipLim, "O0R_CMFACP")//Mod. de FUP para Acompanhamento de cumprimento

					//Inclui follow-up
					If cSituac == '2' .And. !Empty(cModCump)
							aAdd(aIncFup,{cModCump})
					ElseIf cSituac != '2' 
						If !Empty(cModProv)
							aAdd(aIncFup,{cModProv})
						EndIF
						If !Empty(cModCump)
							aAdd(aIncFup,{cModCump})
						EndIF
					EndIF
				EndIF
		
				For nI := 1 to Len(aIncFup)
					If lRetorno
						aErro := J106aFwMod(cFilPro, cProcesso, aIncFup[nI][1], , dPrazo)

						If Len(aErro) > 0
							lRetorno := .F.
							oModel:SetErrorMessage(aErro[1], aErro[2], aErro[3], aErro[4], aErro[5],;
													STR0011 + CRLF + aErro[6], aErro[7] ) //"Erro ao incluir follow-up automático"
						EndIf
					EndIf
				Next
			EndIf

		EndIf

	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaLin()
Valida a linha do grid de multas da liminar.

@param 	oModelO0T 	- Model da O0T
@param 	nLinhaAtu	- Linha posicionada
@return lRetorno	- .T./.F. Determina se as informações forão alteradas corretamente
@author Rafael Tenorio da Costa
@since  30/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaLin(oModelO0T, nLinhaAtu)

	Local lRetorno   := .T.
	Local cErro      := ""
	Local nLinha     := 0
	Local dDtBaseAtu := FwFldGet("O0T_DTBASE")
	Local dDtTermAtu := FwFldGet("O0T_DTTERM")
	Local nQtdLinhas := oModelO0T:GetQtdLine()

	//Valida data base maior que data termino
	If lRetorno .And. !Empty(dDtTermAtu) .And. dDtBaseAtu > dDtTermAtu
		lRetorno := .F.
		cErro 	 := I18n(STR0018, { AllTrim(JurX3Info("O0T_DTBASE", "X3_TITULO")), AllTrim(JurX3Info("O0T_DTTERM", "X3_TITULO")) } )		//"A #1 não pode ser maior que a #2"
	EndIf

	 //Valida data de termino da multa se não for a ultima linha do grid
	If lRetorno .And. nLinhaAtu < nQtdLinhas .And. Empty(dDtTermAtu)
		lRetorno := .F.
		cErro 	 := I18n(STR0019, { AllTrim(JurX3Info("O0T_DTTERM", "X3_TITULO")), cValToChar(FwFldGet("O0T_COD")) } )		//"Preencha a #1 da multa #2 do grid"
	EndIf

	 If lRetorno

	 	//Valida período da milta
		For nLinha:= 1 To nQtdLinhas
			If nLinhaAtu <> nLinha .And. !oModelO0T:IsDeleted(nLinha)

				oModelO0T:GoLine(nLinha)

				If ( oModelO0T:GetValue("O0T_DTBASE") <= dDtBaseAtu .And. oModelO0T:GetValue("O0T_DTTERM") >= dDtBaseAtu ) .Or.;
				   ( oModelO0T:GetValue("O0T_DTBASE") <= dDtTermAtu .And. oModelO0T:GetValue("O0T_DTTERM") >= dDtTermAtu )

				   	cErro	 := STR0020		//"Período da multa já comtemplado"
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		Next nLinha

		//Volta a linha atual
		oModelO0T:GoLine(nLinhaAtu)
	EndIf

	If lRetorno
		//Atualiza campos de multa
		AtuMulta(oModelO0T)
	Else
		lRetorno := .F.
		JurMsgErro(cErro)
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuAssJur()
Atualiza campos da NSZ com dados da ultima liminar aberta caso exista.

@author Rafael Tenorio da Costa
@since  23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuAssJur(oModel, cFilPro, cProcesso)

	Local aArea		:= GetArea()
	Local oModelAct	:= oModel
	Local cQuery    := ""
	Local aRetorno	:= {}
	Local nCont		:= 0

	cQuery := " SELECT O0S_COD, O0S_DTINLI, O0S_DTFILI, O0S_STATUS"
	cQuery += " FROM " + RetSqlName("O0S")
	cQuery += " WHERE O0S_FILIAL = '" + cFilPro + "'"
	cQuery += 	" AND O0S_CAJURI = '" + cProcesso + "'"
	cQuery += 	" AND O0S_SITINT <> '3'"		//1=Não Solicitada;2=Solicitada;3=Cumprida
	cQuery += 	" AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY O0S_DTFILI DESC, O0S_COD DESC"

	For nCont:=1 To 2

		//Retira condição de filtro diferente de cumprida
		If nCont == 2
			cQuery := StrTran(cQuery, " AND O0S_SITINT <> '3'", "")
		EndIf

		aSize(aRetorno, 0)
		aRetorno := JurSql(cQuery, "*")

		If Len(aRetorno) > 0

			NSZ->( DbSetOrder(1) )	//NSZ_FILIAL + NSZ_COD
			If NSZ->( DbSeek(cFilPro + cProcesso) )

				RecLock("NSZ", .F.)
					NSZ->NSZ_DTINLI := StoD(aRetorno[1][2])
					NSZ->NSZ_DTFILI := StoD(aRetorno[1][3])
					NSZ->NSZ_CSTATL := aRetorno[1][4]
					NSZ->NSZ_OBSLIV := JurGetDados("O0S", 1, cFilPro + cProcesso + aRetorno[1][1], "O0S_OBSERV")	//O0S_FILIAL+O0S_CAJURI+O0S_COD
				NSZ->( MsUnlock() )

				//Atualiza o modelo
				If oModel095 <> Nil .And. !Empty(oModel095)
					FwModelActive(oModel095)

					If oModel095:GetModel("NSZMASTER"):HasField("NSZ_DTINLI")
						oModel095:LoadValue("NSZMASTER", "NSZ_DTINLI", NSZ->NSZ_DTINLI)
					EndIf

					If oModel095:GetModel("NSZMASTER"):HasField("NSZ_DTFILI")
						oModel095:LoadValue("NSZMASTER", "NSZ_DTFILI", NSZ->NSZ_DTFILI)
					EndIf

					If oModel095:GetModel("NSZMASTER"):HasField("NSZ_CSTATL")
						oModel095:LoadValue("NSZMASTER", "NSZ_CSTATL", NSZ->NSZ_CSTATL)
					EndIf

					If oModel095:GetModel("NSZMASTER"):HasField("NSZ_OBSLIV")
						oModel095:LoadValue("NSZMASTER", "NSZ_OBSLIV", NSZ->NSZ_OBSLIV)
					EndIf

					//Voltar ao modelo do JURA260
					FwModelActive(oModelAct)
					oModelAct:Activate()
				EndIf
			EndIf

			Exit
		EndIf
	Next nCont

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuMulta()
Atualiza campos de multa (O0T_DIADES\O0T_VLMUL).

@author Rafael Tenorio da Costa
@since  23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuMulta(oModelO0T)

	Local nDiasDes	:= 0
	Local nTetoMulta:= 0
	Local nVlrMulta	:= 0
	Local dDtTerm	:= FwFldGet("O0T_DTTERM")
	Local dDtFimCal := IIF( Empty(dDtTerm) .Or. dDtTerm > dDataBase, dDataBase, dDtTerm)

	//1=Em vigor e diferente de 3=Cumprida
	If FwFldGet("O0S_STATUS") == "1" .And.	FwFldGet("O0S_SITINT") <> "3" .And. dDataBase > FwFldGet("O0S_DTPRAZ") .And. dDataBase >= FwFldGet("O0T_DTBASE")

		//Atualiza dados da ultima multa aplicada
		nDiasDes := dDtFimCal - oModelO0T:GetValue("O0T_DTBASE")
		nDiasDes := IIF(nDiasDes < 0, 0, nDiasDes)
		If oModelO0T:GetValue("O0T_DIADES") <> nDiasDes
			oModelO0T:LoadValue("O0T_DIADES", nDiasDes)
		EndIf

		nTetoMulta:= oModelO0T:GetValue("O0T_TETMUL")
		nVlrMulta := oModelO0T:GetValue("O0T_MULDIA") * oModelO0T:GetValue("O0T_DIADES")
		nVlrMulta := IIF( nTetoMulta > 0 .And. nVlrMulta > nTetoMulta, nTetoMulta, nVlrMulta)
		If oModelO0T:GetValue("O0T_VLMUL") <> nVlrMulta
			oModelO0T:LoadValue("O0T_VLMUL" , nVlrMulta)
		EndIf

	Else

		oModelO0T:ClearField("O0T_DIADES")
		oModelO0T:ClearField("O0T_VLMUL" )
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J260Cajuri
Inicializa o campo O0S_CAJURI

@author  Rafael Tenorio da Costa
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J260Cajuri()

	Local cRet := ""

	If Type("M->NSZ_COD") <> "U" .And. !Empty(M->NSZ_COD)
		cRet := M->NSZ_COD
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J260ValCmp()
Validação dos campos da O0T:
O0T_DTBASE \ O0T_MULDIA \ O0T_TETMUL \ O0T_DTTERM

@author Rafael Tenorio da Costa
@since  23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J260ValCmp(cCampo)

	Local oModel    := FwModelActive()
	Local oModelO0T := oModel:GetModel("O0TDETAIL")
	Local lRetorno  := .T.
	Local cErro     := ""

	Do Case

		Case cCampo == "O0T_DTBASE"

			If Empty( FwFldGet("O0T_DTBASE") )
				cErro := I18n(STR0023, { AllTrim(JurX3Info("O0T_DTBASE", "X3_TITULO")) } )		//"Campo #1 inválido"
			ElseIf !Empty( FwFldGet("O0T_DTBASE") ) .And. !( FwFldGet("O0T_DTBASE") > FwFldGet("O0S_DTPRAZ") )
				cErro := I18n(STR0021, { AllTrim(JurX3Info("O0T_DTBASE", "X3_TITULO")), AllTrim(JurX3Info("O0S_DTPRAZ", "X3_TITULO")) } )		//"#1 da multa tem que ser maior que a #2 da liminar"
			EndIf

	End Case

	If Empty(cErro)
		//Atualiza campos de multa
		AtuMulta(oModelO0T)
	Else
		JurMsgErro(cErro)
		lRetorno := .F.
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J260Multas()
Atualiza as multas das liminares a partir do assunto juridico

@author Rafael Tenorio da Costa
@since  23/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J260Multas(cFilPro, cCodPro)

	Local aArea		:= GetArea()
	Local nDiasDes	:= 0
	Local nTetoMulta:= 0
	Local nVlrMulta	:= 0
	Local dDtTerm	:= ""
	Local dDtFimCal := ""

	DbSelectArea("O0S")
	O0S->( DbSetOrder(1) )	//O0S_FILIAL+O0S_CAJURI+O0S_COD

	DbSelectArea("O0T")
	O0T->( DbSetOrder(1) )	//O0T_FILIAL+O0T_CLIMIN+O0T_COD

	If O0S->( DbSeek(cFilPro + cCodPro) )

		While !O0S->( Eof() ) .And. O0S->O0S_FILIAL == cFilPro .And. O0S->O0S_CAJURI == cCodPro

			//Atualiza valores de multa
			If O0T->( DbSeek(O0S->O0S_FILIAL + O0S->O0S_COD) )

				While !O0T->( Eof() ) .And. O0T->O0T_FILIAL == O0S->O0S_FILIAL .And. O0T->O0T_CLIMIN == O0S->O0S_COD

					//1=Em vigor e diferente de 3=Cumprida
					If	O0S->O0S_STATUS == "1" .And. O0S->O0S_SITINT <> "3" .And. dDataBase > O0S->O0S_DTPRAZ  .And. dDataBase >= O0T->O0T_DTBASE

					 	dDtTerm	  := O0T->O0T_DTTERM
					 	dDtFimCal := IIF( Empty(dDtTerm) .Or. dDtTerm > dDataBase, dDataBase, dDtTerm)

						//Calcula dias
						nDiasDes := dDtFimCal - O0T->O0T_DTBASE
						nDiasDes := IIF(nDiasDes < 0, 0, nDiasDes)

						//Calcula valor da multa
						nTetoMulta := O0T->O0T_TETMUL
						nVlrMulta  := O0T->O0T_MULDIA * nDiasDes
						nVlrMulta  := IIF( (nTetoMulta > 0 .And. nVlrMulta > nTetoMulta), nTetoMulta, nVlrMulta)

					Else

						nDiasDes  := 0
						nVlrMulta := 0
					EndIf

					RecLock("O0T", .F.)
						O0T->O0T_DIADES := nDiasDes
						O0T->O0T_VLMUL	:= nVlrMulta
					O0T->( MsUnlock() )

					O0T->( DbSkip() )
				EndDo
			EndIf

			O0S->( DbSkip() )
		EndDo
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J260Set095
Seta o modelo JURA095 para possiveis atualizações

@author  Rafael Tenorio da Costa
@since   30/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J260Set095(oJura095)
	oModel095 := oJura095
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteLim()
Valida liminar com a mesma vigência.

@param oModel: Modelo da rotina de liminar

@since  30/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExisteLim(oModel)
Local aArea     := GetArea()
Local lRetorno  := .T.
Local cQuery    := ""
Local aRetorno  := {}
Local sDtInLi   := DtoS( FwFldGet("O0S_DTINLI") )
Local sDtFiLi   := DtoS( FwFldGet("O0S_DTFILI") )

	If FwFldGet('O0S_STATUS') == '1'
		cQuery := " SELECT O0S_FILIAL, O0S_COD"
		cQuery += " FROM " + RetSqlName("O0S")
		cQuery += " WHERE O0S_FILIAL = '" + xFilial("O0S") + "'"
		cQuery += 	" AND O0S_CAJURI = '" + FwFldGet("O0S_CAJURI") + "'"
		cQuery += 	" AND O0S_STATUS = '1'"  //1=Em vigor
		cQuery += 	" AND O0S_SITINT <> '3'" //1=Não Solicitada;2=Solicitada;3=Cumprida
		cQuery += 	" AND ( O0S_DTINLI <= '" + sDtInLi + "' AND O0S_DTFILI >= '" + sDtInLi + "' OR"
		cQuery += 		  " O0S_DTINLI <= '" + sDtFiLi + "' AND O0S_DTFILI >= '" + sDtFiLi + "' )"
		If oModel:GetOperation() == 4
			cQuery += " AND R_E_C_N_O_ <> '" + cValToChar( O0S->(Recno()) ) + "'"
		EndIf
		cQuery += 	" AND D_E_L_E_T_ = ' '"

		aRetorno := JurSql(cQuery, "*")

		If Len(aRetorno) > 0
			lRetorno := .F.
			JurMsgErro( I18n(STR0022, {aRetorno[1][2]}) ) //"Já existe Liminar (#1) em Vigor que contempla este período"
		EndIf
	EndIf

	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J260VldAnx(oModel, lPosValid)
Função que valida se a liminar possui anexos.

@Param oModel: Modelo da rotina de liminares
@Param lPosValid: Chamada vem do pós valid?

@since 22/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J260VldAnx(oModel, lPosValid)
Local nOpc      := oModel:GetOperation()
Local cSituac   := oModel:GetValue("O0SMASTER","O0S_SITINT")
Local cTipLim   := oModel:GetValue("O0SMASTER","O0S_CTIPLI")
Local cCajuri   := oModel:GetValue("O0SMASTER","O0S_CAJURI")
Local cCod      := oModel:GetValue("O0SMASTER","O0S_COD")
Local cSolAne   := ''
Local lRetorno  := .T.
Local lWSTLegal := JModRst()

Default lPosValid := .T.

	If nOpc != 5 .And. !lWSTLegal
		//Pega solicita anexo do tipo de liminar
		cSolAne := JurGetDados("O0R", 1, xFilial("O0R") + cTipLim, "O0R_SOLANE")
		
		//Inclui anexo em liminar cumprida
		If cSituac == "3" .And. cSolAne == '1'
			
			If lPosValid
				ApMsgInfo(STR0024) //'Para esse tipo de liminares, é necessário inserir anexos '
			EndIf

			lRetorno := JurAnexos('O0S', cCajuri + cCod, 1)

			If !lRetorno
				JurMsgErro(STR0015,,STR0016) //"A Liminar não possui anexos" //"Insira anexos para Liminares Cumpridas"

				If nOpc == 4
					J260VldAnx(oModel, lPosValid)
				EndIf
			EndIf
		Else
			If !lPosValid
				lRetorno := JurAnexos('O0S', cCajuri + cCod, 1)
			EndIf
		EndIf
	EndIf

return lRetorno
