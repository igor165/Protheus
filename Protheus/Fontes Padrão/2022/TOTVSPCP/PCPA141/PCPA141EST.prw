#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE BUFFER_INTEGRACAO 1000

/*/{Protheus.doc} PCPA141EST
Executa o processamento dos registros de ESToque

@type  Function
@author lucas.franca
@since 07/08/2019
@version P12
@param 01 cUUID    , Caracter, Identificador do processo para buscar os dados na tabela T4R
@param 02 cStatus  , Caracter, Identificador do status para buscar os dados na tabela T4R (default = '3')
@param 03 lMultiThr, Lógico  , Indica se o processamento será multi-thread
@return oErros     , Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141EST(cUUID, cStatus, lMultiThr)
	Local aDados      := {}
	Local aDadosInc   := {}
	Local aDadosDel   := {}
	Local aSuccess    := {}
	Local aError      := {}
	Local cAlias      := PCPAliasQr()
	Local cBanco      := AllTrim(Upper(TcGetDb()))
	Local cChave      := ""
	Local cGlbErros   := "ERROS_141" + cUUID
	Local cQuery      := ""
	Local cQueryOri   := ""
	Local lLock       := .F.
	Local lIncluiu    := .F.
	Local nIndex      := 0
	Local nPos        := 0
	Local nTamFil     := FwSizeFilial()
	Local nTamPrd     := GetSx3Cache("B8_PRODUTO", "X3_TAMANHO")
	Local nTamLoc     := GetSx3Cache("B8_LOCAL"  , "X3_TAMANHO")
	Local nTamLote    := GetSx3Cache("B8_LOTECTL", "X3_TAMANHO")
	Local nTamSubLt   := GetSx3Cache("B8_NUMLOTE", "X3_TAMANHO")
	Local nTamQtd     := GetSx3Cache("B2_QATU"   , "X3_TAMANHO")
	Local nTamDec     := GetSx3Cache("B2_QATU"   , "X3_DECIMAL")
	Local oErros      := JsonObject():New()
	Local oPrdClear   := JsonObject():New()
	Local oPCPLock    := PCPLockControl():New()
	Default cStatus   := '3'
	Default lMultiThr := .F.

	//Chama API de CQ para Atualizacao
	If FWAliasInDic( "HWX", .F. )
		PCPA141CQ(cUUID)
	EndIf

	//Monta a query utilizada para buscar os dados a integrar
	cQuery := " ( "
	cQuery +=  " SELECT branchId, "
	cQuery +=         " product, "
	cQuery +=         " warehouse, "
	cQuery +=         " lot, "
	cQuery +=         " sublot, "
	cQuery +=         " expirationDate, "
	cQuery +=         " SUM(availableQuantity) as availableQuantity, "
	cQuery +=         " SUM(consignedOut) as consignedOut, "
	cQuery +=         " SUM(consignedIn) as consignedIn, "
	cQuery +=         " SUM(unavailableQuantity) as unavailableQuantity, "
	cQuery +=         " SUM(blockedBalance) as blockedBalance "
	cQuery +=    " FROM (SELECT SB2.B2_FILIAL as branchId, "
	cQuery +=                 " SB2.B2_COD    as product, "
	cQuery +=                 " SB2.B2_LOCAL  as warehouse, "
	cQuery +=                 " ''            as lot, "
	cQuery +=                 " ''            as sublot, "
	cQuery +=                 " ''            as expirationDate, "
	cQuery +=                 " (CASE WHEN B1_RASTRO IN ('L', 'S') THEN 0 ELSE B2_QATU  END) as availableQuantity, "
	cQuery +=                 " SB2.B2_QNPT   as consignedOut, "
	cQuery +=                 " SB2.B2_QTNP   as consignedIn, "
	cQuery +=                 " 0             as unavailableQuantity, "
	cQuery +=                 " 0             as blockedBalance "
	cQuery +=                 " FROM " + RetSqlName("SB2") + " SB2 "
	cQuery +=                 " INNER JOIN (SELECT B1_COD, B1_RASTRO "
	cQuery +=                               " FROM " + RetSqlName("SB1")
	cQuery +=                              " WHERE D_E_L_E_T_ = ' ') SB1 "
	cQuery +=                 " ON SB2.B2_COD = SB1.B1_COD "
	cQuery +=           " WHERE [DELETB2] "
	cQuery +=             " AND EXISTS ( SELECT 1 "
	cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
	cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
	cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
	cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
	cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
	If cBanco == "POSTGRES"
		cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SB2.B2_FILIAL, " + cValToChar(nTamFil) + ")||"
		cQuery +=                                              "RPAD(SB2.B2_COD   , " + cValToChar(nTamPrd) + ")||"
		cQuery +=                                              "RPAD(SB2.B2_LOCAL , " + cValToChar(nTamLoc) + ")) "
	Else
		cQuery +=                         " AND T4R.T4R_IDREG = SB2.B2_FILIAL||SB2.B2_COD||SB2.B2_LOCAL) "
	EndIf
	cQuery +=          " UNION "
	cQuery +=          " SELECT SB8.B8_FILIAL  as branchId, "
	cQuery +=                 " SB8.B8_PRODUTO as product, "
	cQuery +=                 " SB8.B8_LOCAL   as warehouse, "
	cQuery +=                 " SB8.B8_LOTECTL as lot, "
	cQuery +=                 " SB8.B8_NUMLOTE as sublot, "
	cQuery +=                 " SB8.B8_DTVALID as expirationDate, "
	cQuery +=                 " SB8.B8_SALDO   as availableQuantity, "
	cQuery +=                 " 0              as consignedOut, "
	cQuery +=                 " 0              as consignedIn, "
	cQuery +=                 " 0              as unavailableQuantity, "
	cQuery +=                 " 0              as blockedBalance "
	cQuery +=            " FROM " + RetSqlName("SB8") + " SB8 "
	cQuery +=            " INNER JOIN (SELECT B1_COD, B1_RASTRO "
	cQuery +=                          " FROM " + RetSqlName("SB1")
	cQuery +=                         " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=                           " AND B1_RASTRO IN ('L', 'S')) SB1 "
	cQuery +=            " ON SB8.B8_PRODUTO = SB1.B1_COD "
	cQuery +=           " WHERE [DELETB8] "
	cQuery +=             " AND SB8.B8_SALDO > 0
	cQuery +=             " AND EXISTS ( SELECT 1 "
	cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
	cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
	cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
	cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
	cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
	If cBanco == "POSTGRES"
		cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SB8.B8_FILIAL , " + cValToChar(nTamFil) + ")||"
		cQuery +=                                              "RPAD(SB8.B8_PRODUTO, " + cValToChar(nTamPrd) + ")||"
		cQuery +=                                              "RPAD(SB8.B8_LOCAL  , " + cValToChar(nTamLoc) + ")) "
	Else
		cQuery +=                         " AND T4R.T4R_IDREG = SB8.B8_FILIAL||SB8.B8_PRODUTO||SB8.B8_LOCAL) "
	EndIf

	cQuery +=          " UNION "
	cQuery +=          " SELECT SDD.DD_FILIAL   as branchId, "
	cQuery +=                 " SDD.DD_PRODUTO  as product, "
	cQuery +=                 " SDD.DD_LOCAL    as warehouse, "
	cQuery +=                 " SDD.DD_LOTECTL  as lot, "
	cQuery +=                 " SDD.DD_NUMLOTE  as sublot, "
	cQuery +=                 " SB8b.B8_DTVALID as expirationDate, "
	cQuery +=                 " 0			    as availableQuantity, "
	cQuery +=                 " 0               as consignedOut, "
	cQuery +=                 " 0               as consignedIn, "
	cQuery +=                 " 0               as unavailableQuantity, "
	cQuery +=                 " SDD.DD_SALDO    as blockedBalance "
	cQuery +=            " FROM " + RetSqlName("SDD") + " SDD "
	cQuery +=            " INNER JOIN (SELECT B8_PRODUTO, B8_DTVALID, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE "
	cQuery +=                          " FROM " + RetSqlName("SB8")
	cQuery +=                          " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=                          " AND B8_FILIAL = '"+xFilial("SB8")+"') SB8b "
	cQuery +=            " ON SB8b.B8_PRODUTO = SDD.DD_PRODUTO AND SB8b.B8_LOCAL = SDD.DD_LOCAL AND SB8b.B8_LOTECTL = SDD.DD_LOTECTL AND SB8b.B8_NUMLOTE = SDD.DD_NUMLOTE"
	cQuery +=           " WHERE SDD.D_E_L_E_T_ = ' '  AND SDD.DD_SALDO > 0 AND SDD.DD_MOTIVO <> 'VV' AND SDD.DD_FILIAL = '"+xFilial("SDD")+"' "
	cQuery +=             " AND EXISTS ( SELECT 1 "
	cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
	cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
	cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
	cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
	cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
	If cBanco == "POSTGRES"
		cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SDD.DD_FILIAL , " + cValToChar(nTamFil) + ")||"
		cQuery +=                                              "RPAD(SDD.DD_PRODUTO, " + cValToChar(nTamPrd) + ")||"
		cQuery +=                                              "RPAD(SDD.DD_LOCAL  , " + cValToChar(nTamLoc) + ")) "
	Else
		cQuery +=                         " AND T4R.T4R_IDREG = SDD.DD_FILIAL||SDD.DD_PRODUTO||SDD.DD_LOCAL) "
	EndIf

	cQuery +=            " ) SB2a"
	cQuery +=          " GROUP BY branchId, "
	cQuery +=                   " product, "
	cQuery +=                   " warehouse, "
	cQuery +=                   " lot, "
	cQuery +=                   " sublot, "
	cQuery +=                   " expirationDate "
	cQuery +=          " [HAVINGSUM] "
	cQuery += " ) SB2b "

	cQuery := "%" + cQuery + "%"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	cQueryOri := cQuery

	//Primeiro roda sem o HAVING SUM, para excluir os saldos existentes.
	cQuery := StrTran(cQueryOri, "[HAVINGSUM]", " ")

	//Não filtra os registros deletados.
	cQuery := StrTran(cQuery, "[DELETB2]", " 1=1 ")
	cQuery := StrTran(cQuery, "[DELETB8]", " 1=1 ")

	BeginSql Alias cAlias
		SELECT branchId,
		       product,
		       warehouse,
		       lot,
		       sublot,
		       expirationDate
		FROM %Exp:cQuery%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPSTOCKBALANCE", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	PutGlbValue(cGlbErros, "0")

	//Se possuir dados a processar, cria as tabelas temporárias utilizadas na integração dos estoques
	If (cAlias)->(!Eof())

		While (cAlias)->(!Eof())
			aSize(aDados, 0)

			aDados := Array(EstqAPICnt("ARRAY_ESTOQUE_SIZE"))

			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL"   )] := PadR((cAlias)->branchId , nTamFil)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"     )] := PadR((cAlias)->product  , nTamPrd)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL"    )] := PadR((cAlias)->warehouse, nTamLoc)

			cChave := aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL")] +;
			          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"  )] +;
			          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL" )]

			If oPrdClear[cChave] == Nil
				aAdd(aDadosDel, aClone(aDados))
				oPrdClear[cChave] := .T.
			EndIf

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		If Len(aDadosDel) > 0
			PcpEstqInt("CLEAR", aDadosDel, @aSuccess, @aError, Nil)
			If Len(aError) > 0
				For nIndex := 1 To Len(aError)
					cChave := aError[nIndex]["detailedMessage"]["branchId"]+;
					          aError[nIndex]["detailedMessage"]["product"]+;
					          aError[nIndex]["detailedMessage"]["warehouse"]

					If oPrdClear[cChave] != Nil
						oPrdClear[cChave] := .F.
					EndIf
				Next nIndex
			EndIf
		EndIf

		cAlias := PCPAliasQr()

		//Roda com o HAVING SUM, para inc luir os saldos atuais
		cQuery := StrTran(cQueryOri,;
		                  "[HAVINGSUM]",;
		                  " HAVING SUM(availableQuantity)+SUM(consignedOut)+SUM(consignedIn)+SUM(unavailableQuantity)+SUM(blockedBalance) != 0 ")

		//Filtra os registros deletados.
		cQuery := StrTran(cQuery, "[DELETB2]", " SB2.D_E_L_E_T_ = ' ' ")
		cQuery := StrTran(cQuery, "[DELETB8]", " SB8.D_E_L_E_T_ = ' ' ")

		BeginSql Alias cAlias
			COLUMN availableQuantity     AS NUMERIC(nTamQtd, nTamDec)
			COLUMN consignedOut          AS NUMERIC(nTamQtd, nTamDec)
			COLUMN consignedIn           AS NUMERIC(nTamQtd, nTamDec)
			COLUMN unavailableQuantity   AS NUMERIC(nTamQtd, nTamDec)
			COLUMN expirationDate        AS DATE
			COLUMN blockedBalance        AS NUMERIC(nTamQtd, nTamDec)
			SELECT branchId,
			       product,
			       warehouse,
			       lot,
			       sublot,
			       expirationDate,
			       availableQuantity,
			       consignedOut,
			       consignedIn,
			       unavailableQuantity,
				   blockedBalance
			FROM %Exp:cQuery%
		EndSql

		nPos := 0
		While (cAlias)->(!Eof())
			aSize(aDados, 0)

			aDados := Array(EstqAPICnt("ARRAY_ESTOQUE_SIZE"))
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL"   )] := PadR((cAlias)->branchId , nTamFil)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"     )] := PadR((cAlias)->product  , nTamPrd)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL"    )] := PadR((cAlias)->warehouse, nTamLoc)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOTE"     )] := PadR((cAlias)->lot      , nTamLote)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_SUBLOTE"  )] := PadR((cAlias)->sublot   , nTamSubLt)
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_VALIDADE" )] := (cAlias)->expirationDate
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD"      )] := (cAlias)->availableQuantity
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_NPT"  )] := (cAlias)->consignedOut
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_TNP"  )] := (cAlias)->consignedIn
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_IND"  )] := (cAlias)->unavailableQuantity
			aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_BLQ"  )] := (cAlias)->blockedBalance

			cChave := aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL")] +;
			          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"  )] +;
			          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL" )]

			If oPrdClear[cChave]
				aAdd(aDadosInc, aClone(aDados))
				nPos++
			EndIf

			(cAlias)->(dbSkip())

			//Executa a integração para inclusão/atualização
			If nPos > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosInc) > 0)
				If lMultiThr
					PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPSTOCKBALANCE", nPos, "PcpEstqInt", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
				Else
					P141Intgra("MRPSTOCKBALANCE", nPos, "PcpEstqInt", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
				EndIf

				nPos     := 0
				lIncluiu := .T.
				aSize(aDadosInc, 0)
			EndIf
		End
	EndIf
	(cAlias)->(dbCloseArea())

	If lMultiThr
		PCPIPCWait(P141IdThr())
	EndIf

	//Limpa as pendências dos registros de saldo que não possuem quantidades a integrar
	If !lIncluiu
		clearPend(cUUID, cStatus)
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPSTOCKBALANCE")
	EndIf

	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	FreeObj(oPrdClear)
	oPrdClear := Nil

	FwFreeArray(aDados)
	FwFreeArray(aDadosDel)
	FwFreeArray(aDadosInc)
	FwFreeArray(aError)
	FwFreeArray(aSuccess)

Return oErros

/*/{Protheus.doc} clearPend
Limpa as pendências de estoque dos registros que não possuem quantidade.

@type  Static Function
@author lucas.franca
@since 15/08/2019
@version P12.1.28
@param 01 cUUID  , Character, Identificador do processo na tabela T4R
@param 02 cStatus, Character, Identificador do status na tabela T4R
/*/
Static Function clearPend(cUUID, cStatus)
	Local cSql   := ""
	Local cError := ""

	cSql := "UPDATE " + RetSqlName("T4R")
	cSql +=   " SET D_E_L_E_T_   = '*', "
	cSql +=       " R_E_C_D_E_L_ = R_E_C_N_O_ "
	cSql += " WHERE T4R_FILIAL = '" + xFilial("T4R") + "' "
	cSql +=   " AND T4R_API    IN ('MRPSTOCKBALANCE', 'MRPREJECTEDINVENTORY') "
	cSql +=   " AND T4R_STATUS = '" + cStatus + "' "
	cSql +=   " AND T4R_IDPRC  = '" + cUUID   + "' "
	cSql +=   " AND D_E_L_E_T_ = ' ' "

	If TcSqlExec(cSql) < 0
		cError := Replicate("-",70)
		cError += CHR(10)
		cError += STR0014 //"Erro ao eliminar as pendências de processamento."
		cError += CHR(10)
		cError += cSql
		cError += CHR(10)
		cError += TcSqlError()
		cError := Replicate("-",70)

		LogMsg('PCPA141RUN', 0, 0, 1, '', '', cError)
		Final(STR0014, TcSqlError()) //"Erro ao eliminar as pendências de processamento."
	EndIf

Return
