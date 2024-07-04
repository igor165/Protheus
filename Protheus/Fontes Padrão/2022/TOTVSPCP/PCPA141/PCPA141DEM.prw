#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE BUFFER_INTEGRACAO 1000

/*/{Protheus.doc} PCPA141DEM
Executa o processamento dos registros de demandas

@type  Function
@author lucas.franca
@since 07/08/2019
@version P12.1.28
@param  cUUID , Caracter, Identificador do processo para buscar os dados na tabela T4R.
@return oErros, Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141DEM(cUUID)
	Local aDados    := {}
	Local aDadosDel := {}
	Local aDadosInc := {}
	Local aErroJson := {}
	Local cAlias    := PCPAliasQr()
	Local cGlbErros := "ERROS_141" + cUUID
	Local cError    := ""
	Local lErro     := .F.
	Local lLock     := .F.
	Local nPosDel   := 0
	Local nPosInc   := 0
	Local nTamFil   := FwSizeFilial()
	Local nTamCod   := GetSx3Cache("VR_CODIGO","X3_TAMANHO")
	Local nTamPrd   := GetSx3Cache("VR_PROD"  ,"X3_TAMANHO")
	Local nTamDoc   := GetSx3Cache("VR_DOC"   ,"X3_TAMANHO")
	Local nTamLoc   := GetSx3Cache("VR_LOCAL" ,"X3_TAMANHO")
	Local oJson     := JsonObject():New()
	Local oErros    := JsonObject():New()
	Local oPCPLock  := PCPLockControl():New()
	Local oTmpInMrp := Nil

    BeginSql Alias cAlias
		SELECT T4R.T4R_TIPO,
		       T4R.R_E_C_N_O_,
		       T4R.T4R_DADOS
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPDEMANDS'
		   AND T4R.T4R_STATUS = '3'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
    EndSql

	If (cAlias)->(!Eof())
		lLock     := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPDEMANDS", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
		oTmpInMrp := P136APITMP()
	EndIf

	PutGlbValue(cGlbErros, "0")

	nPosDel := 0
	nPosInc := 0
    While (cAlias)->(!Eof())
        cError := oJson:FromJson(StrTran((cAlias)->(T4R_DADOS), "\","\\"))
		lErro  := !Empty(cError) .Or. Len(oJson:GetNames()) == 0

		If lErro
			aAdd(aErroJson, {(cAlias)->R_E_C_N_O_, STR0019 + IIf(!Empty(cError), " - " + cError, "")}) //"O campo T4R_DADOS não é um Json válido."
		Else
            //Ajusta tamanho dos dados que são do tipo String.
            oJson["VR_FILIAL"] := PadR(oJson["VR_FILIAL"], nTamFil)
            oJson["VR_CODIGO"] := PadR(oJson["VR_CODIGO"], nTamCod)
            oJson["VR_PROD"]   := PadR(oJson["VR_PROD"]  , nTamPrd)
            oJson["VR_DOC"]    := PadR(oJson["VR_DOC"]   , nTamDoc)
            oJson["VR_LOCAL"]  := PadR(oJson["VR_LOCAL"] , nTamLoc)

            aSize(aDados, 0)
            aDados := Array(A136APICnt("ARRAY_DEMAND_SIZE"))

            aDados[A136APICnt("ARRAY_DEMAND_POS_FILIAL")] := oJson["VR_FILIAL"]
            aDados[A136APICnt("ARRAY_DEMAND_POS_CODE")  ] := oJson["VR_CODIGO"]
            aDados[A136APICnt("ARRAY_DEMAND_POS_SEQUEN")] := oJson["VR_SEQUEN"]
            If (cAlias)->(T4R_TIPO) != "2"
                aDados[A136APICnt("ARRAY_DEMAND_POS_PROD")  ] := oJson["VR_PROD"]
                aDados[A136APICnt("ARRAY_DEMAND_POS_REV")   ] := ""
                aDados[A136APICnt("ARRAY_DEMAND_POS_DATA")  ] := StoD(oJson["VR_DATA"])
                aDados[A136APICnt("ARRAY_DEMAND_POS_TIPO")  ] := oJson["VR_TIPO"]
                aDados[A136APICnt("ARRAY_DEMAND_POS_DOC")   ] := oJson["VR_DOC"]
                aDados[A136APICnt("ARRAY_DEMAND_POS_QUANT") ] := oJson["VR_QUANT"]
                aDados[A136APICnt("ARRAY_DEMAND_POS_LOCAL") ] := oJson["VR_LOCAL"]
                If oJson["VR_MOPC"] != Nil .And. oJson["VR_MOPC"] .And. !Empty(oJson["R_E_C_N_O_"])
                    SVR->(dbGoTo(oJson["R_E_C_N_O_"]))
                    If SVR->(Recno()) == oJson["R_E_C_N_O_"] //Proteção para só colocar o MOPC se posicionar no registro correto.
                        aDados[A136APICnt("ARRAY_DEMAND_POS_OPC")] := SVR->VR_MOPC
                        aDados[A136APICnt("ARRAY_DEMAND_POS_STR_OPC")] := SVR->VR_OPC
                    EndIf
                Else
                    aDados[A136APICnt("ARRAY_DEMAND_POS_OPC")] := Nil
                    aDados[A136APICnt("ARRAY_DEMAND_POS_STR_OPC")] := Nil
                EndIf
            EndIf

            If (cAlias)->(T4R_TIPO) == "1"
                aAdd(aDadosInc, aClone(aDados))
				nPosInc++
            Else
                aAdd(aDadosDel, aClone(aDados))
				nPosDel++
			EndIf
		EndIf
		(cAlias)->(dbSkip())

		//Executa a integração para exclusão de demandas
		If nPosDel > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosDel) > 0)
			P141Intgra("MRPDEMANDS", nPosDel, "PCPA136INT", cGlbErros, "DELETE", aDadosDel, oTmpInMrp, Nil, Nil, cUUID)

			aSize(aDadosDel, 0)
			nPosDel := 0
		EndIf

		//Executa a integração para inclusão/atualização de demandas.
		If nPosInc > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosInc) > 0)
			P141Intgra("MRPDEMANDS", nPosInc, "PCPA136INT", cGlbErros, "INSERT", aDadosInc, oTmpInMrp, Nil, Nil, cUUID)

			aSize(aDadosInc, 0)
			nPosInc := 0
		EndIf
    End
    (cAlias)->(dbCloseArea())

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPDEMANDS")
	EndIf

	If Len(aErroJson) > 0
		oErros["ERRO_JSON"] := aClone(aErroJson)
	EndIf
	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	If oTmpInMrp != Nil
		oTmpInMrp:Delete()
		oTmpInMrp := Nil
	EndIf

    aSize(aDadosDel, 0)
    aSize(aDadosInc, 0)
    aSize(aDados   , 0)

    FwFreeArray(aErroJson)
    FreeObj(oJson)
    oJson := Nil

Return oErros
