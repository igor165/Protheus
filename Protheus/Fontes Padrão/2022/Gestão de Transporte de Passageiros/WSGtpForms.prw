#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGtpForms
Métodos WS do GTP para integração da ficha de remessa

@author SIGAGTP
@since 09/03/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL GTPFORMS DESCRIPTION "WS de Integração com Ficha de Remessa" 

    WSDATA agencia  			AS STRING
    WSDATA dataini  			AS STRING
    WSDATA datafim  			AS STRING
	WSDATA numeroficha 			AS STRING
	WSDATA usuario 				AS STRING
	WSDATA filialSelecionada 	AS STRING
	WSDATA codigoLote  			AS STRING

	// Métodos GET
	WSMETHOD GET nextPeriod 	DESCRIPTION 'Retorna o próximo período da ficha de remessa'  PATH "nextPeriod" PRODUCES APPLICATION_JSON 
	WSMETHOD GET returnValues 	DESCRIPTION 'Retorna totais e receitas e despesas da ficha de remessa'  PATH "returnValues" PRODUCES APPLICATION_JSON 
	WSMETHOD GET validPeriod 	DESCRIPTION 'Efetua a validação do período para criação de ficha de acerto'  PATH "validPeriod" PRODUCES APPLICATION_JSON 
	WSMETHOD GET userAgencys 	DESCRIPTION 'Retorna as agências autorizadas por usuário'  PATH "userAgencys" PRODUCES APPLICATION_JSON 
	WSMETHOD GET userBranches 	DESCRIPTION 'Retorna as filiais por usuário e agência'  PATH "userBranches" PRODUCES APPLICATION_JSON 
	WSMETHOD GET allBranchesGTP DESCRIPTION 'Retorna as filiais das tabelas utilizadas na agencia web'  PATH "allBranchesGTP" PRODUCES APPLICATION_JSON 
	WSMETHOD GET GetOrderGTP	DESCRIPTION 'Retorna os pedidos para o lote'  PATH "GetOrderGTP" PRODUCES APPLICATION_JSON 

	// Métodos POST
	WSMETHOD POST upsertForms DESCRIPTION 'Grava a Ficha de Remessa'  PATH "upsertForms" PRODUCES APPLICATION_JSON 

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} nextPeriod
Retorna o próximo período da ficha de remessa

@author SIGAGTP
@since 22/03/2021
@version 1.0
*/*/
//-------------------------------------------------------------------
WSMETHOD GET nextPeriod WSRECEIVE agencia,filialSelecionada WSREST GTPFORMS
	Local lRet      	:= .T.
	Local cAliasG6X		:= GetNextAlias()
	Local cAgencia		:= Self:agencia
	Local dDataIni		:= CtoD('  /  /  ')
	Local dDataFin		:= CtoD('  /  /  ')
	Local oResponse		:= JsonObject():New()
	Local cFilSelect	:= Self:filialSelecionada
	Local cFilOldS      := cfilant

	cfilant := cFilSelect

	BeginSql Alias cAliasG6X

		SELECT T.GI6_CODIGO,
			T.GI6_DESCRI,
			T.GI6_TITPRO,
			T.GI6_DEPOSI,
			T.GI6_DIASFC,
			T.G6X_DTFIN,
			G6X.G6X_STATUS
		FROM
		(SELECT GI6.GI6_FILIAL,
				GI6.GI6_CODIGO,
				GI6.GI6_DESCRI,
				GI6.GI6_TITPRO,
				GI6.GI6_DEPOSI,
				GI6.GI6_DIASFC,
				COALESCE(MAX(G6X.G6X_DTFIN), '0') AS G6X_DTFIN
		FROM %Table:GI6% GI6
		LEFT JOIN %Table:G6X% G6X ON G6X.G6X_FILIAL = %xFilial:G6X%
		AND G6X.G6X_AGENCI = GI6.GI6_CODIGO
		AND G6X.%NotDel%
		WHERE GI6.GI6_FILIAL = %xFilial:GI6%
			AND GI6_CODIGO = %Exp:cAgencia%
			AND GI6.%NotDel%
		GROUP BY GI6.GI6_FILIAL,
					GI6.GI6_CODIGO,
					GI6.GI6_DESCRI,
					GI6.GI6_TITPRO,
					GI6.GI6_DEPOSI,
					GI6.GI6_DIASFC) T
		LEFT JOIN %Table:G6X% G6X ON G6X_FILIAL = %xFilial:G6X%
		AND G6X.G6X_AGENCI = T.GI6_CODIGO
		AND G6X.G6X_DTFIN = T.G6X_DTFIN
		AND G6X.%NotDel%

	EndSql
		
	If (cAliasG6X)->G6X_STATUS $ ('1|5')
		SetRestFault(400, EncodeUtf8("A última ficha de remessa encontra-se com o status Aberto"))
		lRet :=  .F.
	Endif	

	If (lRet .And. AllTrim((cAliasG6X)->GI6_CODIGO) == '')
		SetRestFault(400, EncodeUtf8("Código de agência não encontrado"))
		lRet :=  .F.
	Endif

	If lRet
		oResponse['agencia'] 			:= cAgencia
		oResponse['nomeAgencia']		:= (cAliasG6X)->GI6_DESCRI
		oResponse['tituloProvisorio']	:= (cAliasG6X)->GI6_TITPRO
		oResponse['tipoDeposito'] 		:= (cAliasG6X)->GI6_DEPOSI
		oResponse['diasFicha']			:= (cAliasG6X)->GI6_DIASFC

		If (cAliasG6X)->G6X_DTFIN <> '0'
			dDataIni := StoD((cAliasG6X)->(G6X_DTFIN))+1

			dbSelectArea('GI6')
			GI6->(dbSetOrder(1))
			If GI6->(DbSeek(xFilial('GI6')+cAgencia))
				If GI6->GI6_FCHCAI == '1'
					dDataFin := dDataIni
				Else
					dDataFin := DaySum(dDataIni, GI6->GI6_DIASFC - 1)

					If (AnoMes(dDataIni) < AnoMes(dDataFin))
						dDataFin := LastDate(dDataIni)
					Endif

				EndIf
			EndIf

			oResponse['dataInicial']	:= DtoS(dDataIni)
			oResponse['dataFinal'] 		:= DtoS(dDataFin)
			oResponse['numeroFicha']	:= DtoS(dDataFin)
			oResponse['dataRemessa']	:= DtoS(dDataFin+1)

		Else
			oResponse['dataInicial']	:= '0'
			oResponse['dataFinal'] 		:= '0'
			oResponse['numeroFicha']	:= '0'
			oResponse['dataRemessa'] 	:= '0'
		Endif

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	Endif

	(cAliasG6X)->(dbCloseArea())
	cfilant := cFilOldS
Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} nextPeriod
Retorna o próximo período da ficha de remessa

@author SIGAGTP
@since 22/03/2021
@version 1.0
*/*/
//-------------------------------------------------------------------
 WSMETHOD GET validPeriod WSRECEIVE dataini, datafim, agencia, filialSelecionada WSREST GTPFORMS
	
	Local cMsg			:= ""
	Local lRet      	:= .T.
	Local oResponse		:= JsonObject():New()
	Local cFilSelect	:= Self:filialSelecionada
	Local cFilOldS      := cfilant

	cfilant := cFilSelect

	lRet := G421bVldMovi(StoD(self:dataini), SToD(self:datafim), self:agencia)

	If ( lRet )
		cMsg := I18N("Periodo selecionado valido.")
	Else
		cMsg := I18N("Periodo informado invalido para a criacao da Ficha de Acerto")
	EndIf

	oResponse['sucesso']	:= lRet
	oResponse['messagem']	:= cMsg

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	cfilant := cFilOldS
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} returnValues
Retorna os dados do cabeçalho e os valores da ficha de remessa

@author SIGAGTP
@since 09/03/2021
@version 1.0

/*/
//-------------------------------------------------------------------
WSMETHOD GET returnValues WSRECEIVE agencia, dataini, datafim, numeroficha, filialSelecionada WSREST GTPFORMS
	Local lRet      	:= .T.
	Local cAgencia		:= Self:agencia
	Local cDataIni		:= Self:dataini
	Local cDataFim		:= Self:datafim
	Local cNumFch		:= Self:numeroficha
	Local oResponse		:= JsonObject():New()
	Local cFilSelect	:= Self:filialSelecionada
	Local cFilOldS      := cfilant

	cfilant := cFilSelect
    oResponse['totals'] := {}
	Aadd(oResponse['totals'], JsonObject():New())

    oResponse['totals'][1]['agencia'] 			:= cAgencia
    oResponse['totals'][1]['dataInicial'] 		:= cDataIni
    oResponse['totals'][1]['dataFinal'] 		:= cDataFim
	oResponse['totals'][1]['receitaBilhetes']	:= 0
	oResponse['totals'][1]['receitaTotal'] 		:= 0
	oResponse['totals'][1]['despesaTotal']		:= 0
	oResponse['totals'][1]['valorLiquido']		:= 0

    oResponse['items'] := {}

	SomaBilhet(cAgencia, cDataIni, cDataFim, cNumFch, oResponse)	
	SomaReq(cAgencia, cDataIni, cDataFim,   oResponse)
	SomaTaxas(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaPos(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaTEF(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaGZT(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaBilDev(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaEnc(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaComissao(cAgencia, cDataIni, cDataFim,  oResponse)
	SomaSldAge(cAgencia, oResponse)

	oResponse['totals'][1]['valorLiquido'] := oResponse['totals'][1]['receitaTotal'] - oResponse['totals'][1]['despesaTotal']

    Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	cfilant := cFilOldS
Return lRet 

Static Function AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, cObserv)
Local nItens := Len(oResponse['items'])

Aadd(oResponse['items'], JsonObject():New())

nItens++
oResponse['items'][nItens]['codigo'] 		:= cCodigo
oResponse['items'][nItens]['descricao'] 	:= AllTrim(FwNoAccent(cDescr))
oResponse['items'][nItens]['tipo'] 			:= cTipo
oResponse['items'][nItens]['valor'] 		:= nValor
oResponse['items'][nItens]['observacao']	:= cObserv

If cTipo = '1'
	oResponse['totals'][1]['receitaTotal'] += nValor
Else
	oResponse['totals'][1]['despesaTotal'] += nValor
Endif

Return

Static Function SomaBilhet(cAgencia, cDataIni, cDataFim, cNumFch, oResponse)
Local cAliasGIC := GetNextAlias()

BeginSql Alias cAliasGIC

	SELECT GIC_TIPO,
	       GIC_STATUS,
	       SUM(GIC_VALTOT) GIC_VALTOT
	FROM %Table:GIC%
	WHERE GIC_FILIAL = %xFilial:GIC%
  	AND GIC_AGENCI = %Exp:cAgencia%
	  AND GIC_DTVEND BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND GIC_NUMFCH = %Exp:cNumFch%
	  AND %NotDel%
	GROUP BY GIC_TIPO,
	         GIC_STATUS

EndSql

While (cAliasGIC)->(!Eof())

	If (cAliasGIC)->GIC_STATUS = 'C'
		cCodigo := StrZero(3,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If (cAliasGIC)->GIC_STATUS = 'D'
		cCodigo := StrZero(4,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If (cAliasGIC)->GIC_TIPO = 'W' .And. (cAliasGIC)->GIC_STATUS = 'E'
		cCodigo := StrZero(8,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If (cAliasGIC)->GIC_TIPO = 'P' .And. (cAliasGIC)->GIC_STATUS = 'E'
		cCodigo := StrZero(9,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If !((cAliasGIC)->GIC_TIPO $ 'P|W') .And. (cAliasGIC)->GIC_STATUS = 'E'
		cCodigo := StrZero(10,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If (cAliasGIC)->GIC_TIPO <> 'T' .And. (cAliasGIC)->GIC_STATUS = 'T'
		cCodigo := StrZero(11,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If (cAliasGIC)->GIC_TIPO = 'P' .And. (cAliasGIC)->GIC_STATUS = 'V'
		cCodigo := StrZero(16,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If (cAliasGIC)->GIC_STATUS = 'I'
		cCodigo := StrZero(17,TamSx3('GZG_COD')[1])
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
		cTipo	:= '2'
		nValor	:= (cAliasGIC)->GIC_VALTOT

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')
	Endif 

	If ((cAliasGIC)->GIC_TIPO $ 'I|E|M' .And. (cAliasGIC)->GIC_STATUS = 'V') .Or.;
		 ((cAliasGIC)->GIC_TIPO $ 'I|P|W' .And. (cAliasGIC)->GIC_STATUS = 'E')

		oResponse['totals'][1]['receitaBilhetes'] += (cAliasGIC)->GIC_VALTOT
		oResponse['totals'][1]['receitaTotal']    += (cAliasGIC)->GIC_VALTOT

	Endif

	(cAliasGIC)->(dbSkip())

End

(cAliasGIC)->(dbCloseArea())

Return

Static Function SomaReq(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasReq := GetNextAlias()
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

BeginSql Alias cAliasReq

	SELECT COALESCE(SUM(GIC_REQTOT), 0) AS GIC_REQTOT
	FROM %Table:GIC%
	WHERE GIC_FILIAL = %xFilial:GIC%
	  AND GIC_STATUS = 'V'
	  AND GIC_AGENCI = %Exp:cAgencia%
	  AND GIC_DTVEND BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND GIC_NUMFCH = ''
	  AND GIC_CODREQ <> ''
	  AND %NotDel%

EndSql

If (cAliasReq)->GIC_REQTOT > 0 

	cCodigo := StrZero(5,TamSx3('GZG_COD')[1])
	cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
	cTipo	:= '2'
	nValor	:= (cAliasReq)->GIC_REQTOT

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

Endif

(cAliasReq)->(dbCloseArea())

Return

Static Function SomaTaxas(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasTax := GetNextAlias()
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

BeginSql Alias cAliasTax

	SELECT GZC.GZC_CODIGO,
	       GZC.GZC_DESCRI,
	       SUM(G57_VALOR) AS G57_VALOR
	FROM %Table:G57% G57
	INNER JOIN %Table:GZC% GZC ON GZC.GZC_FILIAL = %xFilial:GZC%
	AND GZC.GZC_TIPDOC = G57.G57_TIPO
	AND GZC.GZC_TIPO = '1'
	AND GZC.%NotDel%
	WHERE G57.G57_FILIAL = %xFilial:G57%
	  AND G57.G57_AGENCI = %Exp:cAgencia%
	  AND G57.G57_EMISSA BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND G57.G57_NUMFCH = ''
	  AND G57.%NotDel%
	GROUP BY GZC.GZC_CODIGO,
	         GZC.GZC_DESCRI	

EndSql

While (cAliasTax)->(!Eof())

	cCodigo := (cAliasTax)->GZC_CODIGO
	cDescr	:= (cAliasTax)->GZC_DESCRI
	cTipo	:= '1'
	nValor	:= (cAliasTax)->G57_VALOR

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

	(cAliasTax)->(dbSkip())
End

(cAliasTax)->(dbCloseArea())

Return 

Static Function SomaPos(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasPos := GetNextAlias()
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

BeginSql Alias cAliasPos

	SELECT GQL.GQL_TPVEND,
	       SUM(GQM.GQM_VALOR) GQM_VALOR
	FROM %Table:GQL% GQL
	INNER JOIN %Table:GQM% GQM ON GQM.GQM_FILIAL = %xFilial:GQM%
	AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
	AND GQM.GQM_DTVEND BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	AND GQM.%NotDel%
	WHERE GQL.GQL_FILIAL = %xFilial:GQM%
	  AND GQL.GQL_CODAGE = %Exp:cAgencia%
	  AND GQL.GQL_NUMFCH = ''
	  AND GQL.%NotDel%
	GROUP BY GQL.GQL_TPVEND

EndSql

While (cAliasPos)->(!Eof())

	cCodigo := StrZero(Iif((cAliasPos)->GQL_TPVEND = '1', 13, 12),TamSx3('GZG_COD')[1])
	cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
	cTipo	:= '2'
	nValor	:= (cAliasPos)->GQM_VALOR

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

	(cAliasPos)->(dbSkip())

End

(cAliasPos)->(dbCloseArea())

Return

Static Function SomaTEF(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasGZP := GetNextAlias()
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

BeginSql Alias cAliasGZP

	SELECT GZP.GZP_TPAGTO,
	       SUM(GZP.GZP_VALOR) GZP_VALOR
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GZP% GZP ON GZP.GZP_FILIAL = %xFilial:GZP%
	AND GZP.GZP_CODIGO = GIC.GIC_CODIGO
	AND GZP.GZP_CODBIL = GIC.GIC_BILHET
	AND GZP.%NotDel%
	WHERE GIC.GIC_FILIAL = %xFilial:GIC%
	  AND GIC.GIC_AGENCI = %Exp:cAgencia%
	  AND GIC.GIC_DTVEND BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND GIC.GIC_NUMFCH = ''
	  AND GIC.%NotDel%
	GROUP BY GZP.GZP_TPAGTO

EndSql

While (cAliasGZP)->(!Eof())

	Do Case
		Case (cAliasGZP)->GZP_TPAGTO == "CR"
			cCodigo := '14'
		Case (cAliasGZP)->GZP_TPAGTO == "DE"
			cCodigo := '15'
		Case (cAliasGZP)->GZP_TPAGTO == "CD"
			cCodigo := '27'
	EndCase

	cCodigo := StrZero(Val(cCodigo), TamSx3('GZG_COD')[1])	
	cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo , 'GZC_DESCRI')
	cTipo	:= '2'
	nValor	:= (cAliasGZP)->GZP_VALOR

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

	(cAliasGZP)->(dbSkip())

End

(cAliasGZP)->(dbCloseArea())

Return

Static Function SomaGZT(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasGZT		:= GetNextAlias()
Local cCodTxConv	:= GTPGetRules('TXCONVENIE', .F. , , '') 
Local cCodigo		:= ''
Local cDescr		:= ''
Local cTipo			:= ''
Local nValor		:= 0
Local cObserv		:= ''

BeginSql Alias cAliasGZT

	SELECT GZC.GZC_CODIGO,
	       GZC.GZC_TIPO,
	       GZC.GZC_DESCRI,
	       SUM(GZT.GZT_VALOR) AS GZT_VALOR
	FROM %Table:GZT% GZT
	INNER JOIN %Table:GZC% GZC ON GZC.GZC_FILIAL = %xFilial:GZC%
	AND GZC.GZC_CODIGO = GZT.GZT_CODGZC
	AND GZC.%NotDel%
	WHERE GZT.GZT_FILIAL = %xFilial:GZT%
	  AND GZT.GZT_AGENCI = %Exp:cAgencia%
	  AND GZT.GZT_DTVEND BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND GZT.GZT_NUMFCH = ''
	  AND GZT.%NotDel%
	GROUP BY GZC.GZC_CODIGO,
	         GZC.GZC_TIPO,
	         GZC.GZC_DESCRI

EndSql

While (cAliasGZT)->(!Eof())

	cCodigo := (cAliasGZT)->GZC_CODIGO
	cDescr	:= (cAliasGZT)->GZC_DESCRI
	cTipo	:= (cAliasGZT)->GZC_TIPO
	nValor	:= (cAliasGZT)->GZT_VALOR

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

	If !EmpTy(cCodTxConv) .AND. (cAliasGZT)->GZC_CODIGO $ cCodTxConv

		cTipo	:= Iif((cAliasGZT)->GZC_TIPO = '1', '2', '1')
		cObserv := 'Geracao automatica de contra-partida'

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, cObserv)

	Endif				

	(cAliasGZT)->(dbSkip())

End

(cAliasGZT)->(dbCloseArea())

Return

Static Function SomaBilDev(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasDev := GetNextAlias()
Local cJoin		:= ''
Local cWhere	:= ''
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

If ChkFile('GYC') .And. GIC->(FieldPos('GIC_TIPCAN')) > 0;
	 .And. GYC->(FieldPos('GYC_GEREST')) > 0

	cJoin := "%LEFT JOIN "+RetSqlName("GYC")+" GYC " + chr(13)
	cJoin += " ON GYC.GYC_FILIAL = '" + xFilial("GYC") + "' " + chr(13)
	cJoin += " AND GYC.GYC_CODIGO = GIC.GIC_TIPCAN " + chr(13)
	cJoin += " AND GYC.D_E_L_E_T_ = ' '%" 

	cWhere := "% AND (GYC.GYC_GEREST IS NULL OR GYC.GYC_GEREST = '1') %"

Endif

BeginSql Alias cAliasDev

	SELECT GZP.GZP_TPAGTO,
	       GIC.GIC_STATUS,
	       SUM(GZP.GZP_VALOR) AS GZP_VALOR
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GZP% GZP ON GZP.GZP_FILIAL = GIC.GIC_FILIAL
	AND GZP.GZP_CODIGO = GIC.GIC_BILREF
	AND GZP.GZP_TPAGTO = 'CR'
	AND GZP.%NotDel%
	%Exp:cJoin%
	WHERE GIC.GIC_FILIAL = %xFilial:GIC%
	  AND GIC.GIC_AGENCI = %Exp:cAgencia%
	  AND GIC.GIC_BILREF != ''
	  AND GIC.GIC_NUMFCH = ''
	  AND GIC.GIC_STATUS IN ('C','D')
	  %Exp:cWhere%
	  AND GIC.GIC_DTVEND BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND GIC.%NotDel%
	GROUP BY GZP.GZP_TPAGTO, GIC.GIC_STATUS

EndSql

While (cAliasDev)->(!Eof())

	If (cAliasDev)->(GZP_TPAGTO) == 'CR' .And. (cAliasDev)->(GIC_STATUS) == 'C'
		cCodigo := '19'
	ElseIf (cAliasDev)->(GZP_TPAGTO) == 'DE' .And. (cAliasDev)->(GIC_STATUS) == 'C'
		cCodigo := '18'
	ElseIf (cAliasDev)->(GZP_TPAGTO) == 'CR' .And. (cAliasDev)->(GIC_STATUS) == 'D'
		cCodigo := '20'
	Else
		cCodigo := '21'
	Endif

	If (cCodigo == '19' .Or. cCodigo == '20')

		cCodigo :=  StrZero(Val(cCodigo),TamSx3('GZG_COD')[1])

		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo, 'GZC_DESCRI')
		cTipo	:= '1'
		nValor	:= (cAliasDev)->GZP_VALOR

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

	Endif

	(cAliasDev)->(dbSkip())

End

(cAliasDev)->(dbCloseArea())

Return

Static Function SomaEnc(cAgencia, cDataIni, cDataFim, oResponse)
Local cAliasEnc := GetNextAlias()
Local nTotRec	:= 0
Local nTotDesp	:= 0
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

BeginSql Alias cAliasEnc

	SELECT G99.G99_TOMADO,
	       GIR.GIR_TIPPAG,
	       CASE
	           WHEN G99.G99_TIPCTE = '1' THEN SUM(G99.G99_COMPVL)
	        ELSE SUM(GIR.GIR_VALOR)
		   END AS G99_VALOR
	FROM %Table:G99% G99
	INNER JOIN %Table:GIR% GIR ON GIR.GIR_FILIAL = G99.G99_FILIAL
	AND GIR.GIR_CODIGO = G99_CODIGO
	AND GIR.%NotDel%
	WHERE G99.G99_FILIAL = %xFilial:G99%
	  AND ((G99_CODEMI = %Exp:cAgencia%
	        AND G99_TOMADO = '0')
	       OR (G99_CODREC = %Exp:cAgencia%
	           AND G99_TOMADO = '3'
	           AND G99_STAENC = '5'))
	  AND G99.G99_DTEMIS BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	  AND G99.G99_NUMFCH = ''
	  AND G99.G99_STATRA = '2'
	  AND G99.G99_TIPCTE <> '2'
	  AND G99.G99_COMPLM <> 'I'
	  AND G99.%NotDel%
	GROUP BY G99.G99_TOMADO, G99.G99_TIPCTE, GIR.GIR_TIPPAG

EndSql

While (cAliasEnc)->(!Eof())

	nTotRec += (cAliasEnc)->G99_VALOR

	If ((cAliasEnc)->G99_TOMADO == '0' .And. (cAliasEnc)->GIR_TIPPAG $ '3|4') .Or.;
		((cAliasEnc)->G99_TOMADO == '3' .And. (cAliasEnc)->GIR_TIPPAG == '3')				
		nTotDesp += (cAliasEnc)->G99_VALOR
	Endif	

	(cAliasEnc)->(dbSkip())

End

(cAliasEnc)->(dbCloseArea())

If nTotRec > 0
	cCodigo := (StrZero(24, TamSx3('GZG_COD')[1]))

	cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo, 'GZC_DESCRI')
	cTipo	:= '1'
	nValor	:= nTotRec

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

Endif

If nTotDesp > 0

	cCodigo := (StrZero(25, TamSx3('GZG_COD')[1]))
	cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo, 'GZC_DESCRI')
	cTipo	:= '2'
	nValor	:= nTotDesp

	AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

Endif

Return

Static Function SomaSldAge(cAgencia, oResponse)
Local cAliasGQN := GetNextAlias()
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local nValor	:= 0

If GTPxVldDic('GQN', , .T., .T.)

	BeginSql Alias cAliasGQN

		SELECT GQN.GQN_NUMFCH,
			GQN.GQN_TPDIFE,
			GQN.GQN_VLDIFE
		FROM %Table:GQN% GQN
		INNER JOIN %Table:G6T% G6T ON G6T.G6T_FILIAL = %xFilial:G6T%
			AND G6T.G6T_CODIGO = GQN.GQN_CDCAIX
			AND G6T.G6T_STATUS = '2'
			AND G6T.%NotDel%
		WHERE GQN.GQN_FILIAL = %xFilial:GQN%
			AND GQN.GQN_AGENCI = %Exp:cAgencia%
			AND GQN.GQN_FCHDES =  ''
			AND GQN.%NotDel%			


	EndSql

	While (cAliasGQN)->(!(Eof()))

		cTipo := IIf((cAliasGQN)->GQN_TPDIFE == '1','1','2')

		cCodigo := (StrZero(26, TamSx3('GZG_COD')[1]))
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo, 'GZC_DESCRI')
		cTipo	:= cTipo
		nValor	:= (cAliasGQN)->GQN_VLDIFE

		AddItem(oResponse, cCodigo, cDescr, cTipo, nValor, '')

		(cAliasGQN)->(dbSkip())

	End

	(cAliasGQN)->(dbCloseArea())

Endif

Return

Static Function SomaComissao(cAgencia, cDataIni, cDataFim, oResponse)
Local cCodigo	:= ''
Local cDescr	:= ''
Local cTipo		:= ''
Local lOnlyCalc	:= .T.

dbSelectArea("GI6")
GI6->(dbSetOrder(1))

If GI6->(dbSeek(xFilial('GI6')+cAgencia)) .And.;
	 GI6->(FieldPos('GI6_COMFCH')) > 0 .And.;
	 GI6->GI6_COMFCH == '1'

	nVlrCom := GTP410ComFch(cAgencia, StoD(cDataIni), StoD(cDataFim), cDataFim, lOnlyCalc)

	If nVlrcom > 0
		cCodigo := (StrZero(28, TamSx3('GZG_COD')[1]))
		cDescr	:= Posicione('GZC', 1, xFilial('GZC') + cCodigo, 'GZC_DESCRI')
		cTipo	:= '2'

		AddItem(oResponse, cCodigo, cDescr, cTipo, nVlrCom, '')
	Endif

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} userAgencys
Retorna as agencias do usuario logado

@author SIGAGTP
@since 10/08/2021
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET userAgencys WSRECEIVE usuario, filialSelecionada WSREST GTPFORMS
	Local lRet      	:= .T.
	Local cAliasTmp		:= GetNextAlias()
	Local cUsuario		:= Self:usuario
	Local oResponse		:= JsonObject():New()
	Local nItens 		:= 0
	Local cQryFil		:= ""
	Local aGrpsUser		:= {}
	Local cFilSelect	:= Self:filialSelecionada	
	Local cFilOldS      := cfilant

	cfilant := cFilSelect

	If cUsuario = NIL .Or. cUsuario = ''
		SetRestFault(400, EncodeUtf8("O parametro usuario deve ser informado"))
		Return  .F.
	Endif	

	aGrpsUser := FwSFUsrGrps(cUsuario)

	GYF->(dbSetOrder((1)))
	
	If GYF->(dbSeek(xFilial('GYF')+'GRUPOSUP')) .And. aScan(aGrpsUser,{|x| AllTrim(x) == AllTrim(GYF->GYF_CONTEU)})
		oResponse['supervisor'] := 'sim'
	Else
		oResponse['supervisor'] := 'nao'
		cQryFil := " AND G9X.G9X_CODUSR =  '" + cUsuario + "'"
	Endif

	cQryFil := '%' + cQryFil + '%'

	BeginSql Alias cAliasTmp

		SELECT GI6.GI6_FILIAL,
		       GI6.GI6_CODIGO,
		       GI6.GI6_DESCRI
		FROM %Table:GI6% GI6
		INNER JOIN %Table:G9X% G9X ON G9X.G9X_FILIAL = %xFilial:G9X%
		AND G9X.G9X_CODGI6 = GI6.GI6_CODIGO
		%Exp:cQryFil%
		AND G9X.%NotDel%
		WHERE GI6.GI6_FILIAL = %xFilial:GI6%
		  AND GI6.%NotDel%
		GROUP BY GI6.GI6_FILIAL, GI6.GI6_CODIGO, GI6.GI6_DESCRI  

	EndSql

	oResponse['agencias'] := {}

	While (cAliasTmp)->(!Eof())
		
		Aadd(oResponse['agencias'], JsonObject():New())

		nItens++

		oResponse['agencias'][nItens]['filial']		:= (cAliasTmp)->GI6_FILIAL
		oResponse['agencias'][nItens]['codigo'] 	:= AllTrim((cAliasTmp)->GI6_CODIGO)
		oResponse['agencias'][nItens]['descricao']	:= AllTrim((cAliasTmp)->GI6_DESCRI)

		(cAliasTmp)->(dbSkip())

	End

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	(cAliasTmp)->(dbCloseArea())
	cfilant := cFilOldS
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} userBranches
Retorna as filiais do usuario e da agencia

@author SIGAGTP
@since 10/08/2021
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET userBranches WSRECEIVE usuario, filialSelecionada WSREST GTPFORMS
	Local lRet      	:= .T.
	Local cAliasTmp		:= GetNextAlias()
	Local cUsuario		:= Self:usuario
	Local oResponse		:= JsonObject():New()
	Local nItens 		:= 0
	Local cQryFil		:= ""
	Local aGrpsUser		:= {}	
	Local cFilSelect	:= Self:filialSelecionada
	Local cFilOldS      := cfilant

	cfilant := cFilSelect
	
	If cUsuario = NIL .Or. cUsuario = ''
		SetRestFault(400, EncodeUtf8("O parametro usuario deve ser informado"))
		Return  .F.
	Endif	

	aGrpsUser := FwSFUsrGrps(cUsuario)

	GYF->(dbSetOrder((1)))
	
	If !(GYF->(dbSeek(xFilial('GYF')+'GRUPOSUP')) .And. aScan(aGrpsUser,{|x| AllTrim(x) == AllTrim(GYF->GYF_CONTEU)}))
		cQryFil := " AND G9X.G9X_CODUSR =  '" + cUsuario + "'"
	Endif

	cQryFil := '%' + cQryFil + '%'

	BeginSql Alias cAliasTmp

		SELECT DISTINCT GI6.GI6_FILIAL
		FROM %Table:GI6% GI6
		INNER JOIN %Table:G9X% G9X 
			ON G9X.G9X_CODGI6 = GI6.GI6_CODIGO
			%Exp:cQryFil%
			AND G9X.%NotDel%
		WHERE GI6.%NotDel%
		GROUP BY GI6.GI6_FILIAL, GI6.GI6_CODIGO, GI6.GI6_DESCRI  

	EndSql

	oResponse['items'] := {}

	While (cAliasTmp)->(!Eof())
		
		Aadd(oResponse['items'], JsonObject():New())

		nItens++

		oResponse['items'][nItens]['filial'] := (cAliasTmp)->GI6_FILIAL
		oResponse['items'][nItens]['descricao'] := fwfilialname(,(cAliasTmp)->GI6_FILIAL)

		(cAliasTmp)->(dbSkip())

	End

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	(cAliasTmp)->(dbCloseArea())

	cfilant := cFilOldS
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} allBranches
Retorna as filiais das tabelas com base no que foi passado

@author SIGAGTP
@since 10/08/2021
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET allBranchesGTP WSRECEIVE filialSelecionada WSREST GTPFORMS
	Local lRet      	:= .T.
	Local cFilSelect	:= Self:filialSelecionada
	Local oResponse		:= JsonObject():New()
	Local cFilOldS      := cfilant
	Local nCnt          := 0
	Local nItens        := 0
	Local aAlias := { "G52","G53","G54","G55","G56","G57","G58","G59","G5A","G5B","G5C","G5D","G5E","G5F","G5G","G5H","G5I","G5J","G5K","G5L","G6Q","G6R","G6S","G6T","G6U","G6V","G6W","G6X","G6Y","G6Z","G94","G95",;
                "G96","G97","G98","G99","G9A","G9B","G9C","G9D","G9E","G9O","G9P","G9Q","G9R","G9S","G9T","G9U","G9V","G9X","G9Y","G9Z","GI0","GI1","GI2","GI3","GI4","GI5","GI6","GI7","GI8","GI9","GIA","GIB",;
                "GIC","GID","GIE","GIF","GIG","GIH","GII","GIJ","GIK","GIL","GIM","GIN","GIO","GIP","GIQ","GIR","GIS","GIT","GIU","GIV","GIW","GIX","GIY","GIZ","GQ1","GQ2","GQ3","GQ4","GQ5","GQ6","GQ7","GQ8",;
                "GQ9","GQA","GQB","GQC","GQD","GQE","GQF","GQG","GQH","GQI","GQJ","GQK","GQL","GQM","GQN","GQO","GQP","GQQ","GQR","GQS","GQT","GQU","GQV","GQW","GQX","GQY","GQZ","GY0","GY1","GY2","GY3","GY4",;
                "GY5","GY6","GY7","GY8","GY9","GYA","GYB","GYC","GYD","GYE","GYF","GYG","GYH","GYI","GYJ","GYK","GYL","GYM","GYN","GYO","GYP","GYQ","GYR","GYS","GYT","GYU","GYV","GYW","GYX","GYY","GYZ","GZ0",;
                "GZ1","GZ2","GZ3","GZ4","GZ5","GZ6","GZ7","GZ8","GZ9","GZA","GZB","GZC","GZD","GZE","GZF","GZG","GZH","SA6","SAE"}
	
	If cFilSelect = NIL .Or. cFilSelect = '' .OR. cFilSelect = 'NULL'
		SetRestFault(400, EncodeUtf8("Filial deve ser informada"))
		lRet :=  .F.
	Endif	

	If lRet
		cfilant := cFilSelect
		oResponse['items'] := {}
		for nCnt := 1 to LEN(aAlias)
			Aadd(oResponse['items'], JsonObject():New())
			nItens++
			oResponse['items'][nItens]['filial'] := 'filial' + aAlias[nCnt]
			oResponse['items'][nItens]['codigo'] := FWXFILIAL(aAlias[nCnt])
		next nCnt

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		
		cfilant := cFilOldS
	EndIf
Return lRet

WSMETHOD GET GetOrderGTP WSRECEIVE codigoLote, filialSelecionada WSREST GTPFORMS
	Local lRet      	:= .T.
	Local cAliasG9Y		:= GetNextAlias()
	Local cLote  		:= Self:codigoLote
	Local oResponse		:= JsonObject():New()
	Local cFilSelect	:= Self:filialSelecionada
	Local cFilOldS      := cfilant
	Local nItens        := 0
	cfilant := cFilSelect

	BeginSql Alias cAliasG9Y

		SELECT 
			SC6.C6_FILIAL
			, SC6.C6_NUM
			, SC6.C6_QTDENT
			, SC6.C6_QTDVEN
			, SC6.C6_TES
			, SC6.C6_ENTREG
			, SC5.C5_CLIENT
			, SC5.C5_LOJACLI
			, SA1.A1_NOME
			, SC6.C6_PRODUTO
			, SB1.B1_DESC
			, SC6.C6_PRCVEN 
		FROM %Table:G9Y% G9Y
		INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = G9Y.G9Y_PEDIDO
			AND SC5.%NotDel%
		INNER JOIN %Table:SC6% SC6
			ON SC6.C6_FILIAL = SC5.C5_FILIAL
			AND SC6.C6_NUM = SC5.C5_NUM 
			AND SC6.%NotDel%
		INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SC6.C6_PRODUTO
			AND SB1.%NotDel%
		INNER JOIN %Table:SA1% SA1
			ON SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENT
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%NotDel%
		WHERE G9Y.G9Y_FILIAL = %xFilial:G9Y%
			AND G9Y.G9Y_LOTE = %exp:cLote%
			AND G9Y.%NotDel%

	EndSql
		

	oResponse['items'] := {}

	While (cAliasG9Y)->(!Eof())
		
		Aadd(oResponse['items'], JsonObject():New())

		nItens++

		oResponse['items'][nItens]['cG9YPEDIDO'] := (cAliasG9Y)->C6_NUM
		oResponse['items'][nItens]['cG9YCLIENTE'] := "[" + ALLTRIM((cAliasG9Y)->C5_CLIENT) + "] " + (cAliasG9Y)->A1_NOME
		oResponse['items'][nItens]['cG9YLOJA'] := (cAliasG9Y)->C5_LOJACLI
		oResponse['items'][nItens]['cG9YPRODUTO'] := "[" + ALLTRIM((cAliasG9Y)->C6_PRODUTO) + "] " + (cAliasG9Y)->B1_DESC
		oResponse['items'][nItens]['cG9YVALOR'] := (cAliasG9Y)->C6_PRCVEN
		

		(cAliasG9Y)->(dbSkip())

	End

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	(cAliasG9Y)->(dbCloseArea())

	cfilant := cFilOldS

Return lRet 

WSMETHOD POST upsertForms WSREST GTPFORMS
Local lRet  	:= .T.
Local oRequest	:= JSonObject():New()
Local oResponse := JsonObject():New()
Local cBody     := Self:GetContent()

oRequest:fromJson(cBody)

oResponse['ok'] := lRet
Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet
