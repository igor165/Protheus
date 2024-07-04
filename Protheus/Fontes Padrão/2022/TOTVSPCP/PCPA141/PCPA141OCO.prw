#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE BUFFER_INTEGRACAO 1000

Static _nTamFil   := Nil
Static _nTamNum   := Nil
Static _nTamItem  := Nil
Static _nTamItGrd := Nil

/*/{Protheus.doc} PCPA141OCO
Executa o processamento dos registros de Pedido de Compra

@type  Function
@author douglas.heydt
@since 13/08/2019
@version P12.1.28
@param 01 cUUID    , Caracter, Identificador do processo para buscar os dados na tabela T4R
@param 02 lMultiThr, Lógico  , Indica se o processamento será multi-thread
@return oErros     , Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141OCO(cUUID, lMultiThr)
	Local aDados    := {}
	Local aDadosDel := {}
	Local aDadosInc := {}
	Local aErroJson := {}
	Local cAlias    := PCPAliasQr()
	Local cGlbErros := "ERROS_141" + cUUID
	Local lLock     := .F.
	Local nPosDel   := 0
	Local nPosInc   := 0
	Local nRecnoSC7 := 0
	Local oErros    := JsonObject():New()
	Local oPCPLock  := PCPLockControl():New()

	Default lMultiThr := .F.

	If _nTamFil == Nil
		_nTamFil   := FwSizeFilial()
		_nTamNum   := GetSX3Cache("C7_NUM"    , "X3_TAMANHO")
		_nTamItem  := GetSX3Cache("C7_ITEM"   , "X3_TAMANHO")
		_nTamItGrd := GetSX3Cache("C7_ITEMGRD", "X3_TAMANHO")
	EndIf

	BeginSql Alias cAlias
		SELECT T4R.T4R_IDREG,
		       T4R.R_E_C_N_O_
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API = 'MRPPURCHASEREQUEST'
		   AND T4R.T4R_IDPRC = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPPURCHASEREQUEST", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	PutGlbValue(cGlbErros, "0")

	nPosDel := 0
	nPosInc := 0
	While (cAlias)->(!Eof())
        nRecnoSC7 := Val((cAlias)->T4R_IDREG)
		SC7->(dbGoTo(nRecnoSC7))
		If SC7->(!EoF())

			aSize(aDados, 0)
			aDados := Array(PEDCAPICnt("ARRAY_PEDCOM_SIZE"))

			aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_FILIAL") ] := SC7->C7_FILIAL
			aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_NUM")    ] := SC7->C7_NUM
			aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_ITEM")   ] := SC7->C7_ITEM
			aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_ITGRD")  ] := SC7->C7_ITEMGRD
			aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_RESIDUO")] := SC7->C7_RESIDUO
			aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_RECNO")  ] := (cAlias)->T4R_IDREG

			//Só atualiza os dados que não possuem o resíduo zerado (C7_RESIDUO = ' '). Caso contrário, exclui
			If SC7->(!Deleted()) .And. aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_RESIDUO")] == " " .And. SC7->C7_QUJE < SC7->C7_QUANT
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_PROD")	] := SC7->C7_PRODUTO
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_OP")    ] := SC7->C7_OP
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_DATPRF")] := SC7->C7_DATPRF
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_QTD")   ] := SC7->C7_QUANT
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_QUJE")  ] := SC7->C7_QUJE
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_LOCAL") ] := SC7->C7_LOCAL
				aDados[PEDCAPICnt("ARRAY_PEDCOM_POS_TIPO")  ] := SC7->C7_TPOP

				aAdd(aDadosInc, aClone(aDados))
				nPosInc++
			Else
				aAdd(aDadosDel, aClone(aDados))
				nPosDel++
			EndIf
		Else
			aAdd(aErroJson, {(cAlias)->R_E_C_N_O_, STR0021}) // "O campo T4R_IDREG não é um recno válido."
		EndIf

		(cAlias)->(dbSkip())

		//Executa a integração para exclusão de pedidos de compra
		If nPosDel > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosDel) > 0)
			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPPURCHASEREQUEST", nPosDel, "PCPPEDCINT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPPURCHASEREQUEST", nPosDel, "PCPPEDCINT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, cUUID)
			EndIf

			aSize(aDadosDel, 0)
			nPosDel := 0
		EndIf

		//Executa a integração para inclusão/atualização de pedidos de compra.
		If nPosInc > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosInc) > 0)
			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPPURCHASEREQUEST", nPosInc, "PCPPEDCINT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPPURCHASEREQUEST", nPosInc, "PCPPEDCINT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
			EndIf

			aSize(aDadosInc, 0)
			nPosInc := 0
		EndIf
	End
	(cAlias)->(dbCloseArea())

	If lMultiThr
		PCPIPCWait(P141IdThr())
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPPURCHASEREQUEST")
	EndIf

	If Len(aErroJson) > 0
		oErros["ERRO_JSON"] := aClone(aErroJson)
	EndIf
	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	aSize(aDadosDel, 0)
	aSize(aDadosInc, 0)
	aSize(aDados   , 0)

Return oErros
