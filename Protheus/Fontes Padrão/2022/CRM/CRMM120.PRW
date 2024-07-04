#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "CRMM120.CH"

Static lMultDir := MsMultDir()

//---------------------------------------------------------------------------
/*/{Protheus.doc} CRMMDOCUMENTS

Classe responsável por retornar os documentos das entidades armazenado no
banco de conhecimento do Protheus.

@author		Squad CRM/Faturamento
@since		11/06/2018
/*/
//---------------------------------------------------------------------------
WSRESTFUL CRMMDOCUMENTS DESCRIPTION STR0001  // "Banco de Conhecimento para o appCRM."

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL
	WSDATA sourceBranch AS STRING  OPTIONAL
	WSDATA resourceType AS STRING
	WSDATA resourceCode AS STRING
	WSDATA searchKey    AS STRING  OPTIONAL
	WSDATA code	 		AS STRING

	WSMETHOD GET Main DESCRIPTION STR0002;  // "Retorna os documentos das entidades armazenados no Banco de Conhecimento."
	WSSYNTAX "/CRMMDOCUMENTS/{page, pageSize, sourceBranch, resourceType, resourceCode, searchKey}";
	PATH ""

	WSMETHOD GET Code DESCRIPTION STR0002;  // "Retorna os documentos das entidades armazenados no Banco de Conhecimento."
	WSSYNTAX "/CRMMDOCUMENTS/{Code}";
	PATH "{Code}"

	WSMETHOD POST     DESCRIPTION STR0004;  // "Insere um documento de uma entidade no Banco de Conhecimento."
	WSSYNTAX "/CRMMDOCUMENTS";
	PATH ""

	WSMETHOD DELETE   DESCRIPTION STR0005;  // "Exclui um documento de uma entidade no Banco de Conhecimento."
	WSSYNTAX "/CRMMDOCUMENTS/{Code}";
	PATH "{Code}"

END WSRESTFUL


//-------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET/CRMMDOCUMENTS
Retorna os documentos das entidades armazenado no banco de conhecimento.

@param  Page     	- numérico - Posição da página para ser considerada na consulta. Ex: a partir da página 3.
        PageSize	- numérico - Quantidade de registros a ser retornado na consulta. Ex: 10 registros.

@return lReturn		- lógico   - Indica se a consulta foi bem sucedida ou não.

@author     Squad CRM/Faturamento
@since		19/07/2018
/*/
//-------------------------------------------------------------------------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE page, pageSize, sourceBranch, resourceType, resourceCode, searchKey WSSERVICE CRMMDOCUMENTS

Local nError     := 0
Local cError     := ""
Local oResponse  := nil
Local oItem      := nil
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local nIndexJSon := 0
Local nSkip      := 0
Local aSize      := {}

Self:SetContentType("application/json")

// Verifica se o parâmetro obrigatório foi passado.
If (empty(Self:resourceType) .or. empty(Self:resourceCode))
	nError := 400
	cError := STR0006  // "Código do documento não identificado..."
Else
	Default Self:page := 1
	If Self:page < 0
		Self:page := 1
	Endif

	Default Self:pageSize := 20
	If Self:pageSize < 0 .or. Self:pageSize > 30
		Self:pageSize := 20
	Endif

	cQuery := "select AC9.R_E_C_N_O_ AC9RecNo, ACB.R_E_C_N_O_ ACBRecNo " + CRLF

	// Entidade x objeto.
	cQuery += "from " + RetSQLName('AC9') + " AC9 " + CRLF

	// Objeto.
	cQuery += "left join " + RetSQLName('ACB') + " ACB on ACB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and ACB.ACB_FILIAL = AC9.AC9_FILIAL " + CRLF
	cQuery += "and ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + CRLF

	// Chave de pesquisa.
	If !empty(Self:searchKey)
		cQuery += "inner join " + RetSQLName('ACC') + " ACC on ACC.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and ACC.ACC_FILIAL = AC9.AC9_FILIAL " + CRLF
		cQuery += "and ACC.ACC_CODOBJ = AC9.AC9_CODOBJ " + CRLF
		cQuery += "and (upper(ACB.ACB_DESCRI) like '%' + ? + '%' or upper(ACC.ACC_KEYWRD) like '%' + ? + '%') " + CRLF
	Endif

	cQuery += "where AC9.D_E_L_E_T_ = '' " + CRLF
	If empty(Self:sourceBranch)
		cQuery += "and AC9.AC9_FILIAL in (?) " + CRLF
	Else
		cQuery += "and AC9.AC9_FILIAL = ? " + CRLF
	Endif
	cQuery += "and AC9.AC9_ENTIDA = ? " + CRLF
	cQuery += "and AC9.AC9_CODENT = ? " + CRLF

	cQuery += "order by AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

	// Trata SQL para proteger de SQL injection.
	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)

	nSQLParam++
	If empty(Self:sourceBranch)
		oStatement:SetString(nSQLParam, xFilial("AC9"))  // Filiais.
	Else
		oStatement:SetString(nSQLParam, xFilial("AC9", Self:sourceBranch))  // Filial.
	Endif

	nSQLParam++
	oStatement:SetString(nSQLParam, Self:resourceType)  // Entidade.

	nSQLParam++
	oStatement:SetString(nSQLParam, Self:resourceCode)  // Chave.

	If !empty(Self:searchKey)
		nSQLParam++
		oStatement:SetString(nSQLParam, upper(Self:searchKey))  // Descrição.

		nSQLParam++
		oStatement:SetString(nSQLParam, upper(Self:searchKey))  // Chave de pesquisa.
	Endif

	cQuery := oStatement:GetFixQuery()
	oStatement:Destroy()
	oStatement := nil

	cAliasSQL := MPSysOpenQuery(cQuery)

	// Calcula quantos registros pular.
	If (cAliasSQL)->(!eof())
		nSkip := ((Self:page - 1) * Self:pageSize)
		If nSkip > 0
			(cAliasSQL)->(dbSkip(nSkip))
		Endif
	Endif

	oResponse := JsonObject():New()
	oResponse['items'] := {}
	Do While (cAliasSQL)->(!eof() .and. nIndexJSon < Self:pageSize)
		AC9->(dbGoTo((cAliasSQL)->AC9RecNo))
		ACB->(dbGoTo((cAliasSQL)->ACBRecNo))

		// Calcula o tamanho do objeto.
		aSize := FileSize()

			If !aSize[3]
				(cAliasSQL)->(DbSkip())
				Loop
			EndIf

		oItem := JsonObject():New()
		oItem['code']         := RTrim(AC9->AC9_CODOBJ)
		oItem['resourceType'] := AC9->AC9_ENTIDA
		oItem['resourceCode'] := RTrim(AC9->AC9_CODENT)
		oItem['filename']     := RTrim(ACB->ACB_OBJETO)
		oItem['sizeBytes']    := aSize[1]
		oItem['size']         := aSize[2]
		aAdd(oResponse['items'], oItem)

		nIndexJSon ++
		(cAliasSQL)->(dbSkip())
	EndDo
	oResponse['hasNext'] := (cAliasSQL)->(!eof())

	(cAliasSQL)->(dbCloseArea())
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//-------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET/CRMMDOCUMENTS
Retorna um documento específico armazenado no banco de conhecimento.

@param  Page     	- numérico - Posição da página para ser considerada na consulta. Ex: a partir da página 3.
        PageSize	- numérico - Quantidade de registros a ser retornado na consulta. Ex: 10 registros.

@return lReturn		- lógico   - Indica se a consulta foi bem sucedida ou não.

@author     Squad CRM/Faturamento
@since		19/07/2018
/*/
//-------------------------------------------------------------------------------------------------------------------------------------
WSMETHOD GET Code WSSERVICE CRMMDOCUMENTS

Local nError     := 0
Local cError     := ""
Local oResponse  := nil
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local cCode      := Self:code
Local aSize      := {}

Self:SetContentType("application/json")

// Verifica se o parâmetro obrigatório foi passado.
If empty(cCode)
	nError := 400
	cError := STR0006  // "Código do documento não identificado..."
Else
	cQuery := "select AC9.R_E_C_N_O_ AC9RecNo, ACB.R_E_C_N_O_ ACBRecNo, ACC.R_E_C_N_O_ ACCRecNo " + CRLF

	// Entidade x objeto.
	cQuery += "from " + RetSQLName('AC9') + " AC9 " + CRLF

	// Objeto.
	cQuery += "left join " + RetSQLName('ACB') + " ACB on ACB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and ACB.ACB_FILIAL = AC9.AC9_FILIAL " + CRLF
	cQuery += "and ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + CRLF

	// Chave de pesquisa.
	cQuery += "left join " + RetSQLName('ACC') + " ACC on ACC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and ACC.ACC_FILIAL = AC9.AC9_FILIAL " + CRLF
	cQuery += "and ACC.ACC_CODOBJ = AC9.AC9_CODOBJ " + CRLF

	cQuery += "where AC9.D_E_L_E_T_ = '' " + CRLF
	cQuery += "and AC9.AC9_FILIAL = '" + xFilial("AC9") + "' " + CRLF
	cQuery += "and AC9.AC9_CODOBJ = ? " + CRLF

	cQuery += "order by AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

	// Trata SQL para proteger de SQL injection.
	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)

	nSQLParam++
	oStatement:SetString(nSQLParam, cCode)  // Código do objeto.

	cQuery := oStatement:GetFixQuery()
	oStatement:Destroy()
	oStatement := nil

	cAliasSQL := MPSysOpenQuery(cQuery)

	If (cAliasSQL)->(eof())
		nError := 404
		cError := STR0013  // "Documento não foi encontrado no Banco de Conhecimento..."
	Else
		AC9->(dbGoTo((cAliasSQL)->AC9RecNo))
		ACB->(dbGoTo((cAliasSQL)->ACBRecNo))

		// Calcula o tamanho do objeto.
		aSize := FileSize()

		If aSize[3]
			oResponse := JsonObject():New()
			oResponse['code']         := RTrim(AC9->AC9_CODOBJ)
			oResponse['resourceType'] := AC9->AC9_ENTIDA
			oResponse['resourceCode'] := RTrim(AC9->AC9_CODENT)
			oResponse['filename']     := RTrim(ACB->ACB_OBJETO)
			oResponse['sizeBytes']    := aSize[1]
			oResponse['size']         := aSize[2]
			oResponse['content']      := FileCont()
		EndIf
	Endif

	(cAliasSQL)->(dbCloseArea())
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} POST
Método responsável por incluir documentos.

@author		Squad CRM/Faturamento
@since		19/07/2018
/*/
//---------------------------------------------------------------
WSMETHOD POST WSSERVICE CRMMDOCUMENTS

Local nError     := 0
Local cError     := ""
Local cWarning   := ""
Local oResponse  := nil
Local oContent   := nil
Local nSaveSX8   := 0
Local cKeyWord   := ""
Local nLen       := 0
Local nLin       := 0
Local nX

Local cPath      := ""
Local cFile      := ""
Local nHandle    := 0
Local nFileSize  := 0

Self:SetContentType("application/json")

// Verifica se o body veio no formato JSon.
If lower(Self:GetHeader("Content-Type", .F.)) == "application/json"

	FWJsonDeserialize(Self:GetContent(), @oContent)
	If !AttIsMemberOf(oContent, "resourceType") .or. !AttIsMemberOf(oContent, "resourceCode") .or.;
		!AttIsMemberOf(oContent, "filename") .or. !AttIsMemberOf(oContent, "content")

		nError := 400
		cError := STR0015  // "Parâmetros obrigatórios não informados."
	Else
		// Valida tamanho do nome do arquivo.
		oContent:filename := RTrim(oContent:filename)
		If len(oContent:filename) > TamSX3("ACB_OBJETO")[1] - 36
			nError := 400
			cError := STR0016  // "O nome do arquivo ultrapassa o limite para gravação."
		Endif

		// Valida a chave da entidade.
		If nError = 0
			oContent:resourceType := upper(RTrim(oContent:resourceType))
			oContent:resourceCode := upper(RTrim(oContent:resourceCode))
			If !VldChave(oContent:resourceType, oContent:resourceCode)
				nError := 400
				cError := STR0021  // "Entidade / chave inválidas."
			Endif
		Endif

		// Monta o nome do arquivo a ser gravado no servidor.
		If nError = 0
			// Retira caracteres estendidos.
			cFile := Ft340RmvAc(DecodeUTF8(oContent:filename))
			If cFile <> oContent:filename
				cWarning := STR0017  // "O nome teve os caracteres estendidos alterados para _."
			Endif

			// Pega o caminho completo do objeto.
			If lMultDir
				cPath := MsRetPath(cFile)
			Else
				cPath := MsDocPath()
			Endif
			cPath := MsDocRmvBar(cPath) + "\"
		Endif

		// Verifica a existência do arquivo no servidor.
		If nError = 0
			If File(cPath + cFile)
				nError := 400
				cError := STR0018  // "O arquivo já existe no servidor e não pode ser sobreposto."
			Endif
		Endif

		// Se tudo certo, grava o arquivo no servidor e seus registros correspondentes.
		If nError = 0
			Begin Transaction
				// Grava o arquivo em disco.
				nHandle   := FCreate(cPath + cFile, FC_NORMAL)
				nFileSize := FWrite(nHandle, Decode64(oContent:content))
				FClose(nHandle)

				// Grava o registro do objeto.
				nSaveSX8 := GetSX8Len()
				RecLock("ACB", .T.)
				ACB->ACB_FILIAL := xFilial("ACB")
				ACB->ACB_CODOBJ := GetSXENum("ACB", "ACB_CODOBJ")
				ACB->ACB_OBJETO := cFile
				If AttIsMemberOf(oContent, "description")
					oContent:description := AllTrim(oContent:description)
					ACB->ACB_DESCRI := DecodeUTF8(RTrim(oContent:description))
				Else
					ACB->ACB_DESCRI := DecodeUTF8(RTrim(oContent:filename))
				Endif
				ACB->(msUnLock())
				Do While ACB->(GetSx8Len() > nSaveSX8)
					ACB->(ConfirmSX8())
				EndDo

				// Grava registro de chave de pesquisa.
				If AttIsMemberOf(oContent, "description")
					cKeyWord := DecodeUTF8(AllTrim(oContent:description))
					nLen := TamSX3("ACC_KEYWRD")[1]
					nLin := MLCount(cKeyWord, nLen)
					For nX := 1 to nLin
						RecLock("ACC", .T.)
						ACC->ACC_FILIAL := xFilial("ACC")
						ACC->ACC_CODOBJ := ACB->ACB_CODOBJ
						ACC->ACC_KEYWRD := MemoLine(cKeyWord, nLen, nX)
						ACC->(msUnLock())
					Next nX
				Endif

				// Grava a amarração do objeto com a entidade.
				RecLock("AC9", .T.)
				AC9->AC9_FILIAL := xFilial("AC9")
				AC9->AC9_CODOBJ := ACB->ACB_CODOBJ
				AC9->AC9_ENTIDA := oContent:resourceType
				AC9->AC9_FILENT := xFilial(oContent:resourceType)
				AC9->AC9_CODENT := oContent:resourceCode
				AC9->(msUnLock())
			End Transaction
		Endif

		If nError = 0
			oResponse := JsonObject():New()
			oResponse['sucessCode']    := 201
			oResponse['sucessMessage'] := EncodeUTF8(STR0019)  // "Documento incluído com sucesso."
			oResponse['code']          := RTrim(ACB->ACB_CODOBJ)
			oResponse['filename']      := RTrim(cFile)
			oResponse['sizeBytes']     := nFileSize
			If !empty(cWarning)
				oResponse['warning'] := cWarning
			Endif
		Endif
	Endif
Else
	nError := 400
	cError := STR0007  // "Body esperado no formato 'application/json'."
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)


//---------------------------------------------------------------
/*/{Protheus.doc} DELETE
Método responsável por excluir documentos.

@author		Squad CRM/Faturamento
@since		19/07/2018
/*/
//---------------------------------------------------------------
WSMETHOD DELETE WSSERVICE CRMMDOCUMENTS

Local nError     := 0
Local cError     := ""
Local oResponse  := nil
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local cCode      := Self:code
Local cPath      := ""
Local cFile      := ""

Self:SetContentType("application/json")

// Verifica se o parâmetro obrigatório foi passado.
If empty(cCode)
	nError := 400
	cError := STR0006  // "Código do documento não identificado..."
Else
	cQuery := "select AC9.R_E_C_N_O_ AC9RecNo, ACB.R_E_C_N_O_ ACBRecNo, ACC.R_E_C_N_O_ ACCRecNo " + CRLF

	// Entidade x Objeto.
	cQuery += "from " + RetSQLName('AC9') + " AC9 " + CRLF

	// Objeto.
	cQuery += "left join " + RetSQLName('ACB') + " ACB on ACB.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and ACB.ACB_FILIAL = AC9.AC9_FILIAL " + CRLF
	cQuery += "and ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + CRLF

	// Chave de pesquisa.
	cQuery += "left join " + RetSQLName('ACC') + " ACC on ACC.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and ACC.ACC_FILIAL = AC9.AC9_FILIAL " + CRLF
	cQuery += "and ACC.ACC_CODOBJ = AC9.AC9_CODOBJ " + CRLF

	cQuery += "where AC9.D_E_L_E_T_ = '' " + CRLF
	cQuery += "and AC9.AC9_FILIAL = '" + xFilial("AC9") + "' " + CRLF
	cQuery += "and AC9.AC9_CODOBJ = ? " + CRLF

	// Trata SQL para proteger de SQL injection.
	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)

	nSQLParam++
	oStatement:SetString(nSQLParam, cCode)  // Código do objeto.

	cQuery := oStatement:GetFixQuery()
	oStatement:Destroy()
	oStatement := nil

	cAliasSQL := MPSysOpenQuery(cQuery)

	oResponse := JsonObject():New()
	If (cAliasSQL)->(eof())
		nError := 404
		cError := STR0013  // "Documento não foi encontrado no Banco de Conhecimento..."
	Else
		AC9->(dbGoTo((cAliasSQL)->AC9RecNo))
		ACB->(dbGoTo((cAliasSQL)->ACBRecNo))

		// Pega o caminho completo do objeto.
		If lMultDir
			cPath := MsRetPath(ACB->ACB_OBJETO)
		Else
			cPath := MsDocPath()
		Endif
		cFile := MsDocRmvBar(cPath) + "\" + RTrim(ACB->ACB_OBJETO)

		// Monta a mensagem de resposta.
		oResponse['sucessCode']    := 200
		oResponse['sucessMessage'] := EncodeUTF8(STR0012)  // "Documento excluído com sucesso..."
		oResponse["code"] := cCode
		oResponse['resourceType']  := AC9->AC9_ENTIDA
		oResponse['resourceCode']  := RTrim(AC9->AC9_CODENT)
		oResponse['fileName']      := RTrim(ACB->ACB_OBJETO)

		// Apaga o arquivo do servidor e seus registros correspondentes.
		Begin Transaction
			// Apaga o arquivo fisicamente do servidor.
			If FErase(cFile) = 0
				If (cAliasSQL)->ACCRecNo > 0
					Do While (cAliasSQL)->(!eof())
						ACC->(dbGoTo((cAliasSQL)->ACCRecNo))
						RecLock("ACC", .F.)
						ACC->(dbDelete())
						ACC->(msUnLock())
						(cAliasSQL)->(dbSkip())
					EndDo
				Endif

				RecLock("ACB", .F.)
				ACB->(dbDelete())
				ACB->(msUnLock())

				RecLock("AC9", .F.)
				AC9->(dbDelete())
				AC9->(msUnLock())
			Else
				nError := 400
				cError := STR0020  // "Erro ao tentar excluir documento. Falha ao tentar o acesso exclusivo."
			Endif
		End Transaction
	Endif

	(cAliasSQL)->(dbCloseArea())
Endif

If nError = 0
	Self:SetResponse(oResponse:toJson())
Else
	SetRestFault(nError, EncodeUTF8(cError))
Endif

Return (nError = 0)

//-------------------------------------------------------------------
/*/{Protheus.doc} FileSize
Retorna o tamanho do objeto posicionado na tabela AC9.

@Return cSize - Tamanho do objeto em (bytes, KB, MB, GB ou TB).

@author  Felipe Raposo
@since   19/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function FileSize()

Local aLevel     := {"KB", "MB", "GB", "TB", "PB"}
Local cPath      := ""
Local cSize      := ""
Local cFile      := ""
Local lRet	 	 := .F.
Local nBytes     := 0
Local nSize      := 0
Local nLevel     := 0

// Pega o caminho completo do objeto.
If lMultDir
	cPath := MsRetPath(ACB->ACB_OBJETO)
Else
	cPath := MsDocPath()
Endif
cFile := MsDocRmvBar(cPath) + "\" + RTrim(ACB->ACB_OBJETO)

If file(cFile)
	lRet := .T.
	// Tamanho do objeto em bytes.
	nBytes := Directory(cFile)[1, 2]

	// Trata a grandeza do tamanho do arquivo.
	nSize := nBytes / 1024
	Do While nSize > 999 .and. nLevel < len(aLevel)
		nLevel ++
		nSize /= 1024
	EndDo

	cSize := AllTrim(Transform(nSize, "@E 999,999,999,999.99")) + " " + aLevel[nLevel + 1]
Else
	cSize := "0 KB"
Endif

Return {nBytes, cSize, lRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} FileCont
Retorna o conteúdo do objeto posicionado na tabela AC9.

@Return cSize - Tamanho do objeto em (bytes, KB, MB, GB ou TB).

@author  Felipe Raposo
@since   19/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function FileCont()

Local cFileCont  := ""
Local cPath      := ""
Local cFile      := ""
Local nHandle    := 0
Local nFileSize  := 0
Local lCompact   := .T.
Local lChgCase   := .F.

// Pega o caminho completo do objeto.
If lMultDir
	cPath := MsRetPath(ACB->ACB_OBJETO)
Else
	cPath := MsDocPath()
Endif
cFile := MsDocRmvBar(cPath) + "\" + RTrim(ACB->ACB_OBJETO)

nHandle := FOpen(cFile, FO_READ,, lChgCase)

If nHandle > 0 
	nFileSize := FSeek(nHandle, 0, FS_END)
	FSeek(nHandle, FS_SET)
	FRead(nHandle, @cFileCont, nFileSize)
	FClose(nHandle)
	
	cFileCont := Encode64(cFileCont,, lCompact, lChgCase)
EndIf

Return cFileCont


//-------------------------------------------------------------------
/*/{Protheus.doc} VldChave
Valida a chave da entidade passada.

@return lReturn		- lógico   - Indica se a chave foi validada.

@author  Felipe Raposo
@since   20/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldChave(cEntidade, cChave)

Local lReturn    := .F.
Local nRelation  := 0
Local aFields    := {}
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local cFldFilial := ""
Local nSQLParam  := 0
Local nPos       := 0
Local nLen       := 0
Local nX

// Relação de entidades x campos chave.
Static aEntidade := MsRelation()

// Busca a relação da entidade.
nRelation := aScan(aEntidade, {|aChave| aChave[1] == cEntidade})
If nRelation > 0
	cQuery := "select min(A.R_E_C_N_O_) MINRecNo, max(A.R_E_C_N_O_) MAXRecNo " + CRLF
	cQuery += "from " + RetSQLName(cEntidade) + " A " + CRLF
	cQuery += "where A.D_E_L_E_T_ = ' ' " + CRLF

	cFldFilial := PrefixoCpo(cEntidade) + "_FILIAL"
	If (cEntidade)->(FieldPos(cFldFilial)) > 0
		cQuery += "and A." + cFldFilial + " = '" + xFilial(cEntidade) + "' " + CRLF
	Endif

	// Monta a chave de pesquisa.
	aFields := aEntidade[nRelation, 2]
	For nX := 1 to len(aFields)
		cQuery += "and " + aFields[nX] + " = ? " + CRLF
	Next nX

	// Trata SQL para proteger de SQL injection.
	nPos := 1
	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	For nX := 1 to len(aFields)
		nLen := TamSX3(aFields[nX])[1]
		nSQLParam++
		oStatement:SetString(nSQLParam, SubStr(cChave, nPos, nLen))
		nPos += nLen
	Next nX
	cQuery := oStatement:GetFixQuery()
	oStatement:Destroy()
	oStatement := nil

	cAliasSQL := MPSysOpenQuery(cQuery)

	// Verifica se encontrou registro único para a chave.
	lReturn := (cAliasSQL)->(!eof() .and. MINRecNo = MAXRecNo)

	(cAliasSQL)->(dbCloseArea())
Endif

Return lReturn
