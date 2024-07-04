#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.ch"
#INCLUDE "PCPA145DEF.ch"

Static _oProcesso := Nil
Static _lGeraOS   := Nil
Static __lSetDoc  := FindFunction("P145SetDoc")
Static __lVR_ORIG := Nil

/*/{Protheus.doc} PCPA145JOB
THREAD Filha para Geração dos documentos (SC2/SC1/SC7/SD4/SB2) de acordo com o
resultado do processamento do MRP.

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cTicket  , Character, Ticket de processamento do MRP para geração dos documentos
@param aDados   , Array    , Array com as informações do rastreio que serão processados.
                             As posições deste array são acessadas através das constantes iniciadas
                             com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param cCodUsr  , Character, Código do usuário logado no sistema.
@param cNumScUni, Character, Número da SC quando parametrizado para ter numeração única (oProcesso:cIncSC == "1").
@param lGerouPC , Lógico   , Indica que será gerado Pedido de Compra e o JOB deve gerar apenas em empenhos.
@return Nil
/*/
Function PCPA145JOB(cTicket, aDados, cCodUsr, cNumScUni, lGerouPC)
	Local aDocPaiERP  := {}
	Local aDadosSCPC  := {}
	Local aDocDePara  := {}
	Local cDocGerado  := ""
	Local cDocPaiERP  := ""
	Local cTipDocERP  := ""
	Local cChaveLock  := ""
	Local cItemSC     := ""
	Local cStatus     := ""
	Local lContinua   := .T.
	Local lAglutina   := .F.
	Local lLockGlobal := .F.
	Local lIsOp		  := .F.
	Local lCriaDocum  := .T.
	Local lEmpenho    := .T.
	Local lApropInd   := .F.

	Default lGerouPC := .F.

	//Verifica se é necessário instanciar a classe ProcessaDocumentos nesta thread filha para utilização dos métodos.
	If _oProcesso == Nil
		_oProcesso := ProcessaDocumentos():New(cTicket, .T., /*03*/, cCodUsr)
	EndIf

	//Verifica se a filial atual é a mesma filial do registro para processamento
	If cFilAnt != aDados[RASTREIO_POS_FILIAL]
		cFilAnt := aDados[RASTREIO_POS_FILIAL]
	EndIf

	//Verifica parâmetro para geração de ordem de substituição
	_lGeraOS := Iif(_lGeraOS == Nil, SuperGetMV("MV_PCPOS" ,.F.,.F.) .And. FindFunction("geraOrdSub"), _lGeraOS)

	If __lVR_ORIG == Nil
		dbSelectArea("SVR")
		__lVR_ORIG := FieldPos("VR_ORIGEM") > 0
	EndIf

	//Verifica se o documento PAI deste registro já foi gerado.
	If !Empty(aDados[RASTREIO_POS_DOCPAI]) .And. AllTrim(aDados[RASTREIO_POS_TIPODOC]) == "OP"
		aDocDePara := _oProcesso:getDocumentoDePara(aDados[RASTREIO_POS_DOCPAI], cFilAnt)
		cDocPaiERP := aDocDePara[2]
		/*
			Quando aDocDePara[1] for == .F., indica que o produto pai não foi gerado
			devido ao filtro realizado na seleção de datas para geração dos documentos.
			Neste cenário, não irá gerar empenhos, mas irá gerar OP/SC do filho se existir necessidade.
		*/
		lEmpenho := aDocDePara[1]

		If aDocDePara[1] .And. Empty(cDocPaiERP)
			//Verifica se é um documento aglutinado.
			//Nesse caso, os documentos pais são registrados em outro local.
			If _oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
				If aDados[RASTREIO_POS_EMPENHO] <> 0
					aDocPaiERP := _oProcesso:getDocsAglutinados(aDados[RASTREIO_POS_DOCPAI], aDados[RASTREIO_POS_PRODUTO], @lEmpenho)
				EndIf
			EndIf

			If lEmpenho .And. Len(aDocPaiERP) == 0
				_oProcesso:updStatusRastreio("2"                      ,;
				                             " "                      ,;
				                             " "                      ,;
				                             aDados[RASTREIO_POS_RECNO])

				//Documento pai deste registro ainda não foi gerado.
				//Interrompe o processamento.
				lContinua := .F.

				//Incrementa o contador de registros marcados para calcular posteriormente.
				_oProcesso:incCount(CONTADOR_REINICIADOS)
			Else
				cDocPaiERP := " "
			EndIf
		Else
			aDocPaiERP := {{cDocPaiERP, aDados[RASTREIO_POS_EMPENHO]}}
		EndIf

		aSize(aDocDePara, 0)
	EndIf


	lCriaDocum := _oProcesso:dataValida(aDados[RASTREIO_POS_DATA_ENTREGA], IIF(aDados[RASTREIO_POS_NIVEL] <> "99", "OP", "SC") )
	If !lCriaDocum .And. aDados[RASTREIO_POS_NIVEL] <> "99" .And. aDados[RASTREIO_POS_NECESSIDADE] > 0
		//Grava contador que este registro não irá gerar documento devido a filtro de datas na geração dos documentos
		_oProcesso:initCount(AllTrim(aDados[RASTREIO_POS_DOCFILHO]) + CHR(13) + cFilAnt + "FORADATA", 1)
	EndIf

	If lContinua
		//Posiciona no produto
		If SB1->B1_COD != aDados[RASTREIO_POS_PRODUTO] .Or. SB1->B1_FILIAL != xFilial("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + aDados[RASTREIO_POS_PRODUTO]))
		EndIf
		
		lApropInd := SB1->B1_APROPRI == "I"

		lLockGlobal := .F.
		BEGIN TRANSACTION

			If lCriaDocum .And. aDados[RASTREIO_POS_NECESSIDADE] > 0 .And. !lGerouPC //Se gerou PC, não entra no processo de geração de SC e OP, gera apenas o empenho
				If aDados[RASTREIO_POS_NIVEL] == "99"
					If !Empty(cDocPaiERP)
						aDadosSCPC := AvalNecOP(@aDados, @cDocPaiERP, _oProcesso:getGravOP()) //Avalia Necessidade de(E) Remoção do(o) Vínculo com a OP
					Else
						aDadosSCPC := aDados
					EndIf
					cDocGerado := PCPA145SC(@_oProcesso, @aDadosSCPC, cDocPaiERP, , cNumScUni, @cItemSC)
					cDocGerado += cItemSC
					cTipDocERP := "2"
				Else
					cDocGerado := PCPA145OP(@_oProcesso, @aDados, cDocPaiERP )
					cTipDocERP := "1"
					lIsOp := .T.
					_oProcesso:incCount("METRICOP") //Incremento do contador de OP - para envio de métrica
				EndIf
			EndIf

			If _lGeraOS .And. lEmpenho .And. aDados[RASTREIO_POS_QTD_SUBST] < 0 .And. !Empty(aDados[RASTREIO_POS_CHAVE_SUBST])
				PCPA145Sub(@_oProcesso, @aDados, @aDocPaiERP)
			EndIf

			//Se não gerou documento devido a seleção de datas, registra status 3 na HWC.
			cStatus := Iif(lCriaDocum, "1", "3")

			If !lGerouPC //Se gerou PC, não é necessário atualizar o indicador de rastreio novamente.
				_oProcesso:updStatusRastreio(cStatus                  ,;
			                                 cDocGerado               ,;
				                             cTipDocERP               ,;
			                                 aDados[RASTREIO_POS_RECNO])
			EndIf

			If aDados[RASTREIO_POS_EMPENHO] <> 0 .And. lEmpenho
				lAglutina := _oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
				If !lAglutina .Or. (lAglutina .And. aDados[RASTREIO_POS_SEQUEN] == 1)
					cChaveLock  := RTrim(aDados[RASTREIO_POS_PRODUTO]) + CHR(13) + "LOCKEMP"
					lLockGlobal := .T.
					VarBeginT(_oProcesso:cUIDGlobal, cChaveLock)
					PCPA145Emp(@_oProcesso, @aDados, @aDocPaiERP, lApropInd)
				EndIf
			EndIf

			If lCriaDocum .And. Alltrim(aDados[RASTREIO_POS_TIPODOC]) == "1" .Or. Alltrim(aDados[RASTREIO_POS_TIPODOC]) == "0"
				lAglutina := _oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
				If lAglutina
						atuSHCAg(aDados[RASTREIO_POS_DOCPAI], lIsOp, cDocGerado, cTicket)
				ElseIf !Empty(cDocGerado)
						atuSHC(aDados[RASTREIO_POS_DOCPAI], lIsOp, cDocGerado)
				EndIf
			EndIf

			If __lSetDoc .And. lCriaDocum
				P145SetDoc(_oProcesso, aDados, cTipDocERP, cDocGerado)
			EndIf

		END TRANSACTION

		If lLockGlobal
			VarEndT(_oProcesso:cUIDGlobal, cChaveLock)
		EndIf
		_oProcesso:incCount(CONTADOR_GERADOS)
	EndIf

	aSize(aDados     , 0)
	aSize(aDocPaiERP , 0)

	_oProcesso:incCount(_oProcesso:cThrJobs + "_Concluidos")

Return Nil

/*/{Protheus.doc} PCPA145INT
Executa as integrações pendentes das ordens de produção.

@type  Function
@author lucas.franca
@since 26/12/2019
@version P12.1.29
@param 01 aIntegra  , Array   , Array com os indicadores de integração
@param 02 cErrorUID , Caracter, ID de controle de execução multi-thread
@param 03 cUIDGlobal, Caracter, ID de controle das variáveis globais
@param 04 cTicket   , Caracter, Número do ticket do processamento do MRP
@param 05 cUIDIntOP , Caracter, Seção global das OPs a serem integradas
@param 06 cUIDIntEmp, Caracter, Seção global dos Empenhos a serem integrados
@return Nil
/*/
Function PCPA145INT(aIntegra, cErrorUID, cUIDGlobal, cTicket, cUIDIntOP, cUIDIntEmp)
	Local aDadosEmp  := {}
	Local aDadosOP   := {}
	Local lErro      := .F.
	Local lTemInteg  := .F.
	Local nTotal     := 0
	Local nIndex     := 0
	Local nStatus    := 0
	Local nTempo     := 0
	Local nTempoTot  := MicroSeconds()
	Local oPCPError  := PCPMultiThreadError():New(cErrorUID, .F.)
	Private cIntgPPI := "1"

	//Recupera todas as chaves de OP que foram adicionadas na seção global cUIDIntOP
	If VarGetAA(cUIDIntOP, @aDadosOP)
		If aDadosOP <> Nil .And. Len(aDadosOP) > 0
			lTemInteg := .T.
		EndIF
	EndIf

	//Recupera todas as chaves de Empenhos que foram adicionadas na seção global aDadosEmp
	If VarGetAA(cUIDIntEmp, @aDadosEmp)
		If aDadosEmp <> Nil .And. Len(aDadosEmp) > 0
			lTemInteg := .T.
		EndIF
	EndIf

	If !lTemInteg
		P145AtuSta(cTicket, 0)
		PutGlbValue("P145JOBINT", "FIM")
		P145EndInt(cTicket)
		Return
	EndIf

	If !PCPLock("PCPA145INT", .T.)
		aSize(aDadosEmp, 0)
		aSize(aDadosOP, 0)
		PutGlbValue("P145JOBINT", "FIM")
		P145EndInt(cTicket)
		Return
	EndIf

	PutGlbValue("P145JOBINT", "INI")

	SetFunName("PCPA145")

	ProcessaDocumentos():msgLog(STR0002)  //"INICIANDO INTEGRAÇÃO DAS ORDENS DE PRODUÇÃO"

	If Empty(GetGlbValue("P145ERROR"))
		PutGlbValue("P145ERROR", "INI")
	EndIf

	If aIntegra[INTEGRA_OP_MRP]
		PutGlbValue("P145INTMRP", "INI")
		oPCPError:startJob("P145INTMRP", getEnvServer(), .F., cEmpAnt, cFilAnt, aDadosOP, , , , , , , , , , , '{|| PCPUnlock("PCPA145INT"), PutGlbValue("P145INTMRP", "ERRO"), PutGlbValue("P145ERROR", "ERRO") }')
	EndIf

	If aIntegra[INTEGRA_OP_SFC]
		PutGlbValue("P145INTSFC", "INI")
		oPCPError:startJob("P145INTSFC", getEnvServer(), .F., cEmpAnt, cFilAnt, cTicket, aDadosOP, aDadosEmp, , , , , , , , , '{|| PCPUnlock("PCPA145INT"), PutGlbValue("P145INTSFC", "ERRO"), PutGlbValue("P145ERROR", "ERRO") }')
	EndIf

	If aIntegra[INTEGRA_OP_QIP]
		PutGlbValue("P145INTQIP", "INI")
		oPCPError:startJob("P145INTQIP", getEnvServer(), .F., cEmpAnt, cFilAnt, cTicket, aDadosOP, , , , , , , , , , '{|| PCPUnlock("PCPA145INT"), PutGlbValue("P145INTQIP", "ERRO"), PutGlbValue("P145ERROR", "ERRO") }')
	EndIf

	If aIntegra[INTEGRA_OP_PPI]
		cIntgPPI := PCPIntgMRP()
		If cIntgPPI <> "1"
			PutGlbValue(cTicket + "STATUS_MES_INCLUSAO", "INI")

			ProcessaDocumentos():msgLog(STR0031)  //"INICIANDO INTEGRAÇÃO COM O TOTVS MES"
			nTempo := MicroSeconds()

			dbSelectArea("SC2")

			nTotal := Len(aDadosOP)
			For nIndex := 1 To nTotal
				SC2->(dbGoTo(Val(aDadosOP[nIndex][1])))

				If !PCPa650PPI(/*cXml*/, /*cOp*/, .T., .T., .F., /*lFiltra*/)
					lErro := .T.
				EndIf
			Next nIndex

			PutGlbValue(cTicket + "STATUS_MES_INCLUSAO", "FIM")
			ProcessaDocumentos():msgLog(STR0032 + cValToChar(MicroSeconds()-nTempo))  //"TEMPO PARA EXECUTAR A INTEGRAÇÃO COM O MES: "
		EndIf
	EndIf

	//Aguarda as integrações
	While GetGlbValue("P145INTMRP") == "INI" .Or. GetGlbValue("P145INTSFC") == "INI" .Or. GetGlbValue("P145INTQIP") == "INI"
		Sleep(2000)
	End

	If GetGlbValue("P145INTMRP") == "ERRO" .Or. GetGlbValue("P145INTSFC") == "ERRO" .Or. GetGlbValue("P145INTQIP") == "ERRO"
		If GetGlbValue("P145ERROR") == "ERRO"
			If oPCPError:lock("P145ERRORLOCK")
				// Verificação adicional para ver se o log do erro já não foi gravado na thread de execução do MRP
				If !Empty(GetGlbValue("P145ERROR"))
					GravaCV8("4", GetGlbValue("PCPA145PROCCV8"), /*cMsg*/, oPCPError:getcError(3), "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt)
					ClearGlbValue("P145ERROR")
					oPCPError:unlock("P145ERRORLOCK")
				EndIf
			EndIf
		EndIf
		lErro := .T.
	EndIf

	If lErro
		nStatus := 2 //Documentos gerados com pendências
	Else
		nStatus := 1
	EndIf

	P145AtuSta(cTicket, nStatus)

	PCPUnlock("PCPA145INT")
	PutGlbValue("P145JOBINT", "FIM")
	P145EndInt(cTicket)

	ProcessaDocumentos():msgLog(STR0004)  //"FIM DA INTEGRAÇÃO DAS ORDENS DE PRODUÇÃO"
	ProcessaDocumentos():msgLog(STR0033 + cValToChar(MicroSeconds()-nTempoTot))  //"TEMPO TOTAL DAS INTEGRAÇÕES: "

	aSize(aDadosEmp, 0)
	aSize(aDadosOP, 0)
	oPCPError:destroy()
	P145EndLog()

Return Nil

/*/{Protheus.doc} AvalNecOP
Função responsável por avaliar a necessidade da OP e remover o vínculo do registro para geração da SC ou PC
quando foi aplicada política de estoque (necessidade a Necessidade for maior que Necessidade Original - Baixa Estoque - Substituição)

@type  Function
@author brunno.costa
@since 08/04/2020
@version P12.1.30

@param 01 - aDados , Array , Array com as informações do rastreio que serão processados.
                           As posições deste array são acessadas através das constantes iniciadas
                           com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param 02 - cDocPaiERP, caracter, código do documento Pai no ERP - retorna por referência
@param 03 - nGravOP, number, Valor do parâmetro MV_GRAVOP.
@return aDadosSCPC, array, aDados com remoção do vínculo com a OP, quando for o caso
/*/
Static Function AvalNecOP(aDados, cDocPaiERP, nGravOP)
	Local aDadosSCPC := {}

	If  aDados[RASTREIO_POS_NECESSIDADE] > ( aDados[RASTREIO_POS_NECES_ORIG];
	                                        -aDados[RASTREIO_POS_BAIXA_EST] ;
	                                        -aDados[RASTREIO_POS_QTD_SUBST] )
		aDadosSCPC                       := aClone(aDados)
		aDadosSCPC[RASTREIO_POS_TIPODOC] := ""
		aDadosSCPC[RASTREIO_POS_DOCPAI]  := ""
		If nGravOP == 1 .OR. nGravOP == 3
			cDocPaiERP := ""
		EndIf
	Else
		aDadosSCPC                      := aDados

	EndIf

	If nGravOP == 4
		cDocPaiERP := ""
	EndIf

Return aDadosSCPC


/*/{Protheus.doc} atuSHC
Atualiza campos Status e Op da tabela SHC ( plano mestre )
quando o MRP foi rodado sem aglutinação

@type  Function
@author douglas.heydt
@since 21/10/2020
@version P12.1.27
@param cDocPai 	, Character	, Código do documento pai
@param lOp  	, Lógico	, Indica se será gerada uma OP para o documento
@param cDocGerado, Character, Código do documento ( OP, SC ou PC ) gerado
@return Nil
/*/
Static Function atuSHC(cDocPai, lOp, cDocGerado)

	Local cAliasSVR := GetNextAlias()
	Local cQuery    := ""
	Local cVrFil    := ""
	Local cVrCod    := ""
	Local nVrSeq    := 0

	cVrFil := P136GetInf(cDocPai, "VR_FILIAL")
	cVrCod := P136GetInf(cDocPai, "VR_CODIGO")
	nVrSeq := P136GetInf(cDocPai, "VR_SEQUEN")

	cQuery := " SELECT SVR.VR_REGORI"
	cQuery +=   " FROM " + RetSqlName("SVR") + " SVR "
	cQuery +=  " INNER JOIN " + RetSqlName("SHC") + " SHC "
	cQuery +=     " ON SHC.HC_FILIAL  = '" + xFilial("SHC") + "' "
	cQuery +=    " AND SHC.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SHC.R_E_C_N_O_ = SVR.VR_REGORI "
	cQuery +=  " WHERE SVR.VR_FILIAL  = '" + cVrFil + "' "
	cQuery +=    " AND SVR.VR_TIPO    = '3' "
	cQuery +=    " AND SVR.VR_CODIGO  = '" + cVrCod + "' "
	cQuery +=    " AND SVR.VR_SEQUEN  = " + cValToChar(nVrSeq)
	cQuery +=    " AND SVR.D_E_L_E_T_ = ' ' "
	If __lVR_ORIG
		cQuery +=" AND SVR.VR_ORIGEM  = 'SHC' "
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasSVR, .T., .T.)

	If (cAliasSVR)->(!Eof()) .And. (cAliasSVR)->VR_REGORI > 0
		SHC->(dbGoTo( (cAliasSVR)->VR_REGORI ))
		RecLock("SHC",.F.)
			SHC->HC_STATUS := 'E'
			If lOp
				SHC->HC_OP := cDocGerado
			EndIf
		SHC->(MsUnlock())
	EndIf

	(cAliasSVR)->(dbCloseArea())

Return

/*/{Protheus.doc} atuSHCAg
Atualiza campos Status e Op da tabela SHC ( plano mestre )
quando o MRP foi rodado com aglutinação
@type  Function
@author douglas.heydt
@since 21/10/2020
@version P12.1.27
@param cDocPai 	, Character	, Código do documento pai
@param lOp  	, Lógico	, Indica se será gerada uma OP para o documento
@param cDocGerado, Character, Código do documento ( OP, SC ou PC ) gerado
@param cTicket  , Character, Ticket de processamento do MRP para geração dos documentos
@return Nil
/*/
Static Function atuSHCAg(cDocpai, lOp, cDocGerado, cTicket)

	Local aRegs     := {}
	Local nIndex    := 0
	Local nTamRegs  := 0
	Local oJson     := Nil

	If Empty(cDocPai)
		Return
	EndIf

	aRegs := MrpGDocOri(cTicket, cDocpai)

	If aRegs[1]
		oJson := JsonObject():New()
		oJson:FromJson(aRegs[2])
		nTamRegs := Len(oJson["items"])

		For nIndex := 1 To nTamRegs
			atuSHC(oJson["items"][nIndex]["originDocument"], lOp, cDocGerado)
		Next nIndex

		aSize(oJson["items"], 0)
		FreeObj(oJson)
	EndIf

	aSize(aRegs, 0)
Return

/*/{Protheus.doc} P145INTMRP
Executa a integração das ordens de produção com o MRP

@type Function
@author lucas.franca
@since 26/12/2019
@version P12
@param 01 aDados, Array, Array com os dados das ordens de produção que serão integradas.
@return Nil
/*/
Function P145INTMRP(aDados)
	Local aErros     := {}
	Local aFiliais   := {}
	Local lErro      := .F.
	Local lIntegra   := Nil
	Local nIndex     := 0
	Local nIndexErro := 0
	Local nSizeFil   := FwSizeFilial()
	Local nTempo     := 0
	Local nTotal     := 0
	Local oOrdensFil := JsonObject():New()

	ProcessaDocumentos():msgLog(STR0034)  //"INICIANDO INTEGRAÇÃO COM O MRP"
	nTempo := MicroSeconds()

	Ma650MrpOn(lIntegra)

	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		If oOrdensFil[aDados[nIndex][2][2]] == Nil
			oOrdensFil[aDados[nIndex][2][2]] := {}
		EndIf
		aAdd(oOrdensFil[aDados[nIndex][2][2]], aDados[nIndex][2][1][1])
	Next nIndex

	aFiliais := oOrdensFil:GetNames()
	nTotal := Len(aFiliais)
	For nIndex := 1 To nTotal
		If cFilAnt != PadR(aFiliais[nIndex], nSizeFil)
			cFilAnt := PadR(aFiliais[nIndex], nSizeFil)
		EndIf
		MATA650INT("INSERT", oOrdensFil[aFiliais[nIndex]], , aErros)

		If Len(aErros) > 0
			lErro := .T.
			For nIndexErro := 1 to Len(aErros)
				GravaCV8("3", GetGlbValue("PCPA145PROCCV8"), STR0045 + aErros[nIndexErro]["message"], /*cDetalhes*/, "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt) // "ERRO DE INTEGRAÇÃO COM O MRP: "
			Next
			aSize(aErros, 0)
		EndIf
		aSize(oOrdensFil[aFiliais[nIndex]], 0)
	Next nIndex

	If lErro
		PutGlbValue("P145INTMRP", "ERRO")
	Else
		PutGlbValue("P145INTMRP", "FIM")
	EndIf
	FreeObj(oOrdensFil)
	ProcessaDocumentos():msgLog(STR0003 + cValToChar(MicroSeconds()-nTempo))  //"TEMPO PARA EXECUTAR A INTEGRAÇÃO COM O MRP: "

Return lErro

/*/{Protheus.doc} P145INTSFC
Executa a integração das ordens de produção com o Chão de Fábrica (SFC)

@type Function
@author marcelo.neumann
@since 09/08/2021
@version P12
@param 01 cTicket  , Caracter, Ticket de execução do MRP
@param 02 aDadosOP , Array   , Array com os dados das ordens de produção que serão integradas
@param 03 aDadosEmp, Array   , Array com os dados dos empenhos que serão integrados
@return Nil
/*/
Function P145INTSFC(cTicket, aDadosOP, aDadosEmp)
	Local cErro  := ""
	Local cName  := "PCPA145"
	Local lErro  := .F.
	Local nIndex := 0
	Local nTempo := 0
	Local nTotal := 0

	PutGlbValue(cTicket + "STATUS_SFC_INCLUSAO", "INI")

	ProcessaDocumentos():msgLog(STR0036)  //"INICIANDO INTEGRAÇÃO COM O SFC"
	nTempo := MicroSeconds()

	nTotal := Len(aDadosOP)
	ProcessaDocumentos():msgLog(STR0038 + cValToChar(nTotal))  //"INTEGRAÇÃO COM O SFC - QUANTIDADE DE ORDENS DE PRODUÇÃO: "
	For nIndex := 1 To nTotal
		SC2->(dbGoTo(Val(aDadosOP[nIndex][1])))

		If SC2->C2_TPOP == "F"
			//Geração das Ordens
			PCPIntSFC(3, 1, @cErro, cName, , "SC2")
			If !Empty(cErro)
				ProcessaDocumentos():msgLog("PCPA145 - " + Trim(cErro), "3")
				cErro := ""
				lErro := .T.
			EndIf

			//Geração das Operacoes
			PCPIntSFC(4, 2, @cErro, cName)
			If !Empty(cErro)
				ProcessaDocumentos():msgLog("PCPA145 - " + Trim(cErro), "3")
				cErro := ""
				lErro := .T.
			EndIf
		EndIf
	Next nIndex

	nTotal := Len(aDadosEmp)
	ProcessaDocumentos():msgLog(STR0039 + cValToChar(nTotal))  //"INTEGRAÇÃO COM O SFC - QUANTIDADE DE EMPENHOS: "
	For nIndex := 1 To nTotal
		SD4->(dbGoTo(Val(aDadosEmp[nIndex][1])))

		SC2->(dbSetOrder(1))
		If SC2->(dbSeek(xFilial("SC2", SD4->D4_FILIAL) + SD4->D4_OP)) .And. SC2->C2_TPOP == "F"
			//Geração dos Empenhos
			PCPIntSFC(4, 3, @cErro, cName)
			If !Empty(cErro)
				ProcessaDocumentos():msgLog("PCPA145 - " + Trim(cErro), "3")
				cErro := ""
				lErro := .T.
			EndIf
		EndIf
	Next nIndex

	PutGlbValue(cTicket + "STATUS_SFC_INCLUSAO", "FIM")

	aSize(aDadosOP, 0)
	aSize(aDadosEmp, 0)

	If lErro
		PutGlbValue("P145INTSFC", "ERRO")
	Else
		PutGlbValue("P145INTSFC", "FIM")
	EndIf

	ProcessaDocumentos():msgLog(STR0037 + cValToChar(MicroSeconds()-nTempo))  //"TEMPO PARA EXECUTAR A INTEGRAÇÃO COM O SFC: "

Return

/*/{Protheus.doc} P145INTQIP
Executa a integração das ordens de produção com o módulo de qualidade (QIP)

@type Function
@author lucas.franca
@since 30/09/2021
@version P12
@param 01 cTicket  , Caracter, Ticket de execução do MRP
@param 02 aDadosOP , Array   , Array com os dados das ordens de produção que serão integradas
@return Nil
/*/
Function P145INTQIP(cTicket, aDadosOP)
	Local lIntOPInt := SuperGetMV("MV_QPOPINT",.F.,.T.)
	Local nPercent  := 0
	Local nIndex    := 0
	Local nTempo    := 0
	Local nTotal    := 0

	//Variável utilizada nos fontes do QIP.
	Private Inclui := .T.

	PutGlbValue(cTicket + "STATUS_QIP_INCLUSAO", "INI")
	PutGlbValue(cTicket + "STATUS_QIP_INCLUSAO_PERCENT", "0")

	ProcessaDocumentos():msgLog(STR0041)  //"INICIANDO INTEGRAÇÃO COM O QIP"
	nTempo := MicroSeconds()

	nTotal := Len(aDadosOP)
	ProcessaDocumentos():msgLog(STR0042 + cValToChar(nTotal))  //"INTEGRAÇÃO COM O QIP - QUANTIDADE DE ORDENS DE PRODUÇÃO: "
	
	For nIndex := 1 To nTotal
		SC2->(dbGoTo(Val(aDadosOP[nIndex][1])))

		If SC2->C2_TPOP == "F" .And. ( lIntOPInt .Or. ( !lIntOPInt .And. Empty(SC2->C2_SEQPAI) ) )
			OPGeraQIP()
		EndIf

		nPercent := Round((nIndex/nTotal) * 100, 2)
		PutGlbValue(cTicket + "STATUS_QIP_INCLUSAO_PERCENT", cValToChar(nPercent))
	Next nIndex

	aSize(aDadosOP, 0)

	PutGlbValue(cTicket + "STATUS_QIP_INCLUSAO", "FIM")
	PutGlbValue("P145INTQIP", "FIM")

	ProcessaDocumentos():msgLog(STR0043 + cValToChar(MicroSeconds()-nTempo))  //"TEMPO PARA EXECUTAR A INTEGRAÇÃO COM O QIP: "
Return

/*/{Protheus.doc} P145EndInt
Limpa as variaveis globais de integração.
@type  Static Function
@author Lucas Fagundes
@since 23/03/2022
@version P12
@param cTicket, Caracter, Ticket que está na geração de documentos
@return Nil
/*/
Static Function P145EndInt(cTicket)
	ClearGlbValue(cTicket + "STATUS_MES_INCLUSAO")
	ClearGlbValue(cTicket + "STATUS_SFC_INCLUSAO")
	ClearGlbValue(cTicket + "STATUS_QIP_INCLUSAO")
	ClearGlbValue(cTicket + "STATUS_QIP_INCLUSAO_PERCENT")	
Return Nil
