#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a fun��o A637APICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na fun��o A637APICnt
#DEFINE ARRAY_POS_FILIAL     1
#DEFINE ARRAY_POS_PRODUTO    2
#DEFINE ARRAY_POS_ROTEIRO    3
#DEFINE ARRAY_POS_OPERACAO   4
#DEFINE ARRAY_POS_COMPONENTE 5
#DEFINE ARRAY_POS_TRT        6
#DEFINE ARRAY_POS_IDREG      7
#DEFINE ARRAY_POS_XOPER      8
#DEFINE ARRAY_SIZE           8

/*/{Protheus.doc} A637APICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array das opera��es por componente para integra��o.

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A637APICnt(cInfo)
	Local nValue := ARRAY_SIZE
	Do Case
		Case cInfo == "ARRAY_POS_FILIAL"
			nValue := ARRAY_POS_FILIAL

		Case cInfo == "ARRAY_POS_PRODUTO"
			nValue := ARRAY_POS_PRODUTO

		Case cInfo == "ARRAY_POS_ROTEIRO"
			nValue := ARRAY_POS_ROTEIRO

		Case cInfo == "ARRAY_POS_OPERACAO"
			nValue := ARRAY_POS_OPERACAO

		Case cInfo == "ARRAY_POS_COMPONENTE"
			nValue := ARRAY_POS_COMPONENTE

		Case cInfo == "ARRAY_POS_TRT"
			nValue := ARRAY_POS_TRT

		Case cInfo == "ARRAY_POS_IDREG"
			nValue := ARRAY_POS_IDREG

		Case cInfo == "ARRAY_SIZE"
			nValue := ARRAY_SIZE

		Otherwise
			nValue := ARRAY_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} MATA637INT
Fun��o que executa a integra��o de opera��es por componente com o MRP.

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param cOperation, Caracter, Opera��o que ser� executada ('DELETE' ou 'INSERT')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSucess   , Array   , Retorno por refer�ncia dados de sucesso
@param aError    , Array   , Retorno por refer�ncia dados de erro
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualiza��o de pend�ncias.
@param lOnlyDel  , Logic   , Indica que est� sendo executada uma opera��o de Sincroniza��o apenas excluindo os dados existentes (envia somente filial).
@param lBuffer   , Logic   , Define a sincroniza��o em processo de buffer.
@return Nil
/*/
Function MATA637INT(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn    := {}
	Local lAllError  := .F.
	Local nIndex     := 0
	Local nIndAux
	Local nTotal     := 0
	Local oJsDelete  := Nil
	Local oJsInsert  := Nil
	Local oJsonData  := Nil
	Local cApi 		 := "MRPBOMROUTING"

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
		cOperation := Iif(Empty(aDados[nIndex][ARRAY_POS_XOPER]), cOperation, aDados[nIndex][ARRAY_POS_XOPER])

		//Prepara os objetos JSON de DELETE e INSERT
		If !(lOnlyDel .And. cOperation == "SYNC") .AND. cOperation == "DELETE"
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

		oJsonData["items"][nIndAux]["branchId"] := aDados[nIndex][ARRAY_POS_FILIAL]

		If !(lOnlyDel .And. cOperation == "SYNC")
			oJsonData["items"][nIndAux]["code"            ] := aDados[nIndex][ARRAY_POS_FILIAL    ] + ;
			                                                   aDados[nIndex][ARRAY_POS_PRODUTO   ] + ;
			                                                   aDados[nIndex][ARRAY_POS_ROTEIRO   ] + ;
			                                                   aDados[nIndex][ARRAY_POS_OPERACAO  ] + ;
			                                                   aDados[nIndex][ARRAY_POS_COMPONENTE] + ;
			                                                   aDados[nIndex][ARRAY_POS_TRT       ]
			If cOperation $ "|INSERT|SYNC|"
				oJsonData["items"][nIndAux]["product"     ] := aDados[nIndex][ARRAY_POS_PRODUTO   ]
				oJsonData["items"][nIndAux]["routing"     ] := aDados[nIndex][ARRAY_POS_ROTEIRO   ]
				oJsonData["items"][nIndAux]["operation"   ] := aDados[nIndex][ARRAY_POS_OPERACAO  ]
				oJsonData["items"][nIndAux]["component"   ] := aDados[nIndex][ARRAY_POS_COMPONENTE]
				oJsonData["items"][nIndAux]["sequency"    ] := aDados[nIndex][ARRAY_POS_TRT       ]
			EndIf
		EndIf
	Next nIndex

	If nTotal == 0 .AND. cOperation == "SYNC"
		If oJsInsert == Nil
			oJsInsert := JsonObject():New()
			oJsInsert["items"] := {}
		EndIf
	EndIf

	//Envia opera��es de DELETE
	If oJsDelete != Nil
 		aReturn := MrpBRODel(oJsDelete)
		PrcPendMRP(aReturn, cApi, oJsDelete, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
		FreeObj(oJsDelete)
		oJsDelete := Nil
	EndIf

	//Envia opera��es de INSERT
	If oJsInsert != Nil
		If cOperation == "INSERT" .OR. (!(lOnlyDel .And. cOperation == "SYNC") .And. !isInCallStack("PCPA140JOB"))
			aReturn := MrpBROPost(oJsInsert)
		Else
			aReturn := MrpBROSync(oJsInsert, lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsInsert, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
		FreeObj(oJsInsert)
		oJsInsert := Nil
	EndIf

	aSize(aReturn, 0)

Return Nil

/*/{Protheus.doc} A637ADDINT
Adiciona o registro que estiver posicionado na SGF em um array que ser� enviado
para a API atrav�s da fun��o MATA637INT

@type  Function
@author brunno.costa
@since 11/07/2019
@version P12.1.30
@param aDados    , Array   , Array enviado por refer�ncia, para retorno dos dados.
@param nPos      , Numero  , posicao do array para atualizacao
@param cOperation, Caracter, indica a opera��o a ser realizada ("INSERT","DELETE")
@param cAliasGF  , Caracter, Alias que dever� ser utilizado para recuperar os dados da SGF.
@return Nil
/*/
Function A637AddInt(aDados, nPos, cOperation, cAliasGF)

	Default nPos       := 0
	Default cOperation := "INSERT"
	Default cAliasGF   := "SGF"

	If nPos == 0
		aAdd(aDados, Array(ARRAY_SIZE))
		nPos := Len(aDados)
	EndIf

	aDados[nPos][ARRAY_POS_XOPER     ] := cOperation
	aDados[nPos][ARRAY_POS_FILIAL    ] := (cAliasGF)->GF_FILIAL
	aDados[nPos][ARRAY_POS_PRODUTO   ] := (cAliasGF)->GF_PRODUTO
	aDados[nPos][ARRAY_POS_ROTEIRO   ] := (cAliasGF)->GF_ROTEIRO
	aDados[nPos][ARRAY_POS_OPERACAO  ] := (cAliasGF)->GF_OPERAC
	aDados[nPos][ARRAY_POS_COMPONENTE] := (cAliasGF)->GF_COMP
	aDados[nPos][ARRAY_POS_TRT       ] := (cAliasGF)->GF_TRT

	//Tratativa para enviar a filial correta.
	If Empty(aDados[nPos][ARRAY_POS_FILIAL])
		aDados[nPos][ARRAY_POS_FILIAL] := xFilial("SGF")
	EndIf
Return Nil

/*/{Protheus.doc} A637AddJIn
Adiciona OU atualiza o registro que estiver posicionado na SGF em um array que ser� enviado
para a API atrav�s da fun��o MATA637INT

@type  Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param aMRPxJson , Array, Array enviado por refer�ncia, para retorno dos dados:
                       [1] Array aDados referente A637AddInt
                       [2] JsonObject contendo os RECNOS j� adicionados no array
@param cOperation, Caracter, Opera��o executada (INSERT/DELETE)
@param cAliasGF  , Caracter, Alias que dever� ser utilizado para recuperar os dados da SGF.
@return Nil
/*/
Function A637AddJIn(aMRPxJson, cOperation, cAliasGF)

	Local aDados := aMRPxJson[1]
	Local oDados := aMRPxJson[2]
	Local nPos   := 0
	Local cChave := ""

	Default cOperation := "INSERT"
	Default cAliasGF   := "SGF"

	cChave := (cAliasGF)->(GF_FILIAL + GF_PRODUTO + GF_ROTEIRO + GF_OPERAC + GF_COMP + GF_TRT)
	nPos   := oDados[cChave]

	A637AddInt(@aDados, @nPos, cOperation, cAliasGF)
	oDados[cChave] := nPos

Return Nil

/*/{Protheus.doc} MA637MrpOn
Verifica se a integra��o de opera��es por componente est�
configurada de forma ONLINE para o novo MRP.

@type  Static Function
@author brunno.costa
@since 13/04/2020
@version P12.1.30
@param lNewMRP, logico, retorna por referencia indicando se o MRP novo esta habilitado para OP
@return lIntegra, Logical, Indentifica se deve ser executada a integra��o com o novo MRP
/*/
Function MA637MrpOn(lNewMRP)
	Local lIntegra   := .F.
	Local lIntOnline := .F.

	If lNewMRP == Nil
		If FindFunction("IntNewMRP")
			lNewMRP := IntNewMRP("MRPBOMROUTING", @lIntOnline)
			If lNewMRP .And. !lIntOnline
				lNewMRP := .F.
			EndIf
		Else
			lNewMRP := .F.
		EndIf
	EndIf
	lIntegra := lNewMRP

Return lIntegra

