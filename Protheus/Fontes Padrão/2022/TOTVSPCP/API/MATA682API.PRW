#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function MATA682API()
Return

/*/{Protheus.doc} Apontamentos de Parada

API de integração de Apontamentos de Parada

@author		Renan Roeder
@since		27/11/2018
/*/
WSRESTFUL MATA682API DESCRIPTION "Cadastro de Apontamentos de Parada"
	WSDATA Fields				AS STRING	OPTIONAL
	WSDATA Order				AS STRING	OPTIONAL
	WSDATA Page					AS INTEGER	OPTIONAL
	WSDATA PageSize				AS INTEGER	OPTIONAL
	WSDATA IntegrationReport	AS STRING	OPTIONAL
 
    WSMETHOD POST StopReport ;
    DESCRIPTION "Cadastra um novo Apontamento de Parada" ;
    PATH "/api/pcp/v1/stopReports"

    WSMETHOD GET StopReports ;
    DESCRIPTION "Carrega todos os Apontamentos de Parada" ;
    PATH "/api/pcp/v1/stopReports"

	WSMETHOD GET Id_StopReport ;
    DESCRIPTION "Carrega um Apontamento de Parada específico" ;
    PATH "/api/pcp/v1/stopReports/{IntegrationReport}"

	WSMETHOD DELETE StopReportRev ;
    DESCRIPTION "Estorna um Apontamento de Parada específico" ;
    PATH "/api/pcp/v1/stopReports/{IntegrationReport}/reversal"

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/pcp/v1/stopReports
Retorna todos os Apontamentos de Parada

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		27/11/2018
@version	12.1.23
/*/

WSMETHOD GET StopReports WSRECEIVE Order, Page, PageSize, Fields WSSERVICE MATA682API
	Local cError			:= ""
	Local aFatherAlias		:= {"SH6", "items", "items"}
	Local cIndexKey			:= "H6_FILIAL, H6_TIPO, H6_RECURSO, H6_DTAPONT, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN"
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	Local aFilter			:= {}
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("MATA682API","1.003")

	oApiManager:SetApiAdapter("MATA682API")
   	oApiManager:SetApiAlias(aFatherAlias)
	oApiManager:Activate()

	Aadd(aFilter, {"SH6", "items",{"H6_TIPO = 'I'"}})
	oApiManager:SetApiFilter(aFilter)

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} POST /api/pcp/v1/stopReports
Inclui um novo Apontamento de Parada

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		27/11/2018
@version	12.1.23
/*/
WSMETHOD POST StopReport WSRECEIVE Order, Page, PageSize, Fields WSSERVICE MATA682API
	Local aQueryString	:= Self:aQueryString
    Local cBody 		:= ""
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager 	:= FWAPIManager():New("MATA682API","1.003")

	Self:SetContentType("application/json")
    cBody 	   := Self:GetContent()

	oApiManager:SetApiMap(ApiMap())
	oApiManager:SetApiAlias({"SH6","items", "items"})

	lRet := ManutSR(@oApiManager, Self:aQueryString, 3,,, cBody)

	If lRet
		aAdd(aQueryString,{"IntegrationReport",SH6->H6_IDENT})
		lRet := GetMain(@oApiManager, aQueryString, .F.)
	EndIf

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )
	FreeObj( aQueryString )	

Return lRet

/*/{Protheus.doc} GET /api/pcp/v1/stopReports/{IntegrationReport}
Retorna um Apontamento de Parada específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/
WSMETHOD GET Id_StopReport PATHPARAM IntegrationReport WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE MATA682API
	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("MATA682API","1.003")
	
	Default Self:IntegrationReport := ""

    Self:SetContentType("application/json")

	Aadd(aFilter, {"SH6", "items",{"H6_TIPO = 'I' AND H6_IDENT  = '" + self:IntegrationReport + "'"}})
	oApiManager:SetApiFilter(aFilter)
	lRet := GetMain(@oApiManager, Self:aQueryString)

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} Delete /api/pcp/v1/stopReports/{IntegrationReport}/reversal
Estorna um apontamento de parada específico.

@param	IntegrationReport	, caracter, Id do Apontamento de Parada
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

WSMETHOD DELETE StopReportRev PATHPARAM IntegrationReport WSRECEIVE Order, Page, PageSize, Fields WSSERVICE MATA682API
	Local cResp			:= "Registro Estornado com Sucesso"
	Local cError		:= ""
    Local lRet			:= .T.
    Local oJsonPositions:= JsonObject():New()
	Local oApiManager	:= FWAPIManager():New("MATA682API","1.003")
	Local cBody			:= Self:GetContent()
	Local cAliasQry     := GetNextAlias()
	Local cQuery        := ""
	
	Self:SetContentType("application/json")

	oApiManager:Activate()

	cQuery := "SELECT "
	cQuery += "SH6.R_E_C_N_O_ H6RECNO"
	cQuery += "FROM "
	cQuery += RetSqlName("SH6")+ " SH6 "
	cQuery += "WHERE "
	cQuery += "SH6.H6_FILIAL = '" + xFilial("SH6") + "' AND "	
	cQuery += "SH6.H6_IDENT = '" + PADR(Self:IntegrationReport,TamSx3("H6_IDENT")[1]) + "' AND "
	cQuery += "SH6.H6_TIPO = 'I' AND "
	cQuery += "SH6.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If !(cAliasQry)->(Eof())
		SH6->(DbGoTo( (cAliasQry)->H6RECNO))
		lRet := ManutSR(@oApiManager, Self:aQueryString, 5,, (cAliasQry)->H6RECNO, cBody)
	Else
		lRet := .F.
		oApiManager:SetJsonError("404","Erro ao estornar o Apontamento de Parada!", "Apontamento de Parada não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

	If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
    FreeObj( oJsonPositions )

Return lRet

/*/{Protheus.doc} ManutSR
Realiza a manutenção (inclusão/estorno) de Apontamentos de Parada

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com o Id do Apontamento de Parada
@param cBody		, Caracter	, Mensagem Recebida

@return lRet	, Lógico	, Retorna se realizou ou não o processo

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/
Static Function ManutSR(oApiManager, aQueryString, nOpc, aJson, cChave, cBody)
	Local aCab		:= {}
	Local cResp		:= ""
    Local lRet		:= .T.
	Local nX		:= 0
	Local oModel	:= Nil
	Local nPosDtIni := 0
	Local nPosDtFin := 0
	Local nPosId    := 0
	Local nPosDtApo := 0
	Local cDataIni  := ""
	Local cDataFin  := ""
	Local cHoraIni  := ""
	Local cHoraFin  := ""
	Local aMsgErro  := {}


	Default aJson			:= {}
	Default cChave 			:= ""

	Private lAutoErrNoFile	:= .T.
	Private lMsErroAuto 	:= .F.

	If nOpc == 3
		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf

		nPosId := (aScan(aCab ,{|x| AllTrim(x[1]) == "H6_IDENT"}))
		If nPosId > 0
			aDel(aCab,nPosId)
			aSize(aCab,Len(aCab)-1)		
		EndIf

		nPosDtApo := (aScan(aCab ,{|x| AllTrim(x[1]) == "H6_DTAPONT"}))
		If nPosDtApo > 0
			If aCab[nPosDtApo][2] < dDatabase
				lRet := .F.
				oApiManager:SetJsonError("400","Erro durante Inclusão do Apontamento de Parada!.", "Data do reporte menor que a database do sistema.",/*cHelpUrl*/,/*aDetails*/)
			EndIf
		EndIf


		If lRet
			If SetDates(cBody,@aCab)
				//AAAA-MM-DDTHH:MM:SS
				nPosDtIni := (aScan(aCab ,{|x| AllTrim(x[1]) == "H6_DATAINI"}))
				If nPosDtIni > 0
					cDataIni := GetDate(aCab[nPosDtIni][2])
					If Empty(cDataIni)
						lRet := .F.
						oApiManager:SetJsonError("400","Erro durante Inclusão do Apontamento de Parada!.", "Data/Hora inicial com formato incorreto.",/*cHelpUrl*/,/*aDetails*/)
					Else
						cHoraIni := GetTime(aCab[nPosDtIni][2])
						aAdd(aCab,{'H6_HORAINI', cHoraIni, Nil})
						aCab[nPosDtIni][2] := SToD(cDataIni)					
					EndIf
				EndIf
				If lRet
					nPosDtFin := (aScan(aCab ,{|x| AllTrim(x[1]) == "H6_DATAFIN"}))
					If nPosDtFin > 0
						cDataFin := GetDate(aCab[nPosDtFin][2])
						If Empty(cDataFin)
							lRet := .F.
							oApiManager:SetJsonError("400","Erro durante Inclusão do Apontamento de Parada!.", "Data/Hora final com formato incorreto.",/*cHelpUrl*/,/*aDetails*/)
						Else
							cHoraFin := GetTime(aCab[nPosDtFin][2])
							aAdd(aCab,{'H6_HORAFIN', cHoraFin, Nil})
							aCab[nPosDtFin][2] := SToD(cDataFin)						
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If nOpc == 5
		aAdd(aCab,{'AUTRECNO', cChave, Nil})
	EndIf

	If lRet
		MSExecAuto({|x,y| mata682(x,y)},aCab,nOpc)

		If lMsErroAuto
			aMsgErro := GetAutoGRLog()
			cResp	 := ""
			For nX := 1 To Len(aMsgErro)
				cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
			Next nX	
			lRet := .F.
			oApiManager:SetJsonError("400","Erro durante Inclusão/Estorno do Apontamento de Parada!.", cResp,/*cHelpUrl*/,/*aDetails*/)
		Else
			//RECUPERAR H6_IDENT E POSICIONAR NO REGISTRO CRIADO.
		EndIf
	EndIf		

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get dos Apontamentos de Parada

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)
	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default oApiManager		:= Nil	
	Default aQueryString	:={,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Renan Roeder
@since		12/11/2018
@version	12.1.23
/*/

Static Function ApiMap()
	Local aApiMap		:= {}
	Local aStrSH6		:= {}

	//Exp:getDtTime(SH6->H6_DATAINI,SH6->H6_HORAINI)
	aStrSH6			:=	{"SH6","Fields","items","items",;
							{;
								{"MachineCode"			, "H6_RECURSO"						},;
								{"StopReasonCode"		, "H6_MOTIVO"						},;
								{"StopReasonDescription", "Exp:GETSRDESC(SH6->H6_MOTIVO)"	},;
								{"StartDateTime"		, "Exp:getDtTime(1)"				},;
								{"EndDateTime"			, "Exp:getDtTime(2)"				},;
								{"ToolCode"				, "H6_FERRAM"						},;
								{"OperatorCode"			, "H6_OPERADO"						},;
								{"ReportDateTime"		, "H6_DTAPONT"						},;
								{"IntegrationReport"	, "H6_IDENT"						},;
								{"Observation"			, "H6_OBSERVA"						};
							},;
						}
	aStructAlias  := {aStrSH6}

	aApiMap := {"MATA682API","items","1.003","MATA682",aStructAlias, "items"}

Return aApiMap

/*/{Protheus.doc} getDtTime
Monta o datetime para retorno

@return cRet	, caracter	, date/hora formatados.

@author		Renan Roeder
@since		28/11/2018
@version	12.1.23
/*/
Function getDtTime(nData)
	Local cDtTime := ""
	Local cData := ""
	Local cHora := ""

	If nData == 1
		cData := DToS(SH6->H6_DATAINI)
		cHora := SH6->H6_HORAINI
	Else
		cData := DToS(SH6->H6_DATAFIN)
		cHora := SH6->H6_HORAFIN	
	EndIf

	cDtTime := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2) + "T" + cHora + ":00"

Return cDtTime

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDate

Retorna somente a data de uma variável datetime

@param dDateTime - Variável DateTime
 
@return dDate - Retorna a data.

@author  Renan Roeder
@version P12
@since   27/11/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetDate(dDateTime)
	Local dDate := Nil
	If AT("T",dDateTime) > 0
		dDate := StrTokArr(StrTran(dDateTime,"-",""),"T")[1]
	EndIf
Return dDate
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTime

Retorna somente a hora de uma variável datetime

@param dDateTime - Variável DateTime
 
@return cTime - Retorna a hora

@author  Renan Roeder
@version P12
@since   28/11/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function GetTime(dDateTime)
	Local cHora := Nil

	If AT("T",dDateTime) > 0
		cHora := SubStr(StrTokArr(dDateTime,"T")[2],1,5)
	EndIf
Return cHora

/*/{Protheus.doc} GETSRDESC
Busca a descrição do motivo de parada

@return cRet	, caracter	, Descrição do motivo de parada.

@author		Renan Roeder
@since		29/11/2018
@version	12.1.23
/*/
Function GETSRDESC(cSRCod)
	Local cSRDesc := ""

	//TROCAR PELA CONSULTA NA TABELA CYN.
	//cSRDesc := Posicione("SX5", 1, xFilial("SX5") + "44" + cSRCod, "X5DESCRI()")
	cSRDesc := Posicione("CYN", 1, xFilial("CYN") + cSRCod, "CYN_DSSP")

Return cSRDesc

/*/{Protheus.doc} setDates
Adiciona as datas de inicio e fim do reporte no array aCab.

@return cRet	, caracter	, Descrição do motivo de parada.

@author		Renan Roeder
@since		29/11/2018
@version	12.1.23
/*/
Function SetDates(cBody,aCab)
	Local lRet := .T.
	Local oJStReport  := Nil

	If FWJsonDeserialize(Upper(cBody),@oJStReport)
		If AttIsMemberOf(oJStReport,"StartDateTime") 
			aAdd(aCab,{'H6_DATAINI',oJStReport:StartDateTime,Nil})
		EndIf
		If AttIsMemberOf(oJStReport,"EndDateTime") 
			aAdd(aCab,{'H6_DATAFIN',oJStReport:EndDateTime,Nil})
		EndIf		
	EndIf
Return lRet
