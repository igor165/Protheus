#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

Static _nTamFil  := Nil
Static _nTamCode := Nil
Static _nTamTipo := Nil
Static _nTamMRP  := Nil

/*/{Protheus.doc} PCPA141AMZ
Executa o processamento dos registros de armazém

@type  Function
@author brunno.costa
@since 11/08/2020
@version P12.1.27
@param  cUUID , Caracter, Identificador do processo para buscar os dados na tabela T4R
@return oErros, Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141AMZ(cUUID)
	Local aDados    := {}
	Local aDadosDel := {}
	Local aDadosInc := {}
	Local aErroJson := {}
	Local cAlias    := PCPAliasQr()
	Local cError    := ""
	Local cQryBase  := ""
	Local lErro     := .F.
	Local lLock     := .F.
	Local oJson     := JsonObject():New()
	Local oErros    := JsonObject():New()
	Local oPCPLock  := PCPLockControl():New()

	If _nTamFil == Nil
		_nTamFil   := FwSizeFilial()
		_nTamCode  := GetSX3Cache("NNR_CODIGO", "X3_TAMANHO")
		_nTamTipo  := GetSX3Cache("NNR_TIPO"  , "X3_TAMANHO")
		_nTamMRP   := GetSX3Cache("NNR_MRP"   , "X3_TAMANHO")
	EndIf

	//Campos que serão usados
	cQryFields := "%NNR.NNR_FILIAL," +;
				  " NNR.NNR_CODIGO,"+;
				  " NNR.NNR_TIPO,"+;
				  " NNR.NNR_MRP,"+;
				  " NNR.R_E_C_N_O_%"

	//Relacionamento entre Grupo e Local de estoque
	cQryBase := RetSqlName("NNR") + " NNR" + ;
				" WHERE NNR.D_E_L_E_T_ = ' '"

	BeginSql Alias cAlias
		SELECT T4R.T4R_TIPO,
		       T4R.R_E_C_N_O_,
		       T4R.T4R_IDREG,
			   T4R.T4R_DADOS
		  FROM %Table:T4R% T4R
		 WHERE T4R.T4R_FILIAL = %xfilial:T4R%
		   AND T4R.T4R_API    = 'MRPWAREHOUSE'
		   AND T4R.T4R_STATUS = '3'
		   AND T4R.T4R_IDPRC  = %Exp:cUUID%
		   AND T4R.%NotDel%
	EndSql

	If (cAlias)->(!Eof())
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPWAREHOUSE", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
	EndIf

	While (cAlias)->(!Eof())
        cError := oJson:FromJson(StrTran((cAlias)->(T4R_DADOS), "\","\\"))
		lErro  := !Empty(cError) .Or. Len(oJson:GetNames()) == 0

		If lErro
			aAdd(aErroJson, {(cAlias)->R_E_C_N_O_, STR0019 + IIf(!Empty(cError), " - " + cError, "")}) //"O campo T4R_DADOS não é um Json válido."
		Else
			aSize(aDados, 0)
			aDados := Array(WHAPICnt("ARRAY_WH_SIZE"))

			aDados[WHAPICnt("ARRAY_WH_POS_FILIAL") ] := PadR(oJson["NNR_FILIAL"] , _nTamFil )
			aDados[WHAPICnt("ARRAY_WH_POS_COD")    ] := PadR(oJson["NNR_CODIGO"] , _nTamCode)
			aDados[WHAPICnt("ARRAY_WH_POS_TIPO")   ] := PadR(oJson["NNR_TIPO"]   , _nTamTipo)
			aDados[WHAPICnt("ARRAY_WH_POS_MRP")    ] := PadR(oJson["NNR_MRP"]    , _nTamMRP )

			//Só atualiza os dados que não possuem o resíduo zerado (C1_RESIDUO = ' '). Caso contrário, exclui
			If (cAlias)->(T4R_TIPO) = "1"
				aAdd(aDadosInc, aClone(aDados))
			Else
				aAdd(aDadosDel, aClone(aDados))
			EndIf
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	//Executa a integração para exclusão
	If Len(aDadosDel) > 0
		PcpWHInt("DELETE", aDadosDel, Nil, Nil, cUUID)
	EndIf

	//Executa a integração para inclusão/atualização.
	If Len(aDadosInc) > 0
		PcpWHInt("INSERT", aDadosInc, Nil, Nil, cUUID)
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPWAREHOUSE")
	EndIf

	If Len(aErroJson) > 0
		oErros["ERRO_JSON"] := aClone(aErroJson)
    EndIf

	aSize(aDadosDel, 0)
	aSize(aDadosInc, 0)
	aSize(aDados   , 0)

    FwFreeArray(aErroJson)

Return oErros
