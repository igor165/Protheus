#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145DEF.ch"

Static __LenNumSC := GetSx3Cache("C1_NUM" ,"X3_TAMANHO")
Static __LenItem  := GetSx3Cache("C1_ITEM","X3_TAMANHO")
Static __UserGrup := UsrRetGrp()
Static __oGrupCmp := JsonObject():New()
Static __oFilSC1  := JsonObject():New()
Static __oParam   := JsonObject():New()

/*/{Protheus.doc} PCPA145SC
Fun��o para gera��o das solicita��es de compra

@type Function
@author marcelo.neumann
@since 15/11/2019
@version P12.1.27
@param 01 oProcesso , Object   , Inst�ncia da classe ProcessaDocumentos
@param 02 aDados    , Array    , Array com as informa��es do rastreio que ser�o processados.
                                 As posi��es deste array s�o acessadas atrav�s das constantes iniciadas
                                 com o nome RASTREIO_POS. Estas constantes est�o definidas no arquivo PCPA145DEF.ch
@param 03 cDocPaiERP, Character, C�digo do documento pai deste registro
@param 04 cObs      , Character, Oberva��o a ser gravada na SC1, no campo C1_OBS
@param 05 cNumScUni , Character, N�mero da SC quando parametrizado para ter numera��o �nica (oProcesso:cIncSC == "1")
@param 06 cItemSC   , Character, Item da SC criada. Retorna a informa��o por refer�ncia.
@return   cNumSolic , Character, N�mero da solicita��o de compra inclu�da

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

	//Se n�o gera os documentos aglutinados, busca o n�mero da OP Pai para gerar o C1_OP
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

	//Rotina de avalia��o dos eventos de uma solicita��o de compra (COMXFUN)
	MaAvalSC("SC1",1,/*03*/,/*04*/,/*05*/,/*06*/,/*07*/,/*08*/,/*09*/,.T.,@lAtuEstPCP)

	//Finaliza a gravacao dos lancamentos do SIGAPCO
	PcoFinLan("000051")
	PcoFreeBlq("000051")

	If lAtuEstPCP
		//Atualiza tabela tempor�ria para atualiza��o de estoques
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
Busca o n�mero e item da Solicita��o de Compra

@type Static Function
@author marcelo.neumann
@since 15/11/2019
@version P12.1.27
@param  01 oProcesso, Object   , Inst�ncia da classe ProcessaDocumentos
@param  02 cNumScUni, Character, N�mero da SC quando parametrizado para ter numera��o �nica (oProcesso:cIncSC == "1")
@param  03 cItem    , Character, sequ�ncia do item para a solcita��o de compra (refer�ncia)
@return cNumSolic, Character, n�mero da pr�xima solicita��o de compra
/*/
Static Function BuscaNumSC(oProcesso,cNumScUni,cItem)

	Local cAlias    := ""
	Local cNumSolic := ""

	If oProcesso:cIncSC == "2"

		cNumSolic := GetNumSC1(.T.)
		If Empty(cNumSolic)
			cAlias := GetNextAlias()

			//Busca a �ltima numera��o da tabela
			BeginSql Alias cAlias
				SELECT MAX(C1_NUM) MAX_NUM
				FROM %Table:SC1%
				WHERE C1_FILIAL = %xfilial:SC1%
				AND %NotDel%
			EndSql

			//Se n�o existe registro na tabela, usa a numera��o "000001"
			If (cAlias)->(Eof())
				cNumSolic := StrZero(1, __LenNumSC)
			Else
				cNumSolic := Soma1((cAlias)->MAX_NUM)
			EndIf
		EndIf

		cItem := StrZero(1, __LenItem)
	Else
		//Busca n�mero �nico da SC, que foi reservado no NEW do PCPA145
		cNumSolic := cNumScUni
		cItem     := prxItemSc(cNumSolic,oProcesso)
	EndIf
	


Return cNumSolic

/*/{Protheus.doc} prxItemSc
Retorna o pr�ximo item v�lido para utiliza��o na gera��o da tabela SC1

@type  Static Function
@author renan.roeder
@since 28/05/2020
@version P12.1.30
@param cChaveSC , Character, Chave identificadora da SC (C1_NUM)
@param oProcesso, Object   , Refer�ncia da classe de controle do processamento
@return cItem   , Character, Pr�ximo item para utiliza��o na gera��o da tabela SC1
/*/
Static Function prxItemSc(cChaveSC, oProcesso)
	Local cItem  := ""
	Local lRet   := .T.

	cChaveSC := "ITEMSC" + cChaveSC + cFilAnt

	//Abre transa��o na chave da OP
	VarBeginT(oProcesso:cUIDGlobal, cChaveSC )

	//Recupera o valor atual da sequ�ncia desta OP
	lRet := VarGetXD(oProcesso:cUIDGlobal, cChaveSC, @cItem)
	If !lRet
		//N�o encontrou a chave. Inicializa.
		cItem := StrZero(1, __LenItem)
	Else
		//Encontrou a chave, incrementa a sequ�ncia
		cItem := Soma1(cItem)
	EndIf

	//Atualiza a global com a �ltima sequ�ncia
	lRet := VarSetXD(oProcesso:cUIDGlobal, cChaveSC, cItem)

	//Fecha a transa��o da chave da OP
	VarEndT(oProcesso:cUIDGlobal, cChaveSC)

Return cItem
