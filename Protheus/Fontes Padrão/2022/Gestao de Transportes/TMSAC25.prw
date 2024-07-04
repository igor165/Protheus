#include 'totvs.ch'
#include 'TMSAC25.CH'

Static cTotvsDMR	:= "" 
Static nSeqRotDMS	:= Nil
Static oWebChannel 	:= Nil
Static oWebEngine  	:= Nil
Static lAllSeqRot   := .F.   //Todas as sequencias de roteirização
Static _cURLNRout   := SuperGetMv("MV_OMSUROT",.F.,"") //URL de callback da atualizacao da rota
Static _lNovaRout   := SuperGetMv("MV_OMSLROT",.F.,.F.) //Ativa botao de novo ponto no mapa

/*/{Protheus.doc} TMSAC25()
   Mapa TPR Neologss
    @type  Function
    @author Caio Murakami
    @since 21/09/2021
    @version 1
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSAC25( oPanel , cFilRot, cIdRot, nSeqRot )

cTotvsDMR	:= cFilRot +  cIdRot
nSeqRotDMS  := nSeqRot

lAllSeqRot:= nSeqRotDMS == Nil

If lAllSeqRot //Nao permite alterar rotas com varias viagens ao mesmo tempo
	_lNovaRout := .F.
EndIf

WebChannel( oPanel , cTotvsDMR, nSeqRotDMS )

return

/*/-----------------------------------------------------------
{Protheus.doc} WebChannel()
Ativa engine de comunicação WEB
@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function WebChannel( oPanel , cId ,nSeqRotDMS )

Local nWebPort		:= 0 

oWebChannel	:= TWebChannel():New()

// ------------------------------------------
// Prepara o conector WebSocket
// ------------------------------------------
nWebPort    := oWebChannel:connect() // Efetua conexão e retorna a porta do WebSocket

// Verifica conexão
If !oWebChannel:lConnected
	MsgStop(STR0001) //-- MsgStop("Erro na conexão com o WebSocket")
	Return // Aborta aplicação
EndIf
// ------------------------------------------
// Define o CallBack JavaScript
// IMPORTANTE: Este é o canal de comunicação "vindo do Javascript para o ADVPL"
// ------------------------------------------
oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| JsToAdvpl(self,codeType,codeContent) }

WebEngine( oPanel , nWebPort )

Return


/*/{Protheus.doc} WebEngine
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function WebEngine( oPanel , nWebPort )
Local cLink		:= "" 

oWebEngine 	:= TWebEngine():New( oPanel , 0, 0, 100, 100,,nWebPort)
cLink		:= T25URLMap()
oWebEngine:navigate(RTrim(cLink) + "?totvstec_websocket_port="+cValToChar(nWebPort))
If nModulo = 39
	OMSTPRCLOG(Nil, "TMSAC25", AllTrim(cLink) + "?totvstec_websocket_port="+cValToChar(nWebPort))
EndIf
oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

Return 
/*/-----------------------------------------------------------
{Protheus.doc} JsToAdvpl()
@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
// ------------------------------------------
// Esta função recebera todas as chamadas vindas do Javascript
// através do método dialog.jsToAdvpl(), exemplo:
// dialog.jsToAdvpl("page_started", "Pagina inicializada");
// ------------------------------------------
//-----------------------------------------------------------------------------
Static Function JsToAdvpl(self,codeType,codeContent)

If valType(codeType) == "C"
	If codeType == "pageStarted"
		If SetTPRToken() 
			OnPageStarted( cTotvsDMR, nSeqRotDMS )
		EndIf 

	ElseIf codeType == "markerClick"
	ElseIf codeType == "initMap"
	EndIf
EndIf
 
Return

/*/-----------------------------------------------------------
{Protheus.doc} OnPageStarted()
@sample
//ViewDef()
@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function OnPageStarted( cChvEnt, nSeqRotDMS )
Local oJsonObj   	:= JsonObject():New()
Local cJson			:= "" 
Local oObj			:= JsonObject():New()
Local oObjRot		:= JsonObject():New()
Local cJsonObj		:= "" 
Local nCount		:= 1 
Local aAux          := {}
Local cIdentif      := " "

Default cChvEnt		:= "" 

cJson:= TMS21RetJs(cChvEnt)

If oObj:FromJson( cJson ) <> "C" .And. !Empty(cJson)
	For nCount := 1 To Len( oObj["tripsResults"] )
		oObjRot := oObj["tripsResults"][nCount]
		If !lAllSeqRot
			If oObjRot["sequential"] =  nSeqRotDMS
				Aadd( aAux , oObjRot )
			EndIf
		Else
			Aadd( aAux , oObjRot )
		EndIf
	Next nCount
	cIdentif := oObj["qualifiers"]
EndIf 


cJsonObj := fwJsonSerialize( aAux , .F. )
If _lNovaRout
	oWebChannel:advplToJs("newRouteURL" , _cURLNRout )
	oWebChannel:advplToJs("identifier" , cIdentif )
EndIf
oWebChannel:advplToJs("initMap" ,  cJsonObj )
FreeObj(oJsonObj)
	
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} T25URLMap()  //GetURLMap()
Captura URL
Uso: TMSAC25 e TMSAO15

@author Caio Murakami
@since 20/08/2019
@version 1.0
@type function
/*/
//--------------------------------------------------------------------
Function T25URLMap()
Local cURL		:= ""
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

cQuery  := " SELECT DLV_URLMAP,DLV_URLCAL "
cQuery  += " FROM " + RetSQLName("DLV") + " DLV "
cQuery  += " WHERE DLV_FILIAL  	= '" + xFilial("DLV") + "' "
cQuery  += " AND DLV_MSBLQL 	= '2' "
cQuery	+= " AND DLV_ROTERI		= '2' "
cQuery  += " AND DLV.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->( !Eof() )
	cURL		:= (cAliasQry)->DLV_URLMAP
	If _lNovaRout .And. Empty(_cURLNRout)
		_cURLNRout  := SubStr( (cAliasQry)->DLV_URLCAL, 1, AT( "/WSTPRNEOLOG", (cAliasQry)->DLV_URLCAL )  ) + "WSTPRNEOLOG/NEWROUTE"
	EndIf
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->( dbSkip() )

Return cURL

/*/-----------------------------------------------------------
{Protheus.doc} SetTPRToken()

Uso: TMSAC24

@sample
//ViewDef()

@author Caio Murakami   
@since 15/09/2021
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function SetTPRToken()
Local oTPRNeolog	:= NIl 
Local lRet			:= .F. 
Local cToken        := "" 

oTPRNeolog:= TMSBCATPRNeolog():New() 
If oTPRNeolog:Auth() 
    lRet	:= .T. 
    cToken  := oTPRNeolog:GetAcessToken()
    oWebChannel:advplToJs("TPRsetToken" , cToken )
EndIf 

Return lRet
