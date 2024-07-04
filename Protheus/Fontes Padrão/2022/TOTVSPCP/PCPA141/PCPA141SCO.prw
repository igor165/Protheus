#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE BUFFER_INTEGRACAO 1000

Static _nTamFil   := Nil
Static _nTamNum   := Nil
Static _nTamItem  := Nil
Static _nTamItGrd := Nil

/*/{Protheus.doc} PCPA141SCO
Executa o processamento dos registros de Solicitações de Compra

@type Function
@author douglas.heydt
@since 13/08/2019
@version P12
@param 01 cUUID    , Caracter, Identificador do processo para buscar os dados na tabela T4R
@param 02 lMultiThr, Lógico  , Indica se a integração será feita em mais de uma thread
@return oErros     , Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141SCO(cUUID, lMultiThr)
	Local aDados      := {}
	Local aDadosDel   := {}
	Local aDadosInc   := {}
	Local aErroJson := {}
	Local cAlias      := PCPAliasQr()
	Local cGlbErros   := "ERROS_141" + cUUID
	Local lLock       := .F.
	Local nPosDel     := 0
	Local nPosInc     := 0
	Local nRecnoSC1   := 0
	Local oErros      := JsonObject():New()
	Local oPCPLock    := PCPLockControl():New()
	Default lMultiThr := .F.

	If _nTamFil == Nil
		_nTamFil   := FwSizeFilial()
		_nTamNum   := GetSX3Cache("C1_NUM"    , "X3_TAMANHO")
		_nTamItem  := GetSX3Cache("C1_ITEM"   , "X3_TAMANHO")
		_nTamItGrd := GetSX3Cache("C1_ITEMGRD", "X3_TAMANHO")
	EndIf

	BeginSql Alias cAlias
		SELECT T4R.T4R_IDREG,
		       T4R.R_E_C_N_O_
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API = 'MRPPURCHASEORDER'
		   AND T4R.T4R_IDPRC = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPPURCHASEORDER", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	PutGlbValue(cGlbErros, "0")

	nPosDel := 0
	nPosInc := 0
	While (cAlias)->(!Eof())
		nRecnoSC1 := Val((cAlias)->T4R_IDREG)
        SC1->(DbGoTo(nRecnoSC1))
		If SC1->(!EoF())

			aSize(aDados, 0)
			aDados := Array(SOLCAPICnt("ARRAY_SOLCOM_SIZE"))

			aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_FILIAL") ] := SC1->C1_FILIAL
			aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_NUM")    ] := SC1->C1_NUM
			aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_ITEM")   ] := SC1->C1_ITEM
			aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_ITGRD")  ] := SC1->C1_ITEMGRD
			aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_RESIDUO")] := SC1->C1_RESIDUO
			aDados[SOLCAPICnt("ARRAY_SOLCOM_RECNO")      ] := (cAlias)->T4R_IDREG

			//Só atualiza os dados que não possuem o resíduo zerado (C1_RESIDUO = ' '). Caso contrário, exclui
			If SC1->(!Deleted()) .And. aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_RESIDUO")] == " " .And. SC1->C1_QUJE < SC1->C1_QUANT
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_PROD")  ] := SC1->C1_PRODUTO
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_QTD")   ] := SC1->C1_QUANT
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_OP")    ] := SC1->C1_OP
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_LOCAL") ] := SC1->C1_LOCAL
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_QUJE")  ] := SC1->C1_QUJE
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_TIPO")  ] := SC1->C1_TPOP
				aDados[SOLCAPICnt("ARRAY_SOLCOM_POS_DATPRF")] := SC1->C1_DATPRF

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

		//Executa a integração para exclusão de solicitações de compra
		If nPosDel > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosDel) > 0)
			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPPURCHASEORDER", nPosDel, "PCPSOLCINT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPPURCHASEORDER", nPosDel, "PCPSOLCINT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, cUUID)
			EndIf

			aSize(aDadosDel, 0)
			nPosDel := 0
		EndIf

		//Executa a integração para inclusão/atualização de solicitações de compra.
		If nPosInc > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosInc) > 0)
			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPPURCHASEORDER", nPosInc, "PCPSOLCINT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPPURCHASEORDER", nPosInc, "PCPSOLCINT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
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
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPPURCHASEORDER")
	EndIf

	If Len(aErroJson) > 0
		oErros["ERRO_JSON"] := aClone(aErroJson)
	EndIf
	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	FwFreeArray(aDados)
	FwFreeArray(aDadosDel)
	FwFreeArray(aDadosInc)

Return oErros
