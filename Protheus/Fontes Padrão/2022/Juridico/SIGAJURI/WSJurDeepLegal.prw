#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURUTIL.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurDeepLegal
Classe WS do Jurídico para métodos utilizados na integração com o DeepLegal

@since 01/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL JURDEEPLEGAL DESCRIPTION STR0001 //"WS Júridico Deep Legal"

	WSDATA cajuri       AS STRING
	WSDATA filial       AS STRING

	WSMETHOD GET QtdProcEnv   DESCRIPTION STR0002 PATH "qtyProcessesSended" PRODUCES APPLICATION_JSON // "Busca a quantidade de processos enviados para o DeepLegal"
	WSMETHOD PUT MarcaProcEnv DESCRIPTION STR0003 PATH "processSendedMark"  PRODUCES APPLICATION_JSON // "Marca a instância como enviada para o Deep Legal"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdProcEnv
Busca a quantidade de processos enviados ao DeepLegal 
@since 01/12/2021

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURDEEPLEGAL/qtyProcessesSended
/*/
//-------------------------------------------------------------------

WSMETHOD GET QtdProcEnv WSREST JURDEEPLEGAL
Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local oResponse  := JsonObject():New()
Local cQuery     := ''
Local lDicDeepL  := .F.
Local lRet       := .T.

	// Verifica se o campo de id da carteira Deep Legal existe no dicionário
	If Select("NUH") > 0
		lDicDeepL := (NUH->(FieldPos('NUH_IDEEPL')) > 0) .And. (NUQ->(FieldPos('NUQ_DEEPL')) > 0)
	Else
		DBSelectArea("NUH")
			lDicDeepL := (NUH->(FieldPos('NUH_IDEEPL')) > 0) .And. (NUQ->(FieldPos('NUQ_DEEPL')) > 0)
		NUH->( DBCloseArea() )
	EndIf

	If lDicDeepL
		cQuery := " SELECT COUNT(1) QTD FROM " + RetSqlName('NUQ') + " NUQ "
		cQuery += " WHERE NUQ.NUQ_DEEPL = 'T' "
		cQuery += " AND NUQ.D_E_L_E_T_ = '' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		Self:SetContentType("application/json")

		oResponse['quantidade'] := 0

		If (cAlias)->(!Eof())
			oResponse['quantidade'] := (cAlias)->QTD
		EndIf

		(cAlias)->( DbCloseArea() )
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))	
	Else
		lRet := .F.
		SetRestFault(404, STR0004) // "Atualização de dicionário de dados necessária."
	EndIf

	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT MarcaProcEnv
Atualiza o status de envio do processo para o Deep Legal

@since 04/10/2019
@param filial   - Codigo da filial
@param cajuri   - Codigo do processo

@example [Sem Opcional] PUT -> http://127.0.0.1:9090/rest/JURDEEPLEGAL/processSendedMark?filial='        '&cajuri='0000000001'
/*/
//-------------------------------------------------------------------
WSMETHOD PUT MarcaProcEnv WSRECEIVE filial, cajuri WSREST JURDEEPLEGAL

Local aArea      := GetArea()
Local aAreaNUQ   := NUQ->(GetArea())
Local lRet       := .F.
Local cFilCajuri := Self:filial
Local cCajuri    := Self:cajuri
Local oResponse  := JsonObject():New()
Local lDicDeepL  := .F.

	// Verifica se o campo de id da carteira Deep Legal existe no dicionário
	If Select("NUH") > 0
		lDicDeepL := (NUH->(FieldPos('NUH_IDEEPL')) > 0) .And. (NUQ->(FieldPos('NUQ_DEEPL')) > 0)
	Else
		DBSelectArea("NUH")
			lDicDeepL := (NUH->(FieldPos('NUH_IDEEPL')) > 0) .And. (NUQ->(FieldPos('NUQ_DEEPL')) > 0)
		NUH->( DBCloseArea() )
	EndIf

	If lDicDeepL
		dbSelectArea("NUQ")
		NUQ->( dbSetOrder( 2 ) ) // NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU

		If NUQ->(dbSeek(cFilCajuri + cCajuri + '1')) 
			If lRet := NUQ->(RecLock('NUQ',.F. ))
				NUQ->NUQ_DEEPL  := .T.
				NUQ->(MsUnlock())
			EndIf
		EndIf

		oResponse['sended'] := lRet

		Self:SetContentType("application/json")
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		lRet := .F.
		SetRestFault(404, STR0004) // "Atualização de dicionário de dados necessária."
	EndIf

	RestArea(aAreaNUQ)
	RestArea(aArea)

Return lRet
