#INCLUDE "TOTVS.CH"

#DEFINE BUFFER_INTEGRACAO 1000

/*/{Protheus.doc} PCPA141EMP
Executa o processamento dos registros de Empenhos

@type  Function
@author marcelo.neumann
@since 16/08/2019
@version P12
@param 01 cUUID    , Caracter, Identificador do processo para buscar os dados na tabela T4R
@param 02 lMultiThr, Lógico  , Indica se o processamento será multi-thread
/*/
Function PCPA141EMP(cUUID, lMultiThr)
	Local aDados      := {}
	Local aDadosDel   := {}
	Local aDadosInc   := {}
	Local cAlias      := PCPAliasQr()
	Local cGlbErros   := "ERROS_141" + cUUID
	Local lLock       := .F.
	Local nPosDel     := 0
	Local nPosInc     := 0
	Local nRecnoD4    := 0
	Local oErros      := JsonObject():New()
	Local oPCPLock    := PCPLockControl():New()
	Default lMultiThr := .F.

	BeginSql Alias cAlias
		SELECT T4R.T4R_IDREG
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPALLOCATIONS'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPALLOCATIONS", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	PutGlbValue(cGlbErros, "0")

	nPosDel := 0
	nPosInc := 0
	While (cAlias)->(!Eof())
		aDados   := Array(A381APICnt("ARRAY_SIZE"))
		nRecnoD4 := Val((cAlias)->T4R_IDREG)

		SD4->(dbGoTo(nRecnoD4))

		If SD4->(Eof()) .Or. SD4->(Deleted())
			aDados[A381APICnt("ARRAY_POS_RECNO")] := (cAlias)->T4R_IDREG

			aAdd(aDadosDel, aClone(aDados))
			nPosDel++
		Else
			aDados[A381APICnt("ARRAY_POS_FILIAL" )] := SD4->D4_FILIAL
			aDados[A381APICnt("ARRAY_POS_PROD"   )] := SD4->D4_COD
			aDados[A381APICnt("ARRAY_POS_SEQ"    )] := SD4->D4_TRT
			aDados[A381APICnt("ARRAY_POS_LOCAL"  )] := SD4->D4_LOCAL
			aDados[A381APICnt("ARRAY_POS_OP"     )] := SD4->D4_OP
			aDados[A381APICnt("ARRAY_POS_OP_ORIG")] := SD4->D4_OPORIG
			aDados[A381APICnt("ARRAY_POS_DATA"   )] := SD4->D4_DATA
			aDados[A381APICnt("ARRAY_POS_QTD"    )] := SD4->D4_QUANT
			aDados[A381APICnt("ARRAY_POS_QSUSP"  )] := SD4->D4_QSUSP
			aDados[A381APICnt("ARRAY_POS_RECNO"  )] := (cAlias)->T4R_IDREG

			aAdd(aDadosInc, aClone(aDados))
			nPosInc++
		EndIf
		aSize(aDados, 0)

		(cAlias)->(dbSkip())

		//Executa a integração para exclusão dos empenhos
		If nPosDel > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosDel) > 0)
			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPALLOCATIONS", nPosDel, "PCPA381INT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPALLOCATIONS", nPosDel, "PCPA381INT", cGlbErros, "DELETE", aDadosDel, Nil, Nil, cUUID)
			EndIf

			aSize(aDadosDel, 0)
			nPosDel := 0
		EndIf

		//Executa a integração para inclusão/atualização dos empenhos
		If nPosInc > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosInc) > 0)
			If lMultiThr
				PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPALLOCATIONS", nPosInc, "PCPA381INT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
			Else
				P141Intgra("MRPALLOCATIONS", nPosInc, "PCPA381INT", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
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
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPALLOCATIONS")
	EndIf

	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	FwFreeArray(aDadosDel)
	FwFreeArray(aDadosInc)

Return oErros
