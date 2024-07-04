#Include "Protheus.ch"
#Include "Fina137F.ch"

Static lAutomato := .F.

/*/{Protheus.doc} FINA137F
Obtem o Json das operações TOTVS Mais Prazo

@author     Victor Furukawa
@version    1.0
@type       function
@since      21/01/2021
@param      aInfo, array, array contendo as informações da execução do job, sendo elas: 1-Empresa, 2-Filial
@param      oJSONAuto, Object, utilizado para realizar processamento de um JSON informado. Criado para testes automatizados.
@return     Logical, retorna .T. ou  .F. de acordo com o sucesso ou insucesso da operação
/*/

FUNCTION FINA137F(aInfo as Array, oJSONAuto) as Logical

	Local cUrl       	as Character
	Local cPath      	as Character
	Local cCnpj      	as Character
	Local cToken     	as Character
	Local cHttp      	as Character
	Local cCodEmp    	as Character
	Local cCodFil    	as Character
	Local cRet       	as Character
	Local lRet       	as Logical
	Local lBx        	as Logical
	Local lInc       	as Logical
	Local lAlt       	as Logical
	Local oTFConfig  	as Object
	Local oRestClient	as Object
	Local oJson      	as Object
	Local aHeader    	as Array
	Local aArea 	 	as Array
	Default aInfo       := {"", ""}
	Default oJSONAuto   := Nil

	SetFunName("FINA137F")
	FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", FwNoAccent(STR0001), 0, 0, {})

	oTFConfig   := Nil

	cUrl        := ""
	cPath       := ""
	cCnpj       := ""
	cToken      := ""
	cRet        := ""
	cHttp       := ""
	cCodEmp     := aInfo[1]
	cCodFil     := aInfo[2]
	lRet        := .T.
	lBx         := .T.
	lInc        := .T.
	lAlt        := .T.
	lAutomato   := ValType(oJSONAuto) == "J" //se teste automatizado
	aHeader     := {}
	aArea 		:= GetArea()

	If !lAutomato
		RpcSetEnv(cCodEmp, cCodFil, /*cUser*/, /*cPass*/, "FIN", FunName(), {"SA2", "SA6", "SE2", "SE5", "FKA", "FK1", "FK5", "FRV"})
		If LockByName("FINA137F", .T., .F.)
			cUrl := FwTotvsAppsRegistry():GetServiceURL("mais-prazo-boletos","2") //https://api-maisprazo.totvs.app/api/erp/v2/boletos
			If Empty(cUrl)
				lRet := .F.
				cMensagem := STR0002 // "URL de acesso TOTVS Mais Prazo não pode estar em branco."
				If IsBlind()
					FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", cMensagem, 0, 0, {})
				Else
					Help("", 1, "HELP", "HELP", cMensagem, 1,,,,,,, {})
				EndIf
				Return lRet
			EndIf

			cToken := FINA137E()   //Traz o Token valido para Comunicação com o TOTVS Techfin

			AAdd(aHeader, "Content-Type: application/json")
			AAdd(aHeader, "Authorization: Bearer " + cToken)
			AAdd(aHeader, "User-Agent: Protheus")

			oRestClient := FWRest():New(cURL)
			oRestClient:setPath(cPath)
			oJson :=  JsonObject():new()

			If oRestClient:Get(aHeader)   //Consumo da API da Techfin
				cRet       := oRestClient:GetResult()
				oJSON      := JSONObject():New()
				oJSON:FromJSON(cret)  //Carrega o objeto Json
			Else
				FwLogMsg("ERROR",, "TECHFIN", FunName(), "", "01", oRestClient:cResult,  0, 0, {})                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
				cHttp := oRestClient:GetHTTPCode()
				lRet  := .F.
				Return lRet
			Endif
			//Inicio das chamadas das funções para  | Baixa | Inclusão | Alteração | 
			lBx    := FA137BX(oJson)   //Baixa
			lInc   := FA137INC(oJson)  //Inclusão
			lAlt   := FA137ALT(oJson)  //Alteração

			RpcSetEnv(cCodEmp, cCodFil, /*cUser*/, /*cPass*/, "FIN", FunName(), {"SA2", "SA6", "SE2", "SE5", "FKA", "FK1", "FK5", "FRV"})
			UnLockByName("FINA137F", .T., .F. )
		Else
			FwLogMsg(STR0006,, STR0004, FunName(), "", "01", STR0005, 0, 0, {}) //INFO //TECHFIN SCHEDULER //Job já está em execução por outra instância   
		EndIf
	Else
		lBx    := FA137BX(oJSONAuto) //Baixa
		lInc   := FA137INC(oJSONAuto) //Inclusão
		lAlt   := FA137ALT(oJSONAuto) //Alteração
	EndIf

	RestArea(aArea)
	FreeObj(oTFConfig)
	FreeObj(oJSON)
	FreeObj(oRestClient)
	FreeObj(oJSONAuto)

	FwFreeArray(aHeader)
	FwFreeArray(aArea)
	If !lAutomato
		dbCloseall()
		RpcClearEnv()
	Endif

Return lRet


/*/{Protheus.doc} FA137BX
Efetua as Baixas dos titulos com solicitação de Pagamento
@author     Victor Furukawa
@version    1.0
@type       static function
@since      21/01/2021
@param      oJson, Object, Json que a Techfin disponibilizou para as Operações
@return     Logical, retorna .T. ou  .F. de acordo com o sucesso ou insucesso da operação
/*/

STATIC FUNCTION FA137BX(oJson) as Logical

	Local a       as numeric
	Local b       as numeric
	Local c       as Numeric
	Local d       as Numeric

	Local aBaixa    as Array
	Local aBaixa2   as Array
	Local aBaixa3   as Array
	Local aRetBx    as Array
	Local aRetbx2   as Array
	Local aEmpresas as Array

	Local cCnpj   as Character

	Local lRet    as Logical

	a  := 1
	b  := 1
	c  := 1
	d  := 1

	aBaixa    := {}
	aBaixa2   := {}
	aBaixa3   := {}
	aRetBx    := {}
	aRetbx2   := {}
	aEmpresas := {}

	lRet     := .T.

	cCnpj    := ""

	For a := 1 to Len(oJson)

		cCnpj      := oJson[a]["cnpj"]
		aEmpresas  := BuscaEmp(cCnpj)

		If len(aEmpresas) > 0

			If !lAutomato
				RpcClearEnv()
				RpcSetEnv(aEmpresas[1][1], aEmpresas[1][2]) //Seta a Empresa depois da Busca do Grupo de empresa e Filial
			Endif

			If Len(oJson[a]["boletos"]["pagos"]) > 0

				For b:= 1 to len(oJson[a]["boletos"]["pagos"])

					PrintLog(oJson[a]["boletos"]["pagos"][b], "FA137BX")

					aadd(aBaixa, cvaltochar(oJson[a]["boletos"]["pagos"][b]["erpId"]);
						+ "|" + cvaltochar(oJson[a]["boletos"]["pagos"][b]["dataMovimento"]);
						+ "|" + cvaltochar(oJson[a]["boletos"]["pagos"][b]["valor"]);
						+ "|" + STR0003 + Space(1) + cvaltochar(oJson[a]["boletos"]["pagos"][b]["numeroTransacao"]);
						+ "|" + cvaltochar(oJson[a]["boletos"]["pagos"][b]["platformId"]))

				Next

				For c:= 1 to len(abaixa)

					aBaixa2 := StrTokArr(strtran(aBaixa[c], "||" , "|"+ " " + "|"), "|")
					aadd(aBaixa3, {aBaixa2[1], aBaixa2[2], aBaixa2[3], aBaixa2[4], aBaixa2[5], aBaixa2[6], aBaixa2[7], aBaixa2[8], aBaixa2[9], aBaixa2[10], aBaixa2[11], aBaixa2[12]})

				Next

				//Chamada da Função de Baixa dos titulos
				//Array aBaixa3 contendo os dados dos titulos a serem baixados
				For d := 1 to len(aBaixa3)

					Begin Transaction

						aRetbx2 := {}
						aRetBx  := FaBaixaCp(aBaixa3[d], .T.)
						AADD(aRetBx2, {aRetbx[1][1], aRetbx[1][2], aRetbx[1][3], aBaixa3[d][12], "0"})  //Logico (sucesso ou insucesso), Codigo do Erro ou sucesso, Descrição do Resultado, PLataformaID, Operação "0" para baixa

						If !lAutomato
							lRet := FINA137G(aRetBx2)  //Chamada para o Post Techfin
							If !lRet
								DisarmTransaction()
							EndIf
						Endif

					End Transaction

				Next

			Endif

		Endif

		If !lAutomato
			RpcClearEnv()
		Endif

		aBaixa3 := {}
		aBaixa  := {}

	Next

	FwFreeArray(aBaixa)
	FwFreeArray(aBaixa2)
	FwFreeArray(aBaixa3)
	FwFreeArray(aRetBx)
	FwFreeArray(aRetbx2)
	FwFreeArray(aEmpresas)

Return lRet

/*/{Protheus.doc} FA137INC
Efetua as Inclusoes dos novos titulos conforme negociação TOTVS Mais Prazo
@author     Victor Furukawa
@version    1.0
@type       static function
@since      21/01/2021
@param      oJson, Obejct, Json que a Techfin disponibilizou para as Operações
@return     Logical, retorna .T. ou  .F. de acordo com o sucesso ou insucesso da operação
/*/

STATIC FUNCTION FA137INC(oJSON) as Logical

	Local a           As Numeric
	Local b           As Numeric
	Local c           As Numeric
	Local d           As Numeric

	Local aGerados    As Array
	Local aRetInc     As Array
	Local aBolOr2     As Array
	Local aBolOri     As Array
	Local aEmpresas   As Array
	Local aStatus     As Array

	Local cCodEmp     As Character
	Local cCodFil     As Character
	Local cCnpj       As Character

	Local lRet        As Logical
	Local lIOF        As Logical

	Local nQtdParc    As Numeric
	Local nVlrJurParc As Numeric
	Local nVlrJurTot  As Numeric
	Local nVlrJurAcm  As Numeric
	Local nVlrParc    As Numeric
	Local nVlrIOF     As Numeric
	Local nVlrIOFPar  As Numeric
	Local nVlrIOFAcm  As Numeric

	a           := 1
	b           := 1
	c           := 1
	d           := 1

	aGerados    := {}
	aRetInc     := {}
	aBolOr2     := {}
	aBolOri     := {}
	aEmpresas   := {}

	cCodEmp     := ""
	cCodFil     := ""
	cCnpj       := ""

	lRet        := .T.
	lIOF        := .F.

	nQtdParc    := 0
	nVlrJurParc := 0
	nVlrJurTot  := 0
	nVlrJurAcm  := 0
	nVlrParc    := 0
	nVlrIOF     := 0
	nVlrIOFPar  := 0
	nVlrIOFAcm  := 0

	For a := 1 to Len(oJson)

		aGerados := {}
		aRetInc  := {}
		aBolOr2  := {}
		aBolOri  := {}

		cCnpj     := oJson[a]["cnpj"]
		aEmpresas := BuscaEmp(cCnpj)

		If Len(aEmpresas) > 0

			cCodEmp := aEmpresas[1][1]
			cCodFil := aEmpresas[1][2]

			If !lAutomato
				RpcClearEnv()
				RpcSetEnv(cCodEmp, cCodFil, /*cUser*/, /*cPass*/, "FIN", FunName(), {"SA2", "SA6", "SE2", "SE5", "FKA", "FK1", "FK5", "FRV"})
			Endif
			If FKF->(ColumnPos("FKF_IOF")) > 0
				lIOF := .T.
			EndIf

			For b:= 1 to len(oJson[a]["boletos"]["gerados"])

				aGerados   := {}
				aBolOr2    := {}
				nVlrJurAcm := 0
				nVlrIOFAcm := 0

				PrintLog(oJson[a]["boletos"]["gerados"][b], "FA137INC")

				nQtdParc   := Len(oJson[a]["boletos"]["gerados"][b]["parcelas"])
				nVlrJurTot := oJson[a]["boletos"]["gerados"][b]["juros"]
				If lIOF
					nVlrIOF := oJson[a]["boletos"]["gerados"][b]["iof"]
					If nVlrIOF > 0 .And. nQtdParc > 1
						nVlrIOFPar := Round(nVlrIOF / nQtdParc , 2)
					Else
						nVlrIOFPar := nVlrIOF
					EndIf
				EndIf
				//Faz o rateio se tiver valor de juros e mais que uma parcela
				If nVlrJurTot > 0 .And. nQtdParc > 1
					nVlrJurParc := Round(nVlrJurTot / nQtdParc , 2)
				Else
					nVlrJurParc := nVlrJurTot
				EndIf

				For c:= 1 to nQtdParc

					If c == nQtdParc
						nVlrJurParc := nVlrJurTot - nVlrJurAcm
						If lIOF
							nVlrIOFPar := nVlrIOF - nVlrIOFAcm
						EndIf
					EndIf
					nVlrJurAcm += nVlrJurParc
					nVlrIOFAcm += nVlrIOFPar
					nVlrParc   := oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["valorParcela"] - nVlrJurParc

					aadd(aGerados,  { cvaltochar(oJson[a]["boletos"]["gerados"][b]["platformId"]);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["numeroTransacao"]);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["valorTotal"]);
						, cvaltochar(nVlrJurParc);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["numeroParcela"]);
						, cvaltochar(nVlrParc);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["dataVencimento"]);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["dataEmissao"]);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["numeroLinhaDigitavel"]);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["numeroCodigoBarras"]);
						, cvaltochar(oJson[a]["boletos"]["gerados"][b]["parcelas"][c]["historico"]);
						, cValToChar(nVlrIOFPar)})

				Next

				For d:= 1 to len(oJson[a]["boletos"]["gerados"][b]["boletoOrigem"])
					aBolOri := StrTokArr(strtran(oJson[a]["boletos"]["gerados"][b]["boletoOrigem"][d]["erpId"], "||" , "|"+ " " + "|"), "|")
					aadd(aBolOr2, {aBolOri[2], aBolOri[3], aBolOri[4], aBolOri[5] , aBolOri[6], aBolOri[7], aBolOri[8], 1000})
				Next

				If Len(aGerados) > 0

					Begin Transaction

						aStatus := {}
						aRetInc := FaIncSE2(aGerados, aBolOr2, .T., .F., lIOF)
						aAdd(aStatus,aRetInc[Len(aRetInc)])

						If !lAutomato
							lRet := FINA137G(aStatus) //Chamada do POST para informar o TECHFIN
							If !lRet
								DisarmTransaction()
							EndIf
						Endif

					End Transaction

				Endif

			Next

		Endif

		If !lAutomato
			RpcClearEnv()
		Endif

	Next

	FwFreeArray(aBolOr2)
	FwFreeArray(aBolOri)
	FwFreeArray(aEmpresas)
	FwFreeArray(aGerados)
	FwFreeArray(aRetInc)
	FwFreeArray(aStatus)

Return lRet

/*/{Protheus.doc} FA137ALT
Efetua alterações dos titulos TOTVS Mais Prazo, as alterações são:
    1) Data de Vencimento
    2) Inclusão de um valor acessorio, para implementar nos juros cobrados para essa prorrogação
    3) Novo Código de Barras 
    4) Nova Linha Digitável
@author     Victor Furukawa
@version    1.0
@type       static function
@since      21/01/2021
@param      oJson, Object, Json que a Techfin disponibilizou para as Operações
@return     Logical, retorna .T. ou  .F. de acordo com o sucesso ou insucesso da operação
/*/

STATIC FUNCTION FA137ALT(oJSON) as Logical

	Local cCnpj as Character

	Local aEmpresas  as Array
	Local aAlterados as Array
	Local aRetAlt    as Array
	Local aRetAlt2   as Array
	Local aVAAutP    as Array

	Local a          as Numeric
	Local b          as Numeric
	Local c          as Numeric

	Local _cCodVA    as Character
	Local _nValVA    as Character

	Local lRet       as Logical

	Private cTpParc  as Character

	a := 1
	b := 1
	c := 1

	lRet := .T.

	_cCodVA := ""
	_nValVA := ""
	cTpParc := ""

	aEmpresas  := {}
	aAlterados := {}
	aRetAlt    := {}
	aRetAlt2   := {}
	aVAAutP    := {}

	For a := 1 to Len(oJson)

		cCnpj      := oJson[a]["cnpj"]
		aEmpresas  := BuscaEmp(cCnpj)

		If Len(aEmpresas) > 0

			If !lAutomato
				RpcClearEnv()
				RpcSetEnv(aEmpresas[1][1], aEmpresas[1][2]) //Seta a Empresa depois da Busca do Grupo de empresa e Filial
			Endif

			cTpParc := GETMV("MV_1DUP")

			If len(oJson[a]["boletos"]["alterados"]) > 0

				aAlterados := {}

				For b:= 1 to len(oJson[a]["boletos"]["alterados"])

					PrintLog(oJson[a]["boletos"]["alterados"][b], "FA137ALT")

					aadd(aAlterados, {cvaltochar(oJson[a]["boletos"]["alterados"][b]["platformId"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["numeroTransacao"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["numeroParcela"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["novoValor"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["dataVencimento"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["numeroLinhaDigitavel"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["numeroCodigoBarras"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["juros"]);
						, cvaltochar(oJson[a]["boletos"]["alterados"][b]["historico"])})

				Next

				//Chamada da Função de Alteração
				//Array aAlterados contendo os titulos a serem alterado os valores / Codigo de Barras e Linha Digitavel / Vencimento e o- valor dos juros a serem incluidos em valores acessórios
				For c := 1 to len(aAlterados)

					_cCodVA := GetMv("MV_VATECF")     // Pega o código do Vlr Acessório

					_nValVA := val(aAlterados[c][8])  //Valor de Juros para ser inserido em valores acessórios

					aVAAutP := {}                     //Limpa o Array para mandar somente o Valor Acessorio

					Aadd(aVAAutP, {_cCodVA,_nValVA})

					If len(aAlterados) > 0

						If Substr(cTpParc,1,1) == "A" //No caso de o parâmetro MV_1DUP está configurado como Alfanumérico

							aAlterados[c][3] := BuscaParc(val(aAlterados[c][3]))

						Else

							aAlterados[c][3] := StrZero(aAlterados[c][3], TAMSX3("E2_PARCELA")[1])

						Endif

						Begin Transaction

							aRetAlt2 := {}
							aRetAlt  := FaAltSE2(aAlterados[c], aVAAutP)  //Chama a Função para Alterar o Titulo

							AADD(aRetAlt2, {aRetAlt[1][1], aRetAlt[1][2], aRetAlt[1][3], aRetAlt[1][5], aRetAlt[1][4]})

							If !lAutomato
								lRet := FINA137G(aRetAlt2) // Chamada do retorno ao TECHFIN
								If !lRet
									DisarmTransaction()
								EndIf
							Endif

						End Transaction

					Endif

				Next

			Endif

		Endif

		If !lAutomato
			RpcClearEnv()
		Endif

		FwFreeArray(aRetAlt)
		FwFreeArray(aVAAutP)

	Next

	FwFreeArray(aEmpresas)
	FwFreeArray(aAlterados)
	FwFreeArray(aRetAlt)
	FwFreeArray(aRetAlt2)
	FwFreeArray(aVAAutP)

Return lRet

/*/{Protheus.doc} BuscaParc 
Converte a parcela numerica em parcela alfanumérica, pois a TechFin somente envia parcelas Numericas

@author     Victor Furukawa
@version    1.0
@type       static function
@since      21/01/2021
@param      nNumParc, Numeric, Numero da Parcelas 
@return     cParcela, Character, retorna a parcela no formato alfanumérica
/*/

Static Function BuscaParc(nNumParc as Numeric) as Character  //Função utilizada para traduzir a parcela numerica, nos casos em que o Parâmetro MV_1DUP está configurado para parcelas AlfaNumericas

	Local cParcela  as Character
	Local a         as Numeric

	cParcela := cTpParc
	a        := 1
	nNumparc := nNumparc - 1

	For a := 1 to nNumParc
		cParcela := soma1(cParcela)
	Next

Return cParcela

/*/{Protheus.doc} BuscaEmp
Localiza a empresa e filial, por meio de um CNPJ

@author     Victor Furukawa
@version    1.0
@type       static function
@since      21/01/2021
@param      cCNPJ, Character, Cod. CNPJ
@return     aDadEmp, Array, Array com os dados das Empresas
    aDadEmp[1] - Cod da Empresa
    aDadEmp[2] - Cod Filial
/*/

Static Function BuscaEmp(cCNPJ as Character) as Array  //Busca a Filial com base no CNPJ

	Local a         as Numeric
	Local aDadEmp   as Array
	Local aEmpresas as Array

	a         := 1
	aDadEmp   := {}
	aEmpresas := FwLoadSM0()

	For a := 1 to Len(aEmpresas)
		If Alltrim(aEmpresas[a][18]) == cCNPJ
			Aadd(aDadEmp, {aEmpresas[a][1], aEmpresas[a][2]})
		Endif
	Next

	FwFreeArray(aEmpresas)

Return aDadEmp


/*/{Protheus.doc} PrintLog
Exibe no console as informações do JSON da parcela que está sendo executada.

@type       Function
@author     Rafael Riego
@since      15/01/2019
@version    P12.1.27
@param      oJSON, J, JSON a ser exibido no log
@param      cRotina, character, nome da rotina que está sendo executada 
@return     Nil
/*/
Static Function PrintLog(oJSON As J, cRotina As Character)

	Local cLogMsg   As Character

	Default oJSON   := Nil
	Default cRotina := ""

	cLogMsg := ""
	cTipo   := ""
	nChave  := 0
	nChaves := 0

	If ValType(oJSON) == "J"
		cLogMsg := CRLF + "[" + FwNoAccent(cRotina) + "]"
		cLogMsg += ReadJSON(oJSON)
		FwLogMsg("INFO",, "TECHFIN", FunName(), "", "01", cLogMsg, 0, 0, {})
	EndIf

Return Nil


/*/{Protheus.doc} ReadJSON
Exibe no console as informações do JSON da parcela que está sendo executada.

@type       Function
@author     Rafael Riego
@since      26/05/2019
@version    P12.1.27
@param      oJSON, J, JSON a ser exibido no log
@return     character, json simplicado para impressão
/*/
Static Function ReadJSON(oJSON As J) As Character

	Local aChaves   As Array

	Local cLogMsg   As Character
	Local cTipo     As Character

	Local nArray    As Numeric
	Local nChave    As Numeric
	Local nChaves   As Numeric

	Default oJSON := Nil

	cLogMsg := ""
	aChaves := oJSON:GetNames()
	nChaves := Len(aChaves)

	For nChave := 1 To nChaves
		cTipo   := ValType(oJSON[aChaves[nChave]])
		If cTipo == "A"
			cLogMsg += CRLF + aChaves[nChave] + ":"
			For nArray := 1 To Len(oJSON[aChaves[nChave]])
				If ValType(oJSON[aChaves[nChave]][nArray]) == "J"
					cLogMsg += CRLF + aChaves[nChave] + "[" + CValToChar(nArray) +  "]: {"
					cLogMsg += ReadJSON(oJSON[aChaves[nChave]][nArray])
					cLogMsg += "}"
				EndIf
			Next nArray
		Else
			cLogMsg += CRLF + aChaves[nChave] + ": "
			If cTipo == "C"
				If aChaves[nChave] == "history"
					cLogMsg += FwNoAccent(oJSON[aChaves[nChave]])
				Else
					cLogMsg += oJSON[aChaves[nChave]]
				EndIf
			ElseIf cTipo == "D"
				cLogMsg += DToC(oJSON[aChaves[nChave]])
			ElseIf cTipo == "N"
				cLogMsg += CValToChar(oJSON[aChaves[nChave]])
			ElseIf cTipo == "J"
				cLogMsg += ReadJSON(oJSON[aChaves[nChave]])
			EndIf
		EndIf
	Next nChave

	FwFreeArray(aChaves)

Return cLogMsg
