#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A650APICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A650APICnt
#DEFINE ARRAY_OP_POS_FILIAL    1
#DEFINE ARRAY_OP_POS_NUM       2
#DEFINE ARRAY_OP_POS_NUM_PAI   3
#DEFINE ARRAY_OP_POS_PROD      4
#DEFINE ARRAY_OP_POS_LOCAL     5
#DEFINE ARRAY_OP_POS_QTD       6
#DEFINE ARRAY_OP_POS_SALDO     7
#DEFINE ARRAY_OP_POS_DTINI     8
#DEFINE ARRAY_OP_POS_DTENTREGA 9
#DEFINE ARRAY_OP_POS_DTFIM     10
#DEFINE ARRAY_OP_POS_TIPO      11
#DEFINE ARRAY_OP_POS_OPC       12
#DEFINE ARRAY_OP_POS_SITUACAO  13
#DEFINE ARRAY_OP_POS_XOPER     14
#DEFINE ARRAY_OP_POS_STR_OPC   15
#DEFINE ARRAY_OP_POS_RECNO     16
#DEFINE ARRAY_OP_SIZE          16

/*/{Protheus.doc} A650APICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array das ordens de produção para integração.

@type  Function
@author lucas.franca
@since 10/07/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A650APICnt(cInfo)
	Local nValue := ARRAY_OP_SIZE
	Do Case
		Case cInfo == "ARRAY_OP_POS_FILIAL"
			nValue := ARRAY_OP_POS_FILIAL
		Case cInfo == "ARRAY_OP_POS_NUM"
			nValue := ARRAY_OP_POS_NUM
		Case cInfo == "ARRAY_OP_POS_NUM_PAI"
			nValue := ARRAY_OP_POS_NUM_PAI
		Case cInfo == "ARRAY_OP_POS_PROD"
			nValue := ARRAY_OP_POS_PROD
		Case cInfo == "ARRAY_OP_POS_LOCAL"
			nValue := ARRAY_OP_POS_LOCAL
		Case cInfo == "ARRAY_OP_POS_QTD"
			nValue := ARRAY_OP_POS_QTD
		Case cInfo == "ARRAY_OP_POS_SALDO"
			nValue := ARRAY_OP_POS_SALDO
		Case cInfo == "ARRAY_OP_POS_DTINI"
			nValue := ARRAY_OP_POS_DTINI
		Case cInfo == "ARRAY_OP_POS_DTENTREGA"
			nValue := ARRAY_OP_POS_DTENTREGA
		Case cInfo == "ARRAY_OP_POS_DTFIM"
			nValue := ARRAY_OP_POS_DTFIM
		Case cInfo == "ARRAY_OP_POS_TIPO"
			nValue := ARRAY_OP_POS_TIPO
		Case cInfo == "ARRAY_OP_POS_OPC"
			nValue := ARRAY_OP_POS_OPC
		Case cInfo == "ARRAY_OP_POS_STR_OPC"
			nValue := ARRAY_OP_POS_STR_OPC
		Case cInfo == "ARRAY_OP_POS_SITUACAO"
			nValue := ARRAY_OP_POS_SITUACAO
		Case cInfo == "ARRAY_OP_POS_XOPER"
			nValue := ARRAY_OP_POS_XOPER
		Case cInfo == "ARRAY_OP_SIZE"
			nValue := ARRAY_OP_SIZE
		Case cInfo == "ARRAY_OP_POS_RECNO"
			nValue := ARRAY_OP_POS_RECNO
		Otherwise
			nValue := ARRAY_OP_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} MATA650INT
Função que executa a integração da ordem de produção com o MRP.

@type  Function
@author lucas.franca
@since 10/07/2019
@version P12.1.27
@param cOperation, Caracter, Operação que será executada ('DELETE' ou 'INSERT')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSucess   , Array   , Retorno por referência dados de sucesso
@param aError    , Array   , Retorno por referência dados de erro
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param   lBuffer, Lógico, Define a sincronização em processo de buffer.
@return Nil
/*/
Function MATA650INT(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn    := {}
	Local cPathOp    := ""
	Local lAllError  := .F.
	Local nIndex     := 0
	Local nIndAux    := 0
	Local nTotal     := 0
	Local oJsDelete  := Nil
	Local oJsInsert  := Nil
	Local oJsonData  := Nil
	Local cApi 		 := "MRPPRODUCTIONORDERS"

	Default aSuccess := {}
	Default aError   := {}
	Default cUUID    := ""
	Default lOnlyDel := .F.
	Default lBuffer  := .F.

	nTotal := Len(aDados)
	oJsonData := JsonObject():New()

	oJsonData["items"] := Array(nTotal)
	For nIndex := 1 To nTotal
		//Identifica o metodo de envio do registro para API
		cOperation := Iif(Empty(aDados[nIndex][ARRAY_OP_POS_XOPER]), cOperation, aDados[nIndex][ARRAY_OP_POS_XOPER])
		cPathOp    := ""
		//Prepara os objetos JSON de DELETE e INSERT
		If ! (lOnlyDel .And. cOperation == "SYNC") ;
		   .And. (cOperation == "DELETE";
		   .OR. aDados[nIndex][ARRAY_OP_POS_SALDO] == 0;
		   .OR. !Empty(aDados[nIndex][ARRAY_OP_POS_DTFIM]))

			If oJsDelete == Nil
				oJsDelete := JsonObject():New()
				oJsDelete["items"] := {}
			EndIf
			oJsonData := oJsDelete
		Else
			If oJsInsert == Nil
				oJsInsert := JsonObject():New()
				oJsInsert["items"] := {}
			EndIf
			oJsonData := oJsInsert
		EndIf

		aAdd(oJsonData["items"], JsonObject():New())
		nIndAux := Len(oJsonData["items"])

		oJsonData["items"][nIndAux]["branchId"] := aDados[nIndex][ARRAY_OP_POS_FILIAL]
		
		If ! (lOnlyDel .And. cOperation == "SYNC")
			oJsonData["items"][nIndAux]["code"] := cValToChar(aDados[nIndex][ARRAY_OP_POS_RECNO])

			If cOperation $ "|INSERT|SYNC|"
				oJsonData["items"][nIndAux]["product"         ]    := aDados[nIndex][ARRAY_OP_POS_PROD]
				oJsonData["items"][nIndAux]["warehouse"       ]    := aDados[nIndex][ARRAY_OP_POS_LOCAL]
				oJsonData["items"][nIndAux]["quantity"        ]    := aDados[nIndex][ARRAY_OP_POS_QTD]
				oJsonData["items"][nIndAux]["productionAmount"]    := aDados[nIndex][ARRAY_OP_POS_SALDO]
				oJsonData["items"][nIndAux]["startDate"       ]    := convDate(aDados[nIndex][ARRAY_OP_POS_DTINI])
				oJsonData["items"][nIndAux]["deliveryDate"    ]    := convDate(aDados[nIndex][ARRAY_OP_POS_DTENTREGA])
				oJsonData["items"][nIndAux]["type"            ]    := aDados[nIndex][ARRAY_OP_POS_TIPO]
				oJsonData["items"][nIndAux]["situation"       ]    := aDados[nIndex][ARRAY_OP_POS_SITUACAO]
				oJsonData["items"][nIndAux]["productionOrder" ]    := aDados[nIndex][ARRAY_OP_POS_NUM]
				oJsonData["items"][nIndAux]["mainProductionOrder"] := aDados[nIndex][ARRAY_OP_POS_NUM_PAI]
				If Empty(aDados[nIndex][ARRAY_OP_POS_OPC])
					oJsonData["items"][nIndAux]["optional"             ] := Nil
					oJsonData["items"][nIndAux]["erpMemoOptional"      ] := Nil
					oJsonData["items"][nIndAux]["optionalPathStructure"] := Nil
				Else
					oJsonData["items"][nIndAux]["optional"] := MOpcToJson(aDados[nIndex][ARRAY_OP_POS_OPC],;
					                                                      2,;
					                                                      .T.,;
					                                                      @cPathOp,;
					                                                      aDados[nIndex][ARRAY_OP_POS_PROD],;
					                                                      aDados[nIndex][ARRAY_OP_POS_STR_OPC])
					
					oJsonData["items"][nIndAux]["erpMemoOptional"      ] := aDados[nIndex][ARRAY_OP_POS_OPC]
					oJsonData["items"][nIndAux]["optionalPathStructure"] := cPathOp
				EndIf
				If Empty(aDados[nIndex][ARRAY_OP_POS_STR_OPC])
					oJsonData["items"][nIndAux]["erpStringOptional" ] := Nil
				Else
					oJsonData["items"][nIndAux]["erpStringOptional" ] := aDados[nIndex][ARRAY_OP_POS_STR_OPC]
				EndIf
			EndIf
		EndIf
	Next nIndex

	If nTotal == 0 .AND. cOperation == "SYNC"
		If oJsInsert == Nil
			oJsInsert := JsonObject():New()
			oJsInsert["items"] := {}
		EndIf
	EndIf

	//Envia operações de DELETE
	If oJsDelete != Nil
		aReturn := MrpOrdDel(oJsDelete)
		PrcPendMRP(aReturn, cApi, oJsDelete, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
		FreeObj(oJsDelete)
		oJsDelete := Nil
	EndIf

	//Envia operações de INSERT
	If oJsInsert != Nil
		If cOperation == "SYNC"
			aReturn := MrpOPSync(oJsInsert,lBuffer)
		Else
			aReturn := MrpOrdPost(oJsInsert)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsInsert, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
		FreeObj(oJsInsert)
		oJsInsert := Nil
	EndIf

	aSize(aReturn, 0)

Return Nil

/*/{Protheus.doc} A650ADDINT
Adiciona o registro que estiver posicionado na SC2 em um array que será enviado
para a API através da função MATA650INT

@type  Function
@author lucas.franca
@since 11/07/2019
@version P12.1.27
@param aDados    , Array   , Array enviado por referência, para retorno dos dados.
@param nPos      , Numero  , posicao do array para atualizacao
@param cOperation, Caracter, indica a operação a ser realizada ("INSERT","DELETE")
@param cAliasC2  , Caracter, Alias que deverá ser utilizado para recuperar os dados da SC2.
@return Nil
/*/
Function A650AddInt(aDados, nPos, cOperation, cAliasC2, cRecno)

	Default nPos       := 0
	Default cOperation := "INSERT"
	Default cAliasC2   := "SC2"
	Default cRecno     := ""

	If nPos == 0
		aAdd(aDados, Array(ARRAY_OP_SIZE))
		nPos := Len(aDados)
	EndIf

	aDados[nPos][ARRAY_OP_POS_XOPER    ] := cOperation
	aDados[nPos][ARRAY_OP_POS_FILIAL   ] := (cAliasC2)->C2_FILIAL
	aDados[nPos][ARRAY_OP_POS_NUM      ] := (cAliasC2)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	If Empty(SC2->C2_SEQPAI)
		aDados[nPos][ARRAY_OP_POS_NUM_PAI  ] := ""
	Else
		aDados[nPos][ARRAY_OP_POS_NUM_PAI  ] := (cAliasC2)->(C2_NUM+C2_ITEM+C2_SEQPAI)
	EndIf
	aDados[nPos][ARRAY_OP_POS_PROD     ] := (cAliasC2)->C2_PRODUTO
	aDados[nPos][ARRAY_OP_POS_LOCAL    ] := (cAliasC2)->C2_LOCAL
	aDados[nPos][ARRAY_OP_POS_QTD      ] := (cAliasC2)->C2_QUANT
	aDados[nPos][ARRAY_OP_POS_SALDO    ] := ASC2SLD(cAliasC2)
	aDados[nPos][ARRAY_OP_POS_DTINI    ] := (cAliasC2)->C2_DATPRI
	aDados[nPos][ARRAY_OP_POS_DTENTREGA] := (cAliasC2)->C2_DATPRF
	aDados[nPos][ARRAY_OP_POS_DTFIM    ] := (cAliasC2)->C2_DATRF
	aDados[nPos][ARRAY_OP_POS_TIPO     ] := A650TypeOP((cAliasC2)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), cAliasC2)
	aDados[nPos][ARRAY_OP_POS_SITUACAO ] := A650SitOP((cAliasC2)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD), cAliasC2)
	aDados[nPos][ARRAY_OP_POS_OPC      ] := (cAliasC2)->C2_MOPC
	aDados[nPos][ARRAY_OP_POS_STR_OPC  ] := (cAliasC2)->C2_OPC
	aDados[nPos][ARRAY_OP_POS_RECNO    ] := Iif(Empty(cRecno), cValTochar((cAliasC2)->(Recno())), cRecno)

	//Tratativa para enviar a filial correta.
	If Empty(aDados[nPos][ARRAY_OP_POS_FILIAL])
		aDados[nPos][ARRAY_OP_POS_FILIAL] := xFilial("SC2")
	EndIf
Return Nil

/*/{Protheus.doc} A650AddJIn
Adiciona OU atualiza o registro que estiver posicionado na SC2 em um array que será enviado
para a API através da função MATA650INT

@type  Function
@author brunno.costa
@since 18/07/2019
@version P12.1.27
@param aMRPxJson , Array, Array enviado por referência, para retorno dos dados:
                       [1] Array aDados referente A650AddInt
                       [2] JsonObject contendo os RECNOS já adicionados no array
@param cOperation, Caracter, Operação executada (INSERT/DELETE)
@param cAliasC2  , Caracter, Alias que deverá ser utilizado para recuperar os dados da SC2.
@return Nil
/*/
Function A650AddJIn(aMRPxJson, cOperation, cAliasC2)

	Local aDados := aMRPxJson[1]
	Local oDados := aMRPxJson[2]
	Local nPos   := 0
	Local nRecno := 0

	Default cOperation := "INSERT"
	Default cAliasC2   := "SC2"

	If cAliasC2 == "SC2"
		nRecno := SC2->(RecNo())
	Else
		nRecno := (cAliasC2)->RECNO
	EndIf

	nPos := oDados[cValToChar(nRecno)]

	A650AddInt(@aDados, @nPos, cOperation, cAliasC2)
	oDados[cValToChar(nRecno)] := nPos

Return Nil

/*/{Protheus.doc} A650TypeOP
Indentifica o tipo da ordem de produção que deve ser enviada para a API.
1=Planejada;2=Firme;3=Aberta;4=Liberada;5=Fechada;9=Cancelada

@type  Function
@author lucas.franca
@since 10/07/2019
@version P12.1.27
@param cOp     , Caracter, Numero da OP
@param cAliasC2, Caracter, Alias que deverá ser utilizado para recuperar os dados da SC2.
@return cTipo  , Caracter, Tipo da ordem de produção que deve ser enviado para a API
/*/
Function A650TypeOP(cOp, cAliasC2)
	Local aArea     := {}
	Local cTipo     := ""
	Local lValido   := .T.
	Local lRestaura := .F.

	Default cAliasC2 := "SC2"

	If cAliasC2 == "SC2" .And. SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) != cOp
		lRestaura := .T.
		aArea     := SC2->(GetArea())
		//Posiciona SC2 na ordem correta
		SC2->(dbSetOrder(1))
		If !SC2->(dbSeek(xFilial("SC2")+cOp))
			lValido := .F.
		EndIf
	EndIf

	//Verifica qual é o tipo da OP
	If lValido
		If (cAliasC2)->C2_TPOP == "P"
			cTipo := "1" //OP Planejada
		ElseIf (cAliasC2)->C2_TPOP == "F" .And. !Empty((cAliasC2)->C2_DATRF)
			cTipo := "5" //OP Fechada
		Else
			cTipo := "4" //OP Firme
		EndIf
	EndIf

	//Restaura o posicionamento da SC2
	If lRestaura
		SC2->(RestArea(aArea))
	EndIf

Return cTipo

/*/{Protheus.doc} A650SitOP
Indentifica a situação da ordem de produção que deve ser enviada para a API.
1=Normal;2=Sacramentada;3=Suspensa

@type  Function
@author lucas.franca
@since 15/07/2019
@version P12.1.27
@param cOp     , Caracter, Numero da OP
@param cAliasC2, Caracter, Alias que deverá ser utilizado para recuperar os dados da SC2.
@return cSituacao, Caracter, Tipo da ordem de produção que deve ser enviado para a API
/*/
Function A650SitOP(cOp, cAliasC2)
	Local aArea     := {}
	Local cSituacao := "1"
	Local lValido   := .T.
	Local lRestaura := .F.

	Default cAliasC2 := "SC2"

	//Verifica se é necessário posicionar na SC2
	If cAliasC2 == "SC2" .And. SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) != cOp
		lRestaura := .T.
		aArea     := SC2->(GetArea())
		//Posiciona SC2 na ordem correta
		SC2->(dbSetOrder(1))
		If !SC2->(dbSeek(xFilial("SC2")+cOp))
			lValido := .F.
		EndIf
	EndIf

	//Verifica qual é a situação da OP
	If lValido
		If (cAliasC2)->C2_STATUS == "N" //OP Normal
			cSituacao := "1"
		ElseIf (cAliasC2)->C2_STATUS == "S" //OP Sacramentada
			cSituacao := "2"
		ElseIf (cAliasC2)->C2_STATUS == "U" //OP Suspensa
			cSituacao := "3"
		EndIf
	EndIf

	//Restaura o posicionamento da SC2
	If lRestaura
		SC2->(RestArea(aArea))
	EndIf
Return cSituacao

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author lucas.franca
@since 10/07/2019
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData

/*/{Protheus.doc} Ma650MrpOn
Verifica se a integração de ordens de produção está
configurada de forma ONLINE para o novo MRP.

@type  Static Function
@author brunno.costa
@since 18/07/2019
@version P12.1.27
@param lNewMRP, logico, retorna por referencia indicando se o MRP novo esta habilitado para OP
@return lIntegra, Logical, Indentifica se deve ser executada a integração com o novo MRP
/*/
Function Ma650MrpOn(lNewMRP)
	Local lIntegra   := .F.
	Local lIntOnline := .F.

	If lNewMRP == Nil
		If FindFunction("IntNewMRP")
			lNewMRP := IntNewMRP("MRPPRODUCTIONORDERS", @lIntOnline)
			If lNewMRP .And. !lIntOnline
				lNewMRP := .F.
			EndIf
		Else
			lNewMRP := .F.
		EndIf
	EndIf
	lIntegra := lNewMRP

Return lIntegra

