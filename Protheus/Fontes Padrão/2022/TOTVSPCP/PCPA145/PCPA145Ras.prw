#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145DEF.ch"

/*/{Protheus.doc} P145GrvRas
Grava a tabela SMH com o rastreio das demandas
@type Function
@author marcelo.neumann
@since 02/12/2020
@version P12.1.31
@param oProcesso, Objeto, Classe da geração de documentos
@return lOk, Lógico, Indica se gravou com sucesso o rastreio
/*/
Function P145GrvRas(oProcesso)
	Local aDocGerado := {}
	Local aIncluir   := {}
	Local aRegs      := {}
	Local cChave     := ""
	Local cDemanda   := ""
	Local cDocDeman  := ""
	Local cDocGerado := ""
	Local cDocPai    := ""
	Local cFilDeman  := ""
	Local cIdDemAnt  := ""
	Local cIdReg     := ""
	Local cIdPaiPad  := ""
	Local cProduto   := ""
	Local cTipDocGer := ""
	Local cTipDocPai := ""
	Local cTxtES     := ""
	Local cTxtPPed   := ""
	Local cTRT       := ""
	Local lOk        := .T.
	Local lEstSeg    := .F.
	Local lPontPed   := .F.
	Local lEstNeg    := .F.
	Local lPreDoc    := .F.
	Local lPaiPre    := .F.
	Local lRastPai   := .F.
	Local lTemIDPai  := .F.
	Local nDecSMH    := 0
	Local nInd       := 0
	Local nSeqDeman  := 0
	Local nQtdRegs   := 0
	Local nQtdOP     := 0
	Local nQtdOPPai  := 0
	Local nQtdEmp    := 0
	Local nQuant     := 0
	Local nQtdNec    := 0
	Local nUsoPai    := 0
	Local nTamNmEnt  := 0
	Local nTamNmSai  := 0
	Local nTamProd   := 0
	Local nTamTpEnt  := 0
	Local nTamTpSai  := 0
	Local nTamTRT    := 0
	Local nTamIDReg  := 0
	Local oExcluir   := Nil
	Local oIncluidos := Nil
	Local oJson      := Nil
	Local oRastPai   := Nil
	Local oIdsPai    := Nil

	If !AliasInDic("SMH")
		Return lOk
	EndIf
	cTxtES   := MrpDGetSTR("ES")
	cTxtPPed := MrpDGetSTR("PP")
	
	aRegs := MrpGetRasD(oProcesso:cTicket)
	If aRegs[1]
		nTamNmEnt := GetSX3Cache("MH_NMDCENT", "X3_TAMANHO")
		nTamNmSai := GetSX3Cache("MH_NMDCSAI", "X3_TAMANHO")
		nTamProd  := GetSX3Cache("MH_PRODUTO", "X3_TAMANHO")
		nTamTpEnt := GetSX3Cache("MH_TPDCENT", "X3_TAMANHO")
		nTamTpSai := GetSX3Cache("MH_TPDCSAI", "X3_TAMANHO")
		nTamTRT   := GetSX3Cache("MH_TRT"    , "X3_TAMANHO")
		nTamIDReg := GetSX3Cache("MH_IDREG"  , "X3_TAMANHO")
		nDecSMH   := GetSX3Cache("MH_QUANT"  , "X3_DECIMAL")

		oExcluir   := JsonObject():New()
		oIncluidos := JsonObject():New()
		oRastPai   := JsonObject():New()
		oJson      := JsonObject():New()
		oJson:FromJson(aRegs[2])
		nQtdRegs := Len(oJson["items"])
	
		DbSelectArea("SMH")
		If SMH->(FieldPos("MH_IDPAI")) > 0
			cIdPaiPad := Space(GetSX3Cache("MH_IDPAI", "X3_TAMANHO"))
			lTemIDPai := .T.
			oIdsPai   := JsonObject():New()
		EndIf

		For nInd := 1 To nQtdRegs
			lRastPai   := .F.
			cTipDocPai := RTrim(oJson["items"][nInd]["parentDocumentType"])
			
			If nInd == 1 .Or. cIdDemAnt <> oJson["items"][nInd]["demandId"]
				
				lEstSeg  := SubStr(oJson["items"][nInd]["demandId"], 1, Len(cTxtES)  ) == cTxtES
				lPontPed := SubStr(oJson["items"][nInd]["demandId"], 1, Len(cTxtPPed)) == cTxtPPed
				lEstNeg  := SubStr(oJson["items"][nInd]["demandId"], 1, 6            ) == "ESTNEG"

				If lEstSeg .Or. lEstNeg .Or. lPontPed
					cDemanda  := ""
					nSeqDeman := 0
					If lEstSeg
						cDocDeman := cTxtES
					ElseIf lEstNeg
						cDocDeman := "ESTNEG"
					Else
						cDocDeman := cTxtPPed
					EndIf
				Else
					cFilDeman := P136GetInf(oJson["items"][nInd]["demandId"], "VR_FILIAL")
					cDemanda  := P136GetInf(oJson["items"][nInd]["demandId"], "VR_CODIGO")
					nSeqDeman := P136GetInf(oJson["items"][nInd]["demandId"], "VR_SEQUEN")

					cDocDeman := getDocDem(cFilDeman, cDemanda, nSeqDeman)
				EndIf
				cIdDemAnt := oJson["items"][nInd]["demandId"]
			EndIf

			//Busca o De-Para dos documentos (MRP -> ERP)
			//Documento Pai:
			cDocPai    := RTrim(oJson["items"][nInd]["parentDocument"])
			If preExist(@cDocPai)
				lPaiPre := .T.
				If oExcluir["S" + cTipDocPai + "_" + cDocPai] == Nil
					oExcluir["S" + cTipDocPai + "_" + cDocPai] := {"S", PadR(cTipDocPai, nTamTpSai), PadR(cDocPai, nTamNmSai)}
				EndIf
			Else
				lPaiPre := .F.
				cProduto := RTrim(oJson["items"][nInd]["parentProduct"])
				cTRT     := RTrim(oJson["items"][nInd]["parentSequence"])
				cChave   := cDocPai + "_" + cProduto + "_" + cTRT
				VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
				If !Empty(aDocGerado)
					cDocPai := aDocGerado[2]
					aSize(aDocGerado, 0)
				EndIf
			EndIf

			//Documento Gerado:
			cDocGerado := RTrim(oJson["items"][nInd]["document"])
			cTipDocGer := RTrim(oJson["items"][nInd]["documentType"])
			cProduto   := RTrim(oJson["items"][nInd]["product"])
			cTRT       := RTrim(oJson["items"][nInd]["sequenceInStructure"])

			lRastPai := oRastPai:HasProperty(RTrim(oJson["items"][nInd]["parentDocument"])+";"+oJson["items"][nInd]["demandId"])

			If preExist(@cDocGerado)
				lPreDoc  := .T.
				
				If oExcluir["E" + cTipDocGer + "_" + cDocGerado] == Nil
					oExcluir["E" + cTipDocGer + "_" + cDocGerado] := {"E", PadR(cTipDocGer, nTamTpEnt), PadR(cDocGerado, nTamNmEnt)}
				EndIf
			Else
				lPreDoc := .F.
				cChave := cDocGerado + "_" + cProduto + "_"
				
				If !oProcesso:getGeraDocAglutinado(oJson["items"][nInd]["productLevel"])
					cChave += cTRT
				EndIf
		 
				VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
				If !Empty(aDocGerado)
					cTipDocGer := aDocGerado[1]
					cDocGerado := aDocGerado[2]
					aSize(aDocGerado, 0)
				//Verifica se aglutina somente demandas, e se é um doc pré-existente.
				ElseIf lPaiPre .And. oProcesso:getGeraDocAglutinado(oJson["items"][nInd]["productLevel"], .T.)
					cChave := cDocGerado + "_" + cProduto + "_"
					//Tenta buscar o doc gerado sem o TRT.
					VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
					If !Empty(aDocGerado)
						cTipDocGer := aDocGerado[1]
						cDocGerado := aDocGerado[2]
						aSize(aDocGerado, 0)
					EndIf
				Else
					//Verifica se a entrada desse produto foi gerada por um subproduto.
					cChave := "SUBPRD|" + RTrim(oJson["items"][nInd]["product"]) + "|" + oJson["items"][nInd]["date"]
					VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
					If !Empty(aDocGerado)
						cTipDocGer := aDocGerado[1]
						cDocGerado := aDocGerado[2]
						aSize(aDocGerado, 0)
					EndIf
				EndIf
			EndIf

			If !lRastPai .And. (lPreDoc .Or. lPaiPre)
				addRastPai(@oRastPai, oJson["items"][nInd]["quantity"], oJson["items"][nInd]["document"], oJson["items"][nInd]["demandId"])
			EndIf

			cIdReg := IIF(RTrim(oJson["items"][nInd]["productLevel"])=='99','MP','PA') + oProcesso:cTicket + "_" + RTrim(oJson["items"][nInd]["id"])
			cChave := oJson["items"][nInd]["branchId"] + "_" + cDemanda + "_" + cValToChar(nSeqDeman) + "_" + cIdReg

			trataChave(@oIncluidos, cChave, @cIdReg)

			cTipDocGer := PadR(cTipDocGer, nTamTpEnt)
			cDocGerado := PadR(cDocGerado, nTamNmEnt)
			cTipDocPai := PadR(cTipDocPai, nTamTpSai)
			cDocPai    := PadR(cDocPai   , nTamNmSai)
			cProduto   := PadR(cProduto  , nTamProd )
			cTRT       := PadR(cTRT      , nTamTRT  )
			cIdReg     := PadR(cIdReg    , nTamIDReg)

			If (lPreDoc .Or. lPaiPre) .And. lRastPai
				//Calcula a qtd deste componente relacionada ao uso do produto pai para o documento pré-existente.

				//nUsoPai = Quantidade que o produto PAI utilizou da ordem de produção.
				nUsoPai   := oRastPai[RTrim(oJson["items"][nInd]["parentDocument"])+";"+oJson["items"][nInd]["demandId"]]
				//nQtdPai = Quantidade da ordem de produção utilizada para atender a necessidade do EMPENHO
				nQtdOP    := oJson["items"][nInd]["quantityDocumentIn"]
				//nQtdOPPai = Quantidade total da ordem de produção PAI (sem descontar _QUJE)
				nQtdOPPai := oJson["items"][nInd]["quantityDocumentFather"]
				//nQtdEmp = Quantidade original do empenho
				nQtdEmp   := getQtdSD4(cDocPai, cProduto, cTRT)
				//nQtdNec = Quantidade necessária do componente, considerando a QTD DA OP PAI e a QTD TOTAL DO EMPENHO.
				nQtdNec   := (nQtdEmp / nQtdOPPai)

				nQuant := (oJson["items"][nInd]["quantity"]/nQtdEmp) //Verifica a proporção desse empenho X empenho total
				nQuant := nQuant * nQtdNec * nUsoPai //Quantidade atendida do empenho por esta OP, proporcionada ao empenho.
				
				nQuant := Round(nQuant, nDecSMH)

				//Registrar em oRastPai a quantidade atualizada deste produto, para utilizar nos produtos filhos.
				addRastPai(@oRastPai, nQuant, oJson["items"][nInd]["document"], oJson["items"][nInd]["demandId"])
			Else
				nQuant := oJson["items"][nInd]["quantity"]
			EndIf

			aAdd(aIncluir, {oJson["items"][nInd]["branchId"]  , ;
							cDemanda                          , ;
							nSeqDeman                         , ;
							cDocDeman                         , ;
							cTipDocGer                        , ;
							cDocGerado                        , ;
							cProduto                          , ;
							SToD(oJson["items"][nInd]["date"]), ;
							nQuant                            , ;
							cTipDocPai                        , ;
							cDocPai                           , ;
							cIdReg                            , ;
							cTRT} )
			
			If lTemIDPai				
				//Grava o identificador do registro pai
				cChave := RTrim(oJson["items"][nInd]["demandId"]) + "|" + RTrim(oJson["items"][nInd]["document"])
				If ! oIdsPai:HasProperty(cChave)
					oIdsPai[cChave] := cIdReg
				EndIf

				//Verifica se o documento possui registro pai, e adiciona informação na coluna VH_IDPAI
				cChave := RTrim(oJson["items"][nInd]["demandId"]) + "|" + RTrim(oJson["items"][nInd]["parentDocument"])
				If oIdsPai:HasProperty(cChave)
					aAdd(aIncluir[nInd], oIdsPai[cChave])
				Else
					aAdd(aIncluir[nInd], cIdPaiPad)
				EndIf
			EndIf
		Next nInd
		aSize(oJson["items"],0)

		excluiRegs(oExcluir)

		cCols := "MH_FILIAL,MH_DEMANDA,MH_DEMSEQ,MH_DEMDOC,MH_TPDCENT,MH_NMDCENT,MH_PRODUTO,MH_DATA,MH_QUANT,MH_TPDCSAI,MH_NMDCSAI,MH_IDREG,MH_TRT"
		If lTemIDPai
			cCols+=",MH_IDPAI"
		EndIf
		If TCDBInsert(RetSqlName("SMH"), cCols, aIncluir) < 0
			lOk := .F.
			Final("Erro ao gravar a rastreabilidade das demandas.", TcSqlError())
		EndIf
		
		FreeObj(oRastPai)
		FreeObj(oExcluir)
		FreeObj(oIncluidos)
		FreeObj(oJson)
		If lTemIDPai
			FreeObj(oIdsPai)
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} getDocDem
Busca o número do documento (VR_DOC) da demanda
@type Static Function
@author marcelo.neumann
@since 02/12/2020
@version P12.1.31
@param 01 cFilDeman, Character, Filial da demanda
@param 02 cDemanda , Character, Código da demanda
@param 03 nSeqDeman, Numeric  , Sequência da demanda
@return   cDocDeman, Character, Documento da demanda (VR_DOC)
/*/
Static Function getDocDem(cFilDeman, cDemanda, nSeqDeman)

	Local cAliasSVR := GetNextAlias()
	Local cDocDeman := ""

	cAliasSVR := GetNextAlias()
	BeginSql Alias cAliasSVR
		SELECT SVR.VR_DOC
		  FROM %table:SVR% SVR
		 WHERE SVR.VR_FILIAL = %Exp:cFilDeman%
		   AND SVR.VR_CODIGO = %Exp:cDemanda%
		   AND SVR.VR_SEQUEN = %Exp:nSeqDeman%
		   AND %NotDel%
	EndSql

	If (cAliasSVR)->(!Eof())
		cDocDeman := (cAliasSVR)->VR_DOC
	EndIf
	(cAliasSVR)->(dbCloseArea())

Return cDocDeman

/*/{Protheus.doc} P145SetDoc
Seta a variável global com o De-Para do documento
@type Function
@author marcelo.neumann
@since 03/12/2020
@version P12.1.31
@param 01 oProcesso , Objeto  , Classe da geração de documentos
@param 02 aDados    , Array   , Array com as informações do rastreio que serão processados.
                                As posições deste array são acessadas através das constantes iniciadas com o nome RASTREIO_POS.
								Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param 03 cTipDocERP, Caracter, Tipo do documento gerado no ERP
@param 04 cDocGerado, Caracter, Número do documento gerado no ERP
/*/
Function P145SetDoc(oProcesso, aDados, cTipDocERP, cDocGerado)

	Local cDocFilho := ""
	Local cChave    := ""
	Local cProduto  := ""
	Local cTRT      := ""

	If !Empty(cDocGerado)
		If Empty(aDados[RASTREIO_POS_DOCFILHO])
			If aDados[RASTREIO_POS_TIPODOC] == "Ponto Ped."
				cDocFilho := "Ponto Ped." + DToS(aDados[RASTREIO_POS_DATA_ENTREGA]) + "_Filha"
			Else
				cDocFilho := Trim(aDados[RASTREIO_POS_DOCPAI]) + "_Filha"
			EndIf
		Else
			cDocFilho := Trim(aDados[RASTREIO_POS_DOCFILHO])
		EndIf

		cProduto := Trim(aDados[RASTREIO_POS_PRODUTO])
		If oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
			cTRT := ""
		Else
			cTRT := Trim(aDados[RASTREIO_POS_TRT])
		EndIf
		cChave   := cDocFilho + "_" + cProduto + "_" + cTRT

		VarSetAD(oProcesso:cUIDRasEntr, cChave, {cTipDocERP, cDocGerado})

		If AllTrim(aDados[RASTREIO_POS_TIPODOC]) == "SUBPRD"
			cChave := "SUBPRD|" + RTrim(aDados[RASTREIO_POS_DOCPAI]) + "|" + DtoS(aDados[RASTREIO_POS_DATA_ENTREGA])
			VarSetAD(oProcesso:cUIDRasEntr, cChave, {cTipDocERP, cDocGerado})
		EndIf

	EndIf

Return

/*/{Protheus.doc} preExist
Retorna se é um documento pré-existente, removendo o indicador do número
@type Static Function
@author marcelo.neumann
@since 19/12/2020
@version P12.1.31
@param 01 cNumDoc, Character, Número do documento a ser verificado (retornado por referência)
@return lPreExist, Logic    , Indica se o documento é pré-existente
/*/
Static Function preExist(cNumDoc)

	Local lPreExist := .F.

	If Left(cNumDoc, 4) == "Pre_"
		lPreExist := .T.
		cNumDoc   := SubStr(cNumDoc, 5, Len(cNumDoc))
	EndIf

Return lPreExist

/*/{Protheus.doc} excluiRegs
Exclui os documentos pré-existentes que foram usados no cálculo e que já possuíam rastreabilidade
@type Static Function
@author marcelo.neumann
@since 22/12/2020
@version P12
@param 01 oExcluir, Object, Json com os registros a serem excluídos da SMH
@return Nil
/*/
Static Function excluiRegs(oExcluir)
	Local aExcluir := oExcluir:GetNames()
	Local cUpdDel  := ""
	Local nIndex   := 1
	Local nTotal   := Len(aExcluir)

	For nIndex := 1 To nTotal
		cUpdDel := "UPDATE " + RetSqlName("SMH")                    + ;
				 	 " SET D_E_L_E_T_   = '*',"                     + ;
				 	 	 " R_E_C_D_E_L_ = R_E_C_N_O_"               + ;
				   " WHERE MH_FILIAL    = '" + xFilial("SMH") + "'" + ;
					 " AND D_E_L_E_T_   = ' '"

		If oExcluir[aExcluir[nIndex]][1] == "E"
			cUpdDel += " AND MH_TPDCENT = '" + oExcluir[aExcluir[nIndex]][2] + "'" + ;
			           " AND MH_NMDCENT = '" + oExcluir[aExcluir[nIndex]][3] + "'"
		Else
			cUpdDel += " AND MH_TPDCSAI = '" + oExcluir[aExcluir[nIndex]][2] + "'" + ;
			           " AND MH_NMDCSAI = '" + oExcluir[aExcluir[nIndex]][3] + "'"
		EndIf

		If TcSqlExec(cUpdDel) < 0
			Final("Erro ao excluir os registros de rastreabilidade.", TcSqlError())
		EndIf
	Next nIndex

Return

/*/{Protheus.doc} addRastPai
Adiciona a quantidade utilizada ao objeto de rastreio 

@type  Static Function
@author lucas.franca
@since 07/10/2021
@version P12
@param 01 oRastPai  , Object   , Objeto com os rastreios das quantidades utilizadas
@param 02 nQtd      , Numeric  , Quantidade utilizada.
@param 03 cDocSaida , Character, Código do documento de saída
@param 04 cIdDemanda, Character, ID da demanda que consumiu o documento
@return Nil
/*/
Static Function addRastPai(oRastPai, nQtd, cDocSaida, cIdDemanda)
	Local cChave := RTrim(cDocSaida) + ";" + cIdDemanda

	If oRastPai:HasProperty(cChave)
		oRastPai[cChave] += nQtd
	Else
		oRastPai[cChave] := nQtd
	EndIf
Return Nil

/*/{Protheus.doc} getQtdSD4
Busca a quantidade original do empenho

@type  Static Function
@author lucas.franca
@since 20/10/2021
@version P12
@param cNumOp, Character, Número da ordem de produção
@param cComp , Character, Código do componente
@param cTRT  , Character, Sequência do componente
@return nQtdEmp, Numeric, Quantidade original do empenho
/*/
Static Function getQtdSD4(cNumOp, cComp, cTRT)
	Local cAlias  := PCPAliasQr()
	Local cQuery  := ""
	Local nQtdEmp := 0

	cQuery := " SELECT SUM(SD4.D4_QTDEORI) TOTAL "
	cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
	cQuery +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
	cQuery +=    " AND SD4.D4_OP      = '" + cNumOp + "' "
	cQuery +=    " AND SD4.D4_COD     = '" + cComp  + "' "
	cQuery +=    " AND SD4.D4_TRT     = '" + cTRT   + "' "
	cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .F.)
	nQtdEmp := (cAlias)->(TOTAL)
	(cAlias)->(dbCloseArea())

Return nQtdEmp

/*/{Protheus.doc} trataChave
Verifica a necessidade de tratar a chave do registro que será incluído na tabela SME,
e manipula o identificador de registro se necessário.

@type  Static Function
@author lucas.franca
@since 17/01/2022
@version P12
@param oIncluidos, JsonObject, JSON com as chaves já incluídas
@param cChave    , Character , Chave original do registro
@param cIdReg    , Character , Identificador do registro que será gravado
@return Nil
/*/
Static Function trataChave(oIncluidos, cChave, cIdReg)
	
	If oIncluidos:HasProperty(cChave)
		oIncluidos[cChave] := oIncluidos[cChave] + 1
		cIdReg := RTrim(cIdReg) + "_" + cValToChar(oIncluidos[cChave])
	Else
		oIncluidos[cChave] := 0
	EndIf

Return Nil