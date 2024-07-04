#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.ch"
#INCLUDE "PCPA145DEF.ch"

Static _cFunName    := "PCPA144"
Static _lGeraSHY    := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. ;
                       (ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")) .Or. ;
                       SuperGetMV("MV_PCPATOR",.F.,.F.) == .T.
Static _nDiasOci    := SuperGetMV("MV_DIASOCI",.F.,99)
Static _nTamNumOP   := GetSX3Cache("C2_NUM"   , "X3_TAMANHO")
Static _nTamItmOP   := GetSX3Cache("C2_ITEM"  , "X3_TAMANHO")
Static _nTamSeqOP   := GetSX3Cache("C2_SEQUEN", "X3_TAMANHO")
Static _nTamRot     := GetSX3Cache("G2_CODIGO", "X3_TAMANHO")
Static _oCacheIni   := JsonObject():New()
Static _oParam      := JsonObject():New()

/*/{Protheus.doc} PCPA145OP
Função para geração das ordens de produção.

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param 01 oProcesso , Object, Instância da classe ProcessaDocumentos
@param 02 aDados    , Array    , Array com as informações do rastreio que serão processados.
                                 As posições deste array são acessadas através das constantes iniciadas
                                 com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param 03 cDocPaiERP, Character, Código do documento pai deste registro.
@return Nil
/*/
Function PCPA145OP(oProcesso, aDados, cDocPaiERP)

	Local aOPC       := {}
	Local cC2MOPC    := " "
	Local cField     := " "
	Local cItemOp    := " "
	Local cNumOp     := " "
	Local cOPGerada  := " " //"XXXXXXX" + aDados[RASTREIO_POS_DOCFILHO]
	Local cRoteiro   := " "
	Local cRotSB1    := " "
	Local cTicket    := oProcesso:cTicket
	Local cTipoOp    := oProcesso:getTipoDocumento(aDados[RASTREIO_POS_DATA_ENTREGA], "OP")
	Local cSeqOp     := " "
	Local cSeqPai    := " "
	Local cLocal     := aDados[RASTREIO_POS_LOCAL]
	Local lAglutina  := oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
	Local nTotal     := 0
	Local nX         := 0
	Local nQtdSegUM  := 0
	Local oJson

	If !_oParam:HasProperty("MV_OPIPROC"+cFilAnt)
		_oParam["MV_OPIPROC"+cFilAnt] := SuperGetMV("MV_OPIPROC", .F., .T.)
	EndIf

	//Gera a numeração da OP:
	//Se aglutina ou o documento pai é branco, busca numeração nova, caso contrário, incrementa a sequencia.
	If lAglutina .Or. Empty(cDocPaiERP)
		If oProcesso:cIncOP == "2"
			//Busca numeração da OP
			If oProcesso:usaNumOpPadrao(cFilAnt)
				cNumOp := GetNumSC2(.T.)
			Else
				cNumOp := oProcesso:incDocUni("C2_NUM", cFilAnt)
			EndIf
		Else
			//Busca número único da OP, que foi reservado no NEW do PCPA145
			cNumOp := oProcesso:getDocUni("C2_NUM", cFilAnt)
		EndIf

		//Incrementa o item da OP
		cItemOp := prxItemOp(@cNumOp, oProcesso)

		//Incrementa a sequencia da OP
		cSeqOp  := proximaSeq(cNumOp+cItemOp, oProcesso)

		cSeqPai := Space(_nTamSeqOP)

		//Concatena para guardar a numeração completa
		cOPGerada := cNumOp + cItemOp + cSeqOp + "   "
	Else
		//Busca número da OP do documento pai gerado
		cNumOp := Left(cDocPaiERP, _nTamNumOP)

		//Grava o item
		cItemOp := SubStr(cDocPaiERP, _nTamNumOP + 1, _nTamItmOP)

		//A sequencia será extraída do documento que o MRP gerou
		cSeqOp := proximaSeq(cNumOp+cItemOp, oProcesso)

		//Concatena para guardar a numeração completa
		cOPGerada := cNumOp + cItemOp + cSeqOp + "   "

		//Busca SEQPAI usado na geração da ordem pai
		cSeqPai := Substr(cDocPaiERP, _nTamNumOP+_nTamItmOP+1, _nTamSeqOP)
	EndIf

	//Posiciona na SB1
	If SB1->B1_COD != aDados[RASTREIO_POS_PRODUTO] .Or. SB1->B1_FILIAL != xFilial("SB1")
		SB1->(dbSeek(xFilial("SB1")+aDados[RASTREIO_POS_PRODUTO]))
	EndIf

	If SB1->B1_APROPRI == "I" .And. _oParam["MV_OPIPROC"+cFilAnt]  .And. AllTrim(aDados[RASTREIO_POS_TIPODOC]) == "OP"
		cLocal := oProcesso:getLocProcesso()
	EndIf

	//Recupera Roteiro do produto
	cRotSB1 := SB1->B1_OPERPAD

	If Empty(aDados[RASTREIO_POS_ROTEIRO_DOCUMENTO_FILHO])
		aDados[RASTREIO_POS_ROTEIRO_DOCUMENTO_FILHO] := cRotSB1
	EndIf

	//Recupera informações de opcional
	If !Empty(aDados[RASTREIO_POS_OPC_ID])
		If "|"$aDados[RASTREIO_POS_OPC_ID]
            aDados[RASTREIO_POS_OPC_ID] := Left(aDados[RASTREIO_POS_OPC_ID], (At("|", aDados[RASTREIO_POS_OPC_ID])-1) )
        EndIf
		aOPC    := MrpGetOPC(cFilAnt, cTicket, aDados[RASTREIO_POS_OPC_ID])
		oJson   := JsonObject():New()
        oJson:fromJson(aOPC[2])
		cC2MOPC := Array2STR(oJson["optionalMemo"], .F.)
	EndIf

	nQtdSegUM := oProcesso:ConvUm(aDados[RASTREIO_POS_PRODUTO],aDados[RASTREIO_POS_NECESSIDADE],0,2)

	//Inicia a inclusão
	RecLock("SC2",.T.)

		//Gravando inicializador padrão dos campos de usuario
		nTotal := FCount()
		For nX := 1 TO nTotal
			cField := Field(nX)
			If _oCacheIni[cField] == Nil
				If (cField $ "C2_NUM/C2_ITEM/C2_SEQUEN") .Or. !ExistIni(cField, .F.)
					_oCacheIni[cField] := {.F., "", ""}
				Else
					_oCacheIni[cField] := {.T., GetSx3Cache(cField,"X3_RELACAO"), X3Titulo()}
				EndIf
			EndIf

			If _oCacheIni[cField][1]
				SC2->&(cField) := InitPad(_oCacheIni[cField][2], _oCacheIni[cField][3])
			EndIf
		Next nX

		//Dados da numeração da OP
		Replace	C2_FILIAL  With xFilial("SC2")
		Replace	C2_NUM     With cNumOp
		Replace	C2_ITEM    With cItemOp
		Replace	C2_SEQUEN  With cSeqOp
		Replace C2_ITEMGRD With "  "
		Replace C2_OP      With cOPGerada

		//Dados vindo da API
		Replace	C2_DATPRF  With aDados[RASTREIO_POS_DATA_ENTREGA            ]
		Replace	C2_DATPRI  With aDados[RASTREIO_POS_DATA_INICIO             ]
		Replace	C2_LOCAL   With cLocal
		Replace C2_PRODUTO With aDados[RASTREIO_POS_PRODUTO                 ]
		Replace	C2_QUANT   With aDados[RASTREIO_POS_NECESSIDADE             ]
		Replace C2_REVISAO With aDados[RASTREIO_POS_REVISAO                 ]
		Replace	C2_ROTEIRO With aDados[RASTREIO_POS_ROTEIRO_DOCUMENTO_FILHO ]

		//Dados vindo da SB1
		Replace	C2_CC      With SB1->B1_CC
		Replace	C2_SEGUM   With SB1->B1_SEGUM
		Replace	C2_UM      With SB1->B1_UM

		//Dados fixos
		Replace C2_BATCH    With "S"
		Replace C2_BLQAPON  With "2"
		Replace	C2_DESTINA  With "E"
		Replace C2_GRADE    With " "
		Replace	C2_IDENT    With "P"
		Replace	C2_ITEMPV   With " "

		If !Empty(aDados[RASTREIO_POS_OPC_ID])
			Replace C2_MOPC     With cC2MOPC
			Replace	C2_OPC      With oJson["optionalString"]
		Else
			Replace C2_MOPC     With " "
			Replace	C2_OPC      With " "
		EndIf

		Replace	C2_PEDIDO   With " "
		Replace	C2_PRIOR    With "500"

		//Dados diversos
		Replace C2_BATROT   With _cFunName
		Replace C2_BATUSR   With oProcesso:cCodUsr
		Replace C2_DIASOCI  With _nDiasOci
		Replace	C2_EMISSAO  With dDataBase
		Replace	C2_QTSEGUM  With nQtdSegUM
		Replace C2_SEQMRP   With cTicket
		Replace	C2_SEQPAI   With cSeqPai
		Replace C2_TPOP     With cTipoOp

	SC2->(MsUnLock())

	//Verifica roteiro para geração da SHY
	If _lGeraSHY
		If Empty(cRoteiro := SC2->C2_ROTEIRO)
			If Empty(cRoteiro := cRotSB1)
				cRoteiro := StrZero(1, _nTamRot)
			EndIf
		EndIf

		//Gera a SHY
		TAPSOperac(cOPGerada,aDados[RASTREIO_POS_PRODUTO],cRoteiro,aDados[RASTREIO_POS_NECESSIDADE])
	EndIf

	//Salva em memória o roteiro utilizado nesta OP, para reutilização posterior na gravação dos empenhos.
	oProcesso:setDadosOP(cFilAnt, cOPGerada, aDados[RASTREIO_POS_PRODUTO], aDados[RASTREIO_POS_ROTEIRO_DOCUMENTO_FILHO], cTipoOp, aDados[RASTREIO_POS_DATA_INICIO])

	//Inclui dados no array para integração com o novo MRP
	//O envio das ordens será feito somente no fim do processamento, na função PCPA145INT
	salvaOPInt(oProcesso)

	//Após a geração de uma ordem de produção, deve ser atualizado o
	//DE-PARA de documentos do MRP.
	oProcesso:atualizaDeParaDocumentoProduto(aDados[RASTREIO_POS_DOCFILHO], {cOPGerada,aDados[RASTREIO_POS_PRODUTO]}, cFilAnt)

	//Atualiza tabela temporária para atualização de estoques
	oProcesso:atualizaSaldo(aDados[RASTREIO_POS_PRODUTO]    ,;
	                        cLocal                          ,;
	                        aDados[RASTREIO_POS_NIVEL]      ,;
	                        aDados[RASTREIO_POS_NECESSIDADE],;
	                        1                               ,; //Tipo 1 = Entrada
	                        IIF(cTipoOp == "P",.T.,.F.)     ,; //Documento Previsto
	                        cFilAnt                          )
Return cOPGerada

/*/{Protheus.doc} proximaSeq
Retorna a próxima sequência válida para utilização na geração da tabela SC2

@type  Static Function
@author lucas.franca
@since 17/12/2019
@version P12.1.28
@param cChaveOP , Character, Chave identificadora da OP (C2_NUM+C2_ITEM)
@param oProcesso, Object   , Referência da classe de controle do processamento
@return cSequen , Character, Próxima sequência para utilização na geração da tabela SC2
/*/
Static Function proximaSeq(cChaveOP, oProcesso)
	Local cSequen  := ""
	Local lRet     := .T.

	cChaveOP := "SEQOP" + cChaveOP + cFilAnt

	//Abre transação na chave da OP
	VarBeginT(oProcesso:cUIDGlobal, cChaveOP )

	//Recupera o valor atual da sequência desta OP
	lRet := VarGetXD(oProcesso:cUIDGlobal, cChaveOP, @cSequen)
	If !lRet
		//Não encontrou a chave. Inicializa.
		cSequen := StrZero(1, _nTamSeqOP)
	Else
		//Encontrou a chave, incrementa a sequência
		cSequen := Soma1(cSequen)
	EndIf

	//Atualiza a global com a última sequência
	lRet := VarSetXD(oProcesso:cUIDGlobal, cChaveOP, cSequen)

	//Fecha a transação da chave da OP
	VarEndT(oProcesso:cUIDGlobal, cChaveOP)

Return cSequen

/*/{Protheus.doc} prxItemOp
Retorna o próximo item válido para utilização na geração da tabela SC2

@type  Static Function
@author ricardo.prandi
@since 22/04/2020
@version P12.1.30
@param cNumOp   , Character, Número da OP (C2_NUM)
@param oProcesso, Object   , Referência da classe de controle do processamento
@return cItem   , Character, Próximo item para utilização na geração da tabela SC2
/*/
Static Function prxItemOp(cNumOp, oProcesso)
	Local aOpItem   := {}
	Local cItem     := ""
	Local lRet      := .T.
	Local cItemMax  := PadR("", _nTamItmOP,"9")

	If oProcesso:cIncOP == "2"
		cItem := PadR("01", _nTamItmOP)
	Else
		cChaveOP := "ITEMOP" + cFilAnt

		//Abre transação na chave da OP
		VarBeginT(oProcesso:cUIDGlobal, cChaveOP )

		//Recupera o valor atual da sequência desta OP
		lRet := VarGetAD(oProcesso:cUIDGlobal, cChaveOP, @aOpItem)
		If !lRet
			//Não encontrou a chave. Inicializa.
			cItem := StrZero(1, _nTamItmOP)
		Else
			//Encontrou a chave, incrementa a sequência
			cNumOp := aOpItem[DOC_NUM]
			cItem  := Soma1(aOpItem[DOC_ITEM])

			If cItem > cItemMax
				cNumOp := oProcesso:incDocUni("C2_NUM", cFilAnt)
				cItem := StrZero(1, _nTamItmOP)
			EndIf
		EndIf

		aOpItem := {cNumOp,cItem}

		//Atualiza a global com a última sequência
		lRet := VarSetAD(oProcesso:cUIDGlobal, cChaveOP, aOpItem)

		//Fecha a transação da chave da OP
		VarEndT(oProcesso:cUIDGlobal, cChaveOP)
	EndIf

Return cItem

/*/{Protheus.doc} salvaOPInt
Salva em memória os dados da OP posicionada na tabela SC2 para integrar posteriormente.

@type Method
@author marcelo.neumann
@since 30/08/2021
@version P12
@param oProcesso, objeto, instância da classe ProcessaDocumentos
@return Nil
/*/
Static Function salvaOPInt(oProcesso)
	Local aDados := {}
	Local cRecno := 0

	If !oProcesso:lIntegraOP
		Return
	EndIf

	cRecno := Str(SC2->(Recno()))

	If oProcesso:aIntegra[INTEGRA_OP_MRP]
		//Gera os dados da OP posicionada na SC2
		A650AddInt(@aDados)
	EndIf

	//Salva na seção global de ordens a integrar.
	If !VarSetAD(oProcesso:cUIDIntOP, cRecno, {aDados, cFilAnt})
		oProcesso:msgLog(STR0019 + cRecno)  //"Não conseguiu adicionar op para integrar com o MRP. "
	EndIf

	aSize(aDados, 0)

Return
