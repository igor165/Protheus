#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

/*/{Protheus.doc} PCPA141VEP
Executa o processamento dos registros de Versão da Produção

@type  Function
@author marcelo.neumann
@since 27/08/2019
@version P12.1.28
@param  cUUID , Caracter, Identificador do processo para buscar os dados na tabela T4R
@return oErros, Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141VEP(cUUID)
	Local aDados    := {}
	Local aDadosDel := {}
	Local aDadosInc := {}
	Local aErroJson := {}
	Local cAlias    := PCPAliasQr()
	Local cError    := ""
	Local lErro     := .F.
	Local lLock     := .F.
	Local nTamFil   := FwSizeFilial()
	Local nTamVer   := GetSx3Cache("VC_VERSAO" ,"X3_TAMANHO")
	Local nTamPrd   := GetSx3Cache("VC_PRODUTO","X3_TAMANHO")
	Local oErros    := JsonObject():New()
	Local oJson     := JsonObject():New()
	Local oPCPLock  := PCPLockControl():New()

	BeginSql Alias cAlias
		SELECT T4R.T4R_TIPO,
		       T4R.R_E_C_N_O_,
		       T4R.T4R_DADOS
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPPRODUCTIONVERSION'
		   AND T4R.T4R_STATUS = '3'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPPRODUCTIONVERSION", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	While (cAlias)->(!Eof())
        cError := oJson:FromJson(StrTran((cAlias)->(T4R_DADOS), "\","\\"))
		lErro  := !Empty(cError) .Or. Len(oJson:GetNames()) == 0

		If lErro
			aAdd(aErroJson, {(cAlias)->R_E_C_N_O_, STR0019 + IIf(!Empty(cError), " - " + cError, "")}) //"O campo T4R_DADOS não é um Json válido."
		Else
			aSize(aDados, 0)
			aDados := Array(A119APICnt("ARRAY_PRODVERS_SIZE"))

			aDados[A119APICnt("ARRAY_PRODVERS_POS_FILIAL")] := PadR(oJson["VC_FILIAL"] , nTamFil)
			aDados[A119APICnt("ARRAY_PRODVERS_POS_CODE")  ] := PadR(oJson["VC_VERSAO"] , nTamVer)
            aDados[A119APICnt("ARRAY_PRODVERS_POS_PROD")  ] := PadR(oJson["VC_PRODUTO"], nTamPrd)

			If (cAlias)->(T4R_TIPO) != "2"
				aDados[A119APICnt("ARRAY_PRODVERS_POS_DTINI")  ] := StoD(oJson["VC_DTINI"])
                aDados[A119APICnt("ARRAY_PRODVERS_POS_DTFIM")  ] := StoD(oJson["VC_DTFIM"])
				aDados[A119APICnt("ARRAY_PRODVERS_POS_QTDINI") ] := oJson["VC_QTDDE"]
			    aDados[A119APICnt("ARRAY_PRODVERS_POS_QTDFIM") ] := oJson["VC_QTDATE"]
                aDados[A119APICnt("ARRAY_PRODVERS_POS_REVISAO")] := oJson["VC_REV"]
			EndIf

			aDados[A119APICnt("ARRAY_PRODVERS_POS_ROTEIRO")    ] := oJson["VC_ROTEIRO"]
			aDados[A119APICnt("ARRAY_PRODVERS_POS_LOCAL")      ] := oJson["VC_LOCCONS"]

			If (cAlias)->(T4R_TIPO) == "1"
				aAdd(aDadosInc, aClone(aDados))
			Else
				aAdd(aDadosDel, aClone(aDados))
			EndIf
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	//Executa a integração para exclusão da Versão da Produção
	If Len(aDadosDel) > 0
		PCPA119INT("DELETE", aDadosDel, Nil, Nil, cUUID)
	EndIf

	//Executa a integração para inclusão/atualização da Versão da Produção
	If Len(aDadosInc) > 0
		PCPA119INT("INSERT", aDadosInc, Nil, Nil, cUUID)
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPPRODUCTIONVERSION")
	EndIf

	If Len(aErroJson) > 0
		oErros["ERRO_JSON"] := aClone(aErroJson)
	EndIf

	aSize(aDadosDel, 0)
	aSize(aDadosInc, 0)
	aSize(aDados   , 0)

	FwFreeArray(aErroJson)
	FreeObj(oJson)
	oJson := Nil

Return oErros
