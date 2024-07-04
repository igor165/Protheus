#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURUTIL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurUtil
Classe WS do Jurídico para métodos utilitários

@since 12/01/21
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL JurUtil DESCRIPTION STR0001 //"WS Júridico Utilitário"

	WSDATA fields        AS String
	WSDATA assunto       AS String
	WSDATA login         AS STRING
	WSDATA lTeste        AS BOOLEAN

	WSMETHOD GET getVersion        DESCRIPTION STR0002 PATH "getVersion"               PRODUCES APPLICATION_JSON // "Busca a versão do SIGAJURI"
	WSMETHOD GET getStructField    DESCRIPTION STR0003 PATH "structField"              PRODUCES APPLICATION_JSON // "Busca a estrutura de um determinado campo"
	WSMETHOD GET getCfgLegalMatter DESCRIPTION STR0004 PATH "cfgLegalMatter/{assunto}" PRODUCES APPLICATION_JSON // "Busca a configuração de um determinado assunto jurídico"
	WSMETHOD GET getUsrAdm         DESCRIPTION STR0006 PATH "getUsrAdm"                PRODUCES APPLICATION_JSON // "Valida se o usuário é do tipo admin"
	WSMETHOD GET jurUserExists     DESCRIPTION STR0007 PATH "jurUserExists/{login}"    PRODUCES APPLICATION_JSON // "Verifica se o login já existe na tabela de usuários"

	WSMETHOD POST pdfToText        DESCRIPTION STR0005 PATH "pdfToText"                PRODUCES APPLICATION_JSON // "Converte um pdf para texto"
	WSMETHOD POST updtCGC          DESCRIPTION STR0008 PATH "updtCGC"                  PRODUCES APPLICATION_JSON // "Realiza alteração de CPF / CNPJ da parte contrária"
	WSMETHOD POST downloadPDF      DESCRIPTION STR0009 PATH "downloadPDF"              PRODUCES APPLICATION_JSON // "Realiza o download de arquivo PDF e lê a partir do robô de iniciais"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} getVersion
Retorna a versão atual do Sigajuri
@since 12/01/21
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD GET getVersion WSREST JurUtil

	Self:SetContentType("application/json")
	Self:SetResponse('{"version":"2.08"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getStructField
Busca a estrutura de um determinado campo

@since 08/03/21
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET getStructField WSReceive fields WSREST JurUtil
Local oResponse := JsonObject():New()
Local cFields   := Self:fields
Local cBox      := ''
Local cF3       := ''
Local nI        := 1
Local aFields   := {}

	If !Empty(cFields)
		Self:SetContentType("application/json")
		oResponse['fields'] := {}

		aFields := StrToArray( cFields, ',' )

		// Pega os campos que são obrigatórios ou customizados
		For nI := 1 To Len(aFields)
			If AllTrim(getSx3Cache(aFields[nI] ,'X3_CAMPO')) == AllTrim(aFields[nI])
				Aadd(oResponse['fields'], JsonObject():New())
				oResponse['fields'][nI]['tabela']      := getSx3Cache(aFields[nI] ,'X3_ARQUIVO')
				oResponse['fields'][nI]['campo']       := aFields[nI]
				oResponse['fields'][nI]['titulo']      := JurConvUTF8(getSx3Cache(aFields[nI] ,'X3_TITULO'))
				oResponse['fields'][nI]['tamanho']     := getSx3Cache(aFields[nI] ,'X3_TAMANHO')
				oResponse['fields'][nI]['isCustom']    := ('_X' $ aFields[nI] ) .Or. ( '__' $ aFields[nI] )
				oResponse['fields'][nI]['isVisual']    := getSx3Cache(aFields[nI], 'X3_VISUAL') == 'V'
				oResponse['fields'][nI]['agrupamento'] := getSx3Cache(aFields[nI], 'X3_AGRUP')

				cBox := getSx3Cache(aFields[nI] ,'X3_CBOX')
				cF3  := getSx3Cache(aFields[nI] ,'X3_F3')

				// Campos combobox
				If !Empty(cBox)
					oResponse['fields'][nI]['tipo'] := 'CB'

				// Campos F3
				ElseIf !Empty(cF3)
					oResponse['fields'][nI]['tipo']     := 'F3'
					oResponse['fields'][nI]['XB_ALIAS'] := AllTrim(cF3)

				// Demais campos
				Else
					oResponse['fields'][nI]['tipo'] := getSx3Cache(aFields[nI] ,'X3_TIPO')
				EndIf
			EndIf
		Next

		oResponse['length'] := Len(aFields)
	Else
		oResponse['length'] := 0
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	aSize(aFields, 0)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getCfgLegalMatter
Retorna as configurações de um determinado tipo de assunto jurídico.

@param assunto: Tipo de assunto jurídico que deseja validar

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JurUtil/{assunto}
/*/
//-------------------------------------------------------------------
WSMETHOD GET getCfgLegalMatter WSRECEIVE assunto WSREST JurUtil
Local cAssPadrao := "001|002|003|004|005|006|007|008|009|010|011|012" // Assuntos Jurídico padrão
Local cAssJur    := Self:assunto
Local oResponse  := Nil
Local aWidgets   := {}
Local nX         := 0
Local nCont      := 1
Local cGrids     := ""
Local cWidgets   := ""

	/* Código das rotinas de acordo com a tabela JX da SX5:
		01 - Incidentes
		02 - Vinculados
		03 - Anexos
		04 - Andamentos
		05 - Follow-ups
		06 - Objetos
		07 - Garantias
		08 - Despesas
		09 - Contrato Correspondente
		10 - Faturamento
		11 - Histórico (de justificativas - processo encerrado / correspondente)
		12 - Exportação Personalizada
		13 - Relatório
		14 - Processos
		15 - Concessões
		16 - Correção Monetária
		17 - Relacionados
		18 - Alterações em Lote
		19 - Solicitação de Documento
		20 - Liminares

		Rotinas que precisam ser cadastradas na tabela JX da SX5:
		- e-Social
		- Causa Raiz

	Grids:
		NT9 - Envolvidos
		NUQ - Instâncias
		NYP - Acordos / Negociações
		NYX - Aditivos
		NYJ - Unidades
	*/

	// Se o assunto não é padrão busca o pai para apresentar as mesma widgets do api no resumo
	If !(cAssJur $ cAssPadrao)
		cAssJur := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')
	EndIf

	cGrids := JA095TabAj(cAssJur)

	// Verifica quais rotinas o resumo poderá apresentar de acordo com o assunto
	Do Case
		Case cAssJur == "001" // Contencioso
			cWidgets := "01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20"

		Case cAssJur == "002" // Criminal
			cWidgets := "01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19"

		Case cAssJur $ "003|004" // Administrativo / Cade
			cWidgets := "01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "005" // Consultivo
			cWidgets := "02|03|04|05|08|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "006" // Contratos
			cWidgets := "02|03|04|05|08|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "007" // Procurações
			cWidgets := "02|03|04|05|08|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "008" // Societário
			cWidgets := "01|02|03|04|05|08|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "009" // Ofícios
			cWidgets := "02|03|04|05|08|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "010" // Licitações
			cWidgets := "01|02|03|04|05|08|11|12|13|14|15|16|17|18|19"

		Case cAssJur == "011" // Marcas e Patentes
			cWidgets := "02|03|04|05|08|11|12|13|14|15|16|17|18|19|20"
	End Case

	If !Empty(cWidgets) 
		aWidgets := StrTokArr(cWidgets, "|")
		If Len(aWidgets) > 0

			Self:SetContentType("application/json")
			oResponse  := JsonObject():New()
			oResponse['routineLegalMatter'] := {}

			// Verifica quais rotinas permitidas para o usuário podem ser apresentadas no resumo
			For nX := 1 To Len(aWidgets)
				Aadd(oResponse['routineLegalMatter'], JsonObject():New())
				oResponse['routineLegalMatter'][nCont] := aWidgets[nX]
				nCont ++
			Next nX
		EndIf
	EndIf

	oResponse['grids'] := StrTokArr(cGrids, "|")
	oResponse['hasESocial'] := cAssJur $ "001|003|004"
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JurConvUTF8(cValue)
Formata o valor em UTF8 e retira os espaços

@param cValue - Conteúdo a ser convertido

@since 08/03/2021
/*/
//-------------------------------------------------------------------
Function JurConvUTF8(cValue)
Local cReturn := ""
	cReturn := JurEncUTF8(Alltrim(cValue))
Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} POST pdfToText
Retorna o arquivo pdf em texto.

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JurUtil/pdfToText
/*/
//-------------------------------------------------------------------
WSMETHOD POST pdfToText WSREST JurUtil
Local oResponse   :=  Nil
Local cBody       := Self:GetContent()
Local nTamArquivo := 0
Local nHDestino   := 0
Local cContent    := HTTPHeader("content-type")
Local cLimite     := SubStr(cContent,At("boundary=",cContent)+9)
Local cFile       := "" //conteúdo do arquivo
Local cArquivo    := ""
Local cFileName   := ""
Local cSpool      := "\spool\"

	cFileName := SubStr(cBody,At('filename="',cBody)+10, At('"',SubStr(cBody,At('filename="',cBody)+10,200))-1)
	cFileName := decodeUTF8(AllTrim(cFileName))

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cSpool := StrTran(cSpool,"\","/")
	Endif

	cArquivo  := cSpool + cFileName
	cFile := SubStr(SubStr(SubStr(cBody,;
		At("Content-Type:",;
		cBody)+12),;
		At(Chr(10),;
		SubStr(cBody,At("Content-Type:",cBody)+12))+3),;
		1,;
		At(cLimite,SubStr(SubStr(cBody,At("Content-Type:",cBody)+12),;
		At(Chr(10),;
		SubStr(cBody,At("Content-Type:",cBody)+12))+3))-5)
	
	nTamArquivo := Len(cFile)

	nHDestino := FCREATE(cArquivo)
	nBytesSalvo := FWRITE(nHDestino, cFile,nTamArquivo)
	FCLOSE(nHDestino)

	cBody := J268PdfTxt(cArquivo)

	FErase(cArquivo)

	oResponse := JsonObject():New()
	oResponse['body'] := cBody

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

RETURN .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getUsrAdm
Verifica se o usuário logado pertence ao grupo de Administradores

@since 02/12/2021
/*/
//-------------------------------------------------------------------
WSMETHOD GET getUsrAdm WSREST JurUtil

Local cValidUser := IIF( FWIsAdmin(__cUSERID), "true", "false" )

	Self:SetContentType("application/json")
	Self:SetResponse('{"isAdmin":"' + cValidUser + '"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} jurUserExists
Verifica se o login já existe na tabela de usuários

@param login - login de usuário
@since 02/12/2021
/*/
//-------------------------------------------------------------------
WSMETHOD GET jurUserExists PATHPARAM login WSREST JurUtil

Local cCodUser  := IIF( VALTYPE(self:login) == 'C', RetCodUsr(Alltrim(self:login)), '')
Local oResponse := JSonObject():New()

	Self:SetContentType("application/json")

	oResponse['exists'] := !Empty(ALLTRIM(cCodUser))
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST updtCGC
Realiza alteração de CPF / CNPJ da parte contrária.

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JurUtil/updtCGC
body - { chave: "0000000001", cpfCnpj: "40979937043" }
/*/
//-------------------------------------------------------------------
WSMETHOD POST updtCGC WSREST JurUtil

Local oRequest    := JsonObject():New()
Local oResponse   := JSonObject():New()
Local cBody       := Self:GetContent()
Local lAlterou    := .F.

	oRequest:FromJson(cBody)

	lAlterou := WSJUGetReg( oRequest )

	Self:SetContentType("application/json")
	oResponse['okay'] := lAlterou
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJUGetReg( oRequest )

@param  oRequest - Objeto com os dados do registro a ser alterado
@return lGravou - Indica se realizou a gravação

@since 04/02/2022
/*/
//-------------------------------------------------------------------
Static Function WSJUGetReg( oRequest )

Local cChave  := oRequest['chave']
Local cCGC    := oRequest['cpfCnpj']
Local cTabela := "NZ2"
Local lGravou := .F.
Local nOrder  := 1

	If !Empty(cChave)

		DbSelectArea(cTabela)
		(cTabela)->(DbSetOrder(nOrder))

		If (cTabela)->(DbSeek( xFilial(cTabela) + cChave ))
			lGravou := (cTabela)->(RecLock( (cTabela), .F. ))
				NZ2_CGC := cCGC
			(cTabela)->(MsUnlock())
		EndIf

		(cTabela)->(DbCloseArea())
	EndIf

Return lGravou

//-------------------------------------------------------------------
/*/{Protheus.doc} POST downloadPDF
Realiza a baixa do arquivo pdf e em seguida lê o conteúdo com o robo de
iniciais

@param lTeste - Indica se irá utilizar o robo de iniciais localmente para teste
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JurUtil/downloadPDF
		body { "link": "http://fiquedigital.oabrj.org.br/upload/teste.pdf" }
/*/
//-------------------------------------------------------------------
WSMETHOD POST downloadPDF WSRECEIVE lTeste WSREST JurUtil

Local oRest       := Nil
Local oRequest    := JSonObject():New()
Local oResponse   := JsonObject():New()
Local cBody       := Self:GetContent()
Local cTemp       := MsDocPath() + "\totvslegal\"
Local cNomeArq    := JurTimeStamp(1) + "_" + __CUSERID + '.pdf'
Local cDownload   := ""
Local cPath       := ""
Local cPathSpool  := ""
Local cErros      := ""
Local nHandle     := 0
Local nI          := 0
Local lErro       := .F.
Local lTeste      := Self:lTeste
Local aRetAPI     := {}

	oRequest:fromJson(cBody)

	If !Empty(oRequest['link'])
		cPath := DecodeUTF8( oRequest['link'] )
		oRest := FWRest():New("")
		cPath := FWURIDecode(cPath)
		oRest:SetPath( FWURIEncode(cPath) )

		If oRest:Get({})

			// Download do arquivo
			cDownload := oRest:GetResult()

			// Verifica se diretorio temporario existe
			If !JurMkDir(cTemp)
				lErro := .T.
			EndIf

			// Grava arquivo no servidor
			If !lErro .And. ( nHandle := FCreate(cTemp + cNomeArq, FC_NORMAL) ) < 0
				lErro := .T.
			EndIf

			If !lErro
				If FWrite(nHandle, cDownload) < Len(cDownload)
					lErro := .T.
				EndIf

				If !lErro .And. !FClose(nHandle)
					lErro := .T.
				EndIf
			EndIf

			If lErro
				cErros += FError()
			EndIf

			If !lErro
				cPathSpool := IIF( "Linux" $ GetSrvInfo()[2], "/spool/", "\spool\" )
				__copyfile( cTemp + cNomeArq, '\spool\' + cNomeArq)

				// Aguarda a geração do arquivo
				nI := 0
				While !File('\spool\' + cNomeArq) .And. nI < 10 
					nI++
					Sleep(1000)
				EndDo

				cBody := J268PdfTxt(cTemp + cNomeArq)

				If !Empty(cBody)
					aRetAPI   := J268ReqApi(cBody, lTeste)
				EndIf
			EndIf

			If Empty(cBody) .OR. Len(aRetAPI) == 0
				lErro := .T.
				cErros += STR0010 + cNomeArq  // " Não foi possível obter o conteúdo do arquivo "
			EndIf

		Else
			If VALTYPE(oRest:CINTERNALERROR) <> "U"
				lErro := .T.
				cErros := I18n(STR0011 + cNomeArq + CRLF) // 'Não foi possível fazer o download do arquivo: '
				cErros += I18n(STR0012  + oRest:CINTERNALERROR + CRLF) // 'Erro: ' 
				JurConout( cErros )
			EndIf
		EndIf
	EndIf

	If lErro
		SetRestFault(415, cErros)

	Else
		Self:SetContentType("application/json")

		If Len(aRetAPI) > 0
			oResponse := J268GetNT9(aRetAPI)
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		EndIf
	EndIf

	FErase(cTemp + cNomeArq)
	FwFreeObj(oRest)

Return !lErro
