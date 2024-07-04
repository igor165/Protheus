#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

/*/{Protheus.doc} PCPA141CQ
Executa o processamento dos registros de CQ

@type  Function
@author brunno.costa
@since 13/17/2020
@version P12.1.31
@param 01 cUUID  , Character, Identificador do processo para buscar os dados na tabela T4R.
@param 02 cStatus, Character, Identificador do status para buscar os dados na tabela T4R (default = '3')
/*/
Function PCPA141CQ(cUUID, cStatus)
	Local aDados    := {}
	Local aDadosInc := {}
	Local aDadosDel := {}
	Local aSuccess  := {}
	Local aError    := {}
	Local cAlias    := PCPAliasQr()
	Local cBanco    := AllTrim(Upper(TcGetDb()))
	Local cChave    := ""
	Local cQuery    := ""
	Local cQueryOri := ""
	Local lLock     := .F.
	Local nIndex    := 0
	Local nTamFil   := FwSizeFilial()
	Local nTamData  := 8
	Local nTamPrd   := GetSx3Cache("D7_PRODUTO", "X3_TAMANHO")
	Local nTamLoc   := GetSx3Cache("D7_LOCDEST", "X3_TAMANHO")
	Local nTamQtd   := GetSx3Cache("D7_QTDE"   , "X3_TAMANHO")
	Local nTamDec   := GetSx3Cache("D7_QTDE"   , "X3_DECIMAL")
	Local oPCPLock  := PCPLockControl():New()
	Local oPrdClear := JsonObject():New()
	Default cStatus := '3'

	//Monta a query utilizada para buscar os dados a integrar
	cQuery := " ( "
	cQuery +=  " SELECT branchId, "
	cQuery +=         " product, "
	cQuery +=         " SUM(quantity) as quantity, "
	cQuery +=         " warehouse, "
	cQuery +=         " invoiceDate, "
	cQuery +=         " SUM(returnedQuantity) as returnedQuantity, "
	cQuery +=         " T4R_API "
	cQuery +=    " FROM (
	cQuery +=          " SELECT SD7.D7_FILIAL         as branchId, "
	cQuery +=                 " SD7.D7_PRODUTO        as product, "
	cQuery +=                 " SD7.D7_QTDE           as quantity, "
	cQuery +=                 " SD7.D7_LOCDEST        as warehouse, "
	cQuery +=                 " SD7.D7_DATA           as invoiceDate, "
	cQuery +=                 " COALESCE(D2_QUANT, 0) as returnedQuantity, "
	cQuery +=                 " T4R_API "
	cQuery +=            " FROM (SELECT D7_FILIAL, D7_PRODUTO, SUM(D7_QTDE) as D7_QTDE, D7_LOCDEST, D7_DATA, D7_FORNECE, D7_LOJA, D7_DOC, D7_SERIE, D7_TIPO "
	cQuery +=                   " FROM " + RetSqlName("SD7")
	cQuery +=                  " WHERE [DELETD7] "
	cQuery +=                    " AND D7_TIPO IN (2,6) "
	cQuery +=                    " AND D7_FILIAL = '" + xFilial("SD7") + "' "
	cQuery +=                    " AND [D7ESTORNO] "
	cQuery +=                  " GROUP BY D7_FILIAL, D7_PRODUTO, D7_LOCDEST, D7_DATA, D7_FORNECE, D7_LOJA, D7_DOC, D7_SERIE, D7_TIPO) SD7 "
	cQuery +=              " INNER JOIN ( SELECT T4R_IDREG, T4R_API "
	cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
	cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cQuery +=                             " AND T4R.T4R_API    IN ('MRPSTOCKBALANCE','MRPREJECTEDINVENTORY') "
	cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
	cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
	cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "') T4Ra "
	If cBanco == "POSTGRES"
		cQuery +=          " ON T4Ra.T4R_IDREG = RPAD(SD7.D7_FILIAL , " + cValToChar(nTamFil) + ")||"
		cQuery +=                               "RPAD(SD7.D7_PRODUTO, " + cValToChar(nTamPrd) + ")||"
		cQuery +=                               "RPAD(SD7.D7_LOCDEST, " + cValToChar(nTamLoc) + ")||"
		cQuery +=                               "(CASE  T4Ra.T4R_API WHEN 'MRPSTOCKBALANCE' THEN '' ELSE RPAD(SD7.D7_DATA   , " + cValToChar(nTamData) + ") END) "
	Else
		cQuery +=          " ON RTRIM(T4Ra.T4R_IDREG) = SD7.D7_FILIAL||SD7.D7_PRODUTO||SD7.D7_LOCDEST|| "
		cQuery +=                               "(CASE  T4Ra.T4R_API WHEN 'MRPSTOCKBALANCE' THEN '' ELSE SD7.D7_DATA END) "
	EndIf
	cQuery +=              " LEFT JOIN ( SELECT SUM(D2_QUANT) D2_QUANT, "
	cQuery +=                                 " D2_FILIAL, "
    cQuery +=                                 " D2_TIPO, "
    cQuery +=                                 " D2_CLIENTE, "
    cQuery +=                                 " D2_LOJA, "
    cQuery +=                                 " D2_NFORI, "
    cQuery +=                                 " D2_SERIORI, "
    cQuery +=                                 " D2_COD "
	cQuery +=                           " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery +=                          " WHERE [DELETD2] "
	cQuery +=                                " AND D2_TIPO = 'D' "
	cQuery +=                                " AND D2_FILIAL = '" + xFilial("SD2") + "' "
	cQuery +=                           " GROUP BY
	cQuery +=                                 " D2_FILIAL, "
    cQuery +=                                 " D2_TIPO, "
    cQuery +=                                 " D2_CLIENTE, "
    cQuery +=                                 " D2_LOJA, "
    cQuery +=                                 " D2_NFORI, "
    cQuery +=                                 " D2_SERIORI, "
    cQuery +=                                 " D2_COD ) SD2a "
	cQuery +=               " ON  SD7.D7_FORNECE = SD2a.D2_CLIENTE "
	cQuery +=               " AND SD7.D7_LOJA    = SD2a.D2_LOJA "
	cQuery +=               " AND SD7.D7_DOC     = SD2a.D2_NFORI "
	cQuery +=               " AND SD7.D7_SERIE   = SD2a.D2_SERIORI "
	cQuery +=               " AND SD7.D7_PRODUTO = SD2a.D2_COD "
	cQuery +=               " AND SD7.D7_TIPO    = 2 "
	cQuery +=            " ) SD7b"
	cQuery +=          " GROUP BY branchId, "
	cQuery +=                   " product, "
	cQuery +=                   " warehouse, "
	cQuery +=                   " invoiceDate, "
	cQuery +=                   " T4R_API "

	cQuery +=          " [HAVINGSUM] "
	cQuery += " ) SD7b "

	cQuery := "%" + cQuery + "%"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	cQueryOri := cQuery

	//Primeiro roda sem o HAVING SUM, para excluir os saldos existentes.
	cQuery := StrTran(cQueryOri, "[HAVINGSUM]", " ")

	//Não filtra os registros deletados.
	cQuery := StrTran(cQuery, "[DELETD7]", " 1=1 ")
	cQuery := StrTran(cQuery, "[DELETD2]", " 1=1 ")
	cQuery := StrTran(cQuery, "[D7ESTORNO]", " 1=1 ")

	BeginSql Alias cAlias
		SELECT branchId,
			   product,
			   warehouse,
			   invoiceDate,
			   T4R_API
		FROM %Exp:cQuery%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPREJECTEDINVENTORY", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	//Se possuir dados a processar, cria as tabelas temporárias utilizadas na integração dos CQs
	If (cAlias)->(!Eof())

		While (cAlias)->(!Eof())
			aSize(aDados, 0)

			aDados := Array(CQAPICnt("ARRAY_CQ_SIZE"))

			aDados[CQAPICnt("ARRAY_CQ_POS_FILIAL"   )] := PadR((cAlias)->branchId   , nTamFil)
			aDados[CQAPICnt("ARRAY_CQ_POS_PROD"     )] := PadR((cAlias)->product    , nTamPrd)
			aDados[CQAPICnt("ARRAY_CQ_POS_LOCAL"    )] := PadR((cAlias)->warehouse  , nTamLoc)
			aDados[CQAPICnt("ARRAY_CQ_POS_DATA"     )] := PadR((cAlias)->invoiceDate, nTamData)

			cChave := aDados[CQAPICnt("ARRAY_CQ_POS_FILIAL")] +;
			          aDados[CQAPICnt("ARRAY_CQ_POS_PROD"  )] +;
			          aDados[CQAPICnt("ARRAY_CQ_POS_LOCAL" )] +;
					  aDados[CQAPICnt("ARRAY_CQ_POS_DATA"  )]

			If oPrdClear[cChave] == Nil
				aAdd(aDadosDel, aClone(aDados))
				oPrdClear[cChave] := .T.
			EndIf

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		If Len(aDadosDel) > 0
			PcpCQInt("CLEAR", aDadosDel, @aSuccess, @aError, Nil)
			If Len(aError) > 0
				For nIndex := 1 To Len(aError)
					cChave := aError[nIndex]["detailedMessage"]["branchId"] +;
					          aError[nIndex]["detailedMessage"]["product"]  +;
					          aError[nIndex]["detailedMessage"]["warehouse"]+;
							  aError[nIndex]["detailedMessage"]["invoiceDate"]

					If oPrdClear[cChave] != Nil
						oPrdClear[cChave] := .F.
					EndIf
				Next nIndex
			EndIf
		EndIf

		cAlias := PCPAliasQr()

		//Roda com o HAVING SUM, para incluir os saldos atuais
		cQuery := StrTran(cQueryOri,;
		                  "[HAVINGSUM]",;
		                  " HAVING SUM(quantity)+SUM(returnedQuantity) != 0 ")

		//Filtra os registros deletados.
		cQuery := StrTran(cQuery, "[DELETD7]", " D_E_L_E_T_ = ' ' ")
		cQuery := StrTran(cQuery, "[DELETD2]", " SD2.D_E_L_E_T_ = ' ' ")
		cQuery := StrTran(cQuery, "[D7ESTORNO]", " D7_ESTORNO <> 'S' ")

		BeginSql Alias cAlias
			COLUMN quantity         AS NUMERIC(nTamQtd, nTamDec)
			COLUMN returnedQuantity AS NUMERIC(nTamQtd, nTamDec)
			//COLUMN invoiceDate      AS DATE
		SELECT branchId,
			   product,
			   warehouse,
			   invoiceDate,
			   quantity,
			   returnedQuantity,
			   T4R_API
		FROM %Exp:cQuery%
		EndSql

		While (cAlias)->(!Eof())

			aSize(aDados, 0)

			aDados := Array(CQAPICnt("ARRAY_CQ_SIZE"))

			aDados[CQAPICnt("ARRAY_CQ_POS_FILIAL"   )] := PadR((cAlias)->branchId   , nTamFil)
			aDados[CQAPICnt("ARRAY_CQ_POS_PROD"     )] := PadR((cAlias)->product    , nTamPrd)
			aDados[CQAPICnt("ARRAY_CQ_POS_LOCAL"    )] := PadR((cAlias)->warehouse  , nTamLoc)
			aDados[CQAPICnt("ARRAY_CQ_POS_DATA"     )] := PadR((cAlias)->invoiceDate, nTamData)
			aDados[CQAPICnt("ARRAY_CQ_POS_QTDE"     )] := (cAlias)->quantity
			aDados[CQAPICnt("ARRAY_CQ_POS_QTD_DEV"  )] := (cAlias)->returnedQuantity

			cChave := aDados[CQAPICnt("ARRAY_CQ_POS_FILIAL")] +;
			          aDados[CQAPICnt("ARRAY_CQ_POS_PROD"  )] +;
			          aDados[CQAPICnt("ARRAY_CQ_POS_LOCAL" )] +;
					  aDados[CQAPICnt("ARRAY_CQ_POS_DATA"  )]

			If oPrdClear[cChave]
				aAdd(aDadosInc, aClone(aDados))
			EndIf

			(cAlias)->(dbSkip())
		End
	EndIf

	(cAlias)->(dbCloseArea())

	//Executa a integração para inclusão/atualização de CQ.
	If Len(aDadosInc) > 0
		PcpCQInt("INSERT", aDadosInc, Nil, Nil, cUUID)
	EndIf

	//Limpa as pendências dos registros de saldo que não possuem quantidades a integrar
	clearPend(cUUID, cStatus)

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPREJECTEDINVENTORY")
	EndIf

	FreeObj(oPrdClear)
	oPrdClear := Nil

	aSize(aDadosInc, 0)
	aSize(aDadosDel, 0)
	aSize(aDados   , 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)
Return

/*/{Protheus.doc} clearPend
Limpa as pendências de CQ dos registros que não possuem quantidade.

@type  Static Function
@author brunno.costa
@since 13/07/2020
@version P12.1.31
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
	cSql +=   " AND T4R_API    = 'MRPREJECTEDINVENTORY' "
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
