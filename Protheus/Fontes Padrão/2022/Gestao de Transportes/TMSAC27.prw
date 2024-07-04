#include 'totvs.ch'
#include 'TMSAC26.CH'

#define DATA_STATUS		1
#define DATA_FILDOC		2
#define DATA_DOC		3
#define DATA_SERIE		4
#define DATA_CLIENTE	5
#define DATA_LOJACLI	6
#define DATA_NOMECLI	7
#define DATA_NOMEREDZ	8
#define DATA_ENDERECO	9
#define DATA_BAIRRO		10
#define DATA_CIDADE		11
#define DATA_ESTADO		12
#define DATA_CEP		13
#define DATA_RESPON		14
#define DATA_DOCRES		15
#define DATA_DATACHEG	16
#define DATA_HORACHEG	17
#define DATA_TIPODOC	18
#define DATA_IMAGEM		19
#define DATA_IDMPOS		20
#define DATA_VOLUME		21

Static cTFilOri		:= ""
Static cTotvsVia	:= ""
Static aTotvsDoc	:= {}

/*/{Protheus.doc} TMSAC27()
	Mapa OPENStreet
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
Function TMSAC27( oPanel, cFilOri, cViagem, aDocs )
	
	cTFilOri	:= cFilOri
	cTotvsVia	:= cViagem
	aTotvsDoc	:= aClone(aDocs)
	WebChannel( oPanel, cFilOri, cViagem )

Return

/*/-----------------------------------------------------------
{Protheus.doc} WebChannel()
Ativa engine de comunicação WEB

Uso: TMSAO51

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Static Function WebChannel( oPanel, cFilOri, cViagem )

	Local nWebPort		:= 0

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
	oWebChannel:bJsToAdvpl := { | self, codeType, codeContent | JsToAdvpl( self, codeType, codeContent ) }

	WebEngine( oPanel, nWebPort )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} WebEngine()
Montagem e visualização do mapa com integração OPENSTREET

Uso: TMSAC26

@sample
//ViewDef()

@author Rodrigo Pirolo 
@since 09/09/2021
@version 1.0
@type function
*/
//-------------------------------------------------------------------

Static Function WebEngine( oPanel, nWebPort )

	Local cLink		:= SuperGetMV("MV_CHKMAPA",, '' )//"http://localhost:8282/openstreet.html"

	oWebEngine 	:= TWebEngine():New( oPanel , 0, 0, 100, 100,,nWebPort)

	oWebEngine:Navigate( RTrim(cLink) + "?totvstec_websocket_port=" + cValToChar(nWebPort) )
	oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

Return 

//-------------------------------------------------------------------
/*{Protheus.doc} JsToAdvpl()
Esta função recebera todas as chamadas vindas do Javascript através 
do método dialog.jsToAdvpl(), 
exemplo: dialog.jsToAdvpl("page_started", "Pagina inicializada")

Uso: TMSAC26

@sample
//ViewDef()

@author Rodrigo Pirolo 
@since 09/09/2021
@version 1.0
@type function
*/
//-------------------------------------------------------------------

Static Function JsToAdvpl( self, codeType, codeContent )
 
	If valType(codeType) == "C"
		If codeType == "pageStarted"

			OpenInit()

		ElseIf codeType == "markerClick"

		ElseIf codeType == "initMap"

		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} OpenInit()
Montagem e visualização do mapa com integração OPENSTREET

Uso: TMSAC26

@sample
//ViewDef()

@author Rodrigo Pirolo 
@since 09/09/2021
@version 1.0
@type function
*/
//-------------------------------------------------------------------

Static Function OpenInit()

	Local cJsonObj		:= ""
	Local aPosSRep		:= {}
	Local aJsPos		:= {}
	Local lFirst		:= .T.
	Local nX			:= 0
	Local nPosRep		:= 0
	Local nY			:= 0

	DAV->( DbSetOrder( 1 ) ) //DAV_FILIAL, DAV_IDMPOS
	For nX := 1 To Len(aTotvsDoc)

		If DAV->( MsSeek( xFilial("DAV") + aTotvsDoc[nX][DATA_IDMPOS] ) )
			
			nPosRep := AScan( aPosSRep, { | x | x[1] + x[2] == AllTrim( DAV->DAV_LATITU ) + AllTrim( DAV->DAV_LONGIT ) } ) //Ascan(aAutoCab,{ |e| e[1] $ "DUA_FILORI"})
			
			If nPosRep == 0
				AAdd( aPosSRep, { AllTrim( DAV->DAV_LATITU ), AllTrim( DAV->DAV_LONGIT ), { { aTotvsDoc[nX][DATA_STATUS], aTotvsDoc[nX][DATA_FILDOC], aTotvsDoc[nX][DATA_DOC], aTotvsDoc[nX][DATA_SERIE], cValToChar(aTotvsDoc[nX][DATA_VOLUME]) } } } )
			Else
				AAdd( aPosSRep[nPosRep][3], { aTotvsDoc[nX][DATA_STATUS], aTotvsDoc[nX][DATA_FILDOC], aTotvsDoc[nX][DATA_DOC], aTotvsDoc[nX][DATA_SERIE], cValToChar(aTotvsDoc[nX][DATA_VOLUME]) } )
			EndIf
		EndIf

	Next nX
	
	For nX := 1 To Len(aPosSRep)
		If lFirst
			AAdd( aJsPos, JsonObject():New() )
			nPos := Len(aJsPos)
			aJsPos[nPos]['latitude']	:= StrZero( Round( Val( AllTrim( aPosSRep[nX][1] )), 2 ), 8, 4 )
			aJsPos[nPos]['longitude']	:= StrZero( Round( Val( AllTrim( aPosSRep[nX][2] )), 2 ), 8, 4 )
			lFirst := .F.
		EndIf

		AAdd( aJsPos, JsonObject():New() )
		nPos := Len( aJsPos )

		aJsPos[nPos]['latitude']	:= AllTrim( aPosSRep[nX][1]	)
		aJsPos[nPos]['longitude']	:= AllTrim( aPosSRep[nX][2]	)
		aJsPos[nPos]['Document']	:= ""

		For nY := 1 To Len( aPosSRep[nX][3] )

			aJsPos[nPos]['Document']	+= '<b>Doc: </b>' + aPosSRep[nX][3][nY][2] + ' / ' + aPosSRep[nX][3][nY][3] + ' / ' + aPosSRep[nX][3][nY][4] + ' - Vol: ' + aPosSRep[nX][3][nY][5] + ' - ' + If( aPosSRep[nX][3][nY][1] == '2', STR0027 + '<br>', STR0028 + '<br>' )
			
		Next nY

	Next nX
	
	cJsonObj	:= fwJsonSerialize( aJsPos, .F. )
	oWebChannel:advplToJs("initMap" , cJsonObj )

Return
