#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE QTD_MAX_THREADS 8

Static __aCodApi := Nil
Static __cAPIs   := ""
Static __cError  := ""
Static __cIDThr  := ""
Static __cUUID   := ""
Static __nSizeID := Nil
Static __cTicket := Nil

/*/{Protheus.doc} PCPA141
SCHEDULE de envio de dados para o MRP

@type  Static Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
/*/
Function PCPA141()
	Local cApi := AllTrim(MV_PAR01)

	PCPA141RUN(cApi)
Return

/*/{Protheus.doc} SchedDef
Parametrizações do SCHEDULE de envio de dados do MRP

@type  Static Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
@return aParam, Array, Array com os parâmetros para execução do schedule
/*/
Static Function SchedDef()
	Local aOrd   := {}
	Local aParam := {}

	cargaAPI()

	aParam := { "P",;
	            "PCPA141",;
	            "T4R",;
	            aOrd, }
Return aParam

/*/{Protheus.doc} cargaAPI
Verifica se é necessário carregar dados na tabela T4P para
exibir na consulta padrão da configuração da API.

@type  Static Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
/*/
Static Function cargaAPI()
	Local cFil    := xFilial("T4P")
	Local nTamApi := GetSx3Cache("T4P_API","X3_TAMANHO")
	Local nIndex  := 0

	If __aCodApi == Nil
		__aCodApi := RetApiZoom()
	EndIf

	T4P->(dbSetOrder(1))

	For nIndex := 1 To Len(__aCodApi)
		If ! T4P->(dbSeek(cFil+PadR(__aCodApi[nIndex][1], nTamApi)))
			RecLock("T4P",.T.)
				T4P->T4P_FILIAL := cFil
				T4P->T4P_API    := PadR(__aCodApi[nIndex][1], nTamApi)
				T4P->T4P_ATIVO  := "2"
			MsUnLock()
		EndIf
	Next nIndex
	T4P->(dbGoTop())
Return

/*/{Protheus.doc} PCPA141VLD
Verifica se o valor digitado no pergunte PCPA141 está válido.

@type  Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
@return lRet, Logic, Identifica se o valor digitado está válido.
/*/
Function PCPA141VLD()
	Local cValAPI := AllTrim(MV_PAR01)
	Local lRet    := .T.

	If __aCodApi == Nil
		__aCodApi := RetApiZoom()
	EndIf

	If aScan(__aCodApi, {|x| x[1] == cValAPI}) <= 0
		lRet := .F.
		HELP(' ', 1, "HELP",, STR0001,; //"API informada não é válida para o processamento."
		     2, 0, , , , , , {STR0002}) //"Informe um código de API que seja válido para a execução dos processos."
	EndIf

Return lRet

/*/{Protheus.doc} PCPA141DSC
Retorna a descrição de uma API

@type  Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
@param cApi  , Character, Código da API
@return cDesc, Character, Descrição da API
/*/
Function PCPA141DSC(cApi)
	Local cDesc := ""
	Local nPos  := 0

	If __aCodApi == Nil
		__aCodApi := RetApiZoom()
	EndIf

	cApi := AllTrim(cApi)

	nPos :=  aScan(__aCodApi, {|x| x[1] == cApi})
	If nPos > 0
		cDesc := __aCodApi[nPos][2]
	EndIf
Return cDesc

/*/{Protheus.doc} PCPA141RUN
Executa o processamento das APIs

@type  Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
@param 01 cApi    , Character, Código da API
@param 02 nTotPend, Numeric  , Quantidade de registros pendentes
@param 03 cTicket , caracter , Número do ticket em execução (usado no processamento das pendências pelo PCPA712)
@return Nil
/*/
Function PCPA141RUN(cApi, nTotPend, cTicket)
	Local cErrorUID  := ""
	Local cId        := UUIDRandomSeq()
	Local lMultiThr  := .F.
	Local lOnline    := .T.
	Local nQtdMarcad := 0
	Local nQtdErros  := 0
	Local nThreads   := 1
	Local oErros     := JsonObject():New()
	Default nTotPend := 0
	Default cTicket  := "000000"

	//Se a integração está desativada, não executa o JOB
	If !IntNewMRP(cApi, @lOnline)
		Return
	EndIf

	//Se a API está configurada como Online, não executa o JOB
	If lOnline .And. cApi != "MRPBILLOFMATERIAL"
		Return
	EndIf

	If __nSizeID == Nil
		__nSizeID := GetSx3Cache("T4R_IDPRC", "X3_TAMANHO")
	EndIf

	cId := PadR(cId, __nSizeID)

	__cUUID := cId

	//Se está processndo as pendências através do PCPA712, faz o controle de lock
	If cTicket <> "000000"
		PCPLock("PCPA712_PCPA141" + cApi)
	EndIf

	__cError := ""

	ErrorBlock({|e| A141Error(e, cApi) })

	Begin Sequence
		PCPLock("PCPA141_" + __cUUID)
		If marcarT4R(cApi, @nQtdMarcad)
			P141AttGlb(cApi, 0, nQtdMarcad)

			If cApi == "MRPPRODUCTIONORDERS" .Or. ;
			   cApi == "MRPPURCHASEORDER"    .Or. ;
			   cApi == "MRPALLOCATIONS"      .Or. ;
			   cApi == "MRPSTOCKBALANCE"     .Or. ;
			   cApi == "MRPPURCHASEREQUEST"
				lMultiThr := IIf(nQtdMarcad > 1000, .T., .F.)
			EndIf

			If lMultiThr
				__cIDThr  := "P141_" + Left(__cUUID, 5)
				cErrorUID := "P141_" + cApi

				//Calcula a quantidade ideal de threads
				nThreads := Int(nQtdMarcad / 1000) + 1
				If nThreads > QTD_MAX_THREADS
					nThreads := QTD_MAX_THREADS
				EndIf

				//Inicializa as Threads
				PCPIPCStart(__cIDThr, nThreads, 0, cEmpAnt, cFilAnt, cErrorUID)
			EndIf

			Do Case
				Case cApi == "MRPDEMANDS"
					oErros := PCPA141DEM(__cUUID)             //Demandas
				Case cApi == "MRPPURCHASEORDER"
					oErros := PCPA141SCO(__cUUID, lMultiThr)  //Solicitação de compra
				Case cApi == "MRPPURCHASEREQUEST"
					oErros := PCPA141OCO(__cUUID, lMultiThr)  //Pedido de compra
				Case cApi == "MRPALLOCATIONS"
					oErros := PCPA141EMP(__cUUID, lMultiThr)  //Empenhos
				Case cApi == "MRPPRODUCTIONORDERS"
					oErros := PCPA141OP(__cUUID, lMultiThr)   //Ordem de produção
				Case cApi == "MRPSTOCKBALANCE"
					oErros := PCPA141EST(__cUUID,, lMultiThr) //Estoque
				Case cApi == "MRPREJECTEDINVENTORY"
					PCPA141CQ(__cUUID)                        //Estoque Rejeitado
				Case cApi == "MRPPRODUCTIONVERSION"
					oErros := PCPA141VEP(__cUUID)             //Versão da Produção
				Case cApi == "MRPWAREHOUSE"
					oErros := PCPA141AMZ(__cUUID)             //Armazém
				Case cApi == "MRPPRODUCT"
					oErros := PCPA141PRD(__cUUID)             //Produtos
				Case cApi == "MRPPRODUCTINDICATOR"
					PCPA141IPR(__cUUID)                       //Indicadores de Produtos
				Case cAPi == "MRPBILLOFMATERIAL"
					P200RepAll(__cUUID)                       //Estrutura
			EndCase

			If lMultiThr
				PCPIPCFinish(__cIDThr, 100, nThreads)
			EndIf

			//Verifica se houve error.log que tenha derrubado algum processamento
			If oErros:HasProperty("ERROR_LOG")
				nQtdErros += oErros["ERROR_LOG"]
			EndIf

			//Verifica se houve erro na leitura/conteúdo do Json
			If oErros:HasProperty("ERRO_JSON")
				nQtdErros += Len(oErros["ERRO_JSON"])
			EndIf

			If nQtdErros > 0
				P141SetGlb(cTicket, cApi, {cApi, nTotPend, "ERRO", nQtdMarcad, nQtdMarcad - nQtdErros, STR0018}) //"Erro durante o processamento das informações."
				PCPA141ERR( , , __cUUID, cApi, oErros)
			Else
				P141SetGlb(cTicket, cApi, {cApi, nTotPend, "FIM" , nQtdMarcad, nQtdMarcad, ""})
			EndIf

		Else
			P141SetGlb(cTicket, cApi, {cApi, nTotPend, "ERRO", nQtdMarcad, 0, STR0004}) //"Erro ao marcar os registros para processamento. "
		EndIf
		PCPUnLock("PCPA141_" + __cUUID)

	RECOVER
		P141SetGlb(cTicket, cApi, {cApi, nTotPend, "ERRO", nQtdMarcad, 0, IIf(Empty(__cError), STR0018, __cError)}) //"Erro durante o processamento das informações."

		If !Empty(__cUUID)
			StartJob("PCPA141ERR", GetEnvServer(), .T., cEmpAnt, cFilAnt, __cUUID, cApi)
		EndIf
		If !Empty(__cError)
			Final(STR0018, __cError) //"Erro durante o processamento das informações."
		EndIf
	End Sequence

	__cUUID := ""

	FreeObj(oErros)
	oErros := Nil
Return Nil

/*/{Protheus.doc} A141Error
Função para tratativa de erros de execução

@type  Function
@author lucas.franca
@since 09/08/2019
@version P12.1.28
@param e    , Object  , Objeto com os detalhes do erro ocorrido
@param cApi , Caracter, codigo da API
/*/
Function A141Error(e, cApi)
	Local oPCPLock   := PCPLockControl():New()

	__cError := AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10) + AllTrim(e:ErrorEnv)

	LogMsg('PCPA141RUN', 0, 0, 1, '', '', ;
	       Replicate("-",70) + CHR(10) + __cError + CHR(10) + Replicate("-",70))
	oPCPLock:unlock("MRP_MEMORIA", "PCPA141", cApi)
	BREAK
Return

/*/{Protheus.doc} PCPA141ERR
Em caso de erro na execução, libera o campo T4R_IDPRC para que os registros não fique travado.

@type  Function
@author lucas.franca
@since 09/08/2019
@version P12.1.28
@param 01 cEmp  , Character, Código da empresa para conexão (somente caso não tenha conexão - nova thread)
@param 02 cFil  , Character, Código da filial para conexão (somente caso não tenha conexão - nova thread)
@param 03 cUUID , Character, Código identificador do processo na tabela T4R
@param 04 cApi  , Character, Código da API em processamento
@param 05 oErros, Objeto   , Registros que tiveram erro de integração
@return Nil
/*/
Function PCPA141ERR(cEmp, cFil, cUUID, cApi, oErros)
	Local cSql       := ""
	Local cSqlUpdate := ""
	Local cSqlSet    := ""
	Local cSqlSetAux := ""
	Local cSqlWhere  := ""
	Local cSqlWhrAux := ""
	Local nIndex     := 1
	Local nTotal     := 0
	
	Default oErros   := JsonObject():New()

	//Se passou a empresa é porque precisa conectar o ambiente
	If !Empty(cEmp)
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
	EndIf

	//Se já existir registros com o IDPRC diferente do atual, exclui os registros
	//da T4R que estão com o IDPRC igual o atual.
	cSql := "UPDATE " + RetSqlName("T4R")
	cSql +=   " SET D_E_L_E_T_   = '*', "
	cSql +=       " R_E_C_D_E_L_ = R_E_C_N_O_ "
	cSql += " WHERE T4R_FILIAL = '" + xFilial("T4R") + "' "
	cSql +=   " AND T4R_API    = '" + cApi + "' "
	cSql +=   " AND T4R_IDPRC  = '" + cUUID + "' "
	cSql +=   " AND D_E_L_E_T_ = ' ' "
	cSql +=   " AND T4R_IDREG IN (SELECT T4R.T4R_IDREG "
	cSql +=                       " FROM " + RetSqlName("T4R") + " T4R "
	cSql +=                      " WHERE T4R_FILIAL = '" + xFilial("T4R") + "' "
	If cApi == "MRPPRODUCT"
		cSql +=                    " AND (T4R_API = 'MRPPRODUCT' OR T4R_API = 'MRPPRODUCTINDICATOR') "
	Else
		cSql +=                    " AND T4R_API    = '" + cApi + "' "
	EndIf
	cSql +=                        " AND D_E_L_E_T_ = ' '"
	cSql +=                        " AND T4R_IDPRC <> '" + cUUID + "' )"

	If TcSqlExec(cSql) < 0
		Final(STR0003, TcSqlError()) //"Erro ao restaurar os dados de pendências."
	EndIf

	//Limpa o campo T4R_IDPRC dos registros que estão ligados a este processamento
	cSqlUpdate  := "UPDATE " + RetSqlName("T4R")
	cSqlSet     +=   " SET T4R_IDPRC = ' '"
	cSqlWhere   += " WHERE T4R_FILIAL = '" + xFilial("T4R") + "'"
	cSqlWhere   +=   " AND D_E_L_E_T_ = ' '"
	If cApi == "MRPPRODUCT"
		cSqlWhere += " AND (T4R_API = 'MRPPRODUCT' OR T4R_API = 'MRPPRODUCTINDICATOR')"
	Else
		cSqlWhere += " AND T4R_API  = '" + cApi + "'"
	EndIf
	cSqlWhere +=     " AND T4R_IDPRC = '" + cUUID + "'"

	//Verifica se vai inserir erros específicos para os registros
	If oErros:HasProperty("ERRO_JSON") .And. ValType(oErros["ERRO_JSON"]) == "A"
		nTotal := Len(oErros["ERRO_JSON"])

		For nIndex := 1 To nTotal
			cSqlSetAux := ", T4R_MSGRET = '" + PadR(oErros["ERRO_JSON"][nIndex][2], 200) + "'"
			cSqlWhrAux := " AND R_E_C_N_O_ = " + cValToChar(oErros["ERRO_JSON"][nIndex][1])

			cSql := cSqlUpdate + cSqlSet + cSqlSetAux + cSqlWhere + cSqlWhrAux
			If TcSqlExec(cSql) < 0
				Final(STR0003, TcSqlError()) //"Erro ao restaurar os dados de pendências."
			EndIf
		Next nIndex
	EndIf

	If oErros:HasProperty("ERROR_LOG") .And. !Empty(__cError)
		cSqlSet += ", T4R_MSGRET = '" + PadR(__cError, 200) + "'"
	EndIf

	cSql := cSqlUpdate + cSqlSet + cSqlWhere
	If TcSqlExec(cSql) < 0
		Final(STR0003, TcSqlError()) //"Erro ao restaurar os dados de pendências."
	EndIf

Return Nil

/*/{Protheus.doc} marcarT4R
Marca os registros da tabela T4R que serão processados
por este processo.

@type  Static Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
@param 01 cApi    , Character, Código da API
@param 02 nQtdMarcad, Numeric  , Quantidade de registros que serão processados (retorna por referência)
@return   lRet    , Logic    , Indica se conseguiu marcar os registros da T4R
/*/
Static Function marcarT4R(cApi, nQtdMarcad)
	Local cAlias     := PCPAliasQr()
	Local cT4R       := RetSqlName("T4R")
	Local cSql       := ""
	Local cId        := __cUUID
	Local lRet       := .T.
	Local lRegUpd    := .F.
	Local nTentativa := 1

	cSql := "SELECT R_E_C_N_O_ REC"
	cSql +=  " FROM " + cT4R
	cSql += " WHERE T4R_FILIAL = '" + xFilial("T4R") + "'"
	cSql +=   " AND T4R_IDPRC  = ' '"
	cSql +=   " AND D_E_L_E_T_ = ' '"
	If !(cApi $ "|MRPALLOCATIONS|MRPBILLOFMATERIAL|")
		cSql +=   " AND T4R_STATUS = '3'"
	EndIf

	If cApi == "MRPPRODUCT"
		cSql += " AND (T4R_API  = 'MRPPRODUCT' OR T4R_API = 'MRPPRODUCTINDICATOR')"
	ElseIf cApi == "MRPSTOCKBALANCE"
		cSql += " AND (T4R_API  = 'MRPSTOCKBALANCE' OR T4R_API = 'MRPREJECTEDINVENTORY')"
	Else
		cSql += " AND T4R_API   = '" + cApi + "' "
	EndIf

	If !SemafAPI(cApi, .T.)
		Return .F.
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cAlias,.F.,.F.)

	While (cAlias)->(!Eof()) .And. lRet
		nTentativa := 1

		cSql := " UPDATE " + cT4R
		cSql +=    " SET T4R_IDPRC = '" + cId + "' "
		cSql +=  " WHERE R_E_C_N_O_ = " + cValToChar((cAlias)->REC)

		For nTentativa := 1 To 10
			T4R->(dbGoTo((cAlias)->REC))
			If !T4R->(Deleted())
				If TcSqlExec(cSql) < 0
					If nTentativa == 10
						If !lRegUpd
							lRet := .F.
						EndIf
						LogMsg('PCPA141RUN', 0, 0, 1, '', '', STR0004 + TcSqlError()) //"Erro ao marcar os registros para processamento. "
						Exit
					Else
						T4R->(dbGoTo((cAlias)->REC))
						If T4R->(Deleted())
							Exit
						EndIf
						If existT4r(T4R->T4R_FILIAL, T4R->T4R_API, T4R->T4R_IDREG, cId)
							Exit
						EndIf
						LogMsg('PCPA141RUN', 0, 0, 1, '', '', STR0015 + cValToChar(nTentativa)          + ; //"Falha ao atualizar registro. Será executada nova tentativa. Tentativa atual: "
						                                      STR0016 + cValToChar((cAlias)->REC) + "." + ; //" RECNO Registro: "
															  STR0017 + TcSqlError())                       //" Erro: "
						Sleep(500)
					EndIf
				Else
					lRegUpd := .T.
					Exit
				EndIf
			Else
				Exit
			EndIf
		Next nTentativa
		nQtdMarcad++
		(cAlias)->(dbSkip())
	End

	SemafAPI(cApi, .F.)

Return lRet

/*/{Protheus.doc} existT4r
Verifica se existe registro para a chave na tabela T4R
@type Static Function
@author lucas.franca
@since 25/06/2021
@version P12
@param 01 cFil  , Character, Código da filial da T4R
@param 02 cApi  , Character, Código da API
@param 03 cIdReg, Character, ID do registro na T4R
@param 04 cIdPrc, Character, ID do processamento da pendência
@return lExiste, Logic, Indica se o registro existe na T4R
/*/
Static Function existT4r(cFil, cApi, cIdReg, cIdPrc)
	Local cAlias  := PCPAliasQr()
	Local lExiste := .F.

	BeginSql Alias cAlias
		%noparser%
		SELECT COUNT(*) TOTAL
		  FROM %Table:T4R%
		 WHERE %NotDel%
		   AND T4R_FILIAL = %Exp:cFil%
		   AND T4R_API    = %Exp:cApi%
		   AND T4R_IDREG  = %Exp:cIdReg%
		   AND T4R_IDPRC  = %Exp:cIdPrc%
	EndSql
	If (cAlias)->(TOTAL) > 0
		lExiste := .T.
	EndIf
	(cAlias)->(dbCloseArea())
Return lExiste

/*/{Protheus.doc} SemafAPI
Controle de semáforo para marcar as APIs para processamento

@type  Static Function
@author lucas.franca
@since 29/07/2021
@version P12
@param cApi , Character, Código da API em processamento
@param lLock, Logic    , Identifica se deve fazer o bloqueio, ou liberar o bloqueio.
@return lRet, Logic    , Identifica se obteve o lock
/*/
Static Function SemafAPI(cApi, lLock)
	Local cChave := AllTrim(cEmpAnt + "T4R_IDPRC" + cApi)
	Local lRet   := .T.
	Local nTry   := 0

	If lLock
		While !LockByName(cChave,.T.,.F.)
			nTry++
			If nTry > 500
				Return .F.
			EndIf
			Sleep(500)
		End
	Else
		UnLockByName(cChave,.T.,.F.)
	EndIf
Return lRet

/*/{Protheus.doc} RetApiZoom
Retorna as Api´s que serão mostradas no zoom do schedule

@type  Static Function
@author ricardo.prandi
@since 27/12/2019
@version P12.1.27
@return aRet, Array, Array contendo as Api´s que serão mostradas no zoom
/*/
Static Function RetApiZoom()

	aRet := {}

	aAdd(aRet,{"MRPDEMANDS"          ,P139GetAPI("MRPDEMANDS"          )}) //"Demandas"
    aAdd(aRet,{"MRPPRODUCTIONVERSION",P139GetAPI("MRPPRODUCTIONVERSION")}) //"Versão da Produção"
    aAdd(aRet,{"MRPBILLOFMATERIAL"   ,P139GetAPI("MRPBILLOFMATERIAL"   )}) //"Estruturas"
    aAdd(aRet,{"MRPALLOCATIONS"      ,P139GetAPI("MRPALLOCATIONS"      )}) //"Empenhos"
    aAdd(aRet,{"MRPPRODUCTIONORDERS" ,P139GetAPI("MRPPRODUCTIONORDERS" )}) //"Ordens de produção"
    aAdd(aRet,{"MRPPURCHASEORDER"    ,P139GetAPI("MRPPURCHASEORDER"    )}) //"Solicitações de Compras"
    aAdd(aRet,{"MRPPURCHASEREQUEST"  ,P139GetAPI("MRPPURCHASEREQUEST"  )}) //"Pedidos de Compras"
    aAdd(aRet,{"MRPSTOCKBALANCE"     ,P139GetAPI("MRPSTOCKBALANCE"     )}) //"Saldo em Estoque"
    aAdd(aRet,{"MRPCALENDAR"         ,P139GetAPI("MRPCALENDAR"         )}) //"Calendário"
	aAdd(aRet,{"MRPPRODUCT"          ,P139GetAPI("MRPPRODUCT"          )}) //"Produtos"
	If FWAliasInDic("HWY", .F.)
		aAdd(aRet,{"MRPWAREHOUSE"        ,P139GetAPI("MRPWAREHOUSE"        )}) //"Armazéns"
	EndIf
Return aRet

/*/{Protheus.doc} PCPA141FIL
Filtra as APIs listadas no Zoom do Schedule

@type  Static Function
@author brunno.costa
@since 15/07/2020
@version P12.1.27
@return lReturn, logico, indica se o registro atualmente posicionado deve ser exibido no zoom do schedule
/*/
Function PCPA141FIL()

	Local lReturn := .T.

	If Empty(__cAPIs)
		__cAPIs += "|MRPDEMANDS|"           //"Demandas"
		__cAPIs += "|MRPPRODUCTIONVERSION|" //"Versão da Produção"
		__cAPIs += "|MRPBILLOFMATERIAL|"    //"Estruturas"
		__cAPIs += "|MRPALLOCATIONS|"       //"Empenhos"
		__cAPIs += "|MRPPRODUCTIONORDERS|"  //"Ordens de produção"
		__cAPIs += "|MRPPURCHASEORDER|"     //"Solicitações de Compras"
		__cAPIs += "|MRPPURCHASEREQUEST|"   //"Pedidos de Compras"
		__cAPIs += "|MRPSTOCKBALANCE|"      //"Saldo em Estoque"
		__cAPIs += "|MRPCALENDAR|"          //"Calendário"
		__cAPIs += "|MRPPRODUCT|"           //"Produtos"
		__cAPIs += "|MRPWAREHOUSE|"         //"Armazéns"
	EndIf

	lReturn := "|" + AllTrim(Upper(T4P->T4P_API)) + "|" $ __cAPIs .AND. T4P->T4P_TPEXEC == "2"

Return lReturn

/*/{Protheus.doc} P141IdThr
Retorna o identificador da fila de threads

@type Function
@author marcelo.neumann
@since 21/04/2022
@version P12
@return __cIDThr, caracter, identificador da fila de threads
/*/
Function P141IdThr()

Return __cIDThr

/*/{Protheus.doc} P141IniGlb
Inicializa sessão das variáveis globais de controle do processamento

@type Static Function
@author marcelo.neumann
@since 06/05/2022
@version P12
@param cTicket, Caracter, Número do ticket do MRP em execução
@return Nil
/*/
Function P141IniGlb(cTicket)

	If cTicket <> "000000"
		PCPLockPen("LOCK", cTicket)
		VarSetUID(cTicket + "PCPA141")
		PutGlbValue("PCPA141_TICKET", cTicket)
	EndIf

Return

/*/{Protheus.doc} limpaGlb
Limpa as variáveis globais de controle do processamento

@type Static Function
@author marcelo.neumann
@since 06/05/2022
@version P12
@param cTicket, Caracter, Número do ticket do MRP em execução
@return Nil
/*/
Static Function limpaGlb(cTicket)

	If cTicket <> "000000"
		Sleep(5000)
		VarClean(cTicket + "PCPA141")
		ClearGlbValue("PCPA141_TICKET")
		PCPLockPen("UNLOCK", cTicket)
	EndIf

Return

/*/{Protheus.doc} P141SetGlb
Seta variável global de controle do processamento

@type Static Function
@author marcelo.neumann
@since 06/05/2022
@version P12
@param 01 cTicket   , Caracter, Número do ticket em execução (usado no processamento das pendências pelo PCPA712)
@param 02 cApi      , Caracter, Código da API em processamento
@param 03 aNewStatus, Array   , Status do processamento a ser gravado na global
@return Nil
/*/
Function P141SetGlb(cTicket, cApi, aNewStatus)
	Local aAPIsProc  := {}
	Local aOldStatus := {}
	Local lTiraLock  := .T.
	Local nIndex     := 0
	Local nTotal     := 0

	If cTicket <> "000000"
		If !(VarGetAD(cTicket + "PCPA141", cApi, aOldStatus)) .Or. ;
		   (aNewStatus[PCPInMrpCn("API_PEND_STATUS")] <> aOldStatus[PCPInMrpCn("API_PEND_STATUS")])

			//Atualiza a global com o novo status
			VarSetAD(cTicket + "PCPA141", cApi, aNewStatus)

			//Se terminou o processamento, verifica as demais threads para remover o lock
			If aNewStatus[PCPInMrpCn("API_PEND_STATUS")] == "FIM" .Or. aNewStatus[PCPInMrpCn("API_PEND_STATUS")] == "ERRO"
				//Tira o lock da API do License Server
				PCPUnLock("PCPA712_PCPA141" + cApi)

				//Se alguma ainda estiver em execução, não remove o lock
				aAPIsProc := P141GetGlb(cTicket)
				nTotal    := Len(aAPIsProc)
				For nIndex := 1 To nTotal
					If aAPIsProc[nIndex][PCPInMrpCn("API_PEND_STATUS")] == "INI"
						lTiraLock := .F.
						Exit
					EndIf
				Next nIndex

				If lTiraLock
					limpaGlb(cTicket)
				EndIf
			EndIf
		EndIf

		FwFreeArray(aOldStatus)
	EndIf

Return

/*/{Protheus.doc} P141AttGlb
Atualiza a variável global de controle do processamento

@type Static Function
@author marcelo.neumann
@since 06/05/2022
@version P12
@param 01 cApi      , Caracter, Código da API a ser atualizada
@param 02 nQtdProc  , Numeric , Quantidade de registros processados
@param 03 nQtdMarcad, Numeric , Quantidade de registros marcados que serão processados (opcional)
@return Nil
/*/
Function P141AttGlb(cApi, nQtdProc, nQtdMarcad)
	Local aStatus := {}

	If __cTicket == Nil
		__cTicket := GetGlbValue("PCPA141_TICKET")
	EndIf

	If !Empty(__cTicket)
		If VarGetAD(__cTicket + "PCPA141", cApi, aStatus)
			If nQtdMarcad <> Nil
				aStatus[PCPInMrpCn("API_PEND_MARCADOS")] := nQtdMarcad
			EndIf

			aStatus[PCPInMrpCn("API_PEND_PROCESSADOS")] += nQtdProc

			VarSetAD(__cTicket + "PCPA141", cApi, aStatus)
		EndIf
	EndIf

Return

/*/{Protheus.doc} P141GetGlb
Retorna o valor da variável global de controle do processamento

@type Static Function
@author marcelo.neumann
@since 06/05/2022
@version P12
@param cTicket , Caracter, Número do ticket do processamento das pendências
@return aRetAPI, Array   , APIs em processamento
/*/
Function P141GetGlb(cTicket)
	Local aAPIs   := {}
	Local aRetAPI := {}
	Local nIndex  := 1
	Local nTotal  := 0

	If VarGetAA(cTicket + "PCPA141", @aAPIs)
		nTotal := Len(aAPIs)
		For nIndex := 1 To nTotal
			aAdd(aRetAPI, aClone(aAPIs[nIndex][2]))
		Next nIndex
	EndIf

	FwFreeArray(aAPIs)

Return aRetAPI

/*/{Protheus.doc} P141Intgra
Chama a função de integração, atualizando a quantidade processada

@type Function
@author marcelo.neumann
@since 30/08/2022
@version P12
@param 01 cApi     , Character, Função de integração da API
@param 02 nQtdRegs , Numeric  , Quantidade de registros que serão integrados (para atualizar o percentual)
@param 03 cFuncao  , Character, Dados a serem integrados
@param 04 cGlbErros, Character, Nome da global que armazena a quantidade de erros
@param 05 xPar1    , Undefined, 1o Parâmetro a ser passado para a função "cFuncao"
@param 06 xPar2    , Undefined, 2o Parâmetro a ser passado para a função "cFuncao"
@param 07 xPar3    , Undefined, 3o Parâmetro a ser passado para a função "cFuncao"
@param 08 xPar4    , Undefined, 4o Parâmetro a ser passado para a função "cFuncao"
@param 09 xPar5    , Undefined, 5o Parâmetro a ser passado para a função "cFuncao"
@param 10 xPar6    , Undefined, 6o Parâmetro a ser passado para a função "cFuncao"
@return Nil
/*/
Function P141Intgra(cApi, nQtdRegs, cFuncao, cGlbErros, xPar1, xPar2, xPar3, xPar4, xPar5, xPar6)
	Local nQtdErros := Val(GetGlbValue(cGlbErros))

	cFuncao += "(xPar1, xPar2, xPar3, xPar4, xPar5, xPar6)"

	Begin Sequence
		&(cFuncao)
		P141AttGlb(cApi, nQtdRegs)

	RECOVER
		PutGlbValue(cGlbErros, cValToChar(nQtdErros+nQtdRegs))

	End Sequence

Return
