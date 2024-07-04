#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "SFCA311API.CH"

//dummy function
Function SFCA311API()
Return

/*/{Protheus.doc} Apontamentos de Parada SFC

API de integração de Apontamentos de Parada com o SFC - ChÃo de Fábrica

@author		Michele Lais Girardi
@since		09/06/2020
/*/

WSRESTFUL SFCA311API DESCRIPTION "Cadastro de Apontamentos de Parada SFC"
	WSDATA MachineCode            AS String 	
	WSDATA Count                  AS INTEGER Optional	
 
    WSMETHOD POST StopReportSFC ;
    DESCRIPTION "Cadastra um novo Apontamento de Parada SFC" ;
    PATH "/api/pcp/v1/StopReportSFC"

    WSMETHOD GET StopReportReasonSFC ;
    DESCRIPTION "Retorna os motivos de parada utilizados nos Apontamentos de Parada SFC." ;
    PATH "/api/pcp/v1/StopReportReasonSFC"


ENDWSRESTFUL

/*/
{Protheus.doc} POST /api/pcp/v1/StopReportSFC
Realiza o Apontamentos de Parada SFC

@return lRet	, lógico, Informa se o processo foi executado com sucesso.

@author		Michele Lais Girardi
@since		09/06/2020
/*/

WSMETHOD POST StopReportSFC WSSERVICE SFCA311API
Local lPost := .T.
Local cBody := " "
Local oJson
Local oModel
Local aError := {}

Private lMSErroAuto := .F.
Private lAutoErrNoFile := .T.	

oJson := JsonObject():New()

cBody := ::GetContent()
conout(cBody)

If oJson:fromJson( cBody ) <> nil
	SetRestFault(400, EncodeUTF8(STR0001)) //"Parâmetros do apontamento não enviados ou inválidos."                                                                                                                                                                                                                                                                                                                                                                                                                                                              
	lPost := .F.
EndIf

If lPost
	If Empty(oJson['MachineCode']) 
		SetRestFault(400, EncodeUTF8(STR0002)) //"Não foi informada a máquina."
		lPost := .F.
	ElseIf Empty(oJson['StartReportDateTime']) 
		SetRestFault(400, EncodeUTF8(STR0003)) //"Não foi informada a data de início da parada."
		lPost := .F.
	ElseIf Empty(oJson['StartReportTime']) 
		SetRestFault(400, EncodeUTF8(STR0004)) //"Não foi informada a hora de início da parada."
		lPost := .F.
	ElseIf Empty(oJson['EndReportDateTime']) 
		SetRestFault(400, EncodeUTF8(STR0005)) //"Não foi informada a data fim da parada."
		lPost := .F.
	ElseIf Empty(oJson['EndReportTime']) 
		SetRestFault(400, EncodeUTF8(STR0006)) //"Não foi informada a hora fim da parada."
		lPost := .F.
	ElseIf Empty(oJson['StopReasonCode']) 
		SetRestFault(400, EncodeUTF8(STR0007)) //"Não foi informado o motivo da parada."
		lPost := .F.
	EndIf
EndIf

If lPost
	cMaq := PadR(oJson['MachineCode'],TamSX3("CYX_CDMQ")[1])
	cMot := PadR(oJson['StopReasonCode'],TamSX3("CYX_CDSP")[1])

	If !Empty(oJson['StartReportDateTime'])
		cDateIni := CTOD(oJson['StartReportDateTime'])
	EndIf
	If !Empty(oJson['EndReportDateTime'])
		cDateFim := CTOD(oJson['EndReportDateTime'])
	EndIf
	cTimeIni := oJson['StartReportTime']
	cTimeFim := oJson['EndReportTime']

	If Empty(cMaq) 
		SetRestFault(400, EncodeUTF8(STR0002)) //"Não foi informada a máquina."
		lPost := .F.
	ElseIf Empty(cDateIni) 
		SetRestFault(400, EncodeUTF8(STR0003)) //"Não foi informada a data de início da parada."
		lPost := .F.
	ElseIf Empty(cTimeIni) 
		SetRestFault(400, EncodeUTF8(STR0004)) //"Não foi informada a hora de início da parada."
		lPost := .F.
	ElseIf Empty(cDateFim) 
		SetRestFault(400, EncodeUTF8(STR0005)) //"Não foi informada a data fim da parada."
		lPost := .F.
	ElseIf Empty(cTimeFim) 
		SetRestFault(400, EncodeUTF8(STR0006)) //"Não foi informada a hora fim da parada."
		lPost := .F.
	ElseIf Empty(cMot) 
		SetRestFault(400, EncodeUTF8(STR0007)) //"Não foi informado o motivo da parada."
		lPost := .F.
	EndIf
EndIf

If lPost
	// Instancia o modelo
	oModel := FWLoadModel( "SFCA311" )
	oModel:SetOperation( 3 ) //incluir apontamento
	If !oModel:Activate()   				
   		lPost := .F.
		aErro := oModel:GetErrorMessage()
    	If !Empty(aErro[6])
    		cMsgErro := oModel:GetErrorMessage()[6]
    	Else
			cMsgErro := (STR0008) //"Ocorreram erros ao realizar o apontamento."
    	EndIf     								
		SetRestFault(400, EncodeUTF8(cMsgErro))   
	EndIf
EndIf

If lPost
	oModel:SetValue("CYXMASTER","CYX_CDMQ"    ,cMaq)            //MAQUINA	
	oModel:SetValue("CYXMASTER","CYX_CDSP"    ,cMot)            //MOTIVO PARADA	
	oModel:SetValue("CYXMASTER","CYX_DTBGSP"  ,cDateIni)        //DATA INICIO PARADA	
	oModel:SetValue("CYXMASTER","CYX_HRBGSP"  ,cTimeIni)        //HORA INICIO PARADA	
	oModel:SetValue("CYXMASTER","CYX_DTEDSP"  ,cDateFim)        //DATA FIM PARADA	
	oModel:SetValue("CYXMASTER","CYX_HREDSP"  ,cTimeFim)        //HORA FIM PARADA	

	// Valida o modelo
	If oModel:VldData()   				
   		If !oModel:CommitData()
     		lPost := .F.					
			aErro := oModel:GetErrorMessage()
     		If !Empty(aErro[6])
        		cMsgErro := oModel:GetErrorMessage()[6]
     		Else
				cMsgErro := (STR0008) //"Ocorreram erros ao realizar o apontamento."
     		EndIf     								
			SetRestFault(400, EncodeUTF8(cMsgErro))
   		EndIf
	Else
   		lPost := .F.					
		aErro := oModel:GetErrorMessage()
    	If !Empty(aErro[6])
    		cMsgErro := oModel:GetErrorMessage()[6]
    	Else
			cMsgErro := (STR0008) //"Ocorreram erros ao realizar o apontamento."
    	EndIf     								
		SetRestFault(400, EncodeUTF8(cMsgErro))
	EndIf
	oModel:DeActivate()
EndIf

If lPost
	oJson['Status'] = 'Apontamento efetuado com sucesso'
	::SetResponse(oJson:toJson())	
EndIf

FreeObj(oJson)

Return lPost

/*/
{Protheus.doc} GET /api/pcp/v1/StopReportReasonSFC
Retorna os motivos de parada utilizados nos Apontamentos de Parada SFC

@param	MachineCode    , caracter, Máquina ( obrigatório)
@param	Count          , numérico, Número de registros que serão retornados (não obrigatório)

@return lRet	, lógico, Informa se o processo foi executado com sucesso.

@author		Michele Lais Girardi
@since		09/06/2020
/*/

WSMETHOD GET StopReportReasonSFC WSRECEIVE MachineCode, Count WSSERVICE SFCA311API
Local aCYX := {}
Local lGet  := .T.
Local nI := 0
Local oJson

::SetContentType("application/json")
oJson := JsonObject():New()

If Empty(::MachineCode)
	SetRestFault(400, EncodeUTF8(STR0002)) //"NÃo foi informada a máquina."
	lGet := .F.
EndIf

If lGet
	aCYX := a311ConPa(::MachineCode, ::Count)

	If Len(aCYX) < 1 
		lGet := .F.
		SetRestFault(400, EncodeUTF8(STR0009)) //"Apontamentos de Parada não cadastrados."    
	EndIf
EndIf

If lGet
	::SetResponse('[')
	For nI := 1 To len(aCYX)
		If nI > 1
			::SetResponse(',')
		EndIf
	
		oJson['MachineCode']             := aCYX[nI,1]
		oJson['StopReasonCode']          := aCYX[nI,2]
		oJson['StopReasonDescription']   := aCYX[nI,3]
		oJson['StartReportDateTime']     := STOD(aCYX[nI,4])
		oJson['StartReportTime']         := aCYX[nI,5]
		oJson['EndReportDateTime']       := STOD(aCYX[nI,6])
		oJson['EndReportTime']           := aCYX[nI,7]

		::SetResponse(oJson:toJson())
	Next nI
	::SetResponse(']') 
EndIf

Return lGet

/*/
{Protheus.doc} a311ConPa
Retorna um array motivos de parada utilizados nos Apontamentos de Parada SFC

@param	cMaq    , caracter, Máquina ( obrigatório)
@param	nCount  , numérico, Número de registros que serão retornados (não obrigatório)

@return aCYX	, array

@author		Michele Lais Girardi
@since		09/06/2020
/*/

Static Function a311ConPa(cMaq, nCount)

Local nX          := 0
Local cQuery      := ""
Local cAliasTemp  := ""
Local aCYX        := {}

Default nCount := 20

If Empty(nCount) .Or. nCount == 0
	nCount := 20
EndIf

cAliasTemp := GetNextAlias()
cQuery     := "  SELECT CYX_CDMQ MAQUINA, "
cQuery     += "         CYX_CDSP MOTIVO_PARADA, "
cQuery     += "         CYN_DSSP DESC_PARADA, "
cQuery     += "         CYX_DTBGSP DATA_INICIO, "
cQuery     += "         CYX_HRBGSP HORA_INICIO, "
cQuery     += "         CYX_DTEDSP DATA_FIM, "
cQuery     += "         CYX_HREDSP HORA_FIM "
cQuery     += "   FROM " + RetSqlName('CYX') + " CYX " + "," + RetSqlName("CYN") + " CYN "
cQuery     += "   WHERE CYX.CYX_FILIAL  = '" + xFilial("CYX") + "'"
cQuery     += "     AND CYX.CYX_CDMQ    = '" +cMaq+ "'"	
cQuery     += "     AND CYN.CYN_FILIAL  = '" + xFilial("CYX") + "'"	
cQuery     += "     AND CYN.CYN_CDSP  = CYX_CDSP "
cQuery     += "     AND CYX.D_E_L_E_T_  = ' '"
cQuery     += "     AND CYN.D_E_L_E_T_  = ' '"
cQuery     += "   ORDER BY CYX_DTBGSP DESC "
cQuery     := ChangeQuery(cQuery)

dbUseArea ( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTemp, .T., .T.)
While (cAliasTemp)->(!Eof())
	If nX == nCount
		Exit
	EndIf
	aAdd(aCYX,{(cAliasTemp)->MAQUINA, (cAliasTemp)->MOTIVO_PARADA,;
	           (cAliasTemp)->DESC_PARADA, (cAliasTemp)->DATA_INICIO, (cAliasTemp)->HORA_INICIO,;
			   (cAliasTemp)->DATA_FIM, (cAliasTemp)->HORA_FIM})
	(cAliasTemp)->(dbSkip()) 
	nX += 1
End
(cAliasTemp)->(DBCloseArea())

Return aCYX

