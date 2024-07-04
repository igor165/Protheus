#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RESTFUL.CH"
#include "WSFINA884.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL wsfin884 DESCRIPTION "plaid Rest"
	WSDATA session_id   AS string
	WSDATA tabela		AS string
	WSDATA datainicial  AS string
	WSDATA dataFinal	AS string
	WSDATA banco	    AS string
	WSDATA agencia	    AS string
	WSDATA conta	    AS string
	WSDATA pagina 		AS string
	WSDATA itenspagina  AS string
	WSDATA rotina 		AS string
	WSDATA tipo		    AS integer
	WSDATA registro	    AS integer
	WSDATA filtro	    AS string
	WSData valorcredito AS float
	WSData valordebito  AS float
	WSData linked 		AS string



	WSMETHOD POST  DESCRIPTION "Integración Plaid";
		WSSYNTAX "/wsfin884"

	WSMETHOD GET browser DESCRIPTION "Retorna dados browser ";
		WSSYNTAX "/getbrowser"  PATH "/getbrowser"

	WSMETHOD GET dados DESCRIPTION "Retorna dados da tabela ";
		WSSYNTAX "/getdados"  PATH "/getdados"

	WSMETHOD GET dicionario DESCRIPTION "Retorna dados dicionário ";
		WSSYNTAX "/getdicionario"  PATH "/getdicionario"

	WSMETHOD POST gravarplaid DESCRIPTION "Relaciona os titulos ao Plaid";
		WSSYNTAX "/gravarplaid"  PATH "/gravarplaid"

	WSMETHOD POST undoplaid DESCRIPTION "Estornar os titulos ao Plaid";
		WSSYNTAX "/undoplaid"  PATH "/undoplaid"

	WSMETHOD POST receivableaccount DESCRIPTION "Add Account Receivable Record";
		WSSYNTAX "/accountReceivable"  PATH "/accountReceivable"

	WSMETHOD POST payableaccount DESCRIPTION "Add Account Payable Record";
		WSSYNTAX "/accountPayable"  PATH "/accountPayable"

	WSMETHOD POST bankTransaction DESCRIPTION "Add Bank Transaction";
		WSSYNTAX "/bankTransaction"  PATH "/bankTransaction"

	WSMETHOD POST bankWireTransfer DESCRIPTION "Add Bank Wire Transfer";
		WSSYNTAX "/bankWireTransfer"  PATH "/bankWireTransfer"

	WSMETHOD GET lista DESCRIPTION "Retorna lista das tabelas";
		WSSYNTAX "/getlista"  PATH "/getlista"

	WSMETHOD GET class DESCRIPTION "Retorna sugestao da classificação(natureza financeira)  ";
		WSSYNTAX "/getclass"  PATH "/getclass"

	WSMETHOD GET idioma DESCRIPTION "Retorna literais no idioma logado ";
		WSSYNTAX "/idioma"  PATH "/idioma"


END WSRESTFUL

WSMETHOD GET idioma WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro

	Default Self:pagina:=1
	Default Self:itenspagina:=10
	Default Self:rotina:=""

	SetDate()
	Idioma(@cRetorno,@lRetorno,@cErro)

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)

WSMETHOD GET lista WSRECEIVE tabela,pagina,itenspagina,rotina  WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro

	Default Self:pagina:=1
	Default Self:itenspagina:=10
	Default Self:rotina:=""

	SetDate()
	Lista(@cRetorno,@lRetorno,@cErro,Self:pagina,Self:itenspagina,Self:tabela,Self:rotina)

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)

Static Function Lista(cRetorno,lRetorno,cErro,nPagina,nItensPagina,cAliasTab,cRotina,cFiltro)
	Local aAreaAtu:=GetArea()
	Local oJson := JsonObject():new()
	Local oJson['dados']   := {}
	Local cAliasQry:=GetNextAlias()
	Local cQuery:=""
	Local nLinha:=0
	Local nInd
	Local cCampo
	Local nPosicao
	Local aDados:={}
	Local cOrderBy:=""
	Local cCpoBlq

	If cAliasTab=="SED"
		cAliasTab:="SED"
		aHeader:={}
		AAdd(aHeader,{"","ED_CODIGO"})
		AAdd(aHeader,{"","ED_DESCRIC"})


		For nInd:=1 To Len(aHeader)
			cCampo:=AllTrim(aHeader[nInd,2])
			If(nPosicao:=(cAliasTab)->(FieldPos(cCampo)))>0
				Aadd(aDados,{cCampo,nPosicao,AllTrim(GetSx3Cache(cCampo,'X3_TIPO')) }   )
			EndIf
		Next
		cQuery+=" FROM "+RetSqlName("SED")
		cQuery+=" WHERE ED_FILIAL='"+xFilial("SED")+"'"
		cQuery+=" AND ED_CODIGO BETWEEN ' ' AND 'ZZZ'
		cQuery+=" AND D_E_L_E_T_=' '
		cOrderBy:=" ORDER BY 1"


	EndIf

	If !Empty( cFile := FWSX2Util():GetFile( cAliasTab ))
		cCpoBlq:=PrefixoCpo(cAliasTab)+"_MSBLQL"
		If (cAliasTab)->(FieldPos(cCpoBlq))>0
			cQuery+=" And "+cCpoBlq+" <>'1'"
		EndIf
	EndIf

	cQuery+=Space(1)+cOrderBy
	cQuery:="%"+cQuery+"%"
	BeginSql Alias cAliasQry
        SELECT R_E_C_N_O_ RECTAB
        %Exp:cQuery%
	EndSql

	Do While (cAliasQry)->(!Eof())
		(cAliasTab)->(DbGoTo((cAliasQry)->RECTAB ))
		AAdd(oJson['dados'] ,JsonObject():new())
		nLinha++
		For nInd:=1 To Len(aDados)
			cCampo:=aDados[nInd,1]
			xValor:=(cAliasTab)->(FieldGet(aDados[nInd,2]))
			If aDados[nInd,3]=="C"
				xValor:=EncodeUTF8(AllTrim(xValor),"cp1252")
			ElseIf aDados[nInd,3]=="D"
				If Empty(xValor)
					xValor:=""
				Else
					xValor:=Dtoc(xValor)
				EndIf
			EndIf
			oJson['dados'][nLinha][cCampo]:=xValor
			oJson['dados'][nLinha]["RECTAB"]:=(cAliasQry)->RECTAB
		Next

		If cAliasTab=="SED"
			oJson['dados'][nLinha]["CONCATENADO_Z02"]:=SED->(AllTrim(ED_CODIGO)+"-"+AllTrim(ED_DESCRIC))
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	lRetorno:=.T.
	cErro:=""
	cRetorno:=oJson:toJSON()
	RestArea(aAreaAtu)

Return

WSMETHOD POST  WSSERVICE wsfin884
	Local lPost := .T.
	Local cBody
	Local oObj
	Local cEmp	:= "01"
	Local cFil	:= "01"

	::SetContentType("application/json")

	cBody := ::GetContent()

	FWJsonDeserialize(cBody,@oObj)
	If empty(cBody)
		cBody := STR0001// "Sin Valor"
	Else
		if(Select("SX6")==0)
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
		EndIf
		dbSelectArea("RVR")
		RecLock("RVR",.T.)
		REPLACE  RVR->RVR_FILIAL	WITH xFilial("RVR")
		REPLACE  RVR->RVR_TOKEN 	WITH cvaltochar(oObj:token)
		REPLACE  RVR->RVR_USERID 	WITH "INTEGRATIONPLAID"
		RVR->(MsUnlock())
		RVR->(DbCloseArea())
		::SetResponse('{"Recibido":"' + oObj:token + '", "client":"'+ "oObj:session_id" + '"}')
	EndIf

Return lPost

WSMETHOD GET browser WSRECEIVE pagina,itenspagina,tabela,rotina,dataInicial,dataFinal,banco,agencia,conta,tipo,filtro,valorcredito,valordebito,linked  WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro
	Local lZerado:=.F.

	Default Self:tabela:=""
	Default Self:pagina:=1
	Default Self:itenspagina:=10
	Default Self:filtro:=""

	SetDate()
	GetBrowser(@cRetorno,@lRetorno,@cErro,Self:tabela,Self:pagina,Self:itenspagina,Self:rotina,Self:filtro,Self:datainicial,Self:dataFinal,Self:banco,Self:agencia,Self:conta,Self:tipo,Self:registro,@lZerado,self:linked)
	If Self:rotina=="PLAID_SUGESTAO" .And. lZerado
		GetBrowser(@cRetorno,@lRetorno,@cErro,Self:tabela,Self:pagina,Self:itenspagina,"PLAID",Self:filtro,Self:datainicial,Self:dataFinal,Self:banco,Self:agencia,Self:conta,Self:tipo,Self:registro,,self:linked)
	EndIf
	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)

Static Function GetBrowser(cRetorno,lRetorno,cErro,cAliasTab,nPagina,nItensPagina,cRotina,cJsonFiltro,sDataIni,sDataFim,cBanco,cAgencia,cConta,nTipo,nRecno,lZerado,cLinked)
	Local oJson := JsonObject():new()
	Local oJson['dados']   := {}
	Local aAreaAtu:=GetArea()
	Local cAliasQry:=GetNextAlias()
	Local cSeekKey
	Local bSeekWhile
	Local nInd
	Local cCampo
	Local cQuery
	Local nLinha:=0
	Local aBrowser:={}
	Local cQry
	Local oJsonFiltro := JsonObject():new()
	Local aNames
	Local lRVSBrowse:=.F.
	Local lOracle:=TcGetDb() $ "ORACLE"
	Local aAux
	Local lSE5Browse:=(cAliasTab=="SE5")
	Local lSugestao
	Local aDadosFiltro:=Array(4)
	Local nValor
	Local nXnd
	Local axValor
	Local lBetween:=.F.
	Local nContar
	Local nTolera:=GetMv("MV_PLTOLER",,5)/100
	Local cSugFiltro:=""
	Local cExclTipCP 	:= AllTrim(GETMV("MV_PLEXTCP",,""))
	Local cExclTipCR	:= AllTrim(GETMV("MV_PLEXTCR",,""))
	Local dEmissao
	Default cRotina:=""
	Default cJsonFiltro:=""
	Default cAliasTab:=""
	Default nRecno:=0
	Default cLinked:="3"

	aHeader:={}
	aCols:={}

	cSeekKey   :=xFilial(cAliasTab)
	bSeekWhile := {|| .T. }

	If ValType(nTipo)=="C"
		nTipo:=Val(nTipo)
	EndIf

	If ValType(nPagina)=="C"
		nPagina:=Val(nPagina)
	EndIf

	If ValType(nItensPagina)=="C"
		nItensPagina:=Val(nItensPagina)
	EndIf


	If cAliasTab$"SE1*SE2*SE5"
		aAux:=GetCampos(cAliasTab)
	Else
		aAux:=FWSX3Util():GetAllFields( cAliasTab , .T. )
	EndIf
	For nInd:=1 To Len(aAux)
		AAdd(aHeader,{,aAux[nInd]})
	Next

	For nInd:=1 To Len(aHeader)
		cCampo:=AllTrim(aHeader[nInd,2])
		If cCampo=="RVS_DESCRI" .Or. AllTrim(GetSx3Cache(cCampo,'X3_BROWSE'))=="S" .Or. cAliasTab$"SE1*SE2*SE5"
			nPosicao:=(cAliasTab)->(FieldPos(cCampo))
			Aadd(aBrowser,{cCampo,nPosicao,AllTrim(GetSx3Cache(cCampo,'X3_TIPO')) ,AllTrim(GetSx3Cache(cCampo,'X3_INIBRW'))}   )
		EndIf
	Next

	cQuery:=" From "+RetSqlName(cAliasTab)+" TAB"
	cQuery+=" Where "+PrefixoCpo(cAliasTab)+"_FILIAL='"+xFilial(cAliasTab)+"'"

	If !Empty(cJsonFiltro)
		oJsonFiltro:fromJson(cJsonFiltro)
		aNames := oJsonFiltro:GetNames()
		For nInd := 1 to Len( aNames )

			If ValType(oJsonFiltro[aNames[nInd]])=="A"
				lBetween:=.T.
				axValor:={}
				For nXnd:=1 To Len(oJsonFiltro[aNames[nInd]])
					AAdd(axValor,oJsonFiltro[aNames[nInd]][nXnd])
				Next
			Else
				lBetween:=.F.
				xValor:=oJsonFiltro[aNames[nInd]]
			EndIf

			If AllTrim(GetSx3Cache(aNames[nInd],'X3_TIPO'))=="D"

				If lBetween

					If !Empty(axValor[1])
						cQuery+=" And "+ aNames[nInd]+" >='"+StrTran(axValor[1],"-","")+"'"
					EndIf

					If !Empty(axValor[2])
						cQuery+=" And "+ aNames[nInd]+" <='"+StrTran(axValor[2],"-","")+"'"
					EndIf



				ElseIf !Empty(xValor)
					xValor:=StrTran(xValor,"-","")
					cQuery+=" And "+ aNames[nInd]+"='"+xValor+"'"
				EndIf

			ElseIf AllTrim(GetSx3Cache(aNames[nInd],'X3_TIPO'))=="C"


				If lBetween

					If !Empty(axValor[1])
						cQuery+=" And Upper("+ aNames[nInd]+") >='"+DecodeUtf8(AllTrim(Upper(axValor[1])))+"'"
					EndIf
					If !Empty(axValor[2])
						cQuery+=" And Upper("+ aNames[nInd]+") <='"+DecodeUtf8(AllTrim(Upper(axValor[2])))+"'"
					EndIf


				ElseIf !Empty(xValor)
					xValor:=DecodeUtf8(AllTrim(xValor))
					cQuery+=" And Upper("+ aNames[nInd]+") Like '%"+Upper(xValor)+"%'"
				EndIf

			ElseIf AllTrim(GetSx3Cache(aNames[nInd],'X3_TIPO'))=="N"
				If lBetween

					If !Empty(axValor[1])
						cQuery+=" And "+ aNames[nInd]+" >= "+AllTrim(Str((axValor[1])))
					EndIf

					If !Empty(axValor[2])
						cQuery+=" And "+ aNames[nInd]+" <= "+AllTrim(Str((axValor[2])))
					EndIf

				ElseIf xValor>0
					xValor:=AllTrim(Str((xValor)))
					cQuery+=" And "+ aNames[nInd]+"="+xValor
				EndIf
			EndIf


		Next
	EndIf
	FreeObj(oJsonFiltro)

	If cRotina=="RVS_BROWSE" .And.  cAliasTab=="RVS"
		If cLinked=="0"
			cQuery+=" And RVS_STATUS=0"
		ElseIf cLinked=="1"
			cQuery+=" And RVS_STATUS<>0"
		Endif
	Endif


	If Upper(cRotina)=="RVS_BROWSE"
		lRVSBrowse:=.T.
		cQuery+=" AND RVS_COD = '" + cBanco + "'"
		cQuery+=" AND RVS_AGENCI = '" + cAgencia + "'"
		cQuery+=" AND RVS_NUMCON = '"  + cConta +  "'"

		If !Empty(sDataIni)
			cQuery+=" AND RVS_DATA >= '" + (sDataIni)+ "'
		EndIf

		If !Empty(sDataFim)
			cQuery+=" AND RVS_DATA <= '" + (sDataFim)+ "'
		EndIf

		If nTipo = 1
			cQuery += " AND RVS_VALDEB > 0 "
		ElseIf nTipo = 2
			cQuery += " AND RVS_VALCRE > 0 "
		EndIf
	ElseIf Left( Upper(cRotina),5)=="PLAID"
		RVS->(DbGoTo(nRecno))

		If (lSugestao:= AllTrim(Upper(cRotina))=="PLAID_SUGESTAO")
			nValor:=Max(RVS->RVS_VALCRE,RVS->RVS_VALDEB)
			// MV_PLTOLERA = 5%


			aDadosFiltro[1]:=nValor*(1-nTolera)
			aDadosFiltro[2]:=nValor*(1+nTolera)

			aDadosFiltro[3]:=DaySub(RVS->RVS_DATA,3)
			aDadosFiltro[4]:=DaySum(RVS->RVS_DATA,3)

		EndIf


		If cAliasTab=="SE5"
			If RVS->RVS_VALDEB>0
				cQuery 	+= " AND E5_RECPAG = 'P'"
				cQuery 	+= " AND E5_SITUACA NOT IN ('C','X','E') "
				cQuery 	+= " AND E5_BANCO = '" +  cBanco  +  "' "
				cQuery 	+= " AND E5_AGENCIA = '" + cAgencia  +  "' "
				cQuery 	+= " AND E5_CONTA = '" +  cConta  +  "' "
				cQuery 	+= " AND E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','PA',' ' )"
				cQuery 	+= " AND E5_INTPLAI = ' '"
				If lOracle
					cQuery 	+= " AND E5_FILIAL ||E5_BANCO ||E5_NUMCHEQ|| E5_MOEDA||E5_NUMERO||E5_PREFIXO||E5_PARCELA||"
					cQuery 	+= "E5_FORNECE||E5_LOJA||E5_MOTBX||E5_SEQ "
					cQuery 	+= " not in (SELECT SE5CAN.E5_FILIAL || SE5CAN.E5_BANCO ||SE5CAN.E5_NUMCHEQ ||"
					cQuery 	+= " SE5CAN.E5_MOEDA||SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_FORNECE||SE5CAN.E5_LOJA||SE5CAN.E5_MOTBX||SE5CAN.E5_SEQ"
					cQuery 	+= " FROM " + RetSqlName("SE5") + "  SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'R' AND SE5CAN.E5_SITUACA <> 'C' "
					cQuery 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
					cQuery 	+= " AND SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_FORNECE||SE5CAN.E5_LOJA||SE5CAN.E5_NUMCHEQ||SE5CAN.E5_SEQ = E5_NUMERO||E5_PREFIXO||E5_PARCELA||E5_FORNECE||E5_LOJA||E5_NUMCHEQ||E5_SEQ "
				Else
					cQuery 	+= " AND E5_FILIAL +E5_BANCO + E5_NUMCHEQ + E5_MOEDA+E5_NUMERO+E5_PREFIXO+E5_PARCELA+"
					cQuery 	+= "E5_FORNECE+E5_LOJA+E5_MOTBX+E5_SEQ "
					cQuery 	+= " not in (SELECT SE5CAN.E5_FILIAL + SE5CAN.E5_BANCO +SE5CAN.E5_NUMCHEQ +"
					cQuery 	+= " SE5CAN.E5_MOEDA+SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_MOTBX+SE5CAN.E5_SEQ"
					cQuery 	+= " FROM " + RetSqlName("SE5") + " SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'R' AND SE5CAN.E5_SITUACA <> 'C' "
					cQuery 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
					cQuery 	+= " AND SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_FORNECE+SE5CAN.E5_LOJA+SE5CAN.E5_NUMCHEQ+SE5CAN.E5_SEQ  = E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_FORNECE+E5_LOJA+E5_NUMCHEQ+E5_SEQ  "
				EndIf
				cQuery 	+= " AND SE5CAN.D_E_L_E_T_ =' ')"

			Else
				cQuery 	+= " AND E5_RECPAG = 'R'"
				cQuery 	+= " AND E5_SITUACA NOT IN ('C','X','E') "
				cQuery 	+= " AND E5_BANCO = '" +  cBanco  +  "' "
				cQuery 	+= " AND E5_AGENCIA = '" +  cAgencia  +  "' "
				cQuery 	+= " AND E5_CONTA = '" +  cConta  +  "' "

				If !lSugestao
					cQuery 	+= " AND E5_DATA <= '" +  Dtos(RVS->RVS_DATA)  +  "' "
				EndIf

				cQuery 	+= " AND E5_TIPODOC IN ('CH','MT','DC','JR','TR','BA','VL','RA',' ') "
				cQuery 	+= " AND E5_INTPLAI = ' '"
				cQuery 	+= " AND UPPER(E5_HISTOR) NOT LIKE '%REVERSE%'"
				cQuery 	+= " AND E5_HISTOR not like '%REVERSE%'"
				If lOracle
					cQuery 	+= " AND E5_FILIAL||E5_BANCO||E5_TIPO||E5_MOEDA||E5_NUMERO||E5_PREFIXO||E5_PARCELA||"
					cQuery 	+= "E5_CLIENTE||E5_LOJA||E5_MOTBX||E5_SEQ "
					cQuery 	+= " not in (SELECT SE5CAN.E5_FILIAL || SE5CAN.E5_BANCO ||SE5CAN.E5_TIPO ||"
					cQuery 	+= " SE5CAN.E5_MOEDA||SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_CLIENTE||SE5CAN.E5_LOJA||SE5CAN.E5_MOTBX||SE5CAN.E5_SEQ"
					cQuery 	+= " FROM " + RetSqlName("SE5") + " SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'P' AND SE5CAN.E5_SITUACA <> 'C' "
					cQuery 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
					cQuery 	+= " AND SE5CAN.E5_NUMERO||SE5CAN.E5_PREFIXO||SE5CAN.E5_PARCELA||SE5CAN.E5_CLIENTE||SE5CAN.E5_LOJA = E5_NUMERO||E5_PREFIXO||E5_PARCELA||E5_CLIENTE||E5_LOJA "
				Else
					cQuery 	+= " AND E5_FILIAL +E5_BANCO +E5_TIPO + E5_MOEDA+E5_NUMERO+E5_PREFIXO+E5_PARCELA+"
					cQuery 	+= " E5_CLIENTE+E5_LOJA+E5_MOTBX+E5_SEQ "
					cQuery 	+= " NOT IN (SELECT SE5CAN.E5_FILIAL + SE5CAN.E5_BANCO +SE5CAN.E5_TIPO +"
					cQuery 	+= " SE5CAN.E5_MOEDA+SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_CLIENTE+SE5CAN.E5_LOJA+SE5CAN.E5_MOTBX+SE5CAN.E5_SEQ"
					cQuery 	+= " FROM " + RetSqlName("SE5") + " SE5CAN WHERE SE5CAN.E5_FILIAL = E5_FILIAL AND SE5CAN.E5_RECPAG = 'P' AND SE5CAN.E5_SITUACA <> 'C' "
					cQuery 	+= " AND SE5CAN.E5_BANCO = E5_BANCO AND SE5CAN.E5_TIPODOC IN ('ES','EC')"
					cQuery 	+= " AND SE5CAN.E5_NUMERO+SE5CAN.E5_PREFIXO+SE5CAN.E5_PARCELA+SE5CAN.E5_CLIENTE+SE5CAN.E5_LOJA = E5_NUMERO+E5_PREFIXO+E5_PARCELA+E5_CLIENTE+E5_LOJA "
				EndIf
				cQuery 	+= " AND SE5CAN.D_E_L_E_T_ =' ')"
			EndIf

			If lSugestao
				cQuery+=" And E5_VALOR = "+AllTrim(Str(nValor))
				cQuery+=" And E5_DATA ='"+Dtos(RVS->RVS_DATA)+"'"
				cSugFiltro+=AllTrim( FWX3Titulo("E5_VALOR"))  +" Between "
				cSugFiltro+=AllTrim(Transform(nValor,AvSx3("E5_VALOR",6)) )
				cSugFiltro+=" And "
				cSugFiltro+=AllTrim(Transform(nValor,AvSx3("E5_VALOR",6)) )

				cSugFiltro+=" - "

				cSugFiltro+=Space(1)+AllTrim( FWX3Titulo("E5_DATA"))+" Between "
				cSugFiltro+=Dtoc( RVS->RVS_DATA )
				cSugFiltro+=" And "
				cSugFiltro+=Dtoc( RVS->RVS_DATA)

			EndIf


		ElseIf RVS->RVS_VALCRE>0


			cQuery 	+= " AND E1_PORTADO IN ('" + cBanco + "','   ')"
			cQuery 	+= " AND E1_SLPLAID > 0 "
			cQuery 	+= " AND E1_SALDO> 0 "
			cQuery 	+= " AND  E1_TIPO IN ('NF ','NDC','BOL')"

			If !Empty(cExclTipCR)
				cQuery += "AND E1_TIPO NOT IN "+FormatIn(cExclTipCR,";")
			EndIf

			If lSugestao
				cQuery+=" And E1_VALOR Between "+AllTrim(Str(aDadosFiltro[1]))+" And "+AllTrim(Str(aDadosFiltro[2]))
				cQuery+=" And E1_VENCREA Between "+Dtos(aDadosFiltro[3])+" And "+Dtos(aDadosFiltro[4])

				cSugFiltro+=AllTrim( FWX3Titulo("E1_EMISSAO"))  +" Lower than or equal to "+Dtoc(RVS->RVS_DATA)
				cSugFiltro+=" - "

				cSugFiltro+=AllTrim( FWX3Titulo("E1_VALOR"))  +" Between "
				cSugFiltro+=AllTrim(Transform(aDadosFiltro[1],AvSx3("E1_VALOR",6)) )
				cSugFiltro+=" And "
				cSugFiltro+=AllTrim(Transform(aDadosFiltro[2],AvSx3("E1_VALOR",6)) )

				cSugFiltro+=" - "

				cSugFiltro+=Space(1)+AllTrim( FWX3Titulo("E1_VENCREA"))+" Between "
				cSugFiltro+=Dtoc( aDadosFiltro[3] )
				cSugFiltro+=" And "
				cSugFiltro+=Dtoc( aDadosFiltro[4] )
			EndIf
		Else

			cQuery 	+= " AND E2_BCOPAG IN ('" + cBanco + "', '   ')"
			cQuery 	+= " AND E2_SLPLAID > 0 "
			cQuery 	+= " AND E2_SALDO > 0 "
			cQuery 	+= " AND E2_TIPO IN ('NF ','NDP')"

			If !Empty(cExclTipCP)
				cQuery += "AND E2_TIPO NOT IN "+FormatIn(cExclTipCP,";")
			EndIf

			If lSugestao
				cQuery+=" And E2_VALOR Between "+AllTrim(Str(aDadosFiltro[1]))+" And "+AllTrim(Str(aDadosFiltro[2]))
				cQuery+=" And E2_VENCREA Between "+Dtos(aDadosFiltro[3])+" And "+Dtos(aDadosFiltro[4])

				cSugFiltro+=AllTrim( FWX3Titulo("E2_EMISSAO"))  +" Lower than or equal to "+Dtoc(RVS->RVS_DATA)

				cSugFiltro+=" - "

				cSugFiltro:=AllTrim( FWX3Titulo("E2_VALOR"))  +" Between "
				cSugFiltro+=AllTrim(Transform(aDadosFiltro[1],AvSx3("E2_VALOR",6)) )
				cSugFiltro+=" And "
				cSugFiltro+=AllTrim(Transform(aDadosFiltro[2],AvSx3("E2_VALOR",6)) )

				cSugFiltro+=" - "

				cSugFiltro+=Space(1)+AllTrim( FWX3Titulo("E2_VENCREA"))+" Between "
				cSugFiltro+=Dtoc( aDadosFiltro[3] )
				cSugFiltro+=" And "
				cSugFiltro+=Dtoc( aDadosFiltro[4] )


			EndIf

		EndIf
	EndIf

	cQuery+=" And D_E_L_E_T_=' '
	cQry:=cQuery
	cQry:="%"+cQry+"%"

	BeginSql Alias cAliasQry
        Select Count(*) Contar
        %Exp:cQry%
	EndSql
	nContar:=(cAliasQry)->Contar
	oJson['total']:=nContar

	lZerado:=(nContar==0)

	(cAliasQry)->(DbCloseArea())

	cQuery+=" ORDER BY 1 DESC"
	cQuery+=" OFFSET "+AllTrim(Str(nItensPagina))+"*("+AllTrim(Str(nPagina))+"-1) ROWS FETCH NEXT "+AllTrim(Str(nItensPagina))+" ROWS ONLY"


	cQuery:="%"+cQuery+"%"
	BeginSql Alias cAliasQry
        Select R_E_C_N_O_ RECTAB
        %Exp:cQuery%
	EndSql
	aCores:={}
	lTemCores:=Len(aCores)>0

	Do While (cAliasQry)->(!Eof())
		(cAliasTab)->(DbGoTo((cAliasQry)->RECTAB)  )
		AAdd(oJson['dados'] ,JsonObject():new())
		nLinha++
		oJson['dados'][nLinha]['REGISTRO']:=(cAliasQry)->RECTAB

		If cAliasTab == "SE2" .Or. cAliasTab == "SE1"
			If cAliasTab == "SE2
				dEmissao := SE2->E2_EMISSAO
			ElseIf cAliasTab == "SE1"
				dEmissao := SE1->E1_EMISSAO
			EndIf
		EndIf

		For nInd:=1 To Len(aBrowser)
			cCampo:=aBrowser[nInd,1]
			If aBrowser[nInd,2]==0 .And. Empty(aBrowser[nInd,4])
				Loop
			EndIf

			If aBrowser[nInd,2]>0
				xValor:=(cAliasTab)->(FieldGet(aBrowser[nInd,2]))
			Else
				DbSelectArea(cAliasTab)
				bSetDados:=&("{||"+aBrowser[nInd,4]+"}")
				xValor:= Eval(bSetDados)
			EndIf

			If aBrowser[nInd,3]=="C"
				xValor:=EncodeUTF8(AllTrim(xValor),"cp1252")
			ElseIf aBrowser[nInd,3]=="M"
				xValor:=Left(EncodeUTF8(AllTrim(xValor),"cp1252"),50)
			ElseIf aBrowser[nInd,3]=="D"
				If Empty(xValor)
					xValor:=""
				Else
					xValor:=Dtoc(xValor)
				EndIf
			EndIf
			oJson['dados'][nLinha][cCampo]:=xValor

			If lSE5Browse
				oJson['dados'][nLinha]["E5_NUMERO"]:=AllTrim(SE5->E5_NUMCHEQ)+SE5->E5_NUMERO
			EndIf

			If lRVSBrowse
				oJson['dados'][nLinha]['linked']:=RVS->RVS_STATUS==0
			EndIf

		Next

		For nInd:=1 To Len(aCores)
			DbSelectArea(cAliasTab)
			If Eval(aCores[nInd,1])
				oJson['dados'][nLinha]["COR"]:=aCores[nInd,2]
				Exit
			EndIf
		Next

		(cAliasQry)->(DbSkip())
	EndDo
	oJson['offset']:=nItensPagina*(nPagina-1)
	oJson['limit']:=nItensPagina
	oJson['filtro']:=cSugFiltro

	lRetorno:=.T.
	cErro:=""
	cRetorno:=oJson:toJSON()
	RestArea(aAreaAtu)

Return

WSMETHOD GET dicionario WSRECEIVE tabela WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro
	Default Self:tabela:="RVS"

	SetDate()
	RetDicionario(@cRetorno,@lRetorno,@cErro,Self:tabela)

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(.T.)

Static Function RetDicionario(cRetorno,lRetorno,cErro,cAliasTab)
	Local oJson := JsonObject():new()
	Local oJson['dados']   := {}
	Local nInd
	Local aFolder:={}
	Local aAux

	lRetorno:=.T.
	cErro:=""

	aHeader:={}
	aCols:={}

	cSeekKey   :=xFilial(cAliasTab)
	bSeekWhile := {|| .T. }

	If cAliasTab$"SE1*SE2*SE5"
		aAux:=GetCampos(cAliasTab)
	Else
		aAux:=FWSX3Util():GetAllFields( cAliasTab , .T. )
	EndIf

	For nInd:=1 To Len(aAux)
		AAdd(aHeader,{,aAux[nInd]})
	Next

	AAdd(oJson['dados'] ,JsonObject():new())
	oJson['dados'][1]['dynamicView']:={}
	AAdd(oJson['dados'][1]['dynamicView'] ,JsonObject():new())
	oJson['dados'][1]['dynamicView'][1]['fields']:={}

	nCount:=0
	For nInd:=1 To Len(aHeader)

		cCampo:=AllTrim(aHeader[nInd,2])

		If cCampo$"_ALI_WT" .Or. cCampo$"_REC_WT"
			Loop
		EndIf

		AAdd(oJson['dados'][1]['dynamicView'][1]['fields'],JsonObject():new())
		oJsonAux:=oJson['dados'][1]['dynamicView'][1]['fields'][++nCount]
		If Empty(cFolder:=AllTrim(GetSx3Cache(cCampo,'X3_FOLDER')))
			cFolder:="z"
		EndIf

		oJsonAux["label"]	:= EncodeUTF8(AllTrim(FWX3Titulo(cCampo)),"cp1252")
		oJsonAux["property"]:= cCampo
		oJsonAux["tab"]	    := cFolder
		oJsonAux["sequence"]:= AllTrim(GetSx3Cache(cCampo,'X3_ORDEM'))
		oJsonAux["option"]	:= EncodeUTF8(AllTrim(GetSx3Cache(cCampo,'X3_CBOXENG')),"cp1252")
		oJsonAux["readonly"]:= (GetSx3Cache(cCampo,'X3_VISUAL'))=="V"
		oJsonAux["width"]   := GetSx3Cache(cCampo,'X3_TAMANHO')
		oJsonAux["decimal"] := GetSx3Cache(cCampo,'X3_DECIMAL')
		oJsonAux["picture"] := AllTrim(GetSx3Cache(cCampo,'X3_PICTURE'))
		oJsonAux["browse"] 	:= AllTrim(GetSx3Cache(cCampo,'X3_BROWSE'))=="S"
		oJsonAux["used"] 	:= X3USO(GetSx3Cache(cCampo,'X3_USADO'))
		oJsonAux["F3"] 		:= AllTrim(GetSx3Cache(cCampo,'X3_F3'))
		oJsonAux["type"] 	:= AllTrim(GetSx3Cache(cCampo,'X3_TIPO'))
		oJsonAux["required"]:= X3Obrigat( cCampo )

		If cCampo=="RVS_DESCRI"
			oJsonAux["browse"] 	:=.T.
		EndIf

		If cCampo=="RVS_COD"
			oJsonAux["browse"] 	:=.F.
		EndIf

		If cCampo=="RVS_NOMEAG"
			oJsonAux["browse"] 	:=.F.
		EndIf

		If cAliasTab$"SE1*SE2*SE5"
			oJsonAux["browse"] 	:=.T.
		EndIf

		If cCampo=="E2_VALOR"
			oJsonAux["sequence"] 	:=""
		EndIf

		If cCampo=="E2_SLPLAID"
			oJsonAux["sequence"] 	:="0"
		EndIf

		If cCampo=="E1_VALOR"
			oJsonAux["sequence"] 	:=""
		EndIf

		If cCampo=="E1_SLPLAID"
			oJsonAux["sequence"] 	:="0"
		EndIf

		If cCampo=="E5_VALOR"
			oJsonAux["sequence"] 	:="0"
		EndIf


		If Ascan(aFolder,{|a| a[1]==cFolder })==0
			AAdd(aFolder,{cFolder,Iif(cFolder=="z","Outros",AllTRim(Posicione("SXA",1,cAliasTab+cFolder,"XA_DESCRIC") ) )  } )
		EndIf

	Next
	aSort(aFolder,,, { |x, y| x[1] < y[1] })

	oJson['dados'][1]['tabs']:={}
	AAdd(oJson['dados'][1]['tabs'] ,JsonObject():new())
	nCount:=0
	oJsonAux:=oJson['dados'][1]['tabs'][++nCount]
	For nInd:=1 To Len(aFolder)
		oJsonAux[aFolder[nInd,1]]	:=aFolder[nInd,2]
	Next

	cRetorno:=oJson:toJSON()

Return cRetorno

WSMETHOD GET dados WSRECEIVE registro,tabela  WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro
	Default Self:registro:=0

	SetDate()
	GetRegistros(Self:tabela,@cRetorno,@lRetorno,@cErro,Self:registro)
	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(.T.)

Static Function GetRegistros(cAliasTab,cRetorno,lRetorno,cErro,nRegistro)
	Local aAreaAtu:=GetArea()
	Local aAreaSE1:=SE1->(GetArea())
	Local aAreaSE2:=SE2->(GetArea())
	Local aAreaSE5:=SE5->(GetArea())
	Local oJson := JsonObject():new()
	Local oJson['dados']   := {}
	Local cAliasQry:=GetNextAlias()
	Local nInd
	Local cCampo
	Local cQuery
	Local nLinha:=0
	Local aDados:={}
	Local nPosicao
	Local aAux:={}
	Local aHeader:={}
	Default cFiltro:=""


	aAux:=FWSX3Util():GetAllFields( cAliasTab , .T. )
	For nInd:=1 To Len(aAux)
		AAdd(aHeader,{,aAux[nInd]})
	Next

	For nInd:=1 To Len(aHeader)
		cCampo:=AllTrim(aHeader[nInd,2])
		nPosicao:=(cAliasTab)->(FieldPos(cCampo))
		AAdd(aDados,{})
		aDadosAux:=aDados[Len(aDados)]
		AAdd(aDadosAux,cCampo)
		AAdd(aDadosAux,nPosicao)
		AAdd(aDadosAux,AllTrim(GetSx3Cache(cCampo,'X3_TIPO')))
		AAdd(aDadosAux,AllTrim(GetSx3Cache(cCampo,'X3_RELACAO')))
	Next

	cQuery:=" From "+RetSqlName(cAliasTab)+" TAB"
	cQuery+=" Where "+PrefixoCpo(cAliasTab)+"_FILIAL='"+xFilial(cAliasTab)+"'"
	cQuery+=" And D_E_L_E_T_=' '

	cOrderBy:=""
	If cAliasTab=="RVT"
		CHKFILE("RVS")
		RVS->(DbGoTo(nRegistro))
		cQuery+=" And RVT_ID='"+RVS->RVS_ID+"'"
		cOrderBy:=" Order By RVT_ITEM"
	Else
		cQuery+=" And R_E_C_N_O_="+AllTrim(Str(nRegistro))
	EndIf

	cQuery+=cOrderBy
	cQuery:="%"+cQuery+"%"

	SE1->(DbSetOrder(1))
	SE2->(DbSetOrder(1))
	SE5->(DbSetOrder(21))

	BeginSql Alias cAliasQry
        Select R_E_C_N_O_ RECTAB
        %Exp:cQuery%
	EndSql

	INCLUI:=.F.
	ALTERA:=.t.
	Do While (cAliasQry)->(!Eof())
		(cAliasTab)->(DbGoTo((cAliasQry)->RECTAB)  )
		AAdd(oJson['dados'] ,JsonObject():new())
		nLinha++
		For nInd:=1 To Len(aDados)
			If aDados[nInd,2]==0 .And. Empty(aDados[nInd,4])
				Loop
			EndIf

			cCampo:=aDados[nInd,1]
			If aDados[nInd,2]>0
				xValor:=(cAliasTab)->(FieldGet(aDados[nInd,2]))
			Else
				DbSelectArea(cAliasTab)
				bSetDados:=&("{||"+aDados[nInd,4]+"}")
				xValor:= Eval(bSetDados)
			EndIf
			If aDados[nInd,3]=="C"
				xValor:= EncodeUTF8(AllTrim(xValor),"cp1252")
			ElseIf aDados[nInd,3]=="D"
				If Empty(xValor)
					xValor:=""
				Else
					xValor:=Dtoc(xValor)
				EndIf
			EndIf
			oJson['dados'][nLinha][cCampo]:=xValor
			
		Next
		(cAliasQry)->(DbSkip())
	EndDo
	lRetorno:=.T.
	cErro:=""
	cRetorno:=oJson:toJSON()

	RestArea(aAreaSE1)
	RestArea(aAreaSE2)
	RestArea(aAreaSE5)
	RestArea(aAreaAtu)

Return


WSMETHOD POST gravarplaid WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro


	SetDate()
	PlaidBxTit(@cRetorno,@lRetorno,@cErro,Self:GetContent())

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf


	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)


WSMETHOD POST undoplaid WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro


	SetDate()
	PlaidCanc(@cRetorno,@lRetorno,@cErro,Self:GetContent())

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf


	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)

Static Function PlaidCanc(cRetorno,lRetorno,cErro,cJson)
	Local oJson := JsonObject():new()
	Local aTitBx
	Local nOpBaixa
	Local cChaveRVT
	Local aChave
	Private aBaixaSE5:={}
	cRetorno:="[]"

	Private lMsErroAuto:=.F.

	ChkFile("RVS")
	ChkFile("RVT")

	oJson:fromJson(cJson)

	Begin Transaction

		SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

		RVS->(DbGoTo(oJson['REGISTRO_CABEC']))
		RVT->(DbSetOrder(1))//RVT_FILIAL+RVT_ID+RVT_ITEM
		cChaveRVT:=FwxFilial("RVT")+RVS->RVS_ID
		RVT->(DbSeek(cChaveRVT))
		Do While RVT->(!Eof()) .And. RVT->(RVT_FILIAL+RVT_ID)==cChaveRVT

			aChave:=Separa(RVT->RVT_CHAVE,";")
			If  RVT->RVT_ORIGEN=="SE1"

				If SE1->(DbSeek(aChave[01]+aChave[02]+aChave[03]+aChave[04]+aChave[05]  )) .And. !Empty(RVT->RVT_SEQSE5)

					Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_PARCELA ,SE1->E1_TIPO ,,,SE1->E1_CLIENTE,SE1->E1_LOJA  )
					aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } )

					nOpBaixa := aScan(aBaixaSE5,{|x|rTrim(x[9]) ==RVT->RVT_SEQSE5   })
					If nOpBaixa == 0
						cErro := STR0002// "Not Found (E5_SEQ)"
						lRetorno :=.F.
						Exit
					EndIf

					aBaixaSE5:={}
					aTitBx:={}
					Aadd(aTitBx, {"E1_PREFIXO",    SE1->E1_PREFIXO,    NIL})
					Aadd(aTitBx, {"E1_NUM",        SE1->E1_NUM,        NIL})
					Aadd(aTitBx, {"E1_PARCELA",    SE1->E1_PARCELA,    NIL})
					Aadd(aTitBx, {"E1_TIPO",       SE1->E1_TIPO,       NIL})
					Aadd(aTitBx, {"E1_CLIENTE",    SE1->E1_CLIENTE,    NIL})
					Aadd(aTitBx, {"E1_LOJA",       SE1->E1_LOJA,       NIL})
					
					FWVetByDic ( aTitBx, "SE1", .F. )
					MsExecAuto({|x, y, z, v| FINA070(x, y, z, v)}, aTitBx,5,.F.,nOpBaixa)
					If lMsErroAuto
						cErro := AllTrim(MemoRead(NomeAutoLog()))
						MemoWrite(NomeAutoLog()," ")
						lRetorno :=.F.
						Exit
					Else
						SE5->(RecLock("SE5",.F.))
						SE5->E5_INTPLAI:= ""
						SE5->(MSUnlock())
						lRetorno :=.T.
					EndIf
				Else
					cErro := STR0002// "Not Found (E5_SEQ)"
					lRetorno :=.F.
					Exit
				EndIf
			ElseIf RVT->RVT_ORIGEN=="SE2"

				If SE2->(DbSeek(aChave[01]+aChave[02]+aChave[03]+aChave[04]+aChave[05]+aChave[06]+aChave[07]  )) .And. !Empty(RVT->RVT_SEQSE5)

					Sel080Baixa("VL /BA /CP /",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,0,0,SE2->E2_FORNECE,SE2->E2_LOJA,.F.,.F.,.F.,0,.F.,.T.)
					aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } )

					nOpBaixa := aScan(aBaixaSE5,{|x|rTrim(x[9]) ==RVT->RVT_SEQSE5   })
					If nOpBaixa == 0
						cErro := STR0002// "Not Found (E5_SEQ)"
						lRetorno :=.F.
						Exit
					EndIf
					aBaixaSE5:={}
					aTitBx:={}
					Aadd(aTitBx, {"E2_PREFIXO",    SE2->E2_PREFIXO,   NIL})
					Aadd(aTitBx, {"E2_NUM",        SE2->E2_NUM,       NIL})
					Aadd(aTitBx, {"E2_PARCELA",    SE2->E2_PARCELA,   NIL})
					Aadd(aTitBx, {"E2_TIPO",       SE2->E2_TIPO,      NIL})
					Aadd(aTitBx, {"E2_FORNECE",    SE2->E2_FORNECE,   NIL})
					Aadd(aTitBx, {"E2_LOJA",       SE2->E2_LOJA,      NIL})
					// Aadd(aTitBx, {"E2_ORIGEM",     "FINA884",       NIL})

					FWVetByDic ( aTitBx, "SE2", .F. )
					MsExecAuto({|x, y, z, v| FINA080(x, y, z, v)}, aTitBx, 5,,nOpBaixa)
					If lMsErroAuto
						cErro := AllTrim(MemoRead(NomeAutoLog()))
						MemoWrite(NomeAutoLog()," ")
						lRetorno :=.F.
						Exit
					Else
						SE5->(RecLock("SE5",.F.))
						SE5->E5_INTPLAI:= ""
						SE5->(MSUnlock())
						lRetorno :=.T.
					EndIf
				Else
					cErro := STR0002// "Not Found (E5_SEQ)"

					lRetorno :=.F.
					Exit
				EndIf


			ElseIf  RVT->RVT_ORIGEN=="SE5"
				lMsErroAuto:=.F.
				lRetorno:=.T.
				aTitBx:={}

				If  FIN884SE5("SE5",aChave,,.T.)
					SE5->(RecLock("SE5",.F.))
					SE5->E5_INTPLAI:= ""
					SE5->(MSUnlock())
					
				Else
					cErro :=STR0002// "Not Found (E5_SEQ)"
					lRetorno :=.F.
					Exit

				EndIf


			EndIf
			RVT->(DbSkip())
		EndDo

		If lRetorno .And. !GravaRVT(oJson,@cErro,@cRetorno,.T.)
			DisarmTransaction()
			lRetorno:=.F.
		EndIf

		If lRetorno
			cRetorno:='["successful"]'
		Else
			DisarmTransaction()
			cRetorno:='["falied"]'
			lRetorno:=.F.
		EndIf


	End Transaction


Return


Static Function PlaidBxTit(cRetorno,lRetorno,cErro,cJson)
	Local oJson := JsonObject():new()
	Local nInd
	Local aTitBx
	Local cHistor
	Local cCarteira
	Local nOpcBan
	Local cHistory:=""
	Local dDtBaixa

	cRetorno:="[]"

	Private lMsErroAuto:=.F.

	ChkFile("RVS")
	ChkFile("RVT")

	oJson:fromJson(cJson)

	nOpcBan:=IIf( RVS->RVS_VALDEB>0,3,4  )
	cCarteira:=Iif(nOpcBan==3,"P","R")

	Begin Transaction

		RVS->(DbGoTo(oJson['REGISTRO_CABEC']))

		For nInd:=1 To Len(oJson['itens'])
		
			cHistor:=AllTrim(oJson['itens'][nInd]['RVT_OBS'])
			If oJson['itens'][nInd]['RVT_ORIGEN']=="SE1"

				If oJson['itens'][nInd]['RVT_OPPLAI']==0
					Loop
				EndIf

				SE1->(Dbgoto(oJson['itens'][nInd]['REGISTRO']))

				dDtBaixa:=Max( RVS->RVS_DATA,SE1->E1_EMISSAO)


				aTitBx:={}
				Aadd(aTitBx, {"E1_PREFIXO",    SE1->E1_PREFIXO,    NIL})
				Aadd(aTitBx, {"E1_NUM",        SE1->E1_NUM,        NIL})
				Aadd(aTitBx, {"E1_PARCELA",    SE1->E1_PARCELA,    NIL})
				Aadd(aTitBx, {"E1_TIPO",       SE1->E1_TIPO,       NIL})
				Aadd(aTitBx, {"E1_CLIENTE",    SE1->E1_CLIENTE,    NIL})
				Aadd(aTitBx, {"E1_LOJA",       SE1->E1_LOJA,       NIL})
				Aadd(aTitBx, {"AUTDTBAIXA",    dDtBaixa,      NIL})
				Aadd(aTitBx, {"AUTBANCO",      RVS->RVS_COD,       NIL})
				Aadd(aTitBx, {"AUTAGENCIA",    RVS->RVS_AGENCI,    NIL})
				Aadd(aTitBx, {"AUTCONTA",      RVS->RVS_NUMCON,    NIL})
				Aadd(aTitBx, {"AUTDTCREDITO",  dDtBaixa,      NIL})
				Aadd(aTitBx, {"AUTMOTBX",      "NOR"		,  	   NIL})
				Aadd(aTitBx, {"AUTVALREC",     oJson['itens'][nInd]['RVT_OPPLAI'],   NIL})
				Aadd(aTitBx, {"AUTHIST",       cHistor,      NIL})
				
				If oJson['itens'][nInd]['RVT_ACRESC']>0
					Aadd(aTitBx, {"AUTACRESC", oJson['itens'][nInd]['RVT_ACRESC'] ,      NIL})
				EndIf

				FWVetByDic ( aTitBx, "SE1", .F. )
				MsExecAuto({|x, y| FINA070(x, y)}, aTitBx, 3)

				If lMsErroAuto
					cErro := AllTrim(MemoRead(NomeAutoLog()))
					MemoWrite(NomeAutoLog()," ")
					lRetorno :=.F.
					Exit
				Else
					If SE5->E5_VALOR==oJson['itens'][nInd]['RVT_OPPLAI'] .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_CLIFOR+E5_LOJA)==SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_CLIENTE+E1_LOJA)
						oJson['itens'][nInd]['RVT_SEQSE5']:=SE5->E5_SEQ
						SE5->(RecLock("SE5",.F.))
						SE5->E5_INTPLAI:= "I"
						SE5->(MSUnlock())
					EndIf
					cHistory+=SE1->(E1_NUM+"-"+AllTrim(E1_PREFIXO)+"-"+AllTrim(E1_PARCELA)+"-"+"-"+AllTrim(E1_TIPO)+"-"+AllTrim(E1_CLIENTE)+"-"+AllTrim(E1_LOJA))+"/"
					lRetorno :=.T.
				EndIf
			ElseIf oJson['itens'][nInd]['RVT_ORIGEN']=="SE2"

				If oJson['itens'][nInd]['RVT_OPPLAI']==0
					Loop
				EndIf

				SE2->(Dbgoto(oJson['itens'][nInd]['REGISTRO']))
				dDtBaixa:=Max( RVS->RVS_DATA,SE2->E2_EMISSAO)

				aTitBx:={}
				Aadd(aTitBx, {"E2_PREFIXO",    SE2->E2_PREFIXO,   NIL})
				Aadd(aTitBx, {"E2_NUM",        SE2->E2_NUM,       NIL})
				Aadd(aTitBx, {"E2_PARCELA",    SE2->E2_PARCELA,   NIL})
				Aadd(aTitBx, {"E2_TIPO",       SE2->E2_TIPO,      NIL})
				Aadd(aTitBx, {"E2_FORNECE",    SE2->E2_FORNECE,   NIL})
				Aadd(aTitBx, {"E2_LOJA",       SE2->E2_LOJA,      NIL})
				Aadd(aTitBx, {"AUTDTBAIXA",    dDtBaixa		,     NIL})
				Aadd(aTitBx, {"AUTHIST",       cHistor,  NIL})
				Aadd(aTitBx, {"AUTBANCO",      RVS->RVS_COD,       NIL})
				Aadd(aTitBx, {"AUTAGENCIA",    RVS->RVS_AGENCI,   NIL})
				Aadd(aTitBx, {"AUTCONTA",      RVS->RVS_NUMCON,    NIL})
				Aadd(aTitBx, {"AUTVLRPG",      oJson['itens'][nInd]['RVT_OPPLAI'],           NIL})
				Aadd(aTitBx, {"AUTMOTBX",      "NOR",          NIL})
				Aadd(aTitBx, {"AUTCHEQUE",       "",              NIL})
				
				FWVetByDic ( aTitBx, "SE2", .F. )
				MsExecAuto({|x, y| FINA080(x, y)}, aTitBx, 3)
				If lMsErroAuto
					cErro := AllTrim(MemoRead(NomeAutoLog()))
					MemoWrite(NomeAutoLog()," ")
					lRetorno :=.F.
					Exit
				Else
					If SE5->E5_VALOR==oJson['itens'][nInd]['RVT_OPPLAI'] .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_CLIFOR+E5_LOJA)==SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA)
						oJson['itens'][nInd]['RVT_SEQSE5']:=SE5->E5_SEQ
						SE5->(RecLock("SE5",.F.))
						SE5->E5_INTPLAI:= "I"
						SE5->(MSUnlock())
					EndIf
					cHistory+=SE2->(E2_NUM+"-"+AllTrim(E2_PREFIXO)+"-"+AllTrim(E2_PARCELA)+"-"+"-"+AllTrim(E2_TIPO)+"-"+AllTrim(E2_FORNECE)+"-"+AllTrim(E2_LOJA))+"/"
					lRetorno :=.T.
				EndIf


			ElseIf oJson['itens'][nInd]['RVT_ORIGEN']=="SE5"
				lMsErroAuto:=.F.
				cHistory+= SE5->(AllTrim(E5_NATUREZ) + "-" + AllTrim(E5_NUMERO) + "-" + AllTrim(E5_TIPO))+"/ "
				lRetorno:=.T.
				SE5->(Dbgoto(oJson['itens'][nInd]['REGISTRO']))
				SE5->(RecLock("SE5",.F.))
				SE5->E5_INTPLAI:= "I"
				oJson['itens'][nInd]['RVT_SEQSE5']:=SE5->E5_SEQ
				SE5->(MSUnlock())
			EndIf

		Next

		If lRetorno .And. !GravaRVT(oJson,@cErro,@cRetorno,.F.,cHistory)
			DisarmTransaction()
			lRetorno:=.F.
		EndIf

		If lRetorno
			cRetorno:='["successful"]'
		Else
			DisarmTransaction()
			cRetorno:='["falied"]'
			lRetorno:=.F.

		EndIf

	End Transaction


Return

Static Function GravaRVT(oJson,cErro,cRetorno,lCancelar,cHistory)
	Local lRetorno:=.F.
	Local oJsonItem
	Local nInd
	Local nYnd
	Local aNames
	Local aCpoItens
	Local oStruct
	Local cTipo
	Local xValor
	Local cCpoRVT
	Local nAscan
	Local oModel 	:= FWLoadModel('FINA884P')
	Local oModelRVS	:= oModel:GetModel('RVSMASTER')
	Local oModelRVT	:= oModel:GetModel('RVTDETAIL')
	Local aDadosRVT
	Local nContar:=0
	Local nLenItem:=AvSx3("RVT_ITEM",3)

	oStruct:=oModelRVT:GetStruct()
	aCpoItens:=oStruct:GetFields()

	oModel:SetOperation(4)
	oModel:Activate()

	oModelRVS:setValue("RVS_FILIAL",  RVS->RVS_FILIAL  )
	oModelRVS:setValue("RVS_ID"	,     RVS->RVS_ID  )
	oModelRVS:setValue("RVS_VALCRE",  RVS->RVS_VALCRE  )
	oModelRVS:setValue("RVS_VALDEB",  RVS->RVS_VALDEB  )
	oModelRVS:setValue("RVS_DESCRI",  RVS->RVS_DESCRI  )

	If lCancelar
	
		If RVS->RVS_VALCRE>0
			oModelRVS:setValue("RVS_STATUS",1  )
			oModelRVS:setValue("RVS_CATEGO",  "4"  )
		Else
			oModelRVS:setValue("RVS_STATUS", 9 )
			oModelRVS:setValue("RVS_CATEGO",  "3"  )
		EndIf

		oModelRVS:setValue("RVS_DOCREL",  ""  )

		For nInd:=1 To oModelRVT:Length()
			oModelRVT:GoLine( nInd )

			If !oModelRVT:IsDeleted()
				oModelRVT:DeleteLine()
			EndIf

		Next
	Else

		oModelRVS:setValue("RVS_STATUS",   0  )
		oModelRVS:setValue("RVS_CATEGO", IIf( Len(oJson['itens'])==1,"1","2") ) //1=Um registro encontrado;2=Vários registros encontrados;3=Despesa Não Identificada/Receita;4=Receita Não Identificada
		oModelRVS:setValue("RVS_DOCREL",  Padr(cHistory,Len(RVS->RVS_DOCREL))  )

		For nInd:=1 To Len(oJson['itens'])

			oJsonItem:=oJson['itens'][nInd]
			aNames := oJsonItem:GetNames()

			If Empty(oJsonItem['RVT_ITEM']) .Or. ValType(oJsonItem['RVT_ITEM']) <>"C"
				oJsonItem['RVT_ITEM']:=StrZero(nInd,nLenItem)
			EndIf

			If Len(oJsonItem['RVT_ITEM'] )<2
				oJsonItem['RVT_ITEM']:=Padl(oJsonItem['RVT_ITEM'],nLenItem,"0")
			Endif

			If oModelRVT:SeekLine({{"RVT_ITEM", oJsonItem['RVT_ITEM'] }},.T.) .Or. oJsonItem['RVT_OPPLAI']==0
				Loop
			EndIf

			If !oModelRVT:IsEmpty()
				oModelRVT:AddLine()
				oModelRVT:GoLine( oModelRVT:Length() )
			EndIf

			oModelRVT:SetValue("RVT_VALOR",oJsonItem['RVT_OPPLAI']   )
			oModelRVT:SetValue("RVT_SALDO",oJsonItem['RVT_OPPLAI']   )

			aDadosRVT:={"","","","","",""}
			If oJsonItem['RVT_ORIGEN']=="SE1"
				SE1->(Dbgoto(oJsonItem['REGISTRO']))
				aDadosRVT[01]:=SE1->E1_PARCELA
				aDadosRVT[02]:=SE1->E1_TIPO
				aDadosRVT[03]:=SE1->E1_CLIENTE
				aDadosRVT[04]:=SE1->E1_LOJA
				aDadosRVT[05]:=SE1->(E1_FILIAL+";"+E1_PREFIXO+";"+E1_NUM+";"+E1_PARCELA+";"+E1_TIPO)
				aDadosRVT[06]:=SE1->E1_NOMCLI
			ElseIf oJsonItem['RVT_ORIGEN']=="SE2"
				SE2->(Dbgoto(oJsonItem['REGISTRO']))
				aDadosRVT[01]:=SE2->E2_PARCELA
				aDadosRVT[02]:=SE2->E2_TIPO
				aDadosRVT[03]:=SE2->E2_FORNECE
				aDadosRVT[04]:=SE2->E2_LOJA
				aDadosRVT[05]:=SE2->(E2_FILIAL+";"+E2_PREFIXO+";"+E2_NUM+";"+E2_PARCELA+";"+E2_TIPO+";"+E2_FORNECE+";"+E2_LOJA)
				aDadosRVT[06]:=SE2->E2_NOMFOR
			ElseIf oJsonItem['RVT_ORIGEN']=="SE5"
				SE5->(Dbgoto(oJsonItem['REGISTRO']))
				aDadosRVT[01]:=SE5->E5_PARCELA
				aDadosRVT[02]:=SE5->E5_TIPO
				aDadosRVT[03]:=SE5->E5_CLIFOR
				aDadosRVT[04]:=SE5->E5_LOJA
				aDadosRVT[05]:=SE5->(E5_FILIAL+";"+E5_IDORIG)
				aDadosRVT[06]:=AllTrim(Str(oJsonItem['REGISTRO']))
			EndIf

			nContar++

			oModelRVT:SetValue("RVT_PARCEL"	,aDadosRVT[01])
			oModelRVT:SetValue("RVT_TIPO"	,aDadosRVT[02])
			oModelRVT:SetValue("RVT_CLIPRO"	,aDadosRVT[03])
			oModelRVT:SetValue("RVT_LOJA"	,aDadosRVT[04])
			oModelRVT:SetValue("RVT_CHAVE"	,aDadosRVT[05])
			oModelRVT:SetValue("RVT_NAME"   ,aDadosRVT[06])

			For nYnd:=1 to Len(aNames)

				cCpoRVT:=AllTrim(aNames[nYnd])

				If (nAscan:=Ascan(aCpoItens,{|a| a[3]==cCpoRVT }  ))==0
					Loop
				EndIf

				cTipo 	:= aCpoItens[nAscan,4]
				xValor	:= oJsonItem[cCpoRVT]

				If cTipo == 'N'
					If ValType(xValor)=="C"
						xValor:=Val(xValor)
					EndIf
				ElseIf cTipo == 'D'
					xValor:=StoD(StrTran(xValor,"-",""))
				Else
					xValor:=Padr(xValor, aCpoItens[nAscan,5] )
				EndIf
				If !oModelRVT:SetValue(cCpoRVT, xValor)
					Conout("Erro no campo "+cCpoRVT)
				EndIf
				oModelRVT:SetValue("RVT_DATAMO",RVS->RVS_DATA)

			Next

		Next
	EndIf


	If oModel:VldData()
		lRetorno:=.T.
		oModel:CommitData()
		cRetorno:='["successful"]'
	Else
		lRetorno:=.F.
		cErro := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
		cErro += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
		cErro += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
		cRetorno:='["falied"]'
	EndIf

	oModel:DeActivate()
	FreeObj(oModel)
	oModel:=Nil


Return lRetorno

Static Function SetDate()
	Set(4,"mm/dd/yyyy")
Return


Static Function GetCampos(cTabela)
	Local aCampos:={}

	If cTabela=="SE1"
		AADD(aCampos,"E1_NOMCLI"	)
		AADD(aCampos,"E1_CLIENTE"	)
		AADD(aCampos,"E1_LOJA"	)
		AADD(aCampos,"E1_NUM"	)
		AADD(aCampos,"E1_PREFIXO"	)
		AADD(aCampos,"E1_VALOR"	)
		AADD(aCampos,"E1_SALDO"	)
		AADD(aCampos,"E1_SLPLAID"	)
		AADD(aCampos,"E1_TIPO"	)
		AADD(aCampos,"E1_PARCELA")
		AADD(aCampos,"E1_EMISSAO")
		AADD(aCampos,"E1_VENCTO")
		AADD(aCampos,"E1_NATUREZ")
	ElseIf cTabela=="SE2"
		AADD(aCampos,"E2_FORNECE")
		AADD(aCampos,"E2_LOJA"	)
		AADD(aCampos,"E2_NUM"	)
		AADD(aCampos,"E2_PREFIXO")
		AADD(aCampos,"E2_VALOR"	)
		AADD(aCampos,"E2_SALDO"	)
		AADD(aCampos,"E2_SLPLAID")
		AADD(aCampos,"E2_TIPO"	)
		AADD(aCampos,"E2_PARCELA")
		AADD(aCampos,"E2_EMISSAO")
		AADD(aCampos,"E2_VENCTO")
		AADD(aCampos,"E2_NATUREZ")
		AADD(aCampos,"E2_NOMFOR")
	ElseIf cTabela=="SE5"
		AADD(aCampos,"E5_BENEF"	)
		AADD(aCampos,"E5_VALOR"	)
		AADD(aCampos,"E5_NUMERO"	)
		AADD(aCampos,"E5_PREFIXO")
		AADD(aCampos,"E5_PARCELA")
		AADD(aCampos,"E5_NUMCHEQ")
		AADD(aCampos,"E5_HISTOR")
		AADD(aCampos,"E5_TIPODOC")
		AADD(aCampos,"E5_NATUREZ")
		AADD(aCampos,"E5_DOCUMEN")
	EndIf

Return aCampos

WSMETHOD GET class WSRECEIVE registro  WSSERVICE wsfin884
	Local cRetorno
	Local lRetorno
	Local cErro
	Default Self:registro:=0

	SetDate()
	GetNatureza(@cRetorno,@lRetorno,@cErro,Self:registro)

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)


Static Function GetNatureza(cRetorno,lRetorno,cErro,nRegistro)
	Local aAreaAtu	:=GetArea()
	Local cAliasQry :=GetNextAlias()
	Local cNaturez	:=""
	Local cDescricao:=""
	Local cSugestao :=""
	Local oJson:=JsonObject():New()
	Local cFiltro
	Local nInd


	RVS->(DbGoTo(nRegistro))

	cDescricao:=Upper(AllTrim(RVS->RVS_DESCRI))
	For nInd:=1 To Len(cDescricao)
		cDigito:=SubsTring(cDescricao,nInd,1)
		If !Empty(cDigito) .And. !IsAlpha(cDigito)
			Exit
		EndIf
		cSugestao+=cDigito
	Next

	If !Empty(cSugestao)
		cFiltro:=" And Upper(RVS_DESCRI) LIKE '%"+cSugestao+"%'"


		If RVS->RVS_VALCRE>0
			cFiltro+=" And RVS.RVS_VALCRE>0"
		Else
			cFiltro+=" And RVS.RVS_VALDEB>0"
		EndIf

		cFiltro:="%"+cFiltro+"%"

		BeginSql Alias cAliasQry
			Select Max(SE5.R_E_C_N_O_) RECSE5
			From %Table:RVS% RVS,%Table:RVT% RVT,%Table:SE5% SE5
			Where RVS.RVS_FILIAL=%xFilial:RVS%
			And RVS.RVS_COD Between ' ' And 'zzzz'
			And RVS.D_E_L_E_T_=' '
			%Exp:cFiltro%
			And RVT.RVT_FILIAL=%xFilial:RVT%
			And RVT.RVT_ID=RVS.RVS_ID
			And RVT.RVT_ORIGEN='SE5'
			And RVT.D_E_L_E_T_=' '
			And SE5.E5_FILIAL=%xFilial:SE5%
			And SE5.E5_DOCUMEN=RVT_DOC
			And SE5.E5_INTPLAI='I'
			And SE5.D_E_L_E_T_=' '
		EndSql

		If (cAliasQry)->RECSE5>0
			SE5->(DbGoTo((cAliasQry)->RECSE5) )
			cNaturez:=AllTrim(SE5->E5_NATUREZ)
		EndIf

		(cAliasQry)->(DbCloseArea())

	EndIf
	oJson['class']:=cNaturez
	// oJson['query']:=GetLastQuery()[2]

	cRetorno:=oJson:toJSON()
	lRetorno:=.T.

	RestArea(aAreaAtu)
Return


//Inclui titulo a receber
/* JSON MODELO
{
  "E1_PREFIXO']:='PRE",
  "E1_NUM']:='TST001",
  "E1_TIPO']:='NF",
  "E1_CLIENTE']:='000001",
  "E1_LOJA']:='0001",
  "E1_HIST']:='TITULO TESTE",
  "E1_NATUREZ']:='NATUREZ",
  "E1_VENCTO']:='2020-01-01T00:00:00.000Z",
  "E1_VALOR": 123.21
}
*/
WSMETHOD POST receivableaccount WSSERVICE wsfin884

	Local cRetorno
	Local lRetorno
	Local cErro

	SetDate()
	WSAddSE1(@cRetorno,@lRetorno,@cErro,Self:GetContent())

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf
	Self:SetContentType("application/json")
	Self:SetResponse(cRetorno)
Return(lRetorno)


Static Function WSAddSE1(cRetorno,lRetorno,cErro,cJson)

	Local oJson := JsonObject():new()
	Local aFina040 := {}
	Local cNumTit := ""
	Local cPrefixo:= ""
	Local cTipoTit:= ""
	Local cCliente:= ""
	Local cLojaCli:= ""
	Local cHistor := ""
	Local cNaturez:= ""
	Local cNomeCli:= ""
	Local dVencto := Ctod("  /  /  ")
	Local nValor  := 0
	Local cParcela:= ""
	Local aCamposRet:={}
	Local nX

	Private lMsErroAuto:=.F.

	oJson:fromJson(cJson)

	Begin Transaction

		cPrefixo:= oJson['E1_PREFIXO']
		cNumTit := oJson['E1_NUM']
		cTipoTit:= oJson['E1_TIPO']
		cCliente:= oJson['E1_CLIENTE']
		cLojaCli:= oJson['E1_LOJA']
		cNomeCli:= GetadvFval("SA1","A1_NREDUZ",FwxFilial("SA1")+cCliente+cLojaCli,1,"")
		cHistor	:= oJson['E1_HIST']
		cNaturez:= oJson['E1_NATUREZ']
		dVencto	:= oJson['E1_VENCTO']
		nValor	:= oJson['E1_VALOR']
		cParcela:=GetNextParc("SE1",cNumTit,cPrefixo,cTipoTit,cCliente,cLojaCli  )

		aFina040 := {}
		Aadd( aFina040, { "E1_FILIAL"	,FwxFilial("SE1")	    , Nil })
		Aadd( aFina040, { "E1_PREFIXO"	,cPrefixo		    	, Nil })
		Aadd( aFina040, { "E1_NUM"		,cNumTit 				, Nil })
		Aadd( aFina040, { "E1_TIPO"		,cTipoTit				, Nil })
		Aadd( aFina040, { "E1_PARCELA"	,cParcela				, Nil })
		Aadd( aFina040, { "E1_NATUREZ"	,cNaturez           	, Nil })
		Aadd( aFina040, { "E1_CLIENTE"	,cCliente				, Nil })
		Aadd( aFina040, { "E1_LOJA"		,cLojaCli				, Nil })
		Aadd( aFina040, { "E1_NOMCLI"	,Padr(cNomeCli,TamSX3("E1_NOMCLI")[1]), Nil })
		Aadd( aFina040, { "E1_EMIS1"	,Iif(dDatabase>dVencto,dVencto,dDatabase), Nil })
		Aadd( aFina040, { "E1_EMISSAO"	,Iif(dDatabase>dVencto,dVencto,dDatabase), Nil })
		Aadd( aFina040, { "E1_VENCTO"	,dVencto          		, Nil })
		Aadd( aFina040, { "E1_VENCREA"	,DataValida(dVencto,.T.), Nil })
		Aadd( aFina040, { "E1_HIST"		,cHistor				, Nil })
		Aadd( aFina040, { "E1_VALOR" 	,nValor			 	    , Nil })
		aFina040 := FWVetByDic(aFina040,"SE1",.F.,1)

		lMsErroAuto := .F.
		MSExecAuto({|x, y| FINA040(x, y)}, aFina040, 3)
		If lMsErroAuto
			cErro := AllTrim(MemoRead(NomeAutoLog()))
			MemoWrite(NomeAutoLog()," ")
			DisarmTransaction()
		Else
		
			FreeObj(oJson)
			oJson := JsonObject():new()
			aCamposRet:=GetCampos("SE1")
			For nX:=1 to Len(aCamposRet)
				oJson[aCamposRet[nX]] := SE1->(&aCamposRet[nX])
			Next nX
			cRetorno:=oJson:toJSON()

		EndIf

	End Transaction


Return


Static Function GetNextParc(cTabela,cNumTit,cPrefixo,cTipoTit,cClifor,cLoja  )
	Local aAreaAtu	:=GetArea()
	Local cAliasTmp	:=GetNextAlias()
	Local cParcela

	If cTabela == "SE1"
		BeginSql Alias cAliasTmp
		Select Max(E1_PARCELA) E1_PARCELA
		From %table:SE1% SE1
		Where SE1.E1_FILIAL=%xFilial:SE1%
		And SE1.E1_PREFIXO=%Exp:cPrefixo%
		And SE1.E1_NUM=%Exp:cNumTit%
		And SE1.E1_TIPO=%Exp:cTipoTit%
		AND SE1.D_E_L_E_T_=' '

		EndSql
		cParcela:=Soma1((cAliasTmp)->E1_PARCELA)
	Else
		BeginSql Alias cAliasTmp
		Select Max(E2_PARCELA) E2_PARCELA
		From %table:SE2% SE2
		Where SE2.E2_FILIAL=%xFilial:SE2%
		And SE2.E2_PREFIXO=%Exp:cPrefixo%
		And SE2.E2_NUM=%Exp:cNumTit%
		And SE2.E2_TIPO=%Exp:cTipoTit%
		AND SE2.D_E_L_E_T_=' '

		EndSql
		cParcela:=Soma1((cAliasTmp)->E2_PARCELA)
	EndIf

	(cAliasTmp)->(DbCloseArea())
	RestArea(aAreaAtu)
Return 	cParcela

//Inclui titulo a pagar
/* JSON MODELO
{
  "E2_PREFIXO']:='PRE",
  "E2_NUM']:='TST001",
  "E2_TIPO']:='NF",
  "E2_FORNECE']:='000001",
  "E2_LOJA']:='0001",
  "E2_HIST']:='TITULO TESTE",
  "E2_NATUREZ']:='NATUREZ",
  "E2_VENCTO']:='2020-01-01T00:00:00.000Z",
  "E2_VALOR": 123.21
}
*/
WSMETHOD POST payableaccount WSSERVICE wsfin884

	Local cRetorno
	Local lRetorno
	Local cErro

	SetDate()
	WSAddSE2(@cRetorno,@lRetorno,@cErro,Self:GetContent())

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf
	Self:SetContentType("application/json")
	Self:SetResponse(cRetorno)
Return(lRetorno)


Static Function WSAddSE2(cRetorno,lRetorno,cErro,cJson)

	Local oJson := JsonObject():new()
	Local aFina050 := {}
	Local cNumTit := ""
	Local cPrefixo:= ""
	Local cTipoTit:= ""
	Local cFornece:= ""
	Local cLoja:= ""
	Local cHistor := ""
	Local cNaturez:= ""
	Local cNomeFor:= ""
	Local dVencto := Ctod("  /  /  ")
	Local nValor  := 0
	Local cParcela:= ""
	Local aCamposRet:={}
	Local nX

	Private lMsErroAuto:=.F.

	oJson:fromJson(cJson)

	Begin Transaction

		cPrefixo:= oJson['E2_PREFIXO']
		cNumTit := oJson['E2_NUM']
		cTipoTit:= oJson['E2_TIPO']
		cFornece:= oJson['E2_FORNECE']
		cLoja	:= oJson['E2_LOJA']
		cNomeFor:= GetadvFval("SA2","A2_NREDUZ",FwxFilial("SA2")+cFornece+cLoja,1,"")
		cHistor	:= oJson['E2_HIST']
		cNaturez:= oJson['E2_NATUREZ']
		dVencto	:= oJson['E2_VENCTO']
		nValor	:= oJson['E2_VALOR']
		cParcela:=GetNextParc("SE2",cNumTit,cPrefixo,cTipoTit,cFornece,cLoja  )

		aFina040 := {}
		Aadd( aFina050, { "E2_FILIAL"	,FwxFilial("SE1")	    , Nil })
		Aadd( aFina050, { "E2_PREFIXO"	,cPrefixo		    	, Nil })
		Aadd( aFina050, { "E2_NUM"		,cNumTit 				, Nil })
		Aadd( aFina050, { "E2_TIPO"		,cTipoTit				, Nil })
		Aadd( aFina050, { "E2_PARCELA"	,cParcela				, Nil })
		Aadd( aFina050, { "E2_NATUREZ"	,cNaturez           	, Nil })
		Aadd( aFina050, { "E2_CLIENTE"	,cCliente				, Nil })
		Aadd( aFina050, { "E2_LOJA"		,cLojaCli				, Nil })
		Aadd( aFina050, { "E2_NOMFOR"	,Padr(cNomeCli,TamSX3("E1_NOMFOR")[1]), Nil })
		Aadd( aFina050, { "E2_EMIS1"	,dDatabase          	, Nil })
		Aadd( aFina050, { "E2_EMISSAO"	,dDatabase          	, Nil })
		Aadd( aFina050, { "E2_VENCTO"	,dVencto          		, Nil })
		Aadd( aFina050, { "E2_VENCREA"	,DataValida(dVencto,.T.), Nil })
		Aadd( aFina050, { "E2_HIST"		,cHistor				, Nil })
		Aadd( aFina050, { "E2_VALOR" 	,nValor			 	    , Nil })
		aFina050 := FWVetByDic(aFina050,"SE2",.F.,1)

		lMsErroAuto := .F.
		MSExecAuto({|x, y| FINA050(x, y)}, aFina050, 3)
		If lMsErroAuto
			cErro := AllTrim(MemoRead(NomeAutoLog()))
			MemoWrite(NomeAutoLog()," ")
			DisarmTransaction()
		Else
			
			FreeObj(oJson)
			oJson := JsonObject():new()
			aCamposRet:=GetCampos("SE2")
			For nX:=1 to Len(aCamposRet)
				oJson[aCamposRet[nX]] := SE2->(&aCamposRet[nX])
			Next nX
			cRetorno:=oJson:toJSON()

		EndIf

	End Transaction

Return



//Inclui movimentação bancária pagar e receber
/* JSON MODELO
{
	"E5_DATA":"2020-01-01T00:00:00.000Z",
	"E5_VALOR":500.00,
	"E5_NATUREZ":"NATUREZ",
	"E5_BANCO":"001",
	"E5_AGENCIA":"00001",
	"E5_CONTA":"0000001",
	"E5_BENEF":"TESTE",
	"E5_NUMCHEQ":"TESTE",
	"E5_DOCUMEN":"DOCUMENTO",
	"E5_HISTOR":"TESTESTESTESTE"
}
*/
WSMETHOD POST bankTransaction WSSERVICE wsfin884

	Local cRetorno
	Local lRetorno
	Local cErro

	SetDate()
	WSAddSE5(@cRetorno,@lRetorno,@cErro,Self:GetContent())

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf

	Self:SetContentType("application/json")
	Self:SetResponse(cRetorno)

Return(lRetorno)


Static Function WSAddSE5(cRetorno,lRetorno,cErro,cJson)

	Local oJsonAux := JsonObject():new()
	Local oJson
	Local aFINA100
	Local cRecPag
	Local dDtMovto
	Local nValorMov
	Local cNaturez
	Local cBanco
	Local cAgencia
	Local cConta
	Local cBenef
	Local cHistor
	Local cNumCheq
	Local nOpcao
	Local cDocumen
	Local aCamposSE5:=GetCampos("SE5")
	Local nInd
	Local xValor

	Private lMsErroAuto:=.F.

	oJsonAux:fromJson(cJson)
	oJson:=oJsonAux[1]

	RVS->(DbGoTo( oJson['REGISTRO'] ) )

	Begin Transaction

		cRecPag  := Iif(RVS->RVS_VALCRE>0,"R","P")
		cBanco	 := RVS->RVS_COD
		cAgencia := RVS->RVS_AGENCI
		cConta	 := RVS->RVS_NUMCON
		dDtMovto := RVS->RVS_DATA

		nValorMov:= oJson['E5_VALOR']
		cNaturez := oJson['E5_NATUREZ']

		cBenef	 := oJson['E5_BENEF']
		cHistor	 := oJson['E5_HISTOR']
		cNumCheq := oJson['E5_NUMCHEQ']
		cDocumen := oJson['E5_DOCUMEN']

		If cRecPag =="P"
			nOpcao := 3
		ElseIf cRecPag =="R"
			nOpcao := 4
		EndIf

		aFINA100 := {}
		Aadd(aFINA100,{"E5_DATA"    ,dDtMovto              ,Nil})
		Aadd(aFINA100,{"E5_MOEDA"   ,"M1"                  ,Nil})
		Aadd(aFINA100,{"E5_VALOR"   ,nValorMov             ,Nil})
		Aadd(aFINA100,{"E5_NATUREZ" ,cNaturez              ,Nil})
		Aadd(aFINA100,{"E5_BANCO"   ,cBanco  	           ,Nil})
		Aadd(aFINA100,{"E5_AGENCIA" ,cAgencia              ,Nil})
		Aadd(aFINA100,{"E5_CONTA"   ,cConta     	       ,Nil})
		Aadd(aFINA100,{"E5_BENEF"   ,cBenef                ,Nil})
		Aadd(aFINA100,{"E5_NUMCHEQ" ,cNumCheq              ,Nil})
		Aadd(aFINA100,{"E5_HISTOR"  ,cHistor  			   ,Nil})
		Aadd(aFINA100,{"E5_DOCUMEN" ,cDocumen   		   ,Nil})
		aFINA100 := FWVetByDic(aFINA100,"SE5",.F.,1)
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| Fina100(x,y,z)},0,aFINA100,nOpcao) //3=Pagar;4=Receber;5=Exclusão;6=Cancelamento;7=Transferência;8=Estorno Transferência
		FreeObj(oJson)
		oJson := JsonObject():new()
		If lMsErroAuto
			oJson['MENSAGEM']:=""
			cErro := AllTrim(MemoRead(NomeAutoLog()))
			MemoWrite(NomeAutoLog()," ")
			DisarmTransaction()
			lRetorno:=.F.
		Else
			oJson := JsonObject():new()
			oJson['REGISTRO']:=SE5->(Recno())
			SE5->(RecLock("SE5",.F.))
			SE5->(MSUnlock())
			For nInd:=1 To Len(aCamposSE5)
				xValor:=SE5->( FieldGet(FieldPos(aCamposSE5[nInd])) )
				If ValType(xValor)=="C"
					xValor:=AllTrim(xValor)
				EndIf
				oJson[aCamposSE5[nInd]]:=xValor
			Next


			lRetorno:=.T.
		EndIf
		cRetorno:=oJson:toJSON()
	End Transaction


Return

//Inclui transferência bancária
/* JSON MODELO
{
oJson['CBCOORIG']  
oJson['CAGENORIG'] 
oJson['CCTAORIG']  
oJson['CNATURORI'] 
oJson['CBCODEST']  
oJson['CAGENDEST'] 
oJson['CCTADEST']  
oJson['CNATURDES'] 
oJson['CTIPOTRAN'] 
oJson['CDOCTRAN']  
oJson['NVALORTRAN']
oJson['CHIST100']  
oJson['CBENEF100'] }
*/
WSMETHOD POST bankWireTransfer WSSERVICE wsfin884

	Local cRetorno
	Local lRetorno
	Local cErro

	SetDate()
	WSAddSE5Tb(@cRetorno,@lRetorno,@cErro,Self:GetContent())

	If !lRetorno
		SetRestFault(400,cErro)
	EndIf
	::SetContentType("application/json")
	::SetResponse(cRetorno)
Return(lRetorno)


Static Function WSAddSE5Tb(cRetorno,lRetorno,cErro,cJson)

	Local oJson := JsonObject():new()
	Local aFINA100 := {}
	Local aCamposRet := {}
	Local nX := 0

	Private lMsErroAuto:=.F.

	oJson:fromJson(cJson)

	Begin Transaction

		aFINA100 := {}
		Aadd(aFINA100,{"CBCOORIG"  ,oJson['CBCOORIG']  ,Nil})
		Aadd(aFINA100,{"CAGENORIG" ,oJson['CAGENORIG'] ,Nil})
		Aadd(aFINA100,{"CCTAORIG"  ,oJson['CCTAORIG']  ,Nil})
		Aadd(aFINA100,{"CNATURORI" ,oJson['CNATURORI'] ,Nil})
		Aadd(aFINA100,{"CBCODEST"  ,oJson['CBCODEST']  ,Nil})
		Aadd(aFINA100,{"CAGENDEST" ,oJson['CAGENDEST'] ,Nil})
		Aadd(aFINA100,{"CCTADEST"  ,oJson['CCTADEST']  ,Nil})
		Aadd(aFINA100,{"CNATURDES" ,oJson['CNATURDES'] ,Nil})
		Aadd(aFINA100,{"CTIPOTRAN" ,oJson['CTIPOTRAN'] ,Nil})
		Aadd(aFINA100,{"CDOCTRAN"  ,oJson['CDOCTRAN']  ,Nil})
		Aadd(aFINA100,{"NVALORTRAN",oJson['NVALORTRAN'],Nil})
		Aadd(aFINA100,{"CHIST100"  ,oJson['CHIST100']  ,Nil})
		Aadd(aFINA100,{"CBENEF100" ,oJson['CBENEF100'] ,Nil})
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| Fina100(x,y,z)},0,aFINA100,7) //3=Pagar;4=Receber;5=Exclusão;6=Cancelamento;7=Transferência;8=Estorno Transferência
		If lMsErroAuto
			cErro := AllTrim(MemoRead(NomeAutoLog()))
			MemoWrite(NomeAutoLog()," ")
			DisarmTransaction()
		Else
			FreeObj(oJson)
			oJson := JsonObject():new()
			aCamposRet:=GetCampos("SE5")
			For nX:=1 to Len(aCamposRet)
				oJson[aCamposRet[nX]] := SE5->(&aCamposRet[nX])
			Next nX
			cRetorno:=oJson:toJSON()
		EndIf

	End Transaction


Return lRetorno


Static Function FIN884SE5(cTabela,aChave,cSeqSE5,lOrigem)
	Local aAreaAtu:=GetArea()
	Local cAliaQry	:=GetNextAlias()
	Local lFound
	Local cFiltro:=""


	cFiltro+=" And SE5.E5_FILIAL='"	+aChave[01]+"'"
	cFiltro+=" And SE5.E5_IDORIG='"+aChave[02]+"'"

	cFiltro:="%"+cFiltro+"%"

	BeginSql Alias cAliaQry
		Select SE5.R_E_C_N_O_ RecSE5
		From %Table:SE5% SE5
		Where SE5.E5_FILIAL=%xFilial:SE5%		
		And SE5.%notDel%	
		%Exp:cFiltro%
		Order by E5_SEQ DESC		
	EndSql

	If (lFound:=(cAliaQry)->RecSE5>0)
		SE5->(DbGoTo((cAliaQry)->RecSE5))
		cSeqSE5:=SE5->E5_SEQ
	EndIf
	(cAliaQry)->(DbCloseArea())

	RestArea(aAreaAtu)

Return lFound

Static Function Idioma(cRetorno,lRetorno,cErro)
	Local oJson:=JsonObject():New()

	oJson["back"						]:=STR0003			//"Back"
	oJson["viewTransaction"				]:=STR0004			// "View transaction"
	oJson["credit"						]:=STR0005			// "Credit"
	oJson["debit"						]:=STR0006			// "Debit"
	oJson["creditValue"					]:=STR0007			// "Credit Value"
	oJson["toIssueDate"					]:=STR0008			// "To Issue date"
	oJson["messageWarningCalcBalance"	]:=STR0009			// "The maximum value of the item available for launch is:"
	oJson["bankTransaction"				]:=STR0010			// "Bank Transaction"
	oJson["addBankTransaction"			]:=STR0011			// "Add Bank Transaction"
	oJson["searchTransaction"			]:=STR0012			// "Search Transaction"
	oJson["item"						]:=STR0013			//"Item"
	oJson["docNumber"					]:=STR0014			// "Doc Number"
	oJson["remainingBalance"			]:=STR0015			// "Remaining Balance"
	oJson["transactionValu"				]:=STR0016			// "Transaction Valu"
	oJson["match"						]:=STR0017			// "Match"
	oJson["feedBalance"					]:=STR0018			// "Feed Balance"
	oJson["messageWarningPostGeneral"	]:=STR0019			// "Please check the fields and try again"
	oJson["increase"					]:=STR0020			// "Increase"
	oJson["linkedBills"					]:=STR0021			// "Linked Bills"
	oJson["post"						]:=STR0022			// "Post"
	oJson["debitValue"					]:=STR0023			// "Debit Value"
	oJson["note"						]:=STR0024			// "Note"
	oJson["both"						]:=STR0025			// "Both"
	oJson["partiality"					]:=STR0026			// "Partiality"
	oJson["beneficiary"					]:=STR0027			// "Beneficiary"
	oJson["delete"						]:=STR0028			// "Delete"
	oJson["bill"						]:=STR0029			// "Bill"
	oJson["class"						]:=STR0030			// "Class"
	oJson["matchTransaction"			]:=STR0031			// "Match transaction"
	oJson["undo"						]:=STR0032			// "Undo"
	oJson["received"					]:=STR0033			// "Received"
	oJson["accountsPayable"				]:=STR0034			// "Accounts Payable"
	oJson["name"						]:=STR0035			// "Name"
	oJson["loading"						]:=STR0036			// "Loading, please wait."
	oJson["cancel"						]:=STR0037			// "Cancel"
	oJson["messageSucessPostUndo"		]:=STR0038			// "Transaction undone successfully"
	oJson["series"						]:=STR0039			// "Series"
	oJson["review"						]:=STR0040			// "Review"
	oJson["view"						]:=STR0041			// "View"
	oJson["new"							]:=STR0042			// "New"
	oJson["messageSucessPostGeneral"	]:=STR0043			// "Bank transaction added successfully"
	oJson["undoTransaction"				]:=STR0044			// "Undo transaction"
	oJson["searchPlaceholder"			]:=STR0045			// "Search by description"
	oJson["postingVal"					]:=STR0046			// "Posting Val"
	oJson["bankReconciliation"			]:=STR0047			// "Bank Reconciliation"
	oJson["checkNumber"					]:=STR0048			// "Check Number"
	oJson["type"						]:=STR0049			// "Type"
	oJson["fromIssueDate"				]:=STR0050			// "From Issue date"
	oJson["transacValu"					]:=STR0051			// "Transac.Valu"
	oJson["recNumber"					]:=STR0052			// "Rec. Number"
	oJson["paid"						]:=STR0053			// "Paid"
	oJson["accountsReceivable"			]:=STR0054			// "Accounts Receivable"
	oJson["history"						]:=STR0055			// "History"
	oJson["description"					]:=STR0056			// "Description"
	oJson["origin"						]:=STR0057			// "Origin"
	oJson["messageWarningAddBank"		]:=STR0058			//"Invalid form, please check the fields"
	oJson["messageSucessAddBank"		]:=STR0059			//"Bank transaction added successfully"
	oJson["close"						]:=STR0060			//"Close"
	oJson["ok"							]:=STR0061			//"Ok"
	oJson["messageWarningModalFilter"	]:=STR0062			//"Select an item"
	oJson["balPlaidSelected"			]:=STR0063			//"Bal Plaid Selected"
	oJson["transacValuSelected"			]:=STR0064			//"Transac.Valu Selected"
	oJson["billNumber"					]:=STR0065			//"Bill Number"
	oJson["billValue"					]:=STR0066			//"Bill Value"
	oJson["custID"						]:=STR0067			//"Cust. ID"
	oJson["custName"					]:=STR0068			//"Cust.Name"
	oJson["fromDueDate"					]:=STR0069			//"From due date"
	oJson["toDueDate"					]:=STR0070			//"To due date"
	oJson["supplier"					]:=STR0071			//"Supplier"
	oJson["supplName"					]:=STR0072			//"Suppl.Name"
	oJson["fromMaturityDate"			]:=STR0073			//"From maturity date"
	oJson["toMaturityDate"				]:=STR0074			//"To maturity date"
	oJson["transactDt"					]:=STR0075			//"Transact.Dt."
	oJson["selectedQuantity"			]:=STR0076			//"Selected Quantity"
	oJson["search"						]:=STR0077			//"Search"
	oJson["action"						]:=STR0078			//"Action"
	oJson["noBankFound"					]:=STR0079			//"No Bank Found"

	cRetorno:=oJson:toJSON()
	lRetorno:=.T.
	cErro:=""
Return



