#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI070.CH"

Static cMarca   := ""
Static cInterId	:= ""	//Codigo externo utilizada no De/Para
Static cIdMsg   := "FINANCIALMANAGER"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI070

Funcao de integracao com o adapter EAI para recebimento do cadastro de
Administradora Financeira utilizando o conceito de mensagem unica.

@param		cXml          Vari�vel com conte�do XML para envio/recebimento.
@param		nTypeTrans    Tipo de transa��o. (Envio/Recebimento)
@param		cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author		Vendas Cliente
@version	P12
@since		06/10/2015
@return		lRet - (boolean)  Indica o resultado da execu��o da fun��o
			cXmlRet - (caracter) Mensagem XML para envio
			Nome do Adapter EAI
@Obs
/*/
//-------------------------------------------------------------------------------------------------
Function LOJI070(cXml, nTypeTrans, cTypeMsg)

	Local cError	:= ""  //Erros no XML
	Local cWarning	:= ""  //Avisos no XML
	Local cVersao	:= ""  //Versao da Mensagem
	Local cXmlRet	:= ""  //Mensagem de retorno da integracao
	Local lRet		:= .T. //Retorno da integracao
	Local oXmlLj070 := NIL

	Default cXml    := ""

	LjGrvLog("LOJI070", "ID_INICIO")

    If nTypeTrans == TRANS_RECEIVE
        oXmlLj070 := xmlParser(cXml, "_", @cError, @cWarning)

        //Validacoes de erro no XML
        If Valtype(oXmlLj070) == "O" .And. Empty(cError) .And. Empty(cWarning)

            //Validacao de versao
            If XmlChildEx(oXmlLj070:_TOTVSMessage:_MessageInformation, "_VERSION") <> Nil .And.;
                    !Empty(oXmlLj070:_TOTVSMessage:_MessageInformation:_version:Text)

                cVersao := StrTokArr(oXmlLj070:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]

                //Valida se versao implementada
                If cVersao $ "1|2"
                    v1000(oXmlLj070, cTypeMsg, @lRet, @cXmlRet, nTypeTrans)
                Else
                    lRet 	 := .F.
                    cXmlRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"
                EndIf
            Else
                lRet 	 := .F.
                cXmlRet := STR0002 //#"Versao da mensagem nao informada!"
            EndIf
        Else
            lRet 	 := .F.
            cXmlRet := STR0003 //#"Erro no parser!"
        EndIf

    ElseIf nTypeTrans == TRANS_SEND
        v1000(oXmlLj070, cTypeMsg, @lRet, @cXmlRet, nTypeTrans)

    Else
        lRet    := .F.
        cXmlRet := "Tipo de transa��o inv�lida."
    EndIf

	LjGrvLog("LOJI070", "ID_FIM")

Return {lRet, cXmlRet, cIdMsg}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI070

Rotina para processar a mensagem tipo RECEIVE e BUSINESS
Efetua a gravacao da Administradora Financeira

@param   oXmlLj070	Objeto contendo a mensagem (XML)
@param   cTypeMsg    	Tipo da mensagem
@param   lRet  		Indica o resultado da execu��o da fun��o
@param   cXmlRet  		Mensagem Xml para envio
@param   nTypeTrans	Tipo da transa��o

@author  Vendas Cliente
@version P12
@since   06/10/2015
@return  Nil

/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(oXmlLj070, cTypeMsg, lRet, cXmlRet, nTypeTrans)

	Local aArea	 	  := GetArea() 			//Armazena areas
	Local oXmlContent := Nil 				//Objeto Xml com o conteudo da BusinessContent apenas
	Local nI		  := 0

    //Mensagem de Recebimento
	If nTypeTrans == TRANS_RECEIVE

	    //Mensagem tipo Business
		If cTypeMsg == EAI_MESSAGE_BUSINESS
			lRet := LojI070Rec(oXmlLj070, @cXmlRet)	// Recebi as msgs de adm financeira
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
			lRet:= LojI070Res(oXmlLj070, @cXmlRet)
		ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
			cXmlRet := "1.000|2.002|2.003|2.004"
		EndIf

	ElseIf nTypeTrans == TRANS_SEND
	    //Mensagem tipo Business
		lRet := LojI070Env(oXmlLj070, @cXmlRet,@lRet)	// Envia as Tags da Adminstradora
	EndIf

    //Restaura areas
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Rec
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		Recebe o valor do InternalID do XML
@since   18/01/2017
@return  lRet 			Retorno l�gico
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Rec(oXmlLj070,cXmlRet)

	Local cEvent	:= ""	//Armazena o evento
	Local lRet		:= .T.
	Local lItemAtivo:= .T.	// Verifica se esta Ativa
	Local cValInt	:= ""	// InternalId
	conout(CHR(10)+CHR(13)+" LOG MENSAGEM UNICA 01")

    //Verifica se possui Marca
	If XmlChildEx(oXmlLj070:_TOTVSMessage:_MessageInformation:_Product, "_NAME") <> Nil .And.;
			!Empty(oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
		cMarca := oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text //Armazena marca
	Else
		lRet    := .F.
		cXmlRet := STR0018 //"O campo MARCA � obrigatorio"
	EndIf

    //Verifica se tem Evento
	If XmlChildEx(oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessEvent, "_EVENT") <> Nil .And.;
			!Empty(oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
		cEvent := Upper(oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) //Armazena evento
		lRet		:= .T.
	Else
		lRet    := .F.
		cXmlRet := STR0009 //#"O evento e obrigatorio"
	EndIf

	If lRet
	    //Efetua a carga do objeto InternalID
		oXmlContent := oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessContent
		If XmlChildEx(oXmlContent, "_INTERNALID") <> Nil .And. !Empty(oXmlContent:_InternalId:Text) //InternalId da Adm Fin.
			cInterId := oXmlContent:_InternalId:Text
		EndIf

	    //Valida se item esta ativo
		If XmlChildEx(oXmlContent, "_ACTIVE") <> Nil .And. !Empty(oXmlContent:_Active:Text)
			lItemAtivo := AllTrim(Upper(oXmlContent:_Active:Text)) == "TRUE"
		EndIf

	    //Se item inativo, evento sera delete
		If !lItemAtivo
			cEvent := "DELETE"
		EndIf

        //Verifica qual o ID da mensagem
		If XmlChildEx(oXmlLj070:_TOTVSMessage:_MessageInformation, "_TRANSACTION") <> Nil .AND.;
				!Empty(oXmlLj070:_TOTVSMessage:_MessageInformation:_Transaction:Text)
			cIdMsg := AllTrim(Upper(oXmlLj070:_TOTVSMessage:_MessageInformation:_TRANSACTION:Text))
			conout(CHR(10)+CHR(13)+" LOG MENSAGEM UNICA 1-5 : ",cIdMsg)
		EndIf
		conout(CHR(10)+CHR(13)+" LOG MENSAGEM UNICA 02")

	    //Se o evento Upsert
		If cEvent == "UPSERT"
			lRet := LojI070Upd(oXmlContent,@cXMLRet,@cValInt)
		ElseIf cEvent == "DELETE" //Se o evento Delete
			lRet := LojI070Del(oXmlContent,@cXMLRet,@cValInt)
		EndIf

	    //Valida se continua e pega o retorno
		If lRet
			cXMLRet := LojI070Ret(cValInt)
		EndIf
	EndIf
Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Upd
Retorno final do XML para a mensagem unica
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		Recebe o valor do InternalID do XML
@since   18/01/2017
@return  lRet 			Retorno l�gico
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Upd(oXmlContent,cXMLRet,cValInt)

	Local aAux		:= {}	//Array auxiliar no De-Para
	Local aRet		:= {}	//Retorno da integra��o
	Local lRet		:= .T.
	Local cCodigo	:= ""	//Codigo da Adm. Fin
	Local aRates    := {}	//Array de Taxas

	If cIdMsg == "FINANCIALMANAGER"

		conout(CHR(10)+CHR(13)+" LOG MENSAGEM UNICA 03")

		aAux := IntAdmFinInt(cInterId,  cMarca, /*Versao*/) 	//Tratamento utilizando a tabela XXF com um De/Para de codigos

	//Extrai todos os campos do XML
		aAux := LojI070Adm(oXmlContent, @cXMLRet, aRates, aAux)
		If !Empty(cXMLRet)
			lRet := .F. // Problemas de validacao
		Else
			aRet	:= LojI070Atu(aAux, 0 ,aRates)	// Inclui ou altera o registro na tabela
			lRet	:= aRet[1]
			cXMLRet := aRet[2]
			cValInt := IntAdmFinExt(/*Empresa*/, /*Filial*/, aAux[1][2], /*Vers�o*/)[2]


			If lRet
			//Grava na Tabela XXF (de/para)
				lRet := CFGA070Mnt(cMarca, "SAE", "AE_COD", cInterId, cValInt)
				If !lRet
					cXMLRet := STR0008 //#"Erro na integracao do De-Para de Forma de Pagamento"
				EndIf
			EndIf

		EndIf
	Else
		lRet := .F.
		cXmlRet := STR0019 //" Tag TRANSACTION n�o � (FINANCIALMANAGER) "
	EndIf

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Del
Retorno final do XML para a mensagem unica
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		recebe o valor do InternalID do XML
@since   18/01/2017
@return  aRet 		Todas os campos das mensagens
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Del(oXmlContent,cXMLRet,cValInt)
	Local lRet			:= .T.
	Local aAux			:= {}	//Array auxiliar no De-Para
	Local aRet			:= {}	//Retorno da integra��o
	Local cCodigo		:= ""
	Local aRates    	:= {}	//Array de Taxas

	If cIdMsg == "FINANCIALMANAGER"

		aAux := IntAdmFinInt(cInterId,  cMarca, /*Versao*/) 	//Tratamento utilizando a tabela XXF com um De/Para de codigos

	// Extrai todos os campos do XML
		aAux := LojI070Adm(oXmlContent, @cXMLRet, aRates)
		If Empty(aAux[1][2])
			lRet := .F. // Problemas de validacao

		Else
			aRet	:= LojI070Atu(aAux, 5,aRates)	// Exclui o registro na tabela
			lRet	:= aRet[1]
			cXMLRet := aRet[2]

			cValInt := IntAdmFinExt(/*Empresa*/, /*Filial*/, aAux[1][2], /*Vers�o*/)[2]

			If lRet
			//Grava na Tabela XXF (de/para)
				lRet := CFGA070Mnt(cMarca, "SAE", "AE_COD", cInterId, cValInt)
				If !lRet
					cXMLRet := STR0008 //#"Erro na integracao do De-Para de Forma de Pagamento"
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
		cXmlRet := STR0019 //" Tag TRANSACTION n�o � (FINANCIALMANAGER) "
	EndIf
Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Ret
Retorno final do XML para a mensagem unica
@param   cValInt	valor recebido na tag internalId
@since   18/01/2017
@return  cXMLRet 	Mensagem retornada para o EAI
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Ret(cValInt)
	Local cXMLRet := ""

	cXMLRet := "<ListOfInternalId>"
	cXMLRet +=    "<InternalId>"
	cXMLRet +=       "<Name>PaymentMethodInternalId</Name>"
	cXMLRet +=       "<Origin>"+cInterId+ "</Origin>"
	cXMLRet +=       "<Destination>"+cValInt+"</Destination>"
	cXMLRet +=    "</InternalId>"
	cXMLRet += "</ListOfInternalId>"
Return(cXMLRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntAdmFinInt

Recebe um InternalID e retorna a Administradora Financeira Protheus

@param   cInternalID	InternalID recebido na mensagem
@param   cRefer    	Produto que enviou a mensagem
@param   cVersao  		Vers�o da mensagem �nica (Default 1.000)

@author  Vendas Cliente
@version P12
@since   17/12/2015
@return  Array contendo no primeiro par�metro uma vari�vel logica
		  indicando se o registro foi encontrado no de/para
		  No segundo par�metro uma vari�vel array com empresa, filial
		  e a Adm. Financeira.

/*/
//-------------------------------------------------------------------------------------------------
Function IntAdmFinInt(cInternalID, cRefer, cVersao)

	Local aResult  := {}
	Local aTemp    := {}
	Local cTemp    := ""
	Local cAlias   := "SAE"
	Local cField   := "AE_COD"

	Default cVersao  := "1.000"

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

	If Empty(cTemp)
		aAdd(aResult, .F.)
		aAdd(aResult, STR0020 + " " + AllTrim(cInternalID) + " " + STR0013) //#"Administradora financeira" ##"nao encontrada no de/para!"
	Else
		If cVersao $ "1.000|2.002"
			aAdd(aResult, .T.)
			aTemp := Separa(cTemp, "|")
			aAdd(aResult, aTemp)
		Else
			aAdd(aResult, .F.)
			aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000|2.002") //#"Versao nao suportada." ##"As versoes suportadas sao:"
		EndIf
	EndIf

Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntAdmFinExt

Monta o InternalID da Administradora Financeira de acordo com codigo passado

@param   cEmpresa	Codigo da empresa (Default cEmpAnt)
@param   cFil    	Codigo da Filial (Default xFilial)
@param   cAdmFin  Codigo de Barras
@param   cVersao  Versao da Mensagem

@author  Vendas Cliente
@version P12
@since   17/12/2015
@return  Array contendo no primeiro par�metro uma vari�vel logica
		  indicando se o registro foi encontrado
		  No segundo par�metro uma vari�vel string com o InternalID
		  montado

/*/
//-------------------------------------------------------------------------------------------------
Function IntAdmFinExt(cEmpresa, cFil, cCodigo, cVersao)

	Local aResult := {}

	Default cEmpresa 	:= cEmpAnt
	Default cFil     	:= xFilial("SAE")
	Default cCodigo		:= ""
	Default cVersao		:= "1.000"

	If cVersao $ "1.000|2.002"
		aAdd(aResult, .T.)
		aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|"  + RTrim(cCodigo))
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000|2.002") //#"Versao nao suportada." ##"As versoes suportadas sao:"
	EndIf

Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Adm
Retorna os campos do XML da AdmFinanceira
@param   oXmlContent	XML recebido da Mensagem Unica
@param   cXMLRet 		Mensagem retornada para o EAI
@since   18/01/2017
@return  aRet 		Todas os campos das mensagens
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Adm(oXmlContent, cXMLRet, aRates, aIntId)

	Local aRet	 	:= {}
	Local nI   		:= 0
	Local cValInt	:= "" //Codigo interno utilizada no De/Para de codigos - Tabela XXF
	Local cFormaPg  := "" //Forma de pagamento recebida na mensagem
	Local aAux		:= {} //Array Auxiliar para armazenar Internald
	Local aAuxInt   := {} //Array Auxiliar para armazenar Internald
	Local cNum       := "" //Numero da Adm Financeria
	Local cNetworkDe := "" //C�digo da Administradora Financeira que vem na tag NetworkDestination da mensagem FinancialManager
	Local cAdmFinan  := "" //C�digo da Administradora Financeira da tabela XX5 (L9)

	Default aRates   := {}
	Default aIntId   := {} //Array com Internald encontrado

	If Len(aIntId) >= 2 .AND.  aIntId[1]
		cNum := Padr(aIntId[2][3], TamSx3("AE_COD")[1])
		LjGrvLog("LOJI70", "Encontrou Adm.Fin: " + cNum + " Na tabela de De/Para."  )
	Else
		cNum := GETSXENUM("SAE","AE_COD") //Pega proximo numero disponivel)
		LjGrvLog("LOJI70", "Nova Adm.Fin: " + cNum + " GETSXENUM."  )
	EndIf

    //Valida falhas nas tabelas ex Filho "MEN" sem Pai "SAE".
	LjI070Valid(cNum)

	Aadd(aRet,{"AE_COD"		,cNum, NIl}) //1
	Aadd(aRet,{"AE_DESC"	,"", NIl})	 //2
	Aadd(aRet,{"AE_FINPRO"	,"", NIl}) 	 //3
	Aadd(aRet,{"AE_TIPO"	,"", NIl})	 //4
	Aadd(aRet,{"AE_TAXA"	,0 , NIl}) 	 //5
	Aadd(aRet,{"AE_DIAS"	,0 , NIl}) 	 //6
	Aadd(aRet,{"AE_VENCTO"	,0 , NIl}) 	 //7
	Aadd(aRet,{"AE_REDE"	,"", NIl}) 	 //8
	Aadd(aRet,{"AE_ADMCART"	,"", NIl}) 	 //9

    //Descricao da adm financeira
	If XmlChildEx(oXmlContent, "_FINANCIALDESCRIPTION") <> Nil .And. !Empty(oXmlContent:_FinancialDescription:Text)
		aRet[2][2] := oXmlContent:_FINANCIALDESCRIPTION:Text
	Else
		lRet	 := .F.
		cXmlRet := STR0022 //"Descri��o da Administradora n�o informado"
	EndIf

    //Financiamento proprio
	If XmlChildEx(oXmlContent, "_FINANCIALINSTITUTE") <> Nil .And. !Empty(oXmlContent:_FinancialInstitute:Text)
		aRet[3][2] := IIF(oXmlContent:_FINANCIALINSTITUTE:Text == "1", "S", "N")
	Else
		lRet    := .F.
		cXmlRet := STR0023 //"Financiamento proprio (FINANCIALINSTITUTE) nao informado"
	EndIf

    //Tipo/Forma de pagamento
    If XmlChildEx(oXmlContent, "_PAYMENTMETHODINTERNALID") <> Nil .And. !Empty(oXmlContent:_PaymentMethodInternalId:Text)
        cFormaPg := Lji070TiPa(cMarca, oXmlContent:_PaymentMethodInternalId:Text, .F.)
    EndIf

    If Empty(cFormaPg) .And. XmlChildEx(oXmlContent, "_PAYMENTMETHODCODE") <> Nil .And. !Empty(oXmlContent:_PaymentMethodCode:Text)
        cFormaPg := Lji070TiPa(cMarca, oXmlContent:_PaymentMethodCode:Text, .T.)
    EndIf

    If !Empty(cFormaPg)
        aRet[4][2] := cFormaPg
    Else
        aRet	:= {}
        cXmlRet := I18n(STR0032, {"PaymentMethodCode", "PaymentMethodInternalId"})  //"Tipo de Pagamento n�o encontrado. Verifique as TAGs: #1 e #2"
        LjGrvLog("LOJI70", cXmlRet)
        Return(aRet)
    EndIf

    //Taxa da adm financeira
	If XmlChildEx(oXmlContent, "_RATE") <> Nil .And. !Empty(oXmlContent:_Rate:Text)
		aRet[5][2] :=	Val(StrTran(oXmlContent:_RATE:Text, ",", "."))
	EndIf

    //Dias para pagamento
	If XmlChildEx(oXmlContent, "_DAYSSUM") <> Nil .And. !Empty(oXmlContent:_DaysSum:Text)
		aRet[6][2] := Val(oXmlContent:_DAYSSUM:Text)
	EndIf

    //Vencimento
	If XmlChildEx(oXmlContent, "_PAYDAY") <> Nil .And. !Empty(oXmlContent:_PayDay:Text)
		aRet[7][2] := Val(oXmlContent:_PayDay:Text)
	EndIf

	//Rede de Destino
	If XmlChildEx(oXmlContent, "_NETWORKDESTINATION") <> Nil .And. !Empty(oXmlContent:_NetworkDestination:Text)
		cNetworkDe := AllTrim(oXmlContent:_NetworkDestination:Text)
		cValInt := CFGA070INT(cMarca , "SX5", "X5_CHAVE", cNetworkDe) // XXF (de/para)

		If Empty(cValInt)
			cAdmFinan := GetAdmFin(cNetworkDe) // Tenta encontrar a Adm Financ na SX5 (L9)

			If Empty(cAdmFinan)
				If ExistFunc("LjxjAdmFin")
					If LjxjAdmFin(cNetworkDe)
						cAdmFinan := GetAdmFin(cNetworkDe)

						If !Empty(cAdmFinan)
							LjGrvLog("LOJI70", "Rede Destino Encontrado SX5 (L9): " + cAdmFinan)
							aRet[8][2] := Padr(cAdmFinan, TamSx3("AE_REDE")[1])
						EndIf

					Else

						cXMLRet := "O conte�do da tag <NETWORKDESTINATION> "+cNetworkDe+" n�o foi encontrado na tabela L9 da SX5 e nem o equivalente DE/Para da tabela XXF"
						LjGrvLog("LOJI70", cXMLRet)
						aRet := {}
						Return(aRet)

					EndIf
				EndIf

			Else

				LjGrvLog("LOJI70", "Rede Destino Encontrado SX5 (L9): " + cAdmFinan)
				aRet[8][2] := Padr(cAdmFinan, TamSx3("AE_REDE")[1])

			EndIf
		Else
			aAuxInt := Separa(cValInt, "|")
			If ValType(aAuxInt) == "A" .And. Len(aAuxInt) > 3
				If AllTrim(aAuxInt[3]) == "L9"
					LjGrvLog("LOJI70", "Rede Destino Encontrado no DE/Para XXF : " + aAuxInt[4])
					aRet[8][2] := Padr(aAuxInt[4], TamSx3("AE_REDE")[1])
				EndIf
			EndIf
		EndIf

		If Len(aRet[8][2]) > TamSx3("AE_REDE")[1]
			cXMLRet := "Administradora financeira "+aRet[8][2]+" tem mais car�cteres que o campo AE_REDE da tabela SAE. Favor alterar o tamanho do campo AE_REDE da tabela SAE para prosseguir."
			LjGrvLog("LOJI70", cXMLRet)
			aRet := {}
			Return(aRet)
		EndIf

	EndIf

    //Bandeira do Cartao
	If XmlChildEx(oXmlContent, "_FLAGDESTINATION") <> Nil .And. !Empty(oXmlContent:_FlagDestination:Text)

		cValInt :=  CFGA070INT( cMarca , "MDE", "MDE_CODIGO", oXmlContent:_FlagDestination:Text )

		If Empty(cValInt)
			lRet	 := .F.
			LjGrvLog("LOJI70", "Bandeira Destino n�o encontrado no DE/Para XXF : cValInt." + cValInt  )
			cXMLRet := "Bandeira Destino n�o encontrado no DE/Para XXF : cValInt." + cValInt
			aRet	:= {}
			Return(aRet)
		Else
			aAuxInt := Separa(cValInt, "|")

			If ValType(aAuxInt) == "A" .And. Len(aAuxInt) > 2
				LjGrvLog("LOJI70", "Bandeira Destino Encontrado no DE/Para XXF : " + aAuxInt[3]  )
				aRet[9][2] := Padr(aAuxInt[3], TamSx3("AE_ADMCART")[1])
			EndIf
		EndIf
	EndIf

	LjGrvLog("LOJI70", "Adm. Financeira SAE. aRet.", aRet )

    //Preenchimento de Parcelas e Taxas
	If XmlChildEx(oXmlContent,"_LISTOFRATESPARCEL") <> Nil .AND. XmlChildEx(oXmlContent:_LISTOFRATESPARCEL, "_GENERICRATE") <> Nil

		LjGrvLog("LOJI70", "Encontrou tag LISTOFRATESPARCEL." )

		If ValType(oXmlContent:_LISTOFRATESPARCEL:_GENERICRATE) <> "A"
			XmlNode2Arr(oXmlContent:_LISTOFRATESPARCEL:_GENERICRATE, "_GENERICRATE" )
		EndIf

		If Len(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE) > 0

			LjGrvLog("LOJI70", "Recebeu lista de taxas" )

			For nI:=1 To Len(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE)
				aadd(aAux,{"MEN_ITEM"	, StrZero(Val(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE[nI]:_RATESPARCELITEM:TEXT),3)	, Nil } )	//Item
				aadd(aAux,{"MEN_DESC"	, OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE[nI]:_RATESPARCELDESCRIPTION:TEXT			, Nil } ) 	//Descri��o dos Juros
				aadd(aAux,{"MEN_PARINI"	, Val(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE[nI]:_RATESPARCELPARCELMIN:TEXT)		, Nil } ) 	//Parcelas M�nimas
				aadd(aAux,{"MEN_PARFIN"	, Val(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE[nI]:_RATESPARCELPARCELMAX:TEXT)		, Nil } ) 	//Parcelas M�ximas
				aadd(aAux,{"MEN_TAXJUR"	, Val(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE[nI]:_RATESPARCELTAX:TEXT)				, Nil } ) 	//Taxa de Juros
				aadd(aAux,{"MEN_TAXADM"	, Val(OXMLCONTENT:_LISTOFRATESPARCEL:_GENERICRATE[nI]:_RATESPARCELTAXADM:TEXT)			, Nil } )	//Taxa da Administradora

			    //Adicionado LINPOS E AUTDELTA obrigatorio para alteracao com MVC
				DbSelectArea("MEN")
				DbSetOrder(1) //MEN_FILIAL+MEN_ITEM+MEN_CODADM
				If MEN->(dbSeek(xFilial("MEN") + aAux[1][2] + cNum ))
					aadd(aAux, {"LINPOS","MEN_ITEM" ,aAux[1][2]})
					aadd(aAux, {"AUTDELETA","N",Nil})
					LjGrvLog("LOJI70", "Altera��o de Item", nI )
				EndIf

				aadd(aRates, Aclone(aAux)  )
				LjGrvLog("LOJI70", "Encontrou registro para Incluir/Alterar. aAux",aAux )
				aAux := {}
			Next nI

			DbSelectArea("MEN")
			DbSetOrder(2) //MEN_FILIAL+MEN_CODADM
			If MEN->(dbSeek(xFilial("MEN") + cNum ))

				While !Eof() .AND. MEN->MEN_CODADM == cNum

					If aScan(aRates, {|x| AllTrim(x[1][2]) == AllTrim(MEN->MEN_ITEM) }) <= 0
						aadd(aAux, {"MEN_ITEM"		, MEN->MEN_ITEM	, Nil})
						aadd(aAux, {"MEN_CODADM"	, cNum	, Nil})
						aadd(aAux, {"LINPOS","MEN_ITEM" ,MEN->MEN_ITEM})
						aadd(aAux, {"AUTDELETA"		, "S"	, Nil})

						aadd(aRates, Aclone(aAux)  )
						LjGrvLog("LOJI70", "Encontrou registro para deletar. aAux",aAux )
						aAux := {}
					Else
						LjGrvLog("LOJI70", "Item " +  AllTrim(MEN->MEN_ITEM) +  " n�o ser� marcado para dele��o. C�d.Adm: " + AllTrim("MEN->MEN_CODADM") )
					EndIf

					MEN->(DbSkip())
				End
			Else
				LjGrvLog("LOJI70", "N�o encontrou taxas gravadas para essa Adm." )
			EndIf
		Else
			LjGrvLog("LOJI70", "Lista de taxas n�o informada." )
		Endif

	Endif

Return(aRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Atu
Inclui/Altera ou exclui o registro da administradora financeira.

@param   oXmlContent - XML recebido da Mensagem Unica
@param   cXMLRet - Mensagem retornada para o EAI
@since   02/02/2017
@return  lRet - .T.->Opera��o realizada com sucesso / .F.->N�o realizada com sucesso
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Atu(aRet,nOpcAuto,aRates)
	Local lRet		:= .F.
	Local cErro		:= ""
	Local aAutoCab	:= {}
	Local nPosCod	:= aScan(aRet, {|x| AllTrim(x[1]) == "AE_COD"})

	Default nOpcAuto	:= 0	//Se for zero � ser� inclusao ou altera��o
	Default aRates    := {}	//Array de Taxas

	Private lMsErroAuto := .F.	//Necess�rio para verificar possivel erro no ExecAuto

    /* Possiveis valres de nOpcAuto:
        0 - Verificar se � inclus�o ou altera��o.
        3 - Incluir
        4 - Alterar
        5 - Excluir
    */
    //Verificar se � inclusao ou altera��o
	If nOpcAuto == 0 .And. nPosCod > 0 .And. !Empty(aRet[nPosCod][2])

		DbSelectArea("SAE")
		SAE->(DbSetOrder( 1 )) //AE_FILIAL+AE_COD
		If SAE->(MsSeek( xFilial( "SAE" ) + aRet[nPosCod][2] ))
			nOpcAuto := 4
		Else
			nOpcAuto := 3
		EndIf
	EndIf

	LjGrvLog("LOJI70", "Opera��o a ser realizada nOpcAuto ",nOpcAuto )

	aAutoCab 	:= aClone(aRet)
	aAutoItens	:= aClone(aRates)

	Begin Transaction

		MsExecAuto({|a,b,c| LojA070(a,b,c)},aAutoCab,aRates,nOpcAuto)

		lRet := !lMsErroAuto

		If lMsErroAuto
			cErro := AllTrim(MostraErro(IIF( IsBlind(), "\", "")))
			cErro := _NoTags(cErro)
			LjGrvLog("LOJI70", "Ocorreu erro na transacao de gravacao SAE da integra��o")
			LjGrvLog("LOJI70", "Erro:" + iif(!Empty(cErro), cErro, "N�o identificado.") )
			Conout( cErro )
			RollBackSX8()
			DisarmTransaction()
		Else
			ConfirmSX8()
			LjGrvLog("LOJI70", "Opera��o realizada com sucesso" )
		EndIf

	End Transaction

Return {lRet, cErro}


//--------------------------------------------------------
/*/{Protheus.doc} LjI070Valid
//Valida falhas nas tabelas ex Filho "MEN" sem Pai "SAE".
@type       function
@param   	cCodAdm		Codigo da Adm. Financeira
@author  	rafael.pessoa
@since   	26/04/2018
@version 	P12
@return  	Nil
/*/
//--------------------------------------------------------
Static Function LjI070Valid(cCodAdm)

	Default cCodAdm    	:= ""	//Codigo da Adm. Financeira

	If !Empty(cCodAdm)

		LjGrvLog("LOJI70", "Avalia integridade PAI>FILHO Adm.Fin:  " + cCodAdm + " se tiver Taxa sem Adm deleta taxas para conseguir realizar novo cadastro."  )

	//Se n�o achou Adm.FIn("SAE") mas achou as taxas ("MEN")
	//apaga as taxas pois as mesmas n�o devem existir sem a ADM e serao readicionadas.
		DbSelectArea("SAE")
		SAE->(DbSetOrder( 1 )) //AE_FILIAL+AE_COD
		If !SAE->(MsSeek( xFilial( "SAE" ) + cCodAdm ))
			DbSelectArea("MEN")
			DbSetOrder(2) //MEN_FILIAL+MEN_CODADM
			If MEN->(dbSeek(xFilial("MEN") + cCodAdm ))
				RecLock("SAE",.T.)
				SAE->AE_FILIAL = xFilial("SAE")
				SAE->AE_COD = cCodAdm
				SAE->(MsUnlock())
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Rec
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		Recebe o valor do InternalID do XML
@since   18/01/2017
@return  lRet 			Retorno l�gico
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Env(oXmlLj070,cXmlRet,lRet)

	Local cEntity := "FINANCIALMANAGER"
	Local cEvent  :=  "UPSERT"
	Local nQtd	  := 0

	If !ALTERA .AND. !INCLUI
		cEvent  :=  "DELETE"
	Endif

// Monta XML de envio de mensagem unica
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
	cXMLRet +=    '<Event>'  + cEvent  + '</Event>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
	cXMLRet +=    '<FinancialManager>'          + SAE->AE_COD                                                   + '</FinancialManager>'
	cXMLRet +=    '<InternalId>'                + IntAdmFinExt(CEMPANT, CFILANT, SAE->AE_COD, /*Vers�o*/)[2]    + '</InternalId>'
	cXMLRet +=    '<FinancialDescription>'      + ALLTRIM(SAE->AE_DESC)                                         + '</FinancialDescription>'
	cXMLRet +=    '<FinancialInstitute>'        + '1'                                                           + '</FinancialInstitute>'
	cXMLRet +=    '<Rate>'                      + cValToChar(SAE->AE_TAXA)                                      + '</Rate>'
	cXMLRet +=    '<PaymentMethodCode>'         + SAE->AE_TIPO                                                  + '</PaymentMethodCode>'
    cXMLRet +=    '<PaymentMethodInternalId>'   + IntFmPgtExt(/*Empresa*/, /*Filial*/, SAE->AE_TIPO, /*Vers�o*/)[2] + '</PaymentMethodInternalId>'
	cXMLRet +=    '<DaysSum>'                   + cValToChar(SAE->AE_DIAS)                                          + '</DaysSum>'
	cXMLRet +=    '<PayDay>'                    + cValToChar(SAE->AE_VENCTO)                                        + '</PayDay>'
	cXMLRet +=    '<NetworkDestination>'        + SAE->AE_REDE                                                      + '</NetworkDestination>'
	cXMLRet +=    '<FlagDestination>'           + SAE->AE_ADMCART                                                   + '</FlagDestination>'

	DbSelectArea("MEN")
	MEN->(DbSetOrder(2))
	If MEN->(DbSeek(xFilial("MEN")+SAE->AE_COD))
		cXMLRet +=    '<ListOfRatesParcel>'
		While MEN->(!eOF()) .AND. MEN->MEN_CODADM == SAE->AE_COD
			nQtd++
			cXMLRet +=    '		<GenericRate> '
			cXMLRet +=    '			<RatesParcelItem>'+ cValToChar(nQtd) +'</RatesParcelItem>'
			cXMLRet +=    '			<RatesParcelDescription>'+ALLTRIM(MEN->MEN_DESC) +'</RatesParcelDescription>'
			cXMLRet +=    '			<RatesParcelParcelmin>'+ cValToChar(MEN->MEN_PARINI) +'</RatesParcelParcelmin>'
			cXMLRet +=    '			<RatesParcelParcelmax>'+ cValToChar(MEN->MEN_PARFIN) +'</RatesParcelParcelmax>'
			cXMLRet +=    '			<RatesParceltax>'+ cValToChar(MEN->MEN_TAXJUR) +'</RatesParceltax>'
			cXMLRet +=    '			<RatesParceltaxadm>'+ cValToChar(MEN->MEN_TAXADM) +'</RatesParceltaxadm>'
			cXMLRet +=    '		</GenericRate> '
			MEN->(DbSkip())
		Enddo
		cXMLRet +=    '</ListOfRatesParcel>'
	Else
		cXMLRet +=    '<ListOfRatesParcel/>'
	Endif
	cXMLRet += '</BusinessContent>'

	lRet    := .T.

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Res
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Processa o Response
@param   cValInt 		Recebe o valor do InternalID do XML
@since   18/01/2017
@return  lRet 			Retorno l�gico
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Res(oXmlLj070,cXmlRet)

Local cError := ""
Local lRet	 := .T.
lOCAL nI	 := 0

	//Gravacao do De/Para Codigo Interno X Codigo Externo
	If Upper(AllTrim(oXmlLj070:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text)) == "OK"
		If oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text <> Nil .And.	!Empty(oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
			cMarca := oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		EndIf

		If oXmlLj070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text <> Nil .And.;
				!Empty(oXmlLj070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)

			cValInt := oXmlLj070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
		EndIf

		If oXmlLj070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text <> Nil .And.;
				!Empty(oXmlLj070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)

			cValExt := oXmlLj070:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
		EndIf

		If !Empty(cValExt) .And. !Empty(cValInt)
			If !CFGA070Mnt(cMarca, "SAE", "AE_COD", cValExt, cValInt)
				lRet := .F.
				cXmlRet := STR0029 //"N�o foi poss�vel gravar/excluir na tabela De/Para."
			EndIf
		Else
			cXmlRet := STR0030 //"Valor Interno ou Externo em branco, n�o ser� poss�vel gravar na tabela De/Para."
			lRet := .F.
		EndIf
	Else //Erro
		If oXmlLj070:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message <> Nil
   				//Se n�o for array
			If ValType(oXmlLj070:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) <> "A"
          			//Transforma em array
				XmlNode2Arr(oXmlLj070:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
			EndIf

          		//Percorre o array para obter os erros gerados
			For nI := 1 To Len(oXmlLj070:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
				cError := oXmlLj070:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text
			Next nI
		EndIf
		lRet 	 := .F.
		cXmlRet  := cError
	EndIf
Return lRet

//-------------------------------------------------------
/*/{Protheus.doc} Lji070TiPa
Retorna o tipo de pagamento, tenta localizar utilizando o de\para
caso n�o encontre, tenta direto na tabela SX5 - 24

@param   cMarca     - Referecia da XXF
@param   cTipPagExt - InternalId do outro sistema
@param   lTipoPag   - Define se tentar localizar o tipo de pagamento direto na tabela SX5 - 24
@return  cFormaPag  - C�digo do tipo de pagamento
@author  Rafael Tenorio da Costa
@since   18/02/2019
@version 1.0
/*/
//-------------------------------------------------------
Function Lji070TiPa(cMarca, cTipPagExt, lTipoPag, cMsgRET)
Local aArea      := GetArea()
Local aAreaSX5   := SX5->( GetArea() )
Local cFormaPag  := ""
Local cValInt    := ""
Local aAuxInt    := {}
Local cQry		 := ""
Local cAls		 := "PQAETMP"
Local lIntegHtl	 := SuperGetMv("MV_INTHTL",, .F.) //Verifica se a integra��o com hotel esta ativa

Default lTipoPag := .F.
Default cMsgRET  := ""

//Busca pelo de/para da Forma de pagamento na Tabela XXF
cValInt :=  CfgA070Int(cMarca, "SX5", "X5_CHAVE", cTipPagExt)

If !Empty(cValInt)
	aAuxInt := Separa(cValInt, "|")

	If ValType(aAuxInt) == "A" .And. Len(aAuxInt) > 3
		If AllTrim(aAuxInt[3]) == "24"
			cFormaPag := Padr(aAuxInt[4], TamSx3("AE_TIPO")[1])
		EndIf
	EndIf
EndIf

//Se n�o encontrou o tipo de pagamento pelo de\para tentar encontrar o pagamento direto
If lTipoPag .And. Empty(cFormaPag)
	cFormaPag := cTipPagExt
EndIf

//Posiciona na Forma de Pagamento do Protheus
SX5->(DbSetOrder(1))
If Empty(cFormaPag) .Or. !SX5->( DbSeek(xFilial("SX5") + "24" + cFormaPag) )
	cFormaPag := ""
EndIf

//Faz a pesquisa da administradora financeira conforme a forma de pagamento 
//na qual deve conter uma ADM Fin para finalizar a venda no GravaBatch
If !lIntegHtl .AND. !Empty(cFormaPag) .AND. !IsMoney(Alltrim(cFormaPag)) .AND. ;
   (AllTrim(cFormaPag) <> AllTrim(MVCHEQUE))
   
	cQry := "SELECT AE_COD "
	cQry += " FROM " + RetSQLName("SAE")
	cQry += " WHERE AE_TIPO ='" + cFormaPag + "'"
	cQry += " AND D_E_L_E_T_='' "
    cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAls,.F.,.F.)

	If (cAls)->(Eof())		
		cMsgRET   += STR0033 + cFormaPag + "\n"//#"Esta forma de pagamento precisa de uma administradora financeira cadastrada (SAE). Forma de Pagamento: "
		cFormaPag := ""
	EndIf

	(cAls)->(dbCloseArea())
EndIf

RestArea(aAreaSX5)
RestArea(aArea)

Return cFormaPag

//-------------------------------------------------------
/*/{Protheus.doc} GetAdmFin
Retorna Administradora Financeira tentando localizar na
tabela SX5 - L9, caso n�o encontre adiciona um zero a esquerda
e refaz a pesquisa na tabela SX5 - L9.

@param   cNetworkDe - Administradora Financeira
@return  cRet - C�digo da Administradora Financeira, caso n�o encontre retorna vazio
@author  Fabricio Panhan Costa
@since   27/03/2019
@version 1.0
/*/
//-------------------------------------------------------
Static Function GetAdmFin(cNetworkDe)

	Local aArea    := GetArea()
	Local aAreaSX5 := SX5->(GetArea())
	Local cRet     := ""

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	If SX5->(DbSeek(xFilial("SX5")+"L9"+cNetworkDe))
		cRet := AllTrim(SX5->X5_CHAVE)
	EndIf

	// se nao achar coloca um zero a esquerna quando menor que 10 e chamar a rotina novamente para buscar na X5
	If Empty(cRet)
		If SX5->(DbSeek(xFilial("SX5")+"L9"+"0"+cNetworkDe))
			cRet := AllTrim(SX5->X5_CHAVE)
		EndIf
	EndIf

	RestArea(aAreaSX5)
	RestArea(aArea)
Return cRet
