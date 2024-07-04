#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "FINI791.CH"

Static __nTamPref := 0
Static __nTamNum := 0
Static __nTamParc := 0
Static __nTamTipo := 0 
Static __nTamCli := 0
Static __nTamLoja := 0

/*/{Protheus.doc} FINI791
Adapter da rotina de cadastro de fatura de hotel

@param cXml, XML da mensagem
@param nType, Determina se é uma mensagem a ser enviada ou recebida (TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg, Tipo de mensagem (EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE ou EAI_MESSAGE_BUSINESS)
@param cVersion, Versão da Mensagem Única TOTVS

@return lRet, Indica se a mensagem foi processada com sucesso
@return cXmlRet, XML de retorno do adapter

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Function FINI791( cXml, nType, cTypeMessage, cVersion  )
	Local aArea := GetArea()
	Local lRet := .T.
	Local cXMLRet := ""

	If ( nType == TRANS_RECEIVE )

		If ( cTypeMessage == EAI_MESSAGE_WHOIS )

			cXmlRet := "1.000|1.001|1.002"

		ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )

			lRet := RecBusXML( cXml, @cXMLRet )

		EndIf
	ElseIF nType == TRANS_SEND
		lRet := .F.
		cXmlRet += STR0003 //" Operação Inválida."
	Endif

	RestArea( aArea )

Return {lRet, cXmlRet, "HOTELINVOICE"}

/*/{Protheus.doc} RecBusXML
Função para tratar o XML recebido na mensagem de Business

@param cXml, XML recebido
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se processou a mensagem recebida com sucesso

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Static Function RecBusXML( cXml, cXMLRet )
	Local lRet := .T.
	Local oXML := Nil
	Local cEvent := ""
	Local cMarca := ""
	Local lInclusao := .F.
	Local cPathBC := "/TOTVSMessage/BusinessMessage/BusinessContent/"
	Local cIntCom := ""
	Local cExtCom := ""
	Local aRetCom := {}
	Local aChave := {}
	Local nOper := 0
	Local aErroAuto := {}
	Local cCliInt := ""
	Local cCliente := ""
	Local cLoja := ""
	Local dEmiss := cTod("")
	Local nValor := 0
	Local cCode := ""
	Local nX := 0
	Local nY := 0
	Local aAuxList := {}
	Local aAux := {}
	Local aNotaList := {}
	Local aNota := {}
	Local aTitList := {}
	Local aTit := {}
	Local aTitChave := {}
	Local cCampo := ""
	Local nValorTot := 0
	Local lCancela := .F.
	Local cCancela := Nil
	Local nComiss := 0
	Local cFornec := ""
	Local cLojFor := ""
	Local aComiss := {}	
	
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	oXML := tXMLManager():New()
	lRet := oXML:Parse( cXml )

	If lRet
		//Inicia as variáveis estáticas com os tamanhos dos campos do título
		IniTamSX3()
	
		cEvent := oXml:XPathGetNodeValue( "/TOTVSMessage/BusinessMessage/BusinessEvent/Event" )
		cMarca := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )
		cCancela := oXml:XPathGetNodeValue( cPathBC + "HotelInvoiceCancellation" )

		If ValType(cCancela) == "C" .And. !Empty(cCancela)
			lCancela := Alltrim(cCancela) == '1'
		Else
			lCancela := .F.
		Endif

		//Verifica se existe o Registro no XXF para saber se é Inclusão ou Alteração
		cExtCom := oXml:XPathGetNodeValue( cPathBC + "InternalId" )
		If ! Empty( cExtCom )
			aRetCom := F791GetInt( cExtCom, cMarca )
			If aRetCom[1] //Se o registro foi encontrado na tabela de de/para
				cIntCom := aRetCom[3]
			EndIf
		Else
			aAdd( aRetCom, .F. )
			lRet := .F.
			cXmlRet += STR0012 //"  A tag InternalId é obrigatória"
		EndIf

		If lRet

			If Upper( cEvent ) == "UPSERT"

				//Se já existir o registro, então é alteração, senão é inclusão
				If aRetCom[1]
					//Se não conseguir posicionar no registro para alterar, retorna erro
					FO8->( dbSetOrder( 1 ) ) //FO8_FILIAL + FO8_NUM + FO8_CLI + FO8_LOJA
					aChave := aRetCom[2]
					If FO8->( MsSeek( aChave[2] + aChave[3] + aChave[4] + aChave[5] ) )
						If lCancela
							lRet := .T.
							nOper := 5
						Else
							lRet := .F.
							cXmlRet += STR0013 + " " + STR0014 + AllTrim( cExtCom ) //" Não é possível alterar a fatura. Cancele e inclua uma nova com as informações corretas.", "Código da Fatura: "                                                                                                                                                                                                                                                                                                                                                                                                                           
						Endif
					Else
						If lCancela
							lRet := .F.
							cXmlRet += STR0015 + " " + STR0014 + AllTrim( cExtCom ) //" A fatura a ser cancelada não foi encontrada.", "Código da Fatura: "
						Else
							lRet := .F.
							cXmlRet += STR0022 + " " + STR0014 + AllTrim( cExtCom ) //" A fatura foi encontrada no de/para do Protheus, mas não foi encontrado o registro correspondente na tabela FO8.", "Código da Fatura: "
						Endif
					Endif
				Else
					If lCancela
						lRet := .F.
						cXmlRet += STR0008 + " " + STR0014 + AllTrim( cExtCom ) //" Fatura não encontrada.", "Código da Fatura: "
					Else
						lRet := .T.
						lInclusao := .T.
						nOper := 3
					Endif
				Endif

				If lRet
					If lCancela
						If FO8->FO8_STATUS == '1'
							//Cancelamento de Títulos
							Begin Transaction
								lRet := F791CanFat( aChave, @aErroAuto )
								If !lRet
									DisarmTransaction()
									For nX := 1 to len(aErroAuto)
										If Valtype(aErroAuto[nX]) == 'C'
											cXmlRet += _NoTags(aErroAuto[nX]) + " "
										EndIf
									Next nX
								Else
									//Altera o Status
									If FO8->( MsSeek( aChave[2] + aChave[3] + aChave[4] + aChave[5] ) )
										RecLock("FO8",.F.)
										FO8->FO8_STATUS := '2'
										MsUnlock()
									Endif

								Endif

							End Transaction
						Else
							lRet := .F.
							cXmlRet += STR0010 + " " + STR0014 + AllTrim( cExtCom ) //" Fatura cancelada.", "Código da Fatura: "
						Endif
					Else
						cCode := oXml:XPathGetNodeValue( cPathBC + "Code" )
						dEmiss := SToD( StrTran( oXml:XPathGetNodeValue( cPathBC + "IssueDate" ), "-", "" ) )
						cCliInt := oXml:XPathGetNodeValue( cPathBC + "CustomerVendorInternalId" )

						If !Empty( cCliInt )
							aAux := IntCliInt( cCliInt, cMarca )
							If aAux[1]
								cCliente := Alltrim( aAux[2][3] )
								cLoja := Alltrim( aAux[2][4] )
							Else
								lRet := .F.
								cXmlRet += aAux[2]
							Endif
						Else
							lRet 	:= .F.
							cXmlRet += STR0005 //"A tag CustomerVendorInternalId é obrigatória."
						EndIf

						//Comissão descontada
						nComiss := Val( oXml:XPathGetNodeValue( cPathBC + "SalesChargeInformation/SalesChargeDiscount" ) )
						cForInt	:= oXml:XPathGetNodeValue( cPathBC + "SalesChargeInformation/CustomerVendorInternalId" )
						If !Empty( cForInt )
							aAux := IntForInt( cForInt, cMarca )
							If aAux[1]
								cFornec	:= Alltrim( aAux[2][3] )
								cLojFor	:= Alltrim( aAux[2][4] )
							Else
								lRet := .F.
								cXmlRet += aAux[2]
							Endif
						EndIf

						//Notas fiscais (RetailSales)
						nValor := Val( oXml:XPathGetNodeValue( cPathBC + "Value" ) )
						aNotaList	:= oXml:XPathGetChildArray( cPathBC + "ListOfRetailSales" )

						For nX:= 1 to Len(aNotaList)
							aAuxList := oXml:XPathGetChildArray( aNotaList[nX][2] )
							aAux := {}
							For nY := 1 to Len(aAuxList)
								If Upper( alltrim( aAuxList[nY][1] ) ) == "RETAILSALESINTERNALID"
									cIdNota := aAuxList[nY][3]
									aAux := IntVendInt( cIdNota, cMarca )
									If aAux[1]
										aAdd( aNota, aClone( aAux[2] ) )
									Else
										lRet := .F.
										cXmlRet += aAux[2]
									Endif
								EndIf
							Next nY
						Next nX

						aTitList:= oXml:XPathGetChildArray( cPathBC + "ListOfAccountReceivableInformation" )
						For nX:= 1 to Len(aTitList)
							aAuxList := oXml:XPathGetChildArray( aTitList[nX][2] )
							aAux := {0, CTOD(""),""}
							For nY := 1 to Len(aAuxList)
								If Upper( AllTrim( aAuxList[nY][1] ) ) == "VALUE"
									aAux[1] := Val( aAuxList[nY][3] )
									nValorTot += aAux[1]
								ElseIf Upper( AllTrim( aAuxList[nY][1] ) ) == "DUEDATE"
									aAux[2] := SToD( StrTran( aAuxList[nY][3], "-", "" ) )
								ElseIf Upper( AllTrim( aAuxList[nY][1] ) ) == "OBSERVATION"
									aAux[3]	:= aAuxList[nY][3]
								EndIf
							Next nY
							aAdd( aTit, aClone(aAux) )
						Next nX

						If lRet

							//Baixa e Inclusão dos Títulos
							Begin Transaction
								//Faz a baixa dos títulos vinculados aos RPS e gera as parcelas da fatura no contas a receber
								lRet := F791FatHtl( cCliente, cLoja, @aNota, aTit, nComiss, cCode, @aTitChave, @aErroAuto )  
								
								If lRet .AND. nComiss > 0
									lRet := F791IncCom( cCode, cFornec, cLojFor, dEmiss, nOper, nComiss, @aComiss, @aErroAuto )
								EndIf
								lRet := lRet .AND. F791IncFat( cCode, dEmiss, cCliente, cLoja, nValorTot, aNota, aTitChave, @aErroAuto, aComiss )

								//Se não deu nenhum erro nas definições dos valores no model, então valida o modelo de dados e grava
								If !lRet
									DisarmTransaction()
									For nX := 1 to Len( aErroAuto )
										If Valtype( aErroAuto[nX] ) == 'C'
											cXmlRet += _NoTags( aErroAuto[nX] ) + " "
										EndIf
									Next nX
								Else
									If lInclusao
										//Grava o registro na tabela XXF (de/para)
										cIntCom :=  F791MntInt( FO8->( RecNo() ) )
										CFGA070Mnt( cMarca, "FO8", "FO8_NUM", cExtCom, cIntCom, .F. )
									Endif

									//Monta XML de resposta com o internalID gerado para a Reserva em questão
									cXMLRet := "<ListOfInternalId>"
									cXMLRet +=     "<InternalId>"
									cXMLRet +=         "<Name>HotelInvoiceInternalId</Name>"
									cXMLRet +=         "<Origin>" + cExtCom + "</Origin>" //Valor recebido da outra marca
									cXMLRet +=         "<Destination>" + cIntCom + "</Destination>" //Valor interno gerado no Protheus
									cXMLRet +=     "</InternalId>"
									cXMLRet += "</ListOfInternalId>"
								Endif

							End Transaction
						EndIf
					EndIf
				Endif
			Else
				lRet := .F.
				cXmlRet := STR0006 //"O tipo de operação não foi informado corretamente na tag Event."
			Endif
		EndIf
	Else
		cXmlRet := STR0007 //"Houve um erro no tratamento do XML. Verifique se o mesmo está sendo informado corretamente."
	EndIf
	
	aSize ( aRetCom, 0 )
	aRetCom := Nil
	aSize ( aChave, 0 )
	aChave := Nil
	aSize ( aErroAuto, 0 )
	aErroAuto := Nil
	aSize ( aAuxList, 0 )
	aAuxList := Nil
	aSize ( aAux, 0 )
	aAux := Nil
	aSize ( aNotaList, 0 )
	aNotaList := Nil
	aSize ( aNota, 0 )
	aNota := Nil
	aSize ( aTitList, 0 )
	aTitList := Nil
	aSize ( aTit, 0 )
	aTit := Nil
	aSize ( aTitChave, 0 )
	aTitChave := Nil
	aSize ( aComiss, 0 )
	aComiss := Nil
	
	oXML := Nil
	DelClassIntF()

Return lRet

/*/{Protheus.doc} F791GetInt
Função para pegar o código da chave da fatura a partir do código externo

@param cCodigo, InternalID recebido na mensagem
@param cMarca, Produto que enviou a mensagem
@return aRet, Vetor contendo os campos da chave primaria da fatura
@sample Exemplo de retorno: { .T., { "T1", "D MG 01", "1", "00000000001" }, "T1|D MG 01|1|00000000001" }

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Function F791GetInt( cCodigo, cMarca )
	Local cValInt := ""
	Local aRet := {}
	Local aAux := {}
	Local nX := 0
	Local aCampos := { cEmpAnt,'FO8_FILIAL','FO8_NUM','FO8_CLI','FO8_LOJA' }

	cValInt := CFGA070Int( cMarca, "FO8", "FO8_NUM", cCodigo )
	If Empty( cValInt )
		aAdd( aRet, .F. )
		aAdd( aRet, STR0001  + AllTrim(cCodigo) + STR0002 ) //"Fatura " " não encontrado no de/para"
	Else
		aAux := Separa( cValInt, "|" )

		aAdd( aRet, .T. )
		aAdd( aRet, aAux )
		aAdd( aRet, cValInt )

		aRet[2][1] := PADR( aRet[2][1], Len(cEmpAnt) )

		//Garante que o tamanho dos campos esteja correto
		For nX := 2 To Len( aRet[2] )
			aRet[2][nX] := PADR( aRet[2][nX], TamSX3( aCampos[nX])[1] )
		Next nX
	EndIf

Return aRet

/*/{Protheus.doc} F791MntInt
Função para montar o código da chave da fatura a partir do código externo

InternalID composto de:
cEmpAnt|FO8_FILIAL|FO8_NUM|FO8_CLI|FO8_LOJA

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Function F791MntInt( nRecFO8, cFilfat,cFatura,cCliente,cLoja)
	Local cRet := ""
	Local aArea := GetArea()
	Default cFilfat := FWxFilial( "FO8" )
	Default nRecFO8 := 0

	If nRecFO8 > 0
		FO8->(dbGoto(nRecFO8))
		cRet := FO8->( cEmpAnt + "|" + RTrim(FO8_FILIAL) + "|" + RTrim(FO8_NUM) + "|" + RTrim(FO8_CLI)+ "|" + RTrim(FO8_LOJA) )
	Else
		cRet := cEmpAnt + "|" + RTrim(cFilfat) + "|" + RTrim(cFatura) + "|" + RTrim(cCliente)+ "|" + RTrim(cLoja)
	EndIf

	RestArea(aArea)
Return cRet

/*/{Protheus.doc} F791IncCom
Função para incluir o titulo de comissao quando a comissao é descontada da fatura.

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Static Function F791IncCom(cCode,cFornec,cLojFor,dEmiss,nOper,nComiss,aComiss,aErroAuto)
	Local lRet := .T.
	Local nX := 0
	Local nTamE2Parc := TamSX3('E2_PARCELA')[1]
	Local cParcela := StrZero(0,nTamE2Parc)
	Local cNatureza := ""
	Local cTipo := SuperGetMv( "MV_HTLTCDF ", .F., 'DP' )
	Local cPrefix := SuperGetMv( "MV_HTLPREC", .F. ,'CDF' )
	Local xConteudo := Nil
	Local aExecTit := {}
	Local dVencto := Ctod("")
	Local nValor := 0
	Local nY := 0
	Local cParBCO := SuperGetMv( "MV_HTLBCOM", .F. )
	Local aBanco := {}

	SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

	cFornec	:= PADR( cFornec, TamSX3('A2_COD')[1] )
	cLojFor	:= PADR( cLojFor, TamSX3('A2_LOJA')[1] )
	cPrefix	:= PADR( cPrefix, TamSX3('E2_PREFIXO')[1] )
	cCode := PADR( cCode, TamSX3('E2_NUM')[1] )
	cParcela := PADR( cParcela, nTamE2Parc )
	cTipo := PADR( cTipo, TamSX3('E2_TIPO')[1] )

	If SA2->( MsSeek(xFilial("SA2") + cFornec + cLojFor) )
		If SA2->A2_TIPO == 'F' //Fisica
			cNatureza := SuperGetMv( "MV_HTLNCPF", .F. )
		Else
			cNatureza := SuperGetMv( "MV_HTLNCPJ", .F. )
		EndIf
	Endif

	aBanco := StrToKarr( cParBCO, "/" )

	aExecTit := {}
	AADD(aExecTit, {"E2_NUM"    , cCode					, NIL})
	AADD(aExecTit, {"E2_PREFIXO", cPrefix				, NIL})
	AADD(aExecTit, {"E2_PARCELA", cParcela				, NIL})
	AADD(aExecTit, {"E2_TIPO"   , cTipo					, NIL})
	AADD(aExecTit, {"E2_NATUREZ", cNatureza				, NIL})
	AADD(aExecTit, {"E2_FORNECE", cFornec				, NIL})
	AADD(aExecTit, {"E2_LOJA"   , cLojFor				, NIL})
	AADD(aExecTit, {"E2_EMISSAO", dEmiss				, NIL})
	AADD(aExecTit, {"E2_VENCTO" , dEmiss				, NIL})
	AADD(aExecTit, {"E2_VENCREA", DataValida(dEmiss,.T.), NIL})
	AADD(aExecTit, {"E2_VENCORI", DataValida(dEmiss,.T.), NIL})
	AADD(aExecTit, {"E2_EMIS1"  , dEmiss				, NIL})
	AADD(aExecTit, {"E2_MOEDA"  , 1						, NIL})
	AADD(aExecTit, {"E2_VALOR"  , nComiss				, NIL})
	AADD(aExecTit, {"E2_VLCRUZ" , nComiss				, NIL})
	AADD(aExecTit, {"E2_ORIGEM" , 'FINI791'				, NIL})

	For nY := 1 to len(aExecTit)
		cCampo 	:= aExecTit[nY][1]
		xConteudo	:= aExecTit[nY][2]
		If ValType(xConteudo) == "C"
			xConteudo := PADR( xConteudo, TamSX3(cCampo)[1] )
			aExecTit[nY][2] := xConteudo
		EndIf
	Next nY

	MSExecAuto({|x, y| FINA050(x, y)}, aExecTit, 3)

	If ! lMsErroAuto
		lRet := .T.
	Else
		aErroAuto := GetAutoGRLog()
		lRet := .F.
	Endif

	//Realiza a baixa do Título
	If lRet
		aExecTit := {}
		SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If SE2->(dbSeek(xFilial("SE2")+ cFornec + cLojFor + cPrefix + cCode + cParcela + cTipo  ))//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

			AADD(aExecTit,{"E2_FILIAL"	, SE2->E2_FILIAL  , Nil})
			AADD(aExecTit,{"E2_PREFIXO"	, SE2->E2_PREFIXO , Nil})
			AADD(aExecTit,{"E2_NUM"		, SE2->E2_NUM     , Nil})
			AADD(aExecTit,{"E2_PARCELA"	, SE2->E2_PARCELA , Nil})
			AADD(aExecTit,{"E2_TIPO"	, SE2->E2_TIPO    , Nil})
			AADD(aExecTit,{"E2_FORNECE"	, SE2->E2_FORNECE , Nil})
			AADD(aExecTit,{"E2_LOJA"	, SE2->E2_LOJA    , Nil})
			AADD(aExecTit,{"E2_NATUREZ"	, SE2->E2_NATUREZ , Nil})
			AADD(aExecTit,{"AUTMOTBX"	, "DEB"           , Nil})
			AADD(aExecTit,{"AUTDTBAIXA"	, dEmiss		  , Nil})
			AADD(aExecTit,{"AUTDTDEB"	, dEmiss		  , Nil})
			AADD(aExecTit,{"AUTHIST"	, STR0016         , Nil}) //"Baixa Comissao"

			If Len(aBanco) > 0
				aBanco[1] := PADR( aBanco[1], TamSX3('A6_COD')[1] )
				aBanco[2] := PADR( aBanco[2], TamSX3('A6_AGENCIA')[1] )
				aBanco[3] := PADR( aBanco[3], TamSX3('A6_NUMCON')[1] )
				AADD(aExecTit,{"AUTBANCO",aBanco[1],NIL}) //Banco
				AADD(aExecTit,{"AUTAGENCIA",aBanco[2],NIL}) //agencia
				AADD(aExecTit,{"AUTCONTA",aBanco[3],NIL}) //Conta
			EndIf

			MSExecAuto({|x,y| Fina080(x,y)},aExecTit,3)

			SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If ! lMsErroAuto
				lRet := .T.
				//Chave para Gravar o Titulo na Fatura
				If SE2->(dbSeek(xFilial("SE2") + cPrefix + cCode ))
					While SE2->(!EOF()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == xFilial("SE2") + cPrefix + cCode
						aAux := {}
						aAdd(aAux, cFilAnt)
						aAdd(aAux, SE2->E2_PREFIXO)
						aAdd(aAux, SE2->E2_NUM)
						aAdd(aAux, SE2->E2_PARCELA)
						aAdd(aAux, SE2->E2_TIPO)
						aAdd(aAux, SE2->E2_FORNECE)
						aAdd(aAux, SE2->E2_LOJA)
						aAdd(aComiss, aClone(aAux))
						SE2->(dbSkip())
					EndDo
				EndIf
			Else
				aErroAuto := GetAutoGRLog()
				lRet := .F.
			Endif
		Endif

	EndIf
Return lRet

/*/{Protheus.doc} F791IncFat
Função para incluir a fatura.

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Static Function F791IncFat(cCode,dEmiss,cCliente,cLoja,nValorTot,aNota,aTitChave,aErroAuto,aComiss)
	Local lRet := .T.
	Local oModel := FWLoadModel( "FINA791" )
	Local oModelFO8	:= Nil
	Local oModelFO9	:= Nil
	Local oModelFOA	:= Nil
	Local oModelFOB	:= Nil
	Local oModelFOC	:= Nil
	Local nLinFO9 := 1
	Local nX := 0
	Local nLinFOA := 1
	Local nTamFO9It := TamSx3("FO9_ITEM")[1]
	Local nLinFOC := 1
	Local aDANFE := {}
	Default aNota := {}
	
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	oModel:Activate()
	//Carrega Cabecalho
	oModelFO8 := oModel:GetModel( "FO8MASTER" )

	lRet := lRet .And. oModelFO8:SetValue( "FO8_NUM"	  , cCode )
	lRet := lRet .And. oModelFO8:SetValue( "FO8_DATA"  , dEmiss )
	lRet := lRet .And. oModelFO8:SetValue( "FO8_CLI"	  , cCliente )
	lRet := lRet .And. oModelFO8:SetValue( "FO8_LOJA"  , cLoja )
	lRet := lRet .And. oModelFO8:SetValue( "FO8_VALOR" , nValorTot )
	lRet := lRet .And. oModelFO8:SetValue( "FO8_STATUS", '1' )

	//Carrefa grid de notas (Varejo)
	If lRet .AND. Len(aNota) > 0
		oModelFO9 := oModel:GetModel( "FO9DETAIL" )
		nLinFO9 := 1
		For nX := 1 to Len(aNota)
			//Se houver 7 posições no array, então foram adicionados os dados da DANFE no mesmo e, nesse caso, grava a DANFE em uma tabela diferente (FOC) 
			If Len( aNota[nX] ) == 7
				
				//Tratamento para não adicionar a mesma DANFE duas vezes no vetor para gravação da FOC
				If Len( aDANFE ) == 0 .OR. AScan( aDANFE, {|x| AllTrim( x[1] ) == AllTrim( aNota[nX][6] ) .AND. AllTrim( x[2] ) == AllTrim( aNota[nX][7] ) } ) == 0  
					//Adiciona a série e o número da DANFE em um vetor separado para gravar a FOC
					aAdd( aDANFE, { aNota[nX][6], aNota[nX][7] } )
				Endif
			Else
				If nLinFO9 > 1
					nLin := oModelFO9:AddLine()
					oModelFO9:GoLine(nLinFO9)
				EndIf
				lRet := lRet .And. oModelFO9:SetValue( "FO9_ITEM"  , STRZERO(nLinFO9, nTamFO9It) )
				lRet := lRet .And. oModelFO9:SetValue( "FO9_SERIE" , aNota[nX][3]	)
				lRet := lRet .And. oModelFO9:SetValue( "FO9_NUMDOC", aNota[nX][4]	)
				If !lRet
					Exit
				EndIf
				nLinFO9++
			Endif
		Next nX
	EndIf

	//Carrega grid de DANFE com título gerado (DANFE para órgão público)
	If lRet .AND. Len(aDANFE) > 0
		oModelFOC := oModel:GetModel( "FOCDETAIL" )
		nLinFOC := 1
		For nX := 1 to Len(aDANFE)
			If nLinFOC > 1
				nLin := oModelFOC:AddLine()
				oModelFOC:GoLine(nLinFOC)
			EndIf
			lRet := lRet .And. oModelFOC:SetValue( "FOC_ITEM"  , STRZERO(nLinFOC, nTamFO9It) )
			lRet := lRet .And. oModelFOC:SetValue( "FOC_SERIE" , aDANFE[nX][1] )
			lRet := lRet .And. oModelFOC:SetValue( "FOC_NUMDOC", aDANFE[nX][2] )
			If !lRet
				Exit
			EndIf
			nLinFOC++
		Next nX
	EndIf

	//Carrefa grid de Titulos
	If lRet
		oModelFOA := oModel:GetModel( "FOADETAIL" )
		nLinFOA := 1
		For nX := 1 to Len(aTitChave)
			If nLinFOA > 1
				nLin := oModelFOA:AddLine()
				oModelFOA:GoLine(nLinFOA)
			EndIf
			lRet := lRet .And. oModelFOA:SetValue( "FOA_ITEM " , STRZERO(nLinFOA, nTamFO9It) )
			lRet := lRet .And. oModelFOA:SetValue( "FOA_PREFIX", aTitChave[nX][2] )
			lRet := lRet .And. oModelFOA:SetValue( "FOA_NUM"	  , aTitChave[nX][3] )
			lRet := lRet .And. oModelFOA:SetValue( "FOA_PARCEL", aTitChave[nX][4] )
			lRet := lRet .And. oModelFOA:SetValue( "FOA_TIPO"  , aTitChave[nX][5] )
			lRet := lRet .And. oModelFOA:SetValue( "FOA_TITFIL", aTitChave[nX][1] )
			If !lRet
				Exit
			EndIf
			nLinFOA++
		Next nX
	EndIf

	//Carrefa grid de Titulos
	If lRet
		oModelFOB := oModel:GetModel( "FOBDETAIL" )
		nLinFOB := 1
		For nX := 1 to Len(aComiss)
			If nLinFOB > 1
				nLin := oModelFOB:AddLine()
				oModelFOB:GoLine(nLinFOB)
			EndIf
			lRet := lRet .And. oModelFOB:SetValue( "FOB_ITEM " , STRZERO(nLinFOB, nTamFO9It) )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_PREFIX", aComiss[nX][2] )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_NUM"   , aComiss[nX][3] )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_PARCEL", aComiss[nX][4] )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_TIPO"  , aComiss[nX][5] )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_FORCOM", aComiss[nX][6] )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_LOJCOM", aComiss[nX][7] )
			lRet := lRet .And. oModelFOB:SetValue( "FOB_TITFIL", aComiss[nX][1] )

			If !lRet
				Exit
			EndIf
			nLinFOB++
		Next nX
	EndIf

	//Se não deu nenhum erro nas definições dos valores no model, então valida o modelo de dados e grava
	If lRet
		lRet := oModel:VldData()
		If lRet
			oModel:CommitData()
		EndIf
	Endif

	If !lRet
		aErroAuto := oModel:GetErrorMessage()
	EndIf

	oModel:DeActivate()
	oModel		:= Nil
	oModelFO8	:= Nil
	oModelFO9	:= Nil
	oModelFOA	:= Nil
	oModelFOB	:= Nil
	oModelFOC	:= Nil
Return	lRet

/*/{Protheus.doc} F791CanFat
Função para excluir os titulos da fatura e desfazer as baixas dos títulos de RPS a faturar no cancelamento da fatura.

@author Alvaro Camillo Neto
@since 11/01/2016
@version P12.1.8
/*/
Static Function F791CanFat( aChave, aErroAuto )
	Local aAreaSE1 := SE1->( GetArea() )
	Local lRet := .T.
	Local cCampo := ""
	Local xConteudo	:= Nil
	Local aExecTit := {}
	Local nY := 0
	Local cTipo := Alltrim(SuperGetMv( "MV_HTLTCDF ", .F., 'DP' ))
	Local cChaveFO8 := ""
	Local cChaveFO9 := ""
	Local cChaveFOC := ""
	Local cPrefix := ""
	Local cNum := ""
	Local cCliente := ""
	Local cLoja := ""
	Local aCab := {}
	Local cParcTitRPS := PADR( "A", __nTamParc )
	Local cTipoTitRPS := PADR( "FA", __nTamTipo )
	Local nSeq := 0
	Local cFK7Chave := ""
	Local cFK1Chave := ""
	Local cChvComiss := ""
	Local aInfCliLj := {}
	Local aInfCliNF := {}
	Local lCQ := .F. 
	
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	FO9->( dbSetOrder( 1 ) ) //FO9_FILIAL + FO9_NUMFAT + FO9_CLIFAT + FO9_LOJFAT + FO9_SERIE + FO9_NUMDOC
	FOA->( dbSetOrder( 1 ) ) //FOA_FILIAL + FOA_NUMFAT + FOA_CLIFAT + FOA_LOJFAT + FOA_PREFIX + FOA_NUM + FOA_PARCEL + FOA_TIPO
	FOB->( dbSetOrder( 1 ) ) //FOB_FILIAL+FOB_NUMFAT+FOB_CLIFAT+FOB_LOJFAT+FOB_PREFIX+FOB_NUM+FOB_PARCEL+FOB_TIPO
	FOC->( dbSetOrder( 1 ) ) //FOC_FILIAL + FOC_NUMFAT + FOC_CLIFAT + FOC_LOJFAT + FOC_SERIE + FOC_NUMDOC
	SE1->( dbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE2->( dbSetOrder( 6 ) ) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

	If FO8->( MsSeek( aChave[2] + aChave[3] + aChave[4] + aChave[5] ) )

		//Titulos a receber
		cChaveFO8 := FO8->(xFilial("FOA") + FO8_NUM + FO8_CLI + FO8_LOJA)
		FOA->(dbSeek(cChaveFO8) )

		While FOA->(!EOF()) .And. FOA->(FOA_FILIAL + FOA_NUMFAT + FOA_CLIFAT + FOA_LOJFAT) == cChaveFO8
			If SE1->(dbSeek( FOA->(xFilial("SE1") + FOA_CLIFAT + FOA_LOJFAT + FOA_PREFIX + FOA_NUM + FOA_PARCEL + FOA_TIPO) ) )
				
				//Exclui o título a receber criado na fatura
				lRet := F791ExcCR( @aErroAuto )
				
				If !lRet
					Exit
				Endif
							
			EndIf
			FOA->(dbSkip())
		EndDo

		//Titulos a pagar (Comissão)
		If lRet
			cChaveFO8 := FO8->(xFilial("FOA") + FO8_NUM + FO8_CLI + FO8_LOJA)
			FOB->(dbSeek(cChaveFO8) )

			While FOB->(!EOF()) .And. FOB->(FOB_FILIAL+FOB_NUMFAT+FOB_CLIFAT+FOB_LOJFAT) == cChaveFO8
				
				cChvComiss := FOB->( FWxFilial("SE2") + FOB_FORCOM + FOB_LOJCOM + FOB_PREFIX + FOB_NUM + FOB_PARCEL + FOB_TIPO )  
				If Alltrim(FOB->FOB_TIPO) == cTipo .And. SE2->( dbSeek( cChvComiss ) )

					If SE2->E2_SALDO == 0
						aBaixa := {}
						AADD(aBaixa, {"E2_FILIAL" , SE2->E2_FILIAL , Nil})
						AADD(aBaixa, {"E2_PREFIXO", SE2->E2_PREFIXO, Nil})
						AADD(aBaixa, {"E2_NUM"    , SE2->E2_NUM	 , Nil})
						AADD(aBaixa, {"E2_PARCELA", SE2->E2_PARCELA, Nil})
						AADD(aBaixa, {"E2_TIPO"   , SE2->E2_TIPO	 , Nil})
						AADD(aBaixa, {"E2_FORNECE", SE2->E2_FORNECE, Nil})
						AADD(aBaixa, {"E2_LOJA"   , SE2->E2_LOJA	 , Nil})

						lMsErroAuto := .F.
						MsExecAuto ({|x,y| FINA080(x,y)}, aBaixa, 5)

						If !lMsErroAuto
							lRet := .T.
						Else
							aErroAuto := GetAutoGRLog()
							lRet := .F.
							Exit
						Endif
					Endif

					If lRet
						
						//Exclui o título de comissão a pagar
						lRet := F791ExcCP( @aErroAuto )
						
						If !lRet
							Exit
						Endif
						
					EndIf
				Else
					aAdd( aErroAuto, STR0017 + cChvComiss ) //"Título de comissão não econtrado no protheus: "
					lRet := .F.
					Exit
				EndIf
				
				FOB->(dbSkip())
			EndDo
		EndIf

	EndIf

	//Cancelamento das baixas dos títulos gerados na integração de RPS e cupom fiscal CQ
	If lRet
		cChaveFO9 := aChave[2] + aChave[3] + aChave[4] + aChave[5]
		If FO9->( MsSeek( cChaveFO9 ) )

			While FO9->( ! EOF() ) .AND. FO9->( FO9_FILIAL + FO9_NUMFAT + FO9_CLIFAT + FO9_LOJFAT ) == cChaveFO9
				//Pega os campos do RPS pra formar a chave do título a receber que o mesma gerou
				cPrefix := PADR( FO9->FO9_SERIE, __nTamPref )
				cNum := PADR( FO9->FO9_NUMDOC, __nTamNum )				
				
				aInfCliLj := PegaCliLj( cPrefix, cNum ) //Pega o cliente e loja do cupom de crédito ao quarto ou RPS
				
				cCliente := PADR( aInfCliLj[1], __nTamCli )
				cLoja := PADR( aInfCliLj[2], __nTamLoja )
				lCQ := aInfCliLj[3]
				
				//Procura o título do RPS/CFCQ na base e guarda no vetor para passar na execauto de cancelamento de baixa			
				SE1->( dbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->( MsSeek( FWxFilial("SE1") + cCliente + cLoja + cPrefix + cNum + cParcTitRPS + cTipoTitRPS ) )
					aAdd( aCab, {"E1_PREFIXO", cPrefix, NIL})
					aAdd( aCab, {"E1_NUM", cNum, NIL})
					aAdd( aCab, {"E1_PARCELA", cParcTitRPS, NIL})
					aAdd( aCab, {"E1_TIPO", cTipoTitRPS, NIL})
					aAdd( aCab, {"E1_CLIENTE", cCliente, NIL})
					aAdd( aCab, {"E1_LOJA", cLoja, NIL})
					
					//Pega a ultima sequência de baixa para cancelar
					cFK7Chave := FWxFilial( "SE1", SE1->E1_FILORIG ) + "|" +  cPrefix + "|" + cNum + "|" + cParcTitRPS + "|" + cTipoTitRPS + "|" + cCliente + "|" + cLoja
					cFK1Chave := FINBuscaFK7( cFK7Chave, "SE1" )
					nSeq := GetSeqBaixa( cFK1Chave )
				
					//Chama a execauto para cancelamento da baixa (nOpc = 5)
					MSExecAuto( {|x,y,z,a| FINA070(x,y,z,a)}, aCab, 5, , nSeq )
			
					If !lMsErroAuto
						lRet := .T.
						aSize( aCab, 0 )
						aCab := {}
					Else
						aErroAuto := GetAutoGRLog()
						lRet := .F.
						Exit
					Endif
					
					//Se cancelou a baixa e é título de cupom de crédito ao quarto, então também excluí o título (pois esse título foi a prória inclusão de fatura que criou) 
					If lRet .AND. lCQ
					
						//Exclui o título a receber criado na fatura
						lRet := F791ExcCR( @aErroAuto )
						
						If !lRet
							Exit
						Endif
					
					Endif
				Endif
					
				FO9->( dbSkip() )
			EndDo
			
		Endif
		
	Endif

	//Cancelamento das baixas dos títulos gerados na integração de DANFE sobre cupom para órgão público
	If lRet	
		cChaveFOC := aChave[2] + aChave[3] + aChave[4] + aChave[5]
		If FOC->( MsSeek( cChaveFOC ) )

			While FOC->( ! EOF() ) .AND. FOC->( FOC_FILIAL + FOC_NUMFAT + FOC_CLIFAT + FOC_LOJFAT ) == cChaveFOC
				//Pega os campos do RPS pra formar a chave do título a receber que o mesma gerou
				cPrefix := PADR( FOC->FOC_SERIE, __nTamPref )
				cNum := PADR( FOC->FOC_NUMDOC, __nTamNum )
				
				aInfCliNF := PegaCliNFe( cPrefix, cNum ) //Pega o cliente e loja da DANFE
				
				cCliente := PADR( aInfCliNF[1], __nTamCli )
				cLoja := PADR( aInfCliNF[2], __nTamLoja )
				
				//Procura o título do RPS na base e guarda no vetor para passar na execauto de cancelamento de baixa			
				SE1->( dbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->( MsSeek( FWxFilial("SE1") + cCliente + cLoja + cPrefix + cNum + cParcTitRPS + cTipoTitRPS ) )
					aAdd( aCab, {"E1_PREFIXO", cPrefix, NIL})
					aAdd( aCab, {"E1_NUM", cNum, NIL})
					aAdd( aCab, {"E1_PARCELA", cParcTitRPS, NIL})
					aAdd( aCab, {"E1_TIPO", cTipoTitRPS, NIL})
					aAdd( aCab, {"E1_CLIENTE", cCliente, NIL})
					aAdd( aCab, {"E1_LOJA", cLoja, NIL})
					
					//Pega a ultima sequência de baixa para cancelar
					cFK7Chave := FWxFilial( "SE1", SE1->E1_FILORIG ) + "|" +  cPrefix + "|" + cNum + "|" + cParcTitRPS + "|" + cTipoTitRPS + "|" + cCliente + "|" + cLoja
					cFK1Chave := FINBuscaFK7( cFK7Chave, "SE1" )
					nSeq := GetSeqBaixa( cFK1Chave )
				
					//Chama a execauto para cancelamento da baixa (nOpc = 5)
					MSExecAuto( {|x,y,z,a| FINA070(x,y,z,a)}, aCab, 5, , nSeq )
			
					If !lMsErroAuto
						lRet := .T.
						aSize( aCab, 0 )
						aCab := {}
					Else
						aErroAuto := GetAutoGRLog()
						lRet := .F.
						Exit
					Endif
				Endif
					
				FOC->( dbSkip() )
			EndDo
			
		Endif
		
	Endif

	RestArea( aAreaSE1 )
	aSize( aAreaSE1, 0 )
	aAreaSE1 := {}
	aSize( aInfCliLj, 0 )
	aInfCliLj := {}
	aSize( aInfCliNF, 0 )
	aInfCliNF := {}
	
Return lRet

/*/{Protheus.doc} F791FatHtl
Função para baixar os títulos gerados nas integrações de RPS e 
criação das parcelas da fatura no contas a receber

@param cCliente, Código do Cliente da fatura 
@param cLoja, Loja do cliente da fatura
@param aNota, Vetor com os RPS associados a fatura em questão
@param aTit, Vetor com os dados das parcelas que serão geradas no contas a receber
@param nComissao, Valor total de comissão descontada na fatura
@param cNumFat, Número da fatura
@param aTitChave, Vetor passado por referência para receber as chaves das parcelas inseridas no contas a receber

@return lRet, Indica se a baixa e as inclusões de parcelas foram efetuadas com sucesso

@author Pedro Alencar
@since 12/04/2016
@version P12.1.8
/*/
Static Function F791FatHtl( cCliente, cLoja, aNota, aTit, nComissao, cNumFat, aTitChave, aErroAuto )  
	Local lRet := .T.
	Local aAreaSE1 := {}
	Local aAreaSL1 := {}
	Local aAreaSL4 := {}
	Local aAreaSA1 := {}
	Local nI := 0
	Local aRecnoCR := {}
	Local aParcelasFT := {}
	Local cPrefixo := ""
	Local cNumero := ""
	Local cNatureza := SuperGetMv( "MV_HTLNAFT", .F. )
	Local cTipo := SuperGetMv( "MV_HTLFT", .F., "FT" )
	Local cPrefHtl := SuperGetMv( "MV_HTLPREF", .F. )
	Local cParcela := "A"
	Local cParcTitRPS := PADR( "A", __nTamParc )
	Local cTipoTitRPS := PADR( "FA", __nTamTipo )	
	Local cChaveVend := ""
	Local cNumSL1 := ""
	Local cNatFA := SuperGetMV( "MV_NATFATU", .F. )
	Local cChaveTit := ""
	Local nTitRec := 0
	Local lCFCQ := .F.
	Local cCliRPS := ""
	Local cLjCliRPS := ""
	Local cSerDANFE := ""
	Local cNumDANFE := ""
	
	Default cCliente := ""
	Default cLoja := ""
	Default aNota := {}
	Default aTit := {}
	Default nComissao := 0
	Default cNumFat := ""
	
	If Empty( cCliente ) .OR. Empty( cLoja ) .OR. Len( aTit ) <= 0 .OR. Len( aNota ) <= 0
		lRet := .F.
	Endif
	
	If lRet
		aAreaSL1 := SL1->( GetArea() )
		aAreaSL4 := SL4->( GetArea() )		
		aAreaSE1 := SE1->( GetArea() )
		aAreaSA1 := SA1->( GetArea() )
		SE1->( DbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		SL1->( dbSetOrder( 2 ) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		SL4->( dbSetOrder( 1 ) ) //L4_FILIAL+L4_NUM+L4_ORIGEM
		
		cCliente := PADR( cCliente, __nTamCli )
		cLoja := PADR( cLoja, __nTamLoja )
			
		For nI := 1 To Len( aNota )
			//Pega os campos do RPS pra formar a chave do título a receber que a mesma gerou
			cPrefixo := PADR( aNota[nI][3], __nTamPref ) //Série da RPS (L1_SERIE)
			cNumero := PADR( aNota[nI][4], __nTamNum ) //Número do documento (L1_DOC)
			
			//Verifica se é cupom fiscal CQ (crédito ao quarto) e, se for, cria o título do mesmo para geração da fatura (pois na integração desse tipo de cupom, não gera financeiro)
			lCFCQ := .F.
			cChaveVend := FWxFilial("SL1") + cPrefixo + cNumero
			If SL1->( MsSeek( cChaveVend ) )
				cCliRPS := PADR( SL1->L1_CLIENTE, __nTamCli )
				cLjCliRPS := PADR( SL1->L1_LOJA, __nTamLoja )
				cNumSL1 := SL1->L1_NUM
				If SL4->( MsSeek( FWxFilial("SL4") + cNumSL1 ) )
					If Upper( AllTrim( SL4->L4_FORMA ) ) == "CQ"
						lCFCQ := .T.
						
						//Verifica se o título já foi criado através da DANFE sobre Cupons para Empresa Pública
						If VerifCrEp( cPrefixo, cNumero, @nTitRec, @cSerDANFE, @cNumDANFE )
							
							//Verifica se o Recno do título da DANFE já está informado no array de Recnos para a baixa. Do contrário, adiciona no array.
							If Len( aRecnoCR ) == 0 .OR. AScan( aRecnoCR, {|x| x == nTitRec} ) == 0
								aAdd( aRecnoCR, nTitRec )										
							Endif
							
							//Adiciona as informações da DANFE no vetor de notas para, nesse caso de DANFE para órgão público, separar e não gravar os cupons na aba de documentos fiscais e sim a DANFE em outra aba da fatura
							aAdd( aNota[nI], cSerDANFE )
							aAdd( aNota[nI], cNumDANFE )
																								
						Else //Senão, cria o título e envia o recno para a baixa da fatura
							
							//Verifica se já existe um título com a chave que seria incluida para o título de CQ, com base no número e série do cupom
							cChaveTit := FWxFilial("SE1") + SL1->L1_CLIENTE + SL1->L1_LOJA + cPrefixo + cNumero + cParcTitRPS + cTipoTitRPS
							If SE1->( dbSeek( cChaveTit ) )
								lRet := .F.
								aAdd( aErroAuto, STR0021 + AllTrim( cChaveTit ) ) //"Não foi possível incluir o título de crédito ao quarto (CQ). Chave já existente: "
								Exit
							Endif
																			
							nTitRec := GeraFinCQ( cPrefixo, cNumero, cNatFA )
							aAdd( aRecnoCR, nTitRec )
																				
						Endif																							
					
					EndIf
				EndIf
			EndIf
			
			If !lCFCQ
				//Procura o título na base e guarda o RECNO			
				cChaveTit := FWxFilial("SE1") + cCliRPS + cLjCliRPS + cPrefixo + cNumero + cParcTitRPS + cTipoTitRPS
				If SE1->( dbSeek( cChaveTit ) )
					aAdd( aRecnoCR, SE1->( Recno() ) )
				Else
					lRet := .F.
					aAdd( aErroAuto, STR0019 + AllTrim( cChaveTit ) ) //"Título a receber não encontrado no Protheus: "
					Exit
				Endif
			Endif
			
		Next nI
		
		If lRet		
			//Monta o array de parcelas a serem geradas no contas a receber
			For nI := 1 To Len( aTit )			
				//                 {Prefixo,  Número,  Parcela,  Tipo,   Cliente,  Loja, Natureza,   Valor Bruto,            Decréscimo, Vencimento, Historioco} 
				aAdd( aParcelasFT, {cPrefHtl, cNumFat, cParcela, cTipo, cCliente, cLoja, cNatureza, aTit[nI, 1] + nComissao, nComissao, aTit[nI, 2],aTit[nI, 3]} )
				
				//Colaca a chave do titulo no vetor passado por referência, para vincular o titulo na gravação da fatura
				aAdd( aTitChave, {cFilAnt, cPrefHtl, cNumFat, cParcela, cTipo} )
				
				cParcela := Soma1( cParcela )
			Next nI
		
			//Chama a função para baixar os títulos dos RPS e gerar as parcelas definitivas da fatura
			lRet := FinFatAut( aRecnoCR, aParcelasFT, @aErroAuto )
		
			If !lRet
				aSize( aTitChave, 0 )
				aTitChave := {}
			Endif
		Endif
		
		RestArea( aAreaSL4 )
		RestArea( aAreaSL1 )		
		RestArea( aAreaSE1 )
		RestArea( aAreaSA1 )
		aSize( aRecnoCR, 0 )
		aRecnoCR := Nil
		aSize( aParcelasFT, 0 )
		aParcelasFT := Nil
		aSize( aAreaSE1, 0 )
		aAreaSE1 := Nil		
		aSize( aAreaSL1, 0 )
		aAreaSL1 := Nil
		aSize( aAreaSL4, 0 )
		aAreaSL4 := Nil
		aSize( aAreaSA1, 0 )
		aAreaSA1 := Nil
	Endif
	
Return lRet

/*/{Protheus.doc} GetSeqBaixa
Função para baixar os títulos gerados nas integrações de RPS e 
criação das parcelas da fatura no contas a receber

@param cFK1Chave, Chave da baixa na FK1 

@return nRet, Indica o sequenial da ultima baixa para a chave informada

@author Pedro Alencar
@since 13/04/2016
@version P12.1.8
/*/
Static Function GetSeqBaixa( cFK1Chave )
	Local nRet := 1
	Local cAliasFK1 := GetNextAlias()
	Local cQuery := ""
	
	cQuery := "SELECT MAX(FK1_SEQ) AS SEQ" + CRLF
	cQuery += " FROM " + RetSqlName("FK1") + CRLF
	cQuery += " WHERE " + CRLF 
	cQuery += " FK1_FILIAL = '" + FWxFilial("FK1") + "' AND " + CRLF
	cQuery += " FK1_IDDOC = '" + cFK1Chave + "' AND " + CRLF
	cQuery += " FK1_RECPAG = 'R' AND " + CRLF
	cQuery += " FK1_MOTBX = 'BFT' AND " + CRLF
	cQuery += " D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasFK1, .T., .T. )
	
	If ( cAliasFK1 )->( ! EOF() )
		nRet := Val( ( cAliasFK1 )->( SEQ ) )
	Else
		nRet := 1
	Endif
	
	If Select(cAliasFK1) > 0
		( cAliasFK1 )->( dbCloseArea() )
		FErase( ( cAliasFK1 ) + GetDBExtension() )
	EndIf
Return nRet

/*/{Protheus.doc} GeraFinCQ
Função para criar o título de um cupom fiscal com forma de pagamento CQ (Crédito ao quarto)
antes de criar a fatura de hotel 

@param cPrefixo, Prefixo do título (série do cupom)
@param cNumero, Número do título (Número da nota do cupom)
@param cNatFA, natureza do título

@author Pedro Alencar
@since 26/01/2017
@version P12.1.16
/*/
Static Function GeraFinCQ( cPrefixo, cNumero, cNatFA )
	Local nRet := 0
	Default cPrefixo := ""
	Default cNumero := ""
	Default cNatFA := ""
							
	//Gravação do título da forma como seria feito através do LOJXFUNC
	RecLock( "SE1", .T.)
	REPLACE SE1->E1_FILIAL	WITH FWxFilial("SE1")
	REPLACE SE1->E1_PREFIXO	WITH cPrefixo
	REPLACE SE1->E1_NUM		WITH cNumero
	REPLACE SE1->E1_PARCELA	WITH "A"
	REPLACE SE1->E1_TIPO		WITH "FA"
	REPLACE SE1->E1_CLIENTE	WITH SL1->L1_CLIENTE
	REPLACE SE1->E1_LOJA		WITH SL1->L1_LOJA
	REPLACE SE1->E1_NOMCLI	WITH Posicione( "SA1", 1, FWxFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA, "A1_NREDUZ" )
	REPLACE SE1->E1_NATUREZ	WITH cNatFA
	REPLACE SE1->E1_PORTADO	WITH SL1->L1_OPERADO
	REPLACE SE1->E1_AGEDEP 	WITH ".    "
	REPLACE SE1->E1_CONTA	WITH "."
	REPLACE SE1->E1_SITUACA	WITH "0"
	REPLACE SE1->E1_ORIGEM	WITH "FINI791"
	REPLACE SE1->E1_EMISSAO	WITH dDatabase
	REPLACE SE1->E1_EMIS1	WITH dDatabase
	REPLACE SE1->E1_VENCTO	WITH dDatabase
	REPLACE SE1->E1_VENCREA	WITH DataValida( dDatabase, .T. )
	REPLACE SE1->E1_VENCORI	WITH dDatabase
	REPLACE SE1->E1_VALOR	WITH SL4->L4_VALOR
	REPLACE SE1->E1_VLRREAL	WITH SL4->L4_VALOR
	REPLACE SE1->E1_VLCRUZ	WITH xMoeda( SL4->L4_VALOR, 1, 1, dDatabase )
	REPLACE SE1->E1_SALDO	WITH SL4->L4_VALOR
	REPLACE SE1->E1_MOEDA	WITH 1
	REPLACE SE1->E1_STATUS	WITH "A"
	REPLACE SE1->E1_SERIE	WITH cPrefixo
	REPLACE SE1->E1_FILORIG	WITH cFilAnt
	REPLACE SE1->E1_NUMNOTA	WITH cNumero
	REPLACE SE1->E1_HIST		WITH STR0020 //"TIT. P/ FATURA DE HOTEL"
	REPLACE SE1->E1_MULTNAT	WITH "2"
	REPLACE SE1->E1_FLUXO	WITH "S"
	REPLACE SE1->E1_CONHTL	WITH SL1->L1_RESEHTL	
	If cPaisLoc == "BRA"	
		REPLACE SE1->E1_IRRF WITH NoRound( SL1->L1_VALIRRF, 2 )
		REPLACE SE1->E1_PIS WITH NoRound( SL1->L1_VALPIS, 2 )
		REPLACE SE1->E1_COFINS WITH NoRound( SL1->L1_VALCOFI, 2 )
		REPLACE SE1->E1_CSLL WITH NoRound( SL1->L1_VALCSLL, 2 )	
	Endif
	SE1->( MsUnlock() )
	nRet := SE1->( Recno() )
Return nRet

/*/{Protheus.doc} PegaCliLj
Função para retornar o cliente e loja de um cupom/RPS e verficar se é cupom de crédito ao quarto (CQ) 

@param cSerie, série do cupom
@param cNumero, Número do cupom
@return aRet, Retorna o cliente e loja do RPS/cupom e se o mesmo é Crédito ao Quarto: aRet[1] = Código do cliente; aRet[2] = Loja do cliente; aRet[3] = .T. (é CQ) ou .F. (não é CQ)  

@author Pedro Alencar
@since 17/04/2017
@version P12.1.17
/*/
Static Function PegaCliLj( cSerie, cNumero )
	Local aRet := {}
	Local aAreaSL1 := SL1->( GetArea() )
	Local aAreaSL4 := SL4->( GetArea() )
	
	SL1->( dbSetOrder( 2 ) ) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
	If SL1->( MsSeek( FWxFilial("SL1") + cSerie + cNumero ) )
		aAdd( aRet, AllTrim( SL1->L1_CLIENTE ) )
		aAdd( aRet, AllTrim( SL1->L1_LOJA ) )
				
		SL4->( dbSetOrder( 1 ) ) //L4_FILIAL+L4_NUM+L4_ORIGEM		
		If SL4->( MsSeek( FWxFilial("SL4") + SL1->L1_NUM ) )
			If Upper( AllTrim( SL4->L4_FORMA ) ) == "CQ"
				aAdd( aRet, .T. )
			Else
				aAdd( aRet, .F. )
			Endif
		Else
			aAdd( aRet, .F. )
		Endif
	Else
		aAdd( aRet, "" )
		aAdd( aRet, "" )
		aAdd( aRet, .F. )
	Endif
	
	RestArea( aAreaSL4 )
	RestArea( aAreaSL1 )
	aSize( aAreaSL1, 0 )	
	aAreaSL1 := Nil
	aSize( aAreaSL4, 0 )
	aAreaSL4 := Nil
Return aRet

/*/{Protheus.doc} F791ExcCR
Função para excluir o título a receber posicionado 

@return lRet, Indica se o título foi excluído com sucesso  

@author Pedro Alencar
@since 17/04/2017
@version P12.1.17
/*/
Static Function F791ExcCR( aErroAuto )
	Local lRet := .F. 
	Local aCabTit := {}
	Local nY := 0
	Local cCampo := ""
	Local xConteudo := Nil
	
	aAdd(aCabTit, {"E1_PREFIXO", SE1->E1_PREFIXO, NIL})
	aAdd(aCabTit, {"E1_NUM"    , SE1->E1_NUM	  , NIL})
	aAdd(aCabTit, {"E1_PARCELA", SE1->E1_PARCELA, NIL})
	aAdd(aCabTit, {"E1_TIPO"   , SE1->E1_TIPO	  , NIL})
	aAdd(aCabTit, {"E1_NATUREZ", SE1->E1_NATUREZ, NIL})
	aAdd(aCabTit, {"E1_CLIENTE", SE1->E1_CLIENTE, NIL})
	aAdd(aCabTit, {"E1_LOJA"   , SE1->E1_LOJA	  , NIL})

	For nY := 1 to Len( aCabTit )
		cCampo := aCabTit[nY][1]
		xConteudo := aCabTit[nY][2]
		If ValType( xConteudo ) == "C"
			xConteudo := PADR( xConteudo, TamSX3(cCampo)[1] )
			aCabTit[nY][2] := xConteudo
		EndIf
	Next nY
	
	//Chamada da rotina automatica
	//5 = Exclusao
	MSExecAuto( {|x, y| FINA040(x, y)}, aCabTit, 5 )
	If !lMsErroAuto
		lRet := .T.
	Else
		aErroAuto := GetAutoGRLog()
		lRet := .F.
	Endif
	
	aSize( aCabTit, 0 )
	aCabTit := Nil			
Return lRet

/*/{Protheus.doc} F791ExcCP
Função para excluir o título a pagar posicionado 

@return lRet, Indica se o título foi excluído com sucesso  

@author Pedro Alencar
@since 17/04/2017
@version P12.1.17
/*/
Static Function F791ExcCP( aErroAuto )
	Local lRet := .F. 
	Local aCabTit := {}
	Local nY := 0
	Local cCampo := ""
	Local xConteudo := Nil
	
	aAdd(aCabTit, {"E2_PREFIXO", SE2->E2_PREFIXO, NIL})
	aAdd(aCabTit, {"E2_NUM"    , SE2->E2_NUM	  , NIL})
	aAdd(aCabTit, {"E2_PARCELA", SE2->E2_PARCELA, NIL})
	aAdd(aCabTit, {"E2_TIPO"   , SE2->E2_TIPO	  , NIL})
	aAdd(aCabTit, {"E2_NATUREZ", SE2->E2_NATUREZ, NIL})
	aAdd(aCabTit, {"E2_FORNECE", SE2->E2_FORNECE, NIL})
	aAdd(aCabTit, {"E2_LOJA"   , SE2->E2_LOJA	  , NIL})
	
	For nY := 1 to Len( aCabTit )
		cCampo := aCabTit[nY][1]
		xConteudo := aCabTit[nY][2]
		If ValType( xConteudo ) == "C"
			xConteudo := PADR( xConteudo, TamSX3(cCampo)[1] )
			aCabTit[nY][2] := xConteudo
		EndIf
	Next nY
	
	//Chamada da rotina automatica
	//5 = Exclusao
	MSExecAuto( {|x, y, z| FINA050(x, y , z )}, aCabTit, 5 , 5 )
	
	If !lMsErroAuto
		lRet := .T.
	Else
		aErroAuto := GetAutoGRLog()
		lRet := .F.
	Endif
	
	aSize( aCabTit, 0 )
	aCabTit := Nil
Return lRet

/*/{Protheus.doc} VerifCrEp
Função para verificar se o cupom está vínculado à uma DANFE e se tem título
a receber gerado para empresa pública 

@param cPrefDoc, Prefixo da nota a ser verificada
@param cNumDoc, Número da nota a ser verificada
@param nTitRec, Variável numérica informada por referência para retonar o Recno do título encontrado
@param cSerDANFE, Variável caractere informada por referência para retonar a série da DANFE
@param cNumDANFE, Variável caractere informada por referência para retonar o número da DANFE
@return lRet, Indica se o título foi excluído com sucesso  

@author Pedro Alencar
@since 19/05/2017
@version P12.1.17
/*/
Static Function VerifCrEp( cPrefDoc, cNumDoc, nTitRec, cSerDANFE, cNumDANFE )
	Local lRet := .F.
	Local aAreaMDL := MDL->( GetArea() )
	Local aAreaSE1 := SE1->( GetArea() )	
	Local cParcela := "A"
	Local cTipoTit := "FA"
	Local aCliNF := {}
	
	Default nTitRec := 0
	Default cSerDANFE := ""
	Default cNumDANFE := ""
	
	MDL->( DbSetOrder( 2 ) ) //MDL_FILIAL+MDL_CUPOM+MDL_SERCUP+MDL_NFCUP+MDL_SERIE 
	If MDL->( MsSeek( FWxFilial("MDL") + cNumDoc + cPrefDoc ) )		
		cSerDANFE := PADR( MDL->MDL_SERIE, __nTamPref )
		cNumDANFE := PADR( MDL->MDL_NFCUP, __nTamNum )
		
		aCliNF := PegaCliNFe( cSerDANFE, cNumDANFE )		
		cCliente := PADR( aCliNF[1], __nTamCli )
		cLoja := PADR( aCliNF[2], __nTamLoja )
										
		cParcela := PADR( cParcela, __nTamParc )
		cTipoTit := PADR( cTipoTit, __nTamTipo )
		
		SE1->( DbSetOrder( 2 ) ) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->( MsSeek( FWxFilial("SE1") + cCliente + cLoja + cSerDANFE + cNumDANFE + cParcela + cTipoTit ) )
			lRet := .T.
			nTitRec := SE1->( Recno() )
		Endif 	
	Endif
	
	RestArea( aAreaSE1 )
	RestArea( aAreaMDL )
	
	aSize( aAreaSE1, 0 )	
	aAreaSE1 := Nil
	aSize( aAreaMDL, 0 )	
	aAreaMDL := Nil
	aSize( aCliNF, 0 )	
	aCliNF := Nil
Return lRet

/*/{Protheus.doc} IniTamSX3
Inicia as variáveis estáticas com os tamanhos dos campos do título

@author Pedro Alencar
@since 19/05/2017
@version P12.1.17
/*/
Static Function IniTamSX3()
	__nTamPref := TamSX3("E1_PREFIXO")[1]
	__nTamNum := TamSX3("E1_NUM")[1]
	__nTamParc := TamSX3("E1_PARCELA")[1]
	__nTamTipo := TamSX3("E1_TIPO")[1]
	__nTamCli := TamSX3("E1_CLIENTE")[1]
	__nTamLoja := TamSX3("E1_LOJA")[1]	
Return Nil

/*/{Protheus.doc} PegaCliNFe
Função para retornar o cliente e loja de uma DANFE sobre cupons 

@param cSerie, série da DANFE
@param cNumero, Número da DANFE
@return aRet, Retorna o cliente e loja da DANFE: aRet[1] = Código do cliente; aRet[2] = Loja do cliente.  

@author Pedro Alencar
@since 19/05/2017
@version P12.1.17
/*/
Static Function PegaCliNFe( cSerie, cNumero )
	Local aRet := {}
	Local aAreaSF2 := SF2->( GetArea() )
	
	SF2->( dbSetOrder( 1 ) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->( MsSeek( FWxFilial("SF2") + cNumero + cSerie ) )
		aAdd( aRet, AllTrim( SF2->F2_CLIENTE ) )
		aAdd( aRet, AllTrim( SF2->F2_LOJA ) )
	Else
		aAdd( aRet, "" )
		aAdd( aRet, "" )
	Endif
	
	RestArea( aAreaSF2 )
	aSize( aAreaSF2, 0 )
	aAreaSF2 := Nil
Return aRet
