#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "JURRESTFUN.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL JurRESTFun DESCRIPTION STR0011 // "Funções do PFS"
	WSDATA LEGALDESK  AS STRING

	WSMETHOD POST WoTsCreate DESCRIPTION STR0012 PATH "wo-ts" // "Wo em lote de Timesheet"
	WSMETHOD POST WoCancel   DESCRIPTION STR0014 PATH "wo-can" // "Cancelamento de WO em lote"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST WoTsCreate
Função POST para executar ações conforme parâmetro passado na URL.

@author bruno.ritter
@since 25/04/2017
/*/
//-------------------------------------------------------------------
WSMETHOD POST WoTsCreate HEADERPARAM LEGALDESK WSRESTFUL JurRESTFun
Local lRet       := .T.
Local cTpBody    := ""
Local cAccept    := Self:GetAccept()
Local aRetFun    := {.T.,{0,""},""}
Local lLegalDesk := .F.

If !Empty(SELF:LEGALDESK)
	lLegalDesk := Upper(SELF:LEGALDESK) == "TRUE"
EndIf

If lLegalDesk
	JurSetLD(lLegalDesk)

	// Identificando o tipo do Body
	If !Empty(cAccept) .And. ValType(cAccept) == "C"
		cTpBody := Upper(Substr(cAccept, At("/",cAccept)+1))
	EndIf

	If Empty(cTpBody) .Or. (cTpBody != "JSON" .And. cTpBody != "XML")
		SetRestFault(400, EncodeUTF8(STR0006)) // "Não foi possível ler o Body, é apenas aceito JSON ou XML"
		lRet := .F.
	EndIf

	// Executando a função
	If lRet
		aRetFun := JurRtWoTs(Self, cTpBody, "wo-ts")
	EndIf

	If !aRetFun[1]
		If Len(aRetFun[2]) > 1
			SetRestFault(aRetFun[2][1], EncodeUTF8(aRetFun[2][2]), , aRetFun[2][1], EncodeUTF8(aRetFun[2][2]))
		Else
			SetRestFault(500, EncodeUTF8(STR0004)) //"Erro não identificado"
		EndIf
		lRet := .F.
	Else
		Self:SetResponse(aRetFun[3])
	EndIf
Else
	lRet := .F.
EndIf

JurSetLD(.F.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurRtWoTs()
Função para executar WO em lote de Time Sheets.

@param oWsRestFul   - Objeto do Rest 'WSRESTFUL'
@param cTpBody      - Tipo do Body (JSON, XML)
@param cTpMsg       - Tipo da Mensagem "wo-ts", "wo-can"

@return - aRet - aRet[1]    Retorno se foi executado a função de WO em Lote
                 aRet[2][1] Código de erro HTTP
                 aRet[2][2] Mensagem de erro
                 aRet[3]    Retorno em XML ou JSON, dependedo do Body que foi enviado

@author bruno.ritter
@since 25/04/2017
/*/
//-------------------------------------------------------------------
Static Function JurRtWoTs (oWsRestFul, cTpBody, cTpMsg)
Local aRet      := {.T.,{0,""},""}
Local aRetFun   := {}
Local aCodTs    := {}
Local cCodMotv  := ""
Local cCodPart  := ""
Local cMsgWo    := ""
Local nI        := 1
Local nY        := 1
Local cErro     := ""
Local cAviso    := ""
Local oJson     := Nil
Local oXml      := Nil
Local oXmlParam := Nil
Local oXmlACdTs := Nil
Local cResp     := ''
Local nLenRetF  := 0
Local cContent  := ""
Local cCodFil   := "_CCODTS"
Local aCodWO    := {}
Local cCodPai   := "_ACODTS"
Local cCodWo    := ""
Local oResponse := Nil 
Local nWO       := 0
Local nTS       := 0

//------------------------------------------------------
// Leitura do Body
//------------------------------------------------------
cContent  := oWsRestFul:GetContent()

If !Empty(cContent)

	// XML
	If cTpBody == "XML"

		oXml := XmlParser(cContent, "_",@cErro,@cAviso)
		If oXml <> Nil
			
			oXmlParam := XmlChildEx(oXml, "_PARAMETROS")
			If oXmlParam <> Nil

				// Código de Time Sheet
				If cTpMsg == "wo-ts"

					oXmlACdTs := XmlChildEx(oXmlParam, cCodPai)
					If oXmlACdTs <> Nil .And. XmlChildEx(oXmlACdTs, cCodFil) <> Nil
						
						If (ValType(oXmlACdTs:_CCODTS) == "A")
							
							For nI := 1 To Len(oXmlACdTs:_CCODTS)
								Aadd(aCodTs, oXmlACdTs:_CCODTS[nI]:TEXT)
							Next nI
						Else
							Aadd(aCodTs,  oXmlACdTs:_CCODTS:TEXT)
						EndIf
					EndIf
				Else
					cCodPai := "_ACODIGOWO"
					cCodFil := "_CCODIGOWO"
					oXmlACdTs := XmlChildEx(oXmlParam, cCodPai)

					If oXmlACdTs <> Nil .And. XmlChildEx(oXmlACdTs, cCodFil) <> Nil

						If (ValType(oXmlACdTs:_CCODIGOWO) == "A")
							
							For nI := 1 To Len(oXmlACdTs:_CCODIGOWO)
								Aadd(aCodWO, oXmlACdTs:_CCODIGOWO[nI]:TEXT)
							Next nI
						Else
							Aadd(aCodWO, oXmlACdTs:_CCODIGOWO:TEXT)
						EndIf
					EndIf
				EndIf

				// Código do Motivo de WO
				If XmlChildEx(oXmlParam, "_CCODMOTV") <> Nil
					cCodMotv := oXmlParam:_CCODMOTV:TEXT
				Else
					cCodMotv := ""
				EndIf

				// Código do Participante do WO
				If XmlChildEx(oXmlParam, "_CCODPART") <> Nil
					cCodPart := oXmlParam:_CCODPART:TEXT
				Else
					cCodPart := ""
				EndIf

				// Observação do WO
				If XmlChildEx(oXmlParam, "_CMSGWO") <> Nil
					cMsgWo := oXmlParam:_CMSGWO:TEXT
				Else
					cMsgWo := ""
				EndIf
			Else
				aRet[1]    := .F.
				aRet[2][1] := 400
				aRet[2][2] := STR0005 // "Não foi possível encontrar TAG de 'PARAMETROS' no XML"
			EndIf
		Else
			aRet[1]    := .F.
			aRet[2][1] := 400
			aRet[2][2] := STR0006 // "Não foi possível ler o Body, é apenas aceito JSON ou XML"
		EndIF
	EndIf

	//JSON
	If cTpBody == "JSON"
		oJson := JsonObject():New()
		oJson:fromJson(cContent)
		cCodFil := IIf(cTpMsg == "wo-ts", "aCodTs", "acodigoWO")
		
		If ValType(oJson) == "J"
			
			If cTpMsg == "wo-ts"
				aCodTs := Iif(oJson[cCodFil] <> Nil, oJson[cCodFil], {})
			Else
				aCodWO := Iif(oJson[cCodFil] <> Nil, oJson[cCodFil], {})
			EndIf

			cCodMotv := Iif(oJson['cCodMotv'] <> Nil, oJson['cCodMotv'], "")
			cCodPart := Iif(oJson['cCodPart'] <> Nil, oJson['cCodPart'], "")
			cMsgWo   := Iif(oJson['cMsgWo'] <> Nil, DecodeUTF8(oJson['cMsgWo']), "")
		Else
			aRet[1]    := .F.
			aRet[2][1] := 400
			aRet[2][2] := STR0006 // "Não foi possível ler o Body, é apenas aceito JSON ou XML"
		EndIf
	EndIf

Else
	aRet[1]    := .F.
	aRet[2][1] := 400
	aRet[2][2] := STR0006 // "Não foi possível ler o Body, é apenas aceito JSON ou XML"
EndIf

//------------------------------------------------------
// Validação básica
//------------------------------------------------------
If aRet[1]
	
	// Observação do WO
	If aRet[1] .And. Empty(cMsgWo)
		aRet[1]    := .F.
		aRet[2][1] := 400
		aRet[2][2] := Iif(cTpMsg == "wo-can", "01 - ", "") + STR0007 // "A observação do WO 'cMsgWo' é um campo obrigatório!"
	EndIf
	
	// Código do Participante do WO
	If aRet[1] .And. !ExistCpo("RD0",cCodPart,1)
		aRet[1]    := .F.
		aRet[2][1] := 400
		aRet[2][2] := Iif(cTpMsg == "wo-can", "02 - ", "") + STR0008 // "O código de participante 'cCodPart' está inválido!"
	EndIf
	
	// Código do Motivo de WO
	If aRet[1] .And. (Empty(cCodMotv) .Or. !JurVldMot("1", .T., .F., Iif(cTpMsg == "wo-ts", "NXVEMI", "NXVCAN ") , cCodMotv, "", "1" ) )//timeshet")
		aRet[1]    := .F.
		aRet[2][1] := 400
		aRet[2][2] := Iif(cTpMsg == "wo-can", "03 - ", "") + STR0009 // "O código do motivo de WO 'cCodMotv' está inválido!"
	EndIf
	
	// Código de Time Sheet / Código de WO
	If cTpMsg == "wo-ts" 
		If aRet[1] .And. Len(aCodTs) < 1
			aRet[1]    := .F.
			aRet[2][1] := 400
			aRet[2][2] := STR0010 // "É obrigatório informar ao menos um Time Sheet 'aCodTs'/'cCodTs'!"
		EndIf
	Else
		If aRet[1] .And. Len(aCodWO) < 1
			aRet[1]    := .F.
			aRet[2][1] := 400
			aRet[2][2] := "04 - " + STR0013 // "É obrigatório informar ao menos um WO! 'acodigoWO'/'ccodigoWO'!"
		EndIf
	EndIf
EndIf

//------------------------------------------------------
// Execução da Função
//------------------------------------------------------
If aRet[1]

	If cTpMsg == "wo-ts"
		aCodTs := JDelDuplic(aCodTs)
		aRetFun := Ja145WoTs(aCodTs, cCodMotv, cMsgWo, cCodPart)
		aSort(aRetFun,,,{|x,y| x[2] < y[2]})
	Else
		aCodWO := JDelDuplic(aCodWO)
		aRetFun := Ja146WoCan(aCodWO, cCodMotv, cMsgWo, cCodPart)
	EndIf
	//------------------------------------------------------
	// Preparar o Retorno
	//------------------------------------------------------
	nLenRetF := Len(aRetFun)
	
	If cTpBody == "XML" // Criando XML do retorno
		oWsRestFul:SetContentType("application/xml")
		cResp := "<?xml version='1.0' encoding='UTF-8'?>"
		cResp += "<" + cTpMsg + ">"

		For nY := 1 To nLenRetF

			cCodWo := Iif( cTpMsg == "wo-ts", aRetFun[nY][2], aRetFun[nY][1] )
			cCodWo := Iif( Empty(cCodWo), " - ", cCodWo )

			If cTpMsg == "wo-ts"

				If nY == 1
					cResp += "<wo>"
					cResp +=     "<codigoWO>" + cCodWo + "</codigoWO>"
				ElseIf cCodWo != Iif( cTpMsg == "wo-ts", aRetFun[nY-1][2], aRetFun[nY-1][1] )
					cResp += "</wo>"
					cResp += "<wo>"
					cResp +=     "<codigoWO>" + cCodWo + "</codigoWO>"
				EndIf

				cResp +=         "<timeSheet>"
				cResp +=             "<codigoTS>" + aRetFun[nY][1] + "</codigoTS>"
				cResp +=             "<message> " + EncodeUTF8(aRetFun[nY][3]) + "</message>"
				cResp +=         "</timeSheet>"
			Else
				cResp += "<wo>"
				cResp +=     "<codigoWO>" + cCodWo + "</codigoWO>"
				cResp +=     "<situac>" + aRetFun[nY][2] + "</situac>" 
				cResp +=     "<Obs>" + EncodeUTF8(aRetFun[nY][3]) + "</Obs>" 
				cResp +=     "<codErr>" + aRetFun[nY][4] + "</codErr>" 
				cResp += "</wo>"
			EndIf
		Next nY
		
		If cTpMsg == "wo-ts"
			cResp += "</wo>"
		Endif

		cResp += "</" + cTpMsg + ">"

		aRet[3] := cResp

	Else // Criando JSON do retorno
		oWsRestFul:SetContentType("application/json")
		oResponse := JsonObject():New()
		oResponse[cTpMsg] := {}

		For nY := 1 To nLenRetF
			cCodWo := Iif( cTpMsg == "wo-ts", aRetFun[nY][2], aRetFun[nY][1] )
			cCodWo := Iif( Empty(cCodWo), " - ", cCodWo )
			If nY == 1
				nWO := 0
			EndIf

			If nY == 1 .Or. cCodWo != Iif( cTpMsg == "wo-ts", aRetFun[nY-1][2], aRetFun[nY-1][1] )
				nWO ++
				nTS := 1
				Aadd(oResponse[cTpMsg], JsonObject():New())
				oResponse[cTpMsg][nWO]['codWo']:= cCodWo
				If cTpMsg == "wo-ts"
					oResponse[cTpMsg][nWO]['timeSheets']:= {}
				EndIf
			Else
				nTS ++
			EndIf

			If cTpMsg == "wo-ts"
				Aadd(oResponse[cTpMsg][nWO]['timeSheets'], JsonObject():New())
				oResponse[cTpMsg][nWO]['timeSheets'][nTS]['codTs']:= aRetFun[nY][1]
				oResponse[cTpMsg][nWO]['timeSheets'][nTS]['message']:= EncodeUTF8(aRetFun[nY][3])
			Else
				oResponse[cTpMsg][nWO]['situac']:= aRetFun[nY][2]
				oResponse[cTpMsg][nWO]['Obs']:=  EncodeUTF8(aRetFun[nY][3])
				oResponse[cTpMsg][nWO]['codErr']:= aRetFun[nY][4]
			EndIf

		Next nY

		aRet[3] := oResponse

	EndIf
	
EndIf

Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} JDelDuplic
Remove os registros duplicados de TS ou WO para evitar o reprocessamento dos mesmos

@since 03/08/2022
@version 1.0
@param aArray, array, Array contendo a listagem dos TS ou dos WS
@return aRet, retorna o arry somente com os registros unicos
/*/
//------------------------------------------------------------------------------
Static Function JDelDuplic(aArray)
Local aRet     := {}
Local cAux     := ""
Local nLen     := 0
Local nY       := 1
Default aArray := {}

	aRet := aClone(aArray)
	nLen := Len(aRet)
	WHILE nY <= nLen
		
		If !(Alltrim(aRet[nY])+"|" $ cAux)
			cAux += Alltrim(aRet[nY])+"|"
			nY++
		Else
			aDel(aRet,nY)
			aSize(aRet,Len(aRet)-1)
			nLen := Len(aRet)
		Endif
	End

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST WoCancel
Função POST para executar o cancelamento dos WOs.

@author fabiana.silva
@since 22/04/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST WoCancel HEADERPARAM LEGALDESK WSRESTFUL JurRESTFun
Local lRet       := .T.
Local cTpBody    := ""
Local cAccept    := Self:GetAccept()
Local aRetFun    := {.T., {0, ""}, ""}
Local lLegalDesk := .F.

	If !Empty(SELF:LEGALDESK)
		lLegalDesk := Upper(SELF:LEGALDESK) == "TRUE"
	EndIf

	If lLegalDesk
		JurSetLD(lLegalDesk)

		// Identificando o tipo do Body
		If !Empty(cAccept) .And. ValType(cAccept) == "C"
			cTpBody := Upper(Substr(cAccept, At("/",cAccept) + 1))
		EndIf

		If Empty(cTpBody) .Or. (cTpBody != "JSON" .And. cTpBody != "XML")
			SetRestFault(400, EncodeUTF8(STR0006)) // "Não foi possível ler o Body, é apenas aceito JSON ou XML"
			lRet := .F.
		EndIf

		// Executando a função
		If lRet
			aRetFun := JurRtWoTs(Self, cTpBody, "wo-can")
		EndIf

		If !aRetFun[1]
			
			If Len(aRetFun[2]) > 1
				SetRestFault(aRetFun[2][1], EncodeUTF8(aRetFun[2][2]), , aRetFun[2][1], EncodeUTF8(aRetFun[2][2]))
			Else
				SetRestFault(500, EncodeUTF8(STR0004)) //"Erro não identificado"
			EndIf
			lRet := .F.
		Else
			Self:SetResponse(aRetFun[3])
		EndIf
	Else
		lRet := .F.
	EndIf

	JurSetLD(.F.)

Return lRet

