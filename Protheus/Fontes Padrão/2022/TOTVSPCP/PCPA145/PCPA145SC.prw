#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145DEF.ch"

Static __LenNumSC := GetSx3Cache("C1_NUM" ,"X3_TAMANHO")
Static __LenItem  := GetSx3Cache("C1_ITEM","X3_TAMANHO")
Static __UserGrup := UsrRetGrp()
Static __oGrupCmp := JsonObject():New()
Static __oFilSC1  := JsonObject():New()
Static __oParam   := JsonObject():New()

/*/{Protheus.doc} PCPA145SC
Função para geração das solicitações de compra

@type Function
@author marcelo.neumann
@since 15/11/2019
@version P12.1.27
@param 01 oProcesso , Object   , Instância da classe ProcessaDocumentos
@param 02 aDados    , Array    , Array com as informações do rastreio que serão processados.
                                 As posições deste array são acessadas através das constantes iniciadas
                                 com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param 03 cDocPaiERP, Character, Código do documento pai deste registro
@param 04 cObs      , Character, Obervação a ser gravada na SC1, no campo C1_OBS
@param 05 cNumScUni , Character, Número da SC quando parametrizado para ter numeração única (oProcesso:cIncSC == "1")
@param 06 cItemSC   , Character, Item da SC criada. Retorna a informação por referência.
@return   cNumSolic , Character, Número da solicitação de compra incluída

/*/
Function PCPA145SC(oProcesso, aDados, cDocPaiERP, cObs, cNumScUni, cItemSC)

	Local cGrpCompra := ""
	Local cNumOP     := " "
	Local cNumSolic  := BuscaNumSC(oProcesso, cNumScUni, @cItemSC)
	Local cTicket    := oProcesso:cTicket
	Local cTipoOp    := oProcesso:getTipoDocumento(aDados[RASTREIO_POS_DATA_ENTREGA], "SC")
	Local cLocal     := aDados[RASTREIO_POS_LOCAL]
	Local lAtuEstPCP := .F.

	Default cObs     := " "

	If __oGrupCmp[aDados[RASTREIO_POS_PRODUTO]] == Nil
		__oGrupCmp[aDados[RASTREIO_POS_PRODUTO]] := MaRetComSC(aDados[RASTREIO_POS_PRODUTO], __UserGrup, oProcesso:cCodUsr)
	EndIf

	If __oFilSC1[cFilAnt] == Nil
		__oFilSC1[cFilAnt] := xFilial("SC1")
		__oParam["MV_GRVLOCP"+cFilAnt] := SuperGetMV("MV_GRVLOCP", .F., .T.)
	EndIf

	cGrpCompra := __oGrupCmp[aDados[RASTREIO_POS_PRODUTO]]

	//Posiciona no produto
	If SB1->B1_COD != aDados[RASTREIO_POS_PRODUTO] .Or. SB1->B1_FILIAL != xFilial("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + aDados[RASTREIO_POS_PRODUTO]))
	EndIf

	If SB1->B1_APROPRI == "I" .And. __oParam["MV_GRVLOCP"+cFilAnt]
		cLocal := oProcesso:getLocProcesso()
	EndIf

	//Se não gera os documentos aglutinados, busca o número da OP Pai para gerar o C1_OP
	If !oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
		cNumOP := cDocPaiERP
	EndIf

	//Inicializa a gravacao dos lancamentos do SIGAPCO
	PcoIniLan("000051")

	//Inclui o registro
	RecLock("SC1",.T.)
		SC1->C1_FILIAL  := __oFilSC1[cFilAnt]
		SC1->C1_NUM     := cNumSolic
		SC1->C1_ITEM    := cItemSC
		SC1->C1_TPOP    := cTipoOp
		SC1->C1_OP      := cNumOP
		SC1->C1_GRUPCOM := cGrpCompra
		SC1->C1_SEQMRP  := cTicket
		SC1->C1_USER    := oProcesso:cCodUsr
		SC1->C1_EMISSAO := dDataBase
		SC1->C1_PRODUTO := aDados[RASTREIO_POS_PRODUTO]
		SC1->C1_LOCAL   := cLocal
		SC1->C1_QUANT   := aDados[RASTREIO_POS_NECESSIDADE]
		SC1->C1_QTDORIG := aDados[RASTREIO_POS_NECESSIDADE]
		SC1->C1_QTSEGUM := oProcesso:ConvUm(aDados[RASTREIO_POS_PRODUTO], aDados[RASTREIO_POS_NECESSIDADE], 0, 2)
		SC1->C1_DATPRF  := aDados[RASTREIO_POS_DATA_ENTREGA]
		SC1->C1_CC      := SB1->B1_CC
		SC1->C1_UM      := SB1->B1_UM
		SC1->C1_DESCRI  := SB1->B1_DESC
		SC1->C1_FORNECE := SB1->B1_PROC
		SC1->C1_CONTA   := SB1->B1_CONTA
		SC1->C1_SEGUM   := SB1->B1_SEGUM
		SC1->C1_IMPORT  := SB1->B1_IMPORT
		SC1->C1_LOJA    := SB1->B1_LOJPROC
		SC1->C1_COTACAO := If(SB1->B1_IMPORT == "S", "IMPORT", "")
		SC1->C1_FILENT  := xFilEnt(If(Empty(C1_FILENT), C1_FILIAL, C1_FILENT))
		SC1->C1_TIPCOM  := MRetTipCom( , .T., "SC")
		SC1->C1_SOLICIT := oProcesso:getUserName()
		SC1->C1_OBS     := cObs
		SC1->C1_RATEIO  := "2"
		SC1->C1_TIPO    := 1
		SC1->C1_ORIGEM  := "PCPA144"
	SC1->(MsUnlock())

	//Rotina de avaliação dos eventos de uma solicitação de compra (COMXFUN)
	MaAvalSC("SC1",1,/*03*/,/*04*/,/*05*/,/*06*/,/*07*/,/*08*/,/*09*/,.T.,@lAtuEstPCP)

	//Finaliza a gravacao dos lancamentos do SIGAPCO
	PcoFinLan("000051")
	PcoFreeBlq("000051")

	If lAtuEstPCP
		//Atualiza tabela temporária para atualização de estoques
		oProcesso:atualizaSaldo(aDados[RASTREIO_POS_PRODUTO]    ,;
		                        cLocal                          ,;
		                        aDados[RASTREIO_POS_NIVEL]      ,;
		                        aDados[RASTREIO_POS_NECESSIDADE],;
		                        1                               ,; //Tipo 1 = Entrada
		                        IIF(cTipoOp == "P",.T.,.F.)     ,; //Documento Previsto
		                        cFilAnt                          )
	EndIf

Return cNumSolic

/*/{Protheus.doc} BuscaNumSC
Busca o número e item da Solicitação de Compra

@type Static Function
@author marcelo.neumann
@since 15/11/2019
@version P12.1.27
@param  01 oProcesso, Object   , Instância da classe ProcessaDocumentos
@param  02 cNumScUni, Character, Número da SC quando parametrizado para ter numeração única (oProcesso:cIncSC == "1")
@param  03 cItem    , Character, sequência do item para a solcitação de compra (referência)
@return cNumSolic, Character, número da próxima solicitação de compra
/*/
Static Function BuscaNumSC(oProcesso,cNumScUni,cItem)

	Local cAlias    := ""
	Local cNumSolic := ""

	If oProcesso:cIncSC == "2"

		cNumSolic := GetNumSC1(.T.)
		If Empty(cNumSolic)
			cAlias := GetNextAlias()

			//Busca a última numeração da tabela
			BeginSql Alias cAlias
				SELECT MAX(C1_NUM) MAX_NUM
				FROM %Table:SC1%
				WHERE C1_FILIAL = %xfilial:SC1%
				AND %NotDel%
			EndSql

			//Se não existe registro na tabela, usa a numeração "000001"
			If (cAlias)->(Eof())
				cNumSolic := StrZero(1, __LenNumSC)
			Else
				cNumSolic := Soma1((cAlias)->MAX_NUM)
			EndIf
		EndIf

		cItem := StrZero(1, __LenItem)
	Else
		//Busca número único da SC, que foi reservado no NEW do PCPA145
		cNumSolic := cNumScUni
		cItem     := prxItemSc(cNumSolic,oProcesso)
	EndIf
	


Return cNumSolic

/*/{Protheus.doc} prxItemSc
Retorna o próximo item válido para utilização na geração da tabela SC1

@type  Static Function
@author renan.roeder
@since 28/05/2020
@version P12.1.30
@param cChaveSC , Character, Chave identificadora da SC (C1_NUM)
@param oProcesso, Object   , Referência da classe de controle do processamento
@return cItem   , Character, Próximo item para utilização na geração da tabela SC1
/*/
Static Function prxItemSc(cChaveSC, oProcesso)
	Local cItem  := ""
	Local lRet   := .T.

	cChaveSC := "ITEMSC" + cChaveSC + cFilAnt

	//Abre transação na chave da OP
	VarBeginT(oProcesso:cUIDGlobal, cChaveSC )

	//Recupera o valor atual da sequência desta OP
	lRet := VarGetXD(oProcesso:cUIDGlobal, cChaveSC, @cItem)
	If !lRet
		//Não encontrou a chave. Inicializa.
		cItem := StrZero(1, __LenItem)
	Else
		//Encontrou a chave, incrementa a sequência
		cItem := Soma1(cItem)
	EndIf

	//Atualiza a global com a última sequência
	lRet := VarSetXD(oProcesso:cUIDGlobal, cChaveSC, cItem)

	//Fecha a transação da chave da OP
	VarEndT(oProcesso:cUIDGlobal, cChaveSC)

Return cItem
