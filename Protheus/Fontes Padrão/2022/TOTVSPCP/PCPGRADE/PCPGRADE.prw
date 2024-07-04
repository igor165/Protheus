#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PCPGRADE.CH"

Static soGrade

CLASS PCPGRADE

	DATA nOperation AS NUMERIC  //Operacao da tela
	DATA oModelGrd  AS OBJECT   //Modelo da tela de grade

	//Propriedades default para integracao na rotina padrao
	DATA oMdlRotina  AS OBJECT   //Modelo da rotina padrao
	DATA cModelDef   AS CARACTER //ModelGrid default da rotina padrao
	DATA cModelGrade AS CARACTER //ModelGrid referente dados da grade
	DATA cFieldRefe  AS CARACTER //Campo referencia da grade
	DATA cFieldProd  AS CARACTER //Campo codigo do produto
	DATA cFieldQtd   AS CARACTER //Campo quantidade
	DATA cFieldID    AS CARACTER //Campo ID da grade
	DATA cFieldItem  AS CARACTER //Campo item da grade
	DATA cFieldGrade AS CARACTER //Campo indicador de existencia da grade
	DATA cFieldDescr AS CARACTER //Campo descricao do produto / grade
	DATA cFldUnqKey  AS CARACTER //Campos referente chave unica da tabela
	DATA aFieldOpc   AS CARACTER //De-Para do campo Opcional (OPC)
	DATA aFieldMOpc  AS CARACTER //De-Para do campo Memo Opcional (MOPC)

	//Metodos padroes MVC
	METHOD new(oMdlRotina, cModelDef, cModelGrade, cFieldProd, cFieldDescr, cFieldQtd, cFieldID, cFieldItem, cFieldRefe, cFieldGrade, cFldUnqKey) CONSTRUCTOR
	METHOD abreTelaGrade(nOperation)
	METHOD processaSelecao()

	//Metodos complementares rotina padrao
	METHOD addTriggers()                               //Adiciona gatilhos
	METHOD addUserButton()                             //Adiciona botoes em outras acoes
	METHOD getDescricao()                              //Retorna descricao do produto / grade
	METHOD getReferencia()                             //Retorna a referencia grade do produto
	METHOD grade(cProduto, lCodProd)                   //Indica se o codigo eh de uma grade
	METHOD getID(cProduto)                             //Indica se o codigo eh de uma grade
	METHOD loadGrid(oGridModel, lCopy)                 //Substituicao do bloco de carga padrao da tela
	METHOD xBeforeTTS(oModel, cModelGrade)             //Complemento metodo beforeTTS da rotina padrao
	METHOD xGridLinePosVld(oSubModel, cModelID, nLine) //Complemento metodo GridLinePosVld da rotina padrao
	METHOD gravadoNoBanco(cIDGrade)                    //Retorna a referencia grade do produto

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe
@author brunno.costa
@since 17/01/2019
@version P12
@param 01, oMdlRotina , objeto  , modelo padrao da rotina chamadora
@param 02, cModelDef  , caracter, nome da grid padrao - exibe o produto grade
@param 03, cModelGrade, caracter, nome da grid grade  - armazena os itens da grade para commit
@param 04, cFieldProd , caracter, nome do campo com o codigo do produto / grade
@param 05, cFieldDescr, caracter, nome do campo de descricao do produto / grade
@param 06, cFieldQtd  , caracter, nome do campo com a quantidade do produto
@param 07, cFieldID   , caracter, nome do campo com o ID da grade do produto
@param 08, cFieldItem , caracter, nome do campo com o item da grade do produto
@param 09, cFieldRefe , caracter, nome do campo com a referencia da grade do produto
@param 10, cFieldGrade, caracter, nome do campo indicador de grade na grid
@param 11, cFldUnqKey , caracter, campos relacionados a chave unica do registro na tabela origem - nao podem sofrer alteracao
@param 12, aFieldOpc  , array   , array com o DE-PARA do nome do campo Opcional do produto (_OPC)
@param 13, aFieldMOpc , array   , array com o DE-PARA do nome do campo MEMO Opcional do produto (_MOPC)
/*/
METHOD New(oMdlRotina, cModelDef, cModelGrade, cFieldProd, cFieldDescr, cFieldQtd, cFieldID, cFieldItem, ;
           cFieldRefe, cFieldGrade, cFldUnqKey, aFieldOpc, aFieldMOpc) CLASS PCPGRADE

	::oMdlRotina   := oMdlRotina
	::cModelDef    := cModelDef
	::cModelGrade  := cModelGrade
	::cFieldProd   := cFieldProd
	::cFieldDescr  := cFieldDescr
	::cFieldQtd    := cFieldQtd
	::cFieldID     := cFieldID
	::cFieldItem   := cFieldItem
	::cFieldRefe   := cFieldRefe
	::cFieldGrade  := cFieldGrade
	::cFldUnqKey   := cFldUnqKey
	::aFieldOpc    := aFieldOpc
	::aFieldMOpc   := aFieldMOpc

Return

/*/{Protheus.doc} abreTelaGrade
Abre tela para Selecao de Itens - Grade de Produto
@author brunno.costa
@since 06/06/2019
@version P12
@param 01, nOperation, numero  , indica a operacao para a view
@return nTotal, numero, novo valor total da selecao
@See: PCPA136.prw
/*/
METHOD abreTelaGrade(nOperation) CLASS PCPGRADE

	Local aButtons   := {}
	Local cGrade     := ""
	Local lConfirmou := .F.
	Local nReturn    := &(READVAR())
	Local oModel
	Local oEvent
	Local oViewExec
	Local oViewModal
	Local oView      := FWViewActive()
	Local oModelDef  := ::oMdlRotina:GetModel(::cModelDef)

	Default nOperation := OP_ALTERAR

	soGrade      := self
	::nOperation := nOperation

	//Posiciona no registro da grade atual
	If !Empty(::cFieldProd) .AND. ValType(::cFieldProd) == "C"
		cGrade := oModelDef:GetValue(::cFieldProd)
	EndIf

	DbSelectArea("SB4")
	SB4->(DbSetOrder(1))
	If SB4->(dbSeek(xFilial("SB4") + cGrade)) .And. ::grade(cGrade,.F.)
		oViewExec := FWViewExec():New()
		oModel    := ModelDef()
		oEvent    := gtMdlEvent(oModel, "PCPGRADEEVDEF")

		//Ativa o modelo em operacao de alteracao
		oModel:setOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		::oModelGrd := oModel

		//Atualiza variaveis estaticas
		oEvent:nTotal    := 0         //Total recebido da tela anterior
		If !Empty(::cFieldQtd)
			oEvent:nTotal := oModelDef:GetValue(::cFieldQtd)
		EndIf

		//Prepara botoes
		aAdd(aButtons,{.F.,Nil}) //Copiar
		aAdd(aButtons,{.F.,Nil}) //Recortar
		aAdd(aButtons,{.F.,Nil}) //Colar
		aAdd(aButtons,{.F.,Nil}) //Calculadora
		aAdd(aButtons,{.F.,Nil}) //Spool
		aAdd(aButtons,{.F.,Nil}) //Imprimir
		aAdd(aButtons,{.T.,STR0001}) //Confirmar
		aAdd(aButtons,{.F.,Nil}) //Cancelar
		aAdd(aButtons,{.F.,Nil}) //WalkTrhough
		aAdd(aButtons,{.F.,Nil}) //Ambiente
		aAdd(aButtons,{.F.,Nil}) //Mashup
		aAdd(aButtons,{.F.,Nil}) //Help
		aAdd(aButtons,{.F.,Nil}) //Formulário HTML
		aAdd(aButtons,{.F.,Nil}) //ECM

		//Prepara ViewExec
		oViewModal := ViewDef(oView)
		oViewExec:setModel(oModel)
		oViewExec:setView(oViewModal)
		oViewExec:setTitle(STR0002) //"Seleção de itens - Grade do produto:"
		oViewExec:setOperation(nOperation)
		oViewExec:setReduction(30)
		oViewExec:setButtons(aButtons)
		oViewExec:SetCloseOnOk({|| lConfirmou := oEvent:ModelPosVld(oModel, "PCPGRADE")})

		//Abre a tela
		oViewExec:openView(.F.)

		oEvent:nTotal := oEvent:getSoma()
		If lConfirmou
			oModelDef:LoadValue(::cFieldQtd, oEvent:nTotal)
			::processaSelecao()
		EndIf
		nReturn := oEvent:nTotal

		oViewExec:DeActivate()
		oViewModal:DeActivate()
		oViewModal:Destroy()
	EndIf

	FWModelActive(::oMdlRotina)
	FWViewActive(oView)

Return nReturn

/*/{Protheus.doc} processaSelecao
Processa atualizacao do modelo de gravacao referente atualizacao de grade
@author brunno.costa
@since 06/06/2019
@version P12
/*/
METHOD processaSelecao() CLASS PCPGRADE

	Local cGrade
	Local cIDAux
	Local cITAux
	Local cIDGrade
	Local cMascara
	Local cMaxIDGrd
	Local cMaxItem
	Local cProduto
	Local nIcChv
	Local nIndLin
	Local nIndCol
	Local nIndFld
	Local nTamRef
	Local nTamLin
	Local nTamCol
	Local oJsonGrv
	Local oMdlGrade
	Local oModelDig
	Local oModelDef

	If ::nOperation != OP_VISUALIZAR

		//Prepara variaveis locais
		cGrade    := ::oModelGrd:GetModel("SB4_MASTER"):GetValue("B4_COD")
		cMascara  := SuperGetMv("MV_MASCGRD")
		nTamRef   := Val(Substr(cMascara,1,2))
		nTamLin   := Val(Substr(cMascara,4,2))
		nTamCol   := Val(Substr(cMascara,7,2))

		oJsonGrv  := JsonObject():New()
		oMdlGrade := ::oMdlRotina:GetModel(::cModelGrade)
		oModelDig := ::oModelGrd:GetModel("SBV_DETAIL")
		oModelDef := ::oMdlRotina:GetModel(::cModelDef)

		cIDGrade  := oModelDef:GetValue(::cFieldID)
		//cMaxIDGrd := oMdlGrade:GetValue(::cFieldID)
		//cMaxItem  := oMdlGrade:GetValue(::cFieldItem)
		nIcChv    := aScan(oModelDig:aHeader, { |x| AllTrim(x[2]) == "cChave"  })

		If Empty(cMaxIDGrd)
			cMaxIDGrd := If (FunName() == "PCPA136","90000000000","0000000000")
		EndIf
		If Empty(cMaxItem)
			cMaxItem := "000"
		EndIf

		//Percorre modelo de gravacao da grade
		For nIndLin := 1 to oMdlGrade:Length(.F.)
			If !oMdlGrade:IsDeleted(nIndLin)
				//Identifica o maior ID Grade
				cIDAux := oMdlGrade:GetValue(::cFieldID, nIndLin)
				If cMaxIDGrd < cIDAux
					cMaxIDGrd := cIDAux
				EndIf

				//Registra posicoes dos itens grade no modelo de gravacao
				If AllTrim(cIDGrade) == AllTrim(cIDAux)
					cProduto := oMdlGrade:GetValue(::cFieldProd, nIndLin)
					oJsonGrv[cProduto + "|" + cIDGrade] := nIndLin

					//Identifica o maior item da Grade
					cITAux := oMdlGrade:GetValue(::cFieldItem, nIndLin)
					If cMaxItem < cITAux
						cMaxItem := cITAux
					EndIf
				EndIf
			EndIf
		Next

		//Percorre modelo de digitacao da grade
		//Atualiza modelo de gravacao da grade
		For nIndLin := 1 to oModelDig:Length(.F.)
			For nIndCol := (nIcChv + 1) to Len(oModelDig:aHeader)
				cProduto := Left(cGrade, nTamRef);
							+ Left(oModelDig:GetValue("BV_CHAVE", nIndLin),nTamLin);
							+ Substring(oModelDig:aHeader[nIndCol][2] + "  ", 8, nTamCol)
				cProduto := PadR(cProduto, GetSx3Cache("B1_COD", "X3_TAMANHO"))
				nValor   := oModelDig:GetValue(oModelDig:aHeader[nIndCol][2], nIndLin)

				//Adiciona nova linha
				oMdlGrade:SetNoInsertLine(.F.)
				oMdlGrade:SetNoDeleteLine(.F.)
				If oJsonGrv[cProduto + "|" + cIDGrade] == Nil
					If nValor > 0
						If Empty(oMdlGrade:GetValue(::cFieldProd))
							oJsonGrv[cProduto + "|" + cIDGrade] := oMdlGrade:GetLine()
						Else
							oJsonGrv[cProduto + "|" + cIDGrade] := oMdlGrade:AddLine()
						EndIf
						oMdlGrade:GoLine(oJsonGrv[cProduto + "|" + cIDGrade])
						For nIndFld := 1 to Len(oMdlGrade:aHeader)
							cCampo := oMdlGrade:aHeader[nIndFld][2]
							If cCampo == ::aFieldOpc[2]
								oMdlGrade:LoadValue(cCampo, oModelDef:GetValue(::aFieldOpc[1]))
							ElseIf cCampo == ::aFieldMOpc[2]
								oMdlGrade:LoadValue(cCampo, oModelDef:GetValue(::aFieldMOpc[1]))
							Else
								oMdlGrade:LoadValue(cCampo, oModelDef:GetValue(cCampo))
							EndIf
						Next
						oMdlGrade:LoadValue(::cFieldProd  , cProduto)
						oMdlGrade:LoadValue(::cFieldQtd   , nValor)

						//Adiciona ID da grade
						oJsonGrv[cProduto + "|" + cIDGrade] := Nil
						If Empty(oMdlGrade:GetValue(::cFieldID))
							cIDGrade := Soma1(cMaxIDGrd)
							oMdlGrade:LoadValue(::cFieldID , cIDGrade)
							oModelDef:LoadValue(::cFieldID , cIDGrade)
						EndIf
						oJsonGrv[cProduto + "|" + cIDGrade] := oMdlGrade:GetLine()

						//Adiciona item da grade
						cMaxItem := AllTrim(Soma1(cMaxItem))
						oMdlGrade:LoadValue(::cFieldItem , cMaxItem)
						oModelDef:LoadValue(::cFieldItem , cMaxItem)

						If FunName() == "PCPA136"
							oMdlGrade:LoadValue("VR_SEQUEN" , 0)
							oMdlGrade:LoadValue("CLEGEND"   , "BR_AZUL")
							oMdlGrade:LoadValue("VR_INTMRP" , "3")
							oMdlGrade:LoadValue("VR_LOCAL"  , Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD") )
							oMdlGrade:LoadValue("VR_REFGRD" , Left(cGrade, nTamRef))
						EndIf
					EndIf

				//Atualiza linha
				Else
					oMdlGrade:GoLine(oJsonGrv[cProduto + "|" + cIDGrade])
					If nValor > 0
						If FunName() == "PCPA136"
							oMdlGrade:LoadValue(::cFieldQtd   , nValor)
							oMdlGrade:LoadValue("CLEGEND"   , "BR_AZUL")
							oMdlGrade:LoadValue("VR_INTMRP" , "3")
						EndIf
					ElseIf !oMdlGrade:IsDeleted()
						oMdlGrade:DeleteLine()
					EndIf

				EndIf
				oMdlGrade:SetNoInsertLine(.T.)
				oMdlGrade:SetNoDeleteLine(.T.)
			Next
		Next
	EndIf

Return

/*/{Protheus.doc} addTriggers
Adiciona gatilhos a rotina padrao
@author brunno.costa
@since 11/06/2019
@version P12
@param 01 - oStrDetail, objeto, estrutura da grid da rotina padrao
/*/
METHOD addTriggers(oStrDetail) CLASS PCPGRADE

	Local oGrade := self

	oStrDetail:AddTrigger(::cFieldProd ,::cFieldRefe ,{|| .T. }, {|| oGrade:getReferencia() } )
	oStrDetail:AddTrigger(::cFieldProd ,::cFieldGrade,{|| .T. }, {|| Iif(oGrade:grade(Nil, .F.), "S", " ") } )
	oStrDetail:AddTrigger(::cFieldProd ,::cFieldID   ,{|| .T. }, {|| oGrade:getID(Nil, .F.) } )
	oStrDetail:AddTrigger(::cFieldQtd  ,::cFieldQtd  ,{|| oGrade:grade(Nil, .F.) }, {|| oGrade:abreTelaGrade(OP_ALTERAR) } )

Return

/*/{Protheus.doc} addUserButton
Adiciona botoes em outras acoes
@author brunno.costa
@since 11/06/2019
@version P12
@param 01 - oView    , objeto, view da rotina padrao
/*/
METHOD addUserButton(oView) CLASS PCPGRADE
	Local oGrade := self
	oView:AddUserButton(STR0006, "", {|| oGrade:abreTelaGrade(OP_VISUALIZAR) }, , , {MODEL_OPERATION_VIEW }, .T.) //"Grade"
	oView:AddUserButton(STR0006, "", {|| oGrade:abreTelaGrade(OP_ALTERAR)    }, , , {MODEL_OPERATION_UPDATE, MODEL_OPERATION_INSERT }, .T.) //"Grade"
Return

/*/{Protheus.doc} getReferencia
Funcao para preenchimento do campo VR_REFGRD
@type  Function
@author brunno.costa
@since 11/06/2019
@version P12
@return cRefGrade, caracter, codigo da referencia grade do produto
/*/
METHOD getReferencia() CLASS PCPGRADE
	Local oModel    := FWModelActive()
	Local cCodigo   := oModel:GetModel(::cModelDef):GetValue(::cFieldProd)
	Local cRefGrade := cCodigo
	Local cMascara  := SuperGetMv("MV_MASCGRD")
	Local nTamRef   := Val(Substr(cMascara,1,2))
	If !::grade(@cRefGrade) .OR. AllTrim(cRefGrade) == AllTrim(cCodigo)
		cRefGrade := " "
	Else
		cRefGrade := Left(cRefGrade, nTamRef)
	EndIf
Return cRefGrade

/*/{Protheus.doc} grade
Verifica se o codigo do produto e referente grade
@type  Function
@author brunno.costa
@since 11/06/2019
@version P12
@param 01 - cCodigo , caracter, codigo do produto ou grade a ser avaliado
@param 02 - lCodProd, caracter, indica se para cCodigo de produto que faz parte da grade deve retornar true (.T.)
                                ou (.F.) para retornar true somente quando informado o codigo da grade
@return cRefGrade, caracter, codigo da referencia grade do produto
/*/
METHOD grade(cCodigo, lCodProd) CLASS PCPGRADE
	Local oModel
	Local lReturn
	Default lCodProd := .T.
	If cCodigo == Nil .or. Empty(cCodigo)
		oModel  := FWModelActive()
		cCodigo := oModel:GetModel(::cModelDef):GetValue(::cFieldProd)
	EndIf
	lReturn := MatGrdPrrf(@cCodigo, lCodProd)
Return lReturn

/*/{Protheus.doc} getID
Retorna o ID da grade para este registro
@type  Function
@author brunno.costa
@since 11/06/2019
@version P12
@param 01 cCodigo, caracter, codigo do produto para retornar o ID da grade
@return cIDGrade, caracter, identificador unico de agrupamento deste registro de grade
/*/
METHOD getID(cCodigo) CLASS PCPGRADE
	Local oModel    := FWModelActive()
	Local cIDGrade  := oModel:GetModel(::cModelDef):GetValue(::cFieldID)
	Default cCodigo := oModel:GetModel(::cModelDef):GetValue(::cFieldProd)
	cIDGrade := Iif(::grade(cCodigo, .F.), cIDGrade, " ")
Return cIDGrade

/*/{Protheus.doc} getReferencia
Retorna descricao do produto / grade
@type  Function
@author brunno.costa
@since 11/06/2019
@version P12
@return cDescricao, caracter, descricao do produto / grade
/*/
METHOD getDescricao() CLASS PCPGRADE
	Local cDescricao := ""
	Local oModel     := FWModelActive()
	Local cCodigo    := oModel:GetModel(::cModelDef):GetValue(::cFieldProd)

	//Descricao da Grade - SB4
	If ::grade(cCodigo, .F.)
		DbSelectArea("SB4")
		SB4->(DbSetOrder(1))
		If SB4->(dbSeek(xFilial("SB4") + cCodigo))
			cDescricao := SB4->B4_DESC
		EndIf

	//Descricao do Produto - SB1
	Else
		DbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + cCodigo))
			cDescricao := SB1->B1_DESC
		EndIf
	EndIf
Return cDescricao

/*/{Protheus.doc} loadGrid
Substituicao do bloco de carga padrao da grid

@type  Function
@author brunno.costa
@since 11/06/2019
@version P12.1.25
@param 01 - oGridModel, Object, objeto da grid
@param 02 - lCopy     , logico, indica se e operacao de copia
@return aLoad, array, array com os dados para carga
/*/
METHOD loadGrid(oGridModel, lCopy) CLASS PCPGRADE

	Local aFields    := oGridModel:aHeader
	Local aLoad      := {}
	Local aGrade
	Local cBloco1
	Local cBloco2
	Local cProduto
	Local cIDGrade
	Local nInd
	Local nIProd     := aScan(aFields, { |x| AllTrim(x[2]) == ::cFieldProd })
	Local nIIDGrade  := aScan(aFields, { |x| AllTrim(x[2]) == ::cFieldID   })
	Local nIDesc     := aScan(aFields, { |x| AllTrim(x[2]) == ::cFieldDescr})
	Local nIQtde     := aScan(aFields, { |x| AllTrim(x[2]) == ::cFieldQtd  })
	Local oJsonGrade := JsonObject():New()

	//Efetua carga padrao do modelo SVR_DETAIL - Registros sem Grade
	aLoad  := FormLoadGrid(oGridModel, lCopy)

	//Copia Array com os dados carregados no modelo SVR_GRADE - Registros Grade
	aGrade := aClone(oGridModel:GetModel():GetModel(::cModelGrade):aDataModel)

	//Percorre registros do modelo SVR_GRADE - Registros Grade
	For nInd := 1 to Len(aGrade)
		cProduto := aGrade[nInd][1][1][nIProd]
		cIDGrade := aGrade[nInd][1][1][nIIDGrade]
		If !Empty(cProduto)
			If ::grade(@cProduto) //Eh Grade
				//Adiciona novo registro
				If oJsonGrade[cProduto + "|" + cIDGrade] == Nil
					//Corrige codigo e descricao da grade
					aGrade[nInd][1][1][nIProd] := cProduto
					aGrade[nInd][1][1][nIDesc] := SB4->B4_DESC

					//Adiciona ao array de carga
					aAdd(aLoad, {0, aGrade[nInd][1][1]} )
					oJsonGrade[cProduto + "|" + cIDGrade] := Len(aLoad)

				//Soma quantidade em registro existente
				Else
					aLoad[oJsonGrade[cProduto + "|" + cIDGrade]][2][nIQtde] += aGrade[nInd][1][1][nIQtde]

				EndIf
			Else                          //Nao eh grade (registros antigos sem grade vigente...)
				//Adiciona ao array de carga
				aAdd(aLoad, {aGrade[nInd][4], aGrade[nInd][1][1]} )
			EndIf
		EndIf
	Next

	//Reordena com base na ordem padrao do modelo
	cBloco1 := oGridModel:cOrderBy
	For nInd := 1 to Len(aFields)
		cBloco1 := StrTran(cBloco1, AllTrim(aFields[nInd][2]), "x[2][" + cValToChar(nInd) + "]")
	Next
	cBloco2 := StrTran(cBloco1, "x[", "y[")
	aLoad := aSort(aLoad, , , { | x, y | &(cBloco1) < &(cBloco2)} )

Return aLoad

/*/{Protheus.doc} gravadoNoBanco
Indica se o ID grade existe gravado no banco

@type  Function
@author brunno.costa
@since 11/06/2019
@version P12.1.25
@param 01 - cIDGrade, caracter, ID da grade
@return lReturn, logico, indica
/*/
METHOD gravadoNoBanco(oModelDef, nLine, cModelGrade, cFieldID) CLASS PCPGRADE

	Local lReturn   := .F.
	Local cIDGrade  := oModelDef:GetValue(cFieldID, nLine)
	Local oMdlGrade := oModelDef:GetModel():GetModel(cModelGrade)

	If !Empty(cIDGrade);
	   .AND. oMdlGrade:SeekLine({{cFieldID, cIDGrade}}, .T., .T.);
	   .AND. oMdlGrade:GetDataID() > 0
		lReturn := .T.
	EndIf

Return lReturn

 /*/{Protheus.doc} xBeforeTTS
Complemento metodo padrao BeforeTTS
@author brunno.costa
@since 06/06/2019
@version P12
@param oModel     , object    , modelo principal
@param cModelGrade, characters, ID do submodelo de dados
@return Nil
/*/
METHOD xBeforeTTS(oModel, cModelGrade) CLASS PCPGRADE
	Local cIDGrade
	Local oMdlDetail := oModel:GetModel(::cModelDef)
	Local oMdlGrade  := oModel:GetModel(::cModelGrade)
	Local aFields    := oMdlDetail:aHeader
	Local nInd
	Local nIndCol
	Local nOldLineD  := oMdlDetail:GetLine()
	Local nOldLineG  := oMdlGrade:GetLine()

	oMdlGrade:SetNoInsertLine(.F.)
	oMdlGrade:SetNoDeleteLine(.F.)

	//Percorre registros da ::cModelGrade
	For nInd := 1 to oMdlGrade:Length(.F.)
		cIDGrade := oMdlGrade:GetValue(::cFieldID, nInd)
		If !oMdlGrade:IsDeleted(nInd) .AND. !Empty(cIDGrade)
			If oMdlDetail:SeekLine({{::cFieldID, cIDGrade}}, .F., .T.)
				If oMdlDetail:IsUpdated()
					//Atualiza campos conforme conteudo da ::cModelDef
					For nIndCol := 1 to Len(aFields)
						cCampo  := AllTrim(aFields[nIndCol][2])
						If !(cCampo $ "|" + ::cFieldQtd + "|" + ::cFieldProd + "|" + ::cFldUnqKey + "|" + ::cFieldItem );
						   .AND. aFields[nIndCol][10] != "V"
							oMdlGrade:GoLine(nInd)
							If cCampo == ::aFieldOpc[1]
								oMdlGrade:LoadValue(::aFieldOpc[2] , oMdlDetail:GetValue(::aFieldOpc[1]))
							ElseIf cCampo == ::aFieldMOpc[1]
								oMdlGrade:LoadValue(::aFieldMOpc[2], oMdlDetail:GetValue(::aFieldMOpc[1]))
							Else
								oMdlGrade:LoadValue(cCampo, oMdlDetail:GetValue(cCampo))
							EndIf
						EndIf
					Next
				EndIf

			//Exclui registros da ::cModelGrade com ID inexistente na ::cModelDef
			Else
				oMdlGrade:GoLine(nInd)
				oMdlGrade:DeleteLine()
			EndIf
		EndIf

	Next
	oMdlDetail:GoLine(nOldLineD)
	oMdlGrade:GoLine(nOldLineG)

	//Percorre registros da ::cModelDef
	//Deleta registros da grid ::cModelGrade deletados na grid ::cModelDef
	For nInd := 1 to oMdlDetail:Length(.F.)
		cIDGrade := oMdlDetail:GetValue(::cFieldID, nInd)
		If oMdlDetail:IsDeleted(nInd) .AND. !Empty(cIDGrade)
			While oMdlGrade:SeekLine({{::cFieldID, cIDGrade}}, .F., .T.)
				oMdlGrade:DeleteLine()
			EndDo
		EndIf
	Next
	oMdlDetail:GoLine(nOldLineD)
	oMdlGrade:GoLine(nOldLineG)

	//Deleta registros resumidos da grid ::cModelDef referente grade
	//O commit no dos registros originais eh realizado no modelo ::cModelGrade
	For nInd := 1 to oMdlDetail:Length(.F.)
		If !oMdlDetail:IsDeleted(nInd);
			.AND. !Empty(oMdlDetail:GetValue(::cFieldID,nInd))
			oMdlDetail:GoLine(nInd)
			oMdlDetail:DeleteLine()
		EndIf
	Next
	oMdlDetail:GoLine(nOldLineD)
	oMdlGrade:GoLine(nOldLineG)

	oMdlGrade:SetNoInsertLine(.T.)
	oMdlGrade:SetNoDeleteLine(.T.)
Return

/*/{Protheus.doc} xGridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós-validação do Model
Esse evento ocorre uma vez no contexto do modelo principal

@author brunno.costa
@since 06/06/2019
@version P12
@param oSubModel, object    , modelo da grid
@param cModelId , characters, ID do submodelo de dados
@param nLine    , numero    , indica o numero da linha
@return lRet, logico, indicador de validacao do modelo
/*/
METHOD xGridLinePosVld(oSubModel, cModelID, nLine) CLASS PCPGRADE
	Local lRet       := .T.
	If AllTrim(cModelID) == AllTrim(::cModelDef);
	    .AND. Empty(oSubModel:GetValue(::cFieldID, nLine));
		.AND. ::grade(oSubModel:GetValue(::cFieldProd, nLine), .F.)
		lRet := .F.
		Help(' ',1,"Help" ,,STR0014,; //"Linha inválida."
			2,0,,,,,, {STR0015})      //"Informe os itens da grade."
	EndIf
Return lRet

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author brunno.costa
@since 06/06/2019
@version P12
@param 01 - oModel    , object  , modelo de dados
@param 02 - cMdlMaster, caracter, id do modelo master
@return oModel, object, modelo de dados
/*/
Static Function ModelDef(oModel, cMdlMaster)

	Local oEventPad  := PCPGRADEEVDEF():New()
	Local oStrMaster := FWFormStruct(1,"SB4")
	Local oStrDetail := FWFormStruct(1,"SBV")

	Default oModel     := MPFormModel():New('PCPGRADE')
	Default cMdlMaster := Nil

	//Realiza modificacoes nas estruturas dos modelos
	AltStrMdl(@oStrMaster, @oStrDetail)

	//SB4_MASTER - Modelo do campo mestre (Cabeçalho)
	oModel:AddFields("SB4_MASTER", cMdlMaster /*cOwner*/, oStrMaster)
	oModel:GetModel("SB4_MASTER"):SetDescription(STR0006) //"Grade"

	//SVR_DETAIL - Modelo das demandas (Grid)
	oModel:AddGrid("SBV_DETAIL", "SB4_MASTER", oStrDetail)
	oModel:GetModel("SBV_DETAIL"):SetDescription(STR0007) //"Informe as quantidades:"

	//Altera propriedades padrao do modelo
	If !Empty(cMdlMaster)
		oModel:GetModel( "SB4_MASTER" ):SetOptional( .T. )
		oModel:GetModel( "SB4_MASTER" ):SetOnlyQuery()
	EndIf
	oModel:GetModel( "SBV_DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "SBV_DETAIL" ):SetOnlyQuery()
	oModel:GetModel( "SBV_DETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "SBV_DETAIL" ):SetNoInsertLine(.T.)

	//Determina relacionamento padrao
	oModel:SetRelation("SBV_DETAIL",{{"BV_FILIAL", "xFilial('SBV')"},{"BV_TABELA", "B4_LINHA"},{"BV_TIPO", "'1'"}},SBV->(IndexKey(1)))

	//Propriedades do modelo principal
	oModel:SetDescription(STR0002) //"Seleção de itens - Grade do produto:"
	oModel:InstallEvent("PCPGRADEEVDEF", /*cOwner*/, oEventPad)

Return oModel

/*/{Protheus.doc} AltStrMdl
Alterações nas estruturas da Model
@author brunno.costa
@since 06/06/2019
@version P12
@param 01 oStrMaster, object, estrutura do modelo SB4_MASTER
@param 02 oStrDetail, object, estrutura do modelo SVR_DETAIL
@return Nil
/*/
Static Function AltStrMdl(oStrMaster, oStrDetail)

	Local cID
	Local cTitulo

	oStrMaster:AddField(STR0008         ,;	// [01]  C   Titulo do campo  //"Soma seleção:"
	                    STR0008         ,;	// [02]  C   ToolTip do campo //"Soma seleção:"
	                    "nSUM"          ,;	// [03]  C   Id do Field
	                    "N"             ,;	// [04]  C   Tipo do campo
	                    12              ,;	// [05]  N   Tamanho do campo
	                    2               ,;	// [06]  N   Decimal do campo
	                    NIL             ,;	// [07]  B   Code-block de validação do campo
	                    NIL             ,;	// [08]  B   Code-block de validação When do campo
	                    NIL             ,;	// [09]  A   Lista de valores permitido do campo
	                    .F.             ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL             ,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL             ,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL             ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.             )	// [14]  L   Indica se o campo é virtual

	//Adiciona campo chave na grid
	cID     := "cChave"
	cTitulo := "cChave"
	oStrDetail:AddField(cTitulo  ,;	// [01]  C   Titulo do campo  //"Descrição"
						cTitulo  ,;	// [02]  C   ToolTip do campo //"Descrição"
						cID      ,;	// [03]  C   Id do Field
						"C"      ,;	// [04]  C   Tipo do campo
						30       ,;	// [05]  N   Tamanho do campo
						0        ,;	// [06]  N   Decimal do campo
						NIL      ,;	// [07]  B   Code-block de validação do campo
						NIL      ,;	// [08]  B   Code-block de validação When do campo
						NIL      ,;	// [09]  A   Lista de valores permitido do campo
						.F.      ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
						{|| "[" + AllTrim(SBV->BV_CHAVE) + "] " + AllTrim(SBV->BV_DESCRI) }      ,;	// [11]  B   Code-block de inicializacao do campo
						NIL      ,;	// [12]  L   Indica se trata-se de um campo chave
						NIL      ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.      )	// [14]  L   Indica se o campo é virtual

	//Inclui as colunas da grade
	DbSelectArea("SBV")
	SBV->(DbSetOrder(1))
	If SBV->(DbSeek(xFilial("SBV")+SB4->B4_COLUNA))
		While !SBV->(Eof()) .AND. xFilial("SBV")+SB4->B4_COLUNA == SBV->(BV_FILIAL+BV_TABELA)

			cTitulo := "[" + AllTrim(SBV->BV_CHAVE) + "] " + AllTrim(SBV->BV_DESCRI)
			cID     := "COLUNA_" + AllTrim(SBV->BV_CHAVE)

			oStrDetail:AddField(cTitulo  ,;	// [01]  C   Titulo do campo  //"Descrição"
	                            cTitulo  ,;	// [02]  C   ToolTip do campo //"Descrição"
	                            cID      ,;	// [03]  C   Id do Field
	                            "N"      ,;	// [04]  C   Tipo do campo
	                            12       ,;	// [05]  N   Tamanho do campo
	                            2        ,;	// [06]  N   Decimal do campo
	                            NIL      ,;	// [07]  B   Code-block de validação do campo
	                            NIL      ,;	// [08]  B   Code-block de validação When do campo
	                            NIL      ,;	// [09]  A   Lista de valores permitido do campo
	                            .F.      ,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                            NIL      ,;	// [11]  B   Code-block de inicializacao do campo
	                            NIL      ,;	// [12]  L   Indica se trata-se de um campo chave
	                            NIL      ,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                            .T.      )	// [14]  L   Indica se o campo é virtual

			SBV->(DbSkip())
		Enddo
	EndIf

Return Nil

/*/{Protheus.doc} ViewDef
Definição da View
@author brunno.costa
@since 06/06/2019
@version P12
@return oViewPai, object, objeto de View pai
/*/
Static Function ViewDef(oViewPai)
	Local oModel     := FWLoadModel("PCPGRADE")
	Local oStrMaster := FWFormStruct(2,"SB4", {|cCampo| '|'+AllTrim(cCampo)+'|' $ "|B4_COD|B4_DESC|"})
	Local oStrDetail := FWFormStruct(2,"SBV", {|cCampo| '|'+AllTrim(cCampo)+'|' $ "|BV_CHAVE|"})
	Local oView

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)

	//Realiza alteracoes na estrutura dos modelos da View
	AltStrView(@oStrMaster, @oStrDetail, soGrade:nOperation)

	//Seta os modelos na View
	oView:AddField("V_SB4_MASTER", oStrMaster, "SB4_MASTER")
	oView:AddGrid( "V_SBV_DETAIL", oStrDetail, "SBV_DETAIL")

	//Seta quatro colunas no cabecalho
	oView:SetViewProperty( "V_SB4_MASTER", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 4 } )

	//Seta bloqueio para inclusao/exclusao de novas linhas na grid
	oView:SetNoInsertLine("V_SBV_DETAIL")
	oView:SetNoDeletLine("V_SBV_DETAIL")

	//Cria os BOXs para as Views
	oView:CreateHorizontalBox("UPPER" ,  76, , .T.)
	oView:CreateHorizontalBox("BOTTOM", 100)

	//Adiciona um título para a grid.
	oView:EnableTitleView("V_SBV_DETAIL", STR0007) //"Informe as quantidades:"

	//Relaciona cada BOX com sua view
	oView:SetOwnerView("V_SB4_MASTER", "UPPER" )
	oView:SetOwnerView("V_SBV_DETAIL", "BOTTOM")

	//Desabilita o filtro e busca na grid.
	oView:SetViewProperty("V_SBV_DETAIL","GRIDFILTER",{.F.})
	oView:SetViewProperty("V_SBV_DETAIL","GRIDSEEK",{.F.})

	//Seta bloco de execucao para execucao apos ativacao da view
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

Return oView

/*/{Protheus.doc} AfterView
Função executada após ativar a view
@author brunno.costa
@since 06/06/2019
@version P12
@param oView	- Objeto da View.
@return Nil
/*/
Static Function AfterView(oView)
	Local oModel    := oView:GetModel()
	Local oEvent    := gtMdlEvent(oModel, "PCPGRADEEVDEF")
	Local oMdlGrade := soGrade:oMdlRotina:GetModel(soGrade:cModelGrade)
	Local oModelDig := oModel:GetModel("SBV_DETAIL")
	Local nIndLin
	Local oModelDef := soGrade:oMdlRotina:GetModel(soGrade:cModelDef)
	Local cIDGrade  := oModelDef:GetValue(soGrade:cFieldID)
	Local cIDAux
	Local cMascara  := SuperGetMv("MV_MASCGRD")
	Local nTamRef   := Val(Substr(cMascara,1,2))
	Local nTamLin   := Val(Substr(cMascara,4,2))
	Local nTamCol   := Val(Substr(cMascara,7,2))
	Local nQtde
	Local cChvLin
	Local cChvCol
	Local cProduto
	Local lModify   := oModel:lModify
	Local nSUM      := 0

	//Habilita propriedade de execucao com view
	oEvent:lViewGrade   := .T.
	oEvent:lExecGrdLine := .T.

	//Atualiza valores da GRID - Percorre modelo de gravacao da grade
	For nIndLin := 1 to oMdlGrade:Length(.F.)
		If !oMdlGrade:IsDeleted(nIndLin)
			cIDAux := oMdlGrade:GetValue(soGrade:cFieldID, nIndLin)
			If cIDGrade == cIDAux
				cProduto := oMdlGrade:GetValue(soGrade:cFieldProd, nIndLin)
				cChvLin  := Substring(cProduto, nTamRef + 1, nTamLin)
				cChvCol  := Substring(cProduto, nTamRef + nTamLin + 1, nTamCol)
				cColuna  := "COLUNA_" + cChvCol
				If oModelDig:SeekLine({{"BV_CHAVE", cChvLin}}, .F., .T.)
					nQtde := oMdlGrade:GetValue(soGrade:cFieldQtd, nIndLin)
					oModelDig:LoadValue(cColuna, nQtde)
					nSUM  += nQtde
				EndIf
			EndIf
		EndIf
	Next
	oModelDig:GoLine(1)

	//Atualiza valor total
	oModel:GetModel("SB4_MASTER"):LoadValue("nSUM"  , nSUM)

	//Refresh
	oView:Refresh("V_SBV_DETAIL")
	oView:Refresh("V_SB4_MASTER")

	oModel:lModify := lModify

Return

/*/{Protheus.doc} AltStrView
Alterações nas estruturas da View
@author brunno.costa
@since 06/06/2019
@version P12
@param 01 oStrMaster, object, estrutura do modelo SB4_MASTER
@param 02 oStrDetail, object, estrutura do modelo SVR_DETAIL
@param 03 nOperation, numero, identificador do tipo de operacao: OP_ALTERAR, OP_VISUALIZAR...
@return Nil
/*/
Static Function AltStrView(oStrMaster, oStrDetail, nOperation)

	Local cOrdem     := "01"
	Local lVisualiza := nOperation == OP_VISUALIZAR

	//Remove campo padrao
	oStrDetail:RemoveField("BV_CHAVE")

	//Altera titulo dos campos
	oStrMaster:SetProperty("B4_COD"  , MVC_VIEW_TITULO, STR0010) //"Código Grade:"
	oStrMaster:SetProperty("B4_DESC" , MVC_VIEW_TITULO, STR0011) //"Descrição da grade:"

	//Bloqueia edicao de campos
	oStrMaster:SetProperty("B4_DESC"  , MVC_VIEW_CANCHANGE, .F.)

	//Altera ordem dos campos
	oStrMaster:SetProperty("B4_COD"   , MVC_VIEW_ORDEM, "01")
	oStrMaster:SetProperty("B4_DESC"  , MVC_VIEW_ORDEM, "02")

	//Retira o campo VR_INTMRP da View, e cria um campo virtual para exibir a legenda.
	oStrMaster:AddField("nSUM"              ,;	// [01]  C   Nome do Campo
	                    "03"                ,;	// [02]  C   Ordem
	                    STR0008             ,;	// [03]  C   Titulo do campo    //"Soma seleção:"
	                    STR0008             ,;	// [04]  C   Descricao do campo //"Soma seleção:"
	                    NIL                 ,;	// [05]  A   Array com Help
	                    "N"                 ,;	// [06]  C   Tipo do campo
	                    "@S10 999999999.99" ,;	// [07]  C   Picture
	                    NIL                 ,;	// [08]  B   Bloco de Picture Var
	                    NIL                 ,;	// [09]  C   Consulta F3
	                    .F.                 ,;	// [10]  L   Indica se o campo é alteravel
	                    NIL                 ,;	// [11]  C   Pasta do campo
	                    NIL                 ,;	// [12]  C   Agrupamento do campo
	                    NIL                 ,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                 ,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                 ,;	// [15]  C   Inicializador de Browse
	                    .T.                 ,;	// [16]  L   Indica se o campo é virtual
	                    NIL                 ,;	// [17]  C   Picture Variavel
	                    NIL                 ) 	// [18]  L   Indica pulo de linha após o campo


	//Monta titulo do campo chave da linha
	If SBV->(DbSeek(xFilial("SBV")+SB4->B4_LINHA))
		cTitulo := AllTrim(SBV->BV_DESCTAB)
	EndIf
	cTitulo += " \ "
	If SBV->(DbSeek(xFilial("SBV")+SB4->B4_COLUNA))
		cTitulo += AllTrim(SBV->BV_DESCTAB)
	EndIf

	//Adiciona campo chave da linha
	oStrDetail:AddField("cChave"            ,;	// [01]  C   Nome do Campo
						"01"                ,;	// [02]  C   Ordem
						cTitulo             ,;	// [03]  C   Titulo do campo    //"Descrição"
						cTitulo             ,;	// [04]  C   Descricao do campo //"Descrição"
						NIL                 ,;	// [05]  A   Array com Help
						"C"                 ,;	// [06]  C   Tipo do campo
						""                  ,;	// [07]  C   Picture
						NIL                 ,;	// [08]  B   Bloco de Picture Var
						NIL                 ,;	// [09]  C   Consulta F3
						.F.                 ,;	// [10]  L   Indica se o campo é alteravel
						NIL                 ,;	// [11]  C   Pasta do campo
						NIL                 ,;	// [12]  C   Agrupamento do campo
						NIL                 ,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL                 ,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL                 ,;	// [15]  C   Inicializador de Browse
						.T.                 ,;	// [16]  L   Indica se o campo é virtual
						NIL                 ,;	// [17]  C   Picture Variavel
						NIL                 ) 	// [18]  L   Indica pulo de linha após o campo

	//Altera largura dos campos
	oStrMaster:SetProperty("B4_COD"  , MVC_VIEW_PICT , "@S15")
	oStrMaster:SetProperty("B4_DESC" , MVC_VIEW_PICT , "@S50")
	oStrDetail:SetProperty("cChave"  , MVC_VIEW_WIDTH, 150   )

	//Adiciona colunas da grade
	DbSelectArea("SBV")
	SBV->(DbSetOrder(1))
	If SBV->(DbSeek(xFilial("SBV")+SB4->B4_COLUNA))
		While !SBV->(Eof()) .AND. xFilial("SBV")+SB4->B4_COLUNA == SBV->(BV_FILIAL+BV_TABELA)

			cTitulo := "[" + AllTrim(SBV->BV_CHAVE) + "] " + AllTrim(SBV->BV_DESCRI)
			cID     := "COLUNA_" + AllTrim(SBV->BV_CHAVE)
			cOrdem  := Soma1(cOrdem)

			oStrDetail:AddField(cID                 ,;	// [01]  C   Nome do Campo
								cOrdem              ,;	// [02]  C   Ordem
								cTitulo             ,;	// [03]  C   Titulo do campo    //"Descrição"
								cTitulo             ,;	// [04]  C   Descricao do campo //"Descrição"
								NIL                 ,;	// [05]  A   Array com Help
								"N"                 ,;	// [06]  C   Tipo do campo
								"@S10 999999999.99" ,;	// [07]  C   Picture
								NIL                 ,;	// [08]  B   Bloco de Picture Var
								NIL                 ,;	// [09]  C   Consulta F3
								!lVisualiza         ,;	// [10]  L   Indica se o campo é alteravel
								NIL                 ,;	// [11]  C   Pasta do campo
								NIL                 ,;	// [12]  C   Agrupamento do campo
								NIL                 ,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL                 ,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL                 ,;	// [15]  C   Inicializador de Browse
								.T.                 ,;	// [16]  L   Indica se o campo é virtual
								NIL                 ,;	// [17]  C   Picture Variavel
								NIL                 ) 	// [18]  L   Indica pulo de linha após o campo

			SBV->(DbSkip())
		Enddo
	EndIf

Return Nil

/*/{Protheus.doc} AltStrView
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 06/06/2019
@version P12
@param oModel  , Object   , Modelo de dados
@param cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent , Object   , Referência do evento do modelo de dados.
/*/
Static Function gtMdlEvent(oModel, cIdEvent)
	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent